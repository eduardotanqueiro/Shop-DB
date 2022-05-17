from genericpath import exists
import flask
import logging
import psycopg2
import time

import jwt
import hashlib as hs
import json

app = flask.Flask(__name__)

StatusCodes = {
    'success': 200,
    'api_error': 400,
    'internal_error': 500
}

jwt_key = 'chave_jwt' #CHANGE TO RANDOM 

user_type_hashed = {'customer': hs.md5('customer'.encode('ascii')).hexdigest(), 'administrador': hs.md5('administrador'.encode('ascii')).hexdigest(), 'vendedor': hs.md5('vendedor'.encode('ascii')).hexdigest()}

##########################################################
## DATABASE ACCESS
##########################################################

def db_connection():
    db = psycopg2.connect(
        user='ProjetoBD',
        password='ProjetoBD',
        host='127.0.0.1',
        port='5432',
        database='ProjetoBD'
    )

    db.set_session(autocommit=False)

    return db


##########################################################
## ENDPOINTS
##########################################################


##
##  REGISTER USER
##

@app.route('/dbproj/user', methods=['POST'])
def add_user():
    logger.info('POST /customer')
    payload = flask.request.get_json()

    conn = db_connection()
    cur = conn.cursor()

    logger.debug(f'POST /customer - payload: {payload}')


    #ler token inserido em Header Postman (authorization->Bearer Token)
    global token
    header=flask.request.headers
    if 'Authorization' not in header:
        response = {'status': StatusCodes['api_error'], 'errors': 'Missing auth token'}
        return flask.jsonify(response)
    else:
        token=(header['Authorization'].split(" ")[1])

    decode_token = jwt.decode(token,jwt_key,'HS256')
    
    if 'type' in payload:
        #é para introduzir vendedor ou admin, e isto só os admins podem fazer

        #If user is not admin
        if decode_token['user_type'] == user_type_hashed['customer'] or decode_token['user_type'] == user_type_hashed['vendedor']:
            response = {'status': StatusCodes['api_error'], 'errors': 'You don\'t have permission to execute this task!'}
            return flask.jsonify(response)
        
        if payload[ 'type'] == 'vendedor':
                #verify arguments
                if 'username' not in payload or 'mail' not in payload or 'password' not in payload or 'pais' not in payload or 'cidade' not in payload or 'rua' not in payload:
                    response = {'status': StatusCodes['api_error'], 'results': 'Missing value(s) in the payload'}
                    return flask.jsonify(response)

    else:
        #verify arguments
        if 'username' not in payload or 'mail' not in payload or 'password' not in payload or 'pais' not in payload or 'cidade' not in payload or 'rua' not in payload:
            response = {'status': StatusCodes['api_error'], 'results': 'Missing value(s) in the payload'}
            return flask.jsonify(response)
    


    #hashing da password
    bin_pw = str(payload['password']).encode('ascii')
    hash_pw = hs.md5( bin_pw ).hexdigest()



    #TODO -> FAZER A VERIFICAÇÃO SE VIER COM NIF OU NÃO (TIRAR NIF??)

    try:

        if 'type' not in payload:
            values = (payload['username'], hash_pw , payload['mail'] , payload['nome'], payload['pais'], payload['cidade'], payload['rua'])

            cur.execute("select insert_customer(%s,%s,%s,%s,%s,%s,%s)",values)
        else:   
            
            if payload['type'] ==  'admin':
                values = (payload['username'], hash_pw , payload['mail'] , payload['nome'])
                cur.execute("select insert_admin(%s,%s,%s,%s)",values)


            elif payload['type'] == 'vendedor':
                values = (payload['username'], hash_pw , payload['mail'] , payload['nome'], payload['pais'], payload['cidade'], payload['rua'])
                cur.execute("select insert_vendedor(%s,%s,%s,%s,%s,%s,%s)",values)


        # commit the transaction
        id_result = cur.fetchone()
        conn.commit()

        response = {'status': StatusCodes['success'], 'results': id_result}
        logger.info(f'New user inserted')

    except (Exception, psycopg2.DatabaseError) as error:
        logger.error(f'POST /customer - error: {error}')
        response = {'status': StatusCodes['internal_error'], 'errors': str(error)}

        # an error occurred, rollback
        conn.rollback()

    finally:
        if conn is not None:
            conn.close()

    return flask.jsonify(response)


##
##  LOGIN ROUTINE
##

@app.route('/dbproj/user', methods=['PUT'])
def user_login():
    logger.info('User Login')
    payload = flask.request.get_json()

    conn = db_connection()
    cur = conn.cursor()

    logger.debug(f'User login attempt')

    #validate every argument
    if 'username' not in payload:
        response = {'status': StatusCodes['api_error'], 'errors': 'Missing username value'}
        return flask.jsonify(response)

    if 'password' not in payload:
        response = {'status': StatusCodes['api_error'], 'errors': 'Missing password value'}
        return flask.jsonify(response)


    #hashing da password
    bin_pw = str(payload['password']).encode('ascii')
    hash_pw = hs.md5( bin_pw ).hexdigest()

    #Query searching for matching username and password
    login_statement = 'SELECT id FROM utilizador WHERE username = %s AND password = %s'
    values = (payload['username'], hash_pw )

    

    try:
        cur.execute(login_statement, values)

        res = cur.fetchall()

        if res == []:
        #wrong user or password
            logger.error("Invalid user or password!")
            response = {'status': StatusCodes['internal_error'], 'errors': 'Invalid username or password!'}

        

        else:
        #user and password matched
            logger.info("User found, creating JWT")

            #check which user type it is
            id = str(res[0][0])
            user_type_check = check_user_type(id)

            #logger.debug("Já checkei tipo user")

            #create a JWT token
            token = jwt.encode( {'id': id,'username': payload['username'], 'user_type': user_type_hashed[ user_type_check ]} , jwt_key , 'HS256')
            

            #insert token into token's table
            cur.execute('INSERT INTO login_token (token, utilizador_id) VALUES (%s,%s)',(token,res[0][0]))

            response = {'status': StatusCodes['success'], 'token': token}

        # commit the transaction
        conn.commit()

    except (Exception, psycopg2.DatabaseError) as error:
        logger.error(error)
        response = {'status': StatusCodes['internal_error'], 'errors': str(error)}

        # an error occurred, rollback
        conn.rollback()

    finally:
        if conn is not None:
            conn.close()

    return flask.jsonify(response)


##
## ADD PRODUCT
##

@app.route('/dbproj/product',methods = ['POST'])
def add_product():

    logger.info('User Login Product Insertion')
    payload = flask.request.get_json()

    conn = db_connection()
    cur = conn.cursor()
    
    #ler token inserido em Header Postman (authorization->Bearer Token)
    global token
    header=flask.request.headers
    if 'Authorization' not in header:
        response = {'status': StatusCodes['api_error'], 'errors': 'Missing auth token'}
        return flask.jsonify(response)
    else:
        token=(header['Authorization'].split(" ")[1])

    #1st check if user is customer,seller or admin
    decode_token = jwt.decode(token,jwt_key,'HS256')
    
    
    #If user is not seller
    if decode_token['user_type'] == user_type_hashed['customer'] or decode_token['user_type'] == user_type_hashed['administrador']:
        response = {'status': StatusCodes['api_error'], 'errors': 'You don\'t have permission to execute this task!'}
        return flask.jsonify(response)


    #---------------------------------------
    #2nd CHECK PAYLOAD ARGUMENTS
    if 'descricao' not in payload or 'preco' not in payload or 'stock' not in payload or 'tipo' not in payload:
        response = {'status': StatusCodes['api_error'], 'errors': 'Missing values for product in the payload'}
        return flask.jsonify(response)


    if payload['tipo'] == 'smartphone':
        if 'tamanho' not in payload or 'marca' not in payload or 'ram' not in payload or 'rom' not in payload:
            response = {'status': StatusCodes['api_error'], 'errors': 'Missing values for product type \'smartphone\' in the payload'}
            return flask.jsonify(response)

    elif payload['tipo'] == 'tv':
        if 'tamanho' not in payload or 'marca' not in payload:
            response = {'status': StatusCodes['api_error'], 'errors': 'Missing values for product type \'tv\' in the payload'}
            return flask.jsonify(response)

    elif payload['tipo'] == 'pc':
        if 'cpu' not in payload or 'ram' not in payload or 'rom' not in payload or 'marca' not in payload:
            response = {'status': StatusCodes['api_error'], 'errors': 'Missing values for product type \'pc\' in the payload'}
            return flask.jsonify(response)
    else:
        response = {'status': StatusCodes['api_error'], 'errors': 'Invalid product type'}
        return flask.jsonify(response)

    #--------------------------------------

    #4th Insert product into the correct tables
    decode_token[ 'id'] = int(decode_token['id'])

    try:

        
        if payload['tipo'] == 'smartphone':

            values = (payload['descricao'],payload['preco'],payload['stock'], decode_token['id'] ,payload['tamanho'],payload['marca'],payload['ram'],payload['rom'])

            cur.execute("select insert_smartphone(%s::VARCHAR,%s::FLOAT(8),%s::INTEGER,%s::INTEGER,%s::SMALLINT,%s::VARCHAR,%s::SMALLINT,%s::SMALLINT)", values)

        elif payload['tipo'] == 'tv':

            values = ((payload['descricao']),(payload['preco']),(payload['stock']), (decode_token['id']) ,(payload['tamanho']),(payload['marca']))
            print(values)

            cur.execute("select insert_tv(%s::VARCHAR(512),%s::FLOAT(8),%s::INTEGER,%s::INTEGER,%s::SMALLINT,%s::VARCHAR(50))", values)

        elif payload['tipo'] == 'pc':

            values = (payload['descricao'],payload['preco'],payload['stock'], decode_token['id'],payload['cpu'],payload['ram'],payload['rom'],payload['marca'])

            cur.execute("select insert_pc(%s::VARCHAR,%s::FLOAT(8),%s::INTEGER,%s::INTEGER,%s::VARCHAR,%s::SMALLINT,%s::SMALLINT,%s::VARCHAR)", values)


        id_prod = cur.fetchone()
        conn.commit()

        response = {'status': StatusCodes['success'], 'results': id_prod[0]}
        logger.debug('New product added')

    except (Exception, psycopg2.DatabaseError) as error:
        logger.error(error)
        response = {'status': StatusCodes['internal_error'], 'errors': str(error)}

        # an error occurred, rollback
        conn.rollback()

    finally:
        if conn is not None:
            conn.close()


    return flask.jsonify(response)


##
## PURCHASE PRODUCTS
##

@app.route('/dbproj/order',methods = ['POST'])
def make_order():


    payload = flask.request.get_json()

    conn = db_connection()
    cur = conn.cursor()

    #ler token inserido em Header Postman (authorization->Bearer Token)
    global token
    header=flask.request.headers
    if 'Authorization' not in header:
        response = {'status': StatusCodes['api_error'], 'errors': 'Missing auth token'}
        return flask.jsonify(response)
    else:
        token=(header['Authorization'].split(" ")[1])

    #Decode Toke
    decode_token = jwt.decode(token,jwt_key,'HS256')

    #Check payload arguments
    if 'cart' not in payload or payload['cart'] == '':
        response = {'status': StatusCodes['api_error'], 'errors': 'No cart given or empty'}
        return flask.jsonify(response)


    #TODO ATENÇÃO: PROBLEMAS DE LOCKS E SINCRONIZAÇÃO DE DADOS NAS TABELAS

    #converter carrinho para dicionario json
    cart_dict = {}
    for i in payload['cart']:
        cart_dict[i[0]] = i[1]

    cart_json = json.dumps(cart_dict)


    try:
        #compra
        if 'coupon' not in payload:
            values = (decode_token['id'], cart_json ,'-1')
            cur.execute("select make_order(%s::INTEGER,%s::json,%s::INTEGER);",values)

        else:
            logger.debug("Buying with coupon")
            values = (decode_token['id'], cart_json ,payload['coupon'])
            cur.execute("select make_order(%s::INTEGER,%s::json,%s::INTEGER);",values)

        compra_id = cur.fetchone()
        conn.commit()
        response = {'status': StatusCodes['success'], 'results': compra_id}


    except (Exception, psycopg2.DatabaseError) as error:
        logger.error(error)
        response = {'status': StatusCodes['internal_error'], 'errors': str(error)}

        # an error occurred, rollback
        conn.rollback()

    finally:
        if conn is not None:
            conn.close()


    return flask.jsonify(response)







##
## GET ALL PRODUCTS 
##

@app.route('/dbproj/products', methods=['GET'])
def get_all_products():
    logger.info('GET /products')

    conn = db_connection()
    cur = conn.cursor()

    try:
        cur.execute('SELECT id,descricao,preco,vendedor_utilizador_id FROM produto')
        rows = cur.fetchall()

        logger.debug('GET /products - parse')
        Results = []

        if rows == []:
            raise Exception("There are no products to sell")
        else:
            for row in rows:
                logger.debug(row)
                content = {'id': int(row[0]), 'descricao': row[1], 'preco': row[2], 'id vendedor': int(row[3])}
                Results.append(content)  # appending to the payload to be returned

        response = {'status': StatusCodes['success'], 'results': Results}

    except (Exception, psycopg2.DatabaseError) as error:
        logger.error(f'GET /products - error: {error}')
        response = {'status': StatusCodes['internal_error'], 'errors': str(error)}

    finally:
        if conn is not None:
            conn.close()

    return flask.jsonify(response)

##
## GET PRODUCT
##
@app.route('/dbproj/product/<product_id>', methods=['GET'])
def get_product(product_id):
    logger.info('GET /product/<product_id>')

    logger.debug(f'product_id: {product_id}')
    
    conn = db_connection()
    cur = conn.cursor()
    try:
        cur.execute('select get_product_id(%s::INTEGER)', (product_id,))
        rows = cur.fetchone()

        json_result=rows[0]

        if 'error' in json_result:
                logger.error(f'GET /product/<product_id> - error: {json_result["error"]}')
                response = {'status': StatusCodes['internal_error'], 'errors': str(json_result["error"])}
        else:
                logger.debug('GET /product/<product_id> - parse')

                response = {'status': StatusCodes['success'], 'results': json_result}

    except (Exception, psycopg2.DatabaseError) as error:
            logger.error(f'GET /product/<product_id> - error: {error}')
            response = {'status': StatusCodes['internal_error'], 'errors': str(error)}

    finally:
            if conn is not None:
                conn.close()

    return flask.jsonify(response)

##
## UPDATE PRODUCT
##
@app.route('/dbproj/product/<product_id>', methods=['PUT'])
def update_product(product_id):
    payload = flask.request.get_json()
    conn = db_connection()
    cur = conn.cursor()
    try:

        #TODO só pode dar update o vendedor que está a vender o produto, e mais ninguém

        cur.execute('select update_product_id(%s::INTEGER,%s::json)', (product_id,str(str(json.dumps(payload)))))
        rows = cur.fetchone()

        json_result=rows[0]

        if 'error' in json_result:
            logger.error(f'GET /product/<product_id> - error: {json_result["error"]}')
            response = {'status': StatusCodes['internal_error'], 'errors': str(json_result["error"])}
        else:
            logger.debug('GET /product/<product_id> - parse')

            response = {'status': StatusCodes['success'], 'results': json_result}

    except (Exception, psycopg2.DatabaseError) as error:
        logger.error(f'GET /product/<product_id> - error: {error}')
        response = {'status': StatusCodes['internal_error'], 'errors': str(error)}

    finally:
        if conn is not None:
            conn.commit()
            conn.close()
    
    return flask.jsonify(response)

##
## ADD CAMPAIGN
##
@app.route('/dbproj/campaign', methods=['POST'])
def add_campaign():
    logger.info('User Login Campaign Insertion')
    payload=flask.request.get_json()

    conn=db_connection()
    cur=conn.cursor()

    #ler token inserido em Header Postman (authorization->Bearer Token)
    global token
    header=flask.request.headers
    if 'Authorization' not in header:
        response = {'status': StatusCodes['api_error'], 'errors': 'Missing auth token'}
        return flask.jsonify(response)
    else:
        token=(header['Authorization'].split(" ")[1])

    #Decode Token
    decode_token = jwt.decode(token,jwt_key,'HS256')

    #If user is not admin
    if decode_token['user_type'] == user_type_hashed['customer'] or decode_token['user_type'] == user_type_hashed['vendedor']:
        response = {'status': StatusCodes['api_error'], 'errors': 'You don\'t have permission to execute this task!'}
        return flask.jsonify(response)
    
    #Ckeck is payload parameters are correct
    if 'desconto' not in payload or 'numero_cupoes' not in payload or 'data_inicio' not in payload or 'data_fim' not in payload or 'validade_cupao' not in payload:
         response = {'status': StatusCodes['api_error'], 'errors': 'Missing values for product in the payload'}
         return flask.jsonify(response) 

    #Insert campaign

    decode_token['id']=int(decode_token['id'])

    try:
        values=(payload['desconto'],payload['numero_cupoes'],payload['data_inicio'],payload['data_fim'],payload['validade_cupao'],decode_token['id'])

        cur.execute("select insert_campaign(%s::INTEGER,%s::INTEGER,%s::DATE,%s::DATE,%s::SMALLINT,%s::INTEGER)",values)

        id_campanha = cur.fetchone();
        conn.commit()

        response = {'status': StatusCodes['success'], 'results': id_campanha}
        logger.debug('New campaign added')

    except (Exception, psycopg2.DatabaseError) as error:
        logger.error(error)
        response = {'status': StatusCodes['internal_error'], 'errors': str(error)}

        # an error occurred, rollback
        conn.rollback()
    finally:
        if conn is not None:
            conn.close()
    
    return flask.jsonify(response)


##
## SUBSCRIBE CAMPAIGN
##
@app.route('/dbproj/subscribe/<campaign_id>', methods=['PUT'])
def subscribe_campaign(campaign_id):

    if int(campaign_id) < 0:
        response = {'status': StatusCodes['api_error'], 'errors': 'Missing values for product in the payload'}
        return flask.jsonify(response)
    
    
    logger.info('User Login Campaign Subscribe')
    payload=flask.request.get_json()


    conn=db_connection()
    cur=conn.cursor()

    #ler token inserido em Header Postman (authorization->Bearer Token)
    global token
    header=flask.request.headers
    if 'Authorization' not in header:
        response = {'status': StatusCodes['api_error'], 'errors': 'Missing auth token'}
        return flask.jsonify(response)
    else:
        token=(header['Authorization'].split(" ")[1])

    #Decode Token
    decode_token = jwt.decode(token,jwt_key,'HS256')

    #If user is not customer
    if decode_token['user_type'] == user_type_hashed['administrador'] or decode_token['user_type'] == user_type_hashed['vendedor']:
        response = {'status': StatusCodes['api_error'], 'errors': 'You don\'t have permission to execute this task!'}
        return flask.jsonify(response)
    
    #Ckeck is payload parameters are correct
    #if 'id_campanha' not in payload:
    #     response = {'status': StatusCodes['api_error'], 'errors': 'Missing values for product in the payload'}
    #     return flask.jsonify(response)
    
    #Insert campaign

    decode_token['id']=int(decode_token['id'])

    try:
        values=(campaign_id,decode_token['id'])

        cur.execute("select subscribe_campaign(%s::INTEGER,%s::INTEGER)",values)
        result=cur.fetchone()
        conn.commit()

        print(result[0])

        if 'error' in result[0]:
             response = {'status': StatusCodes['api_error'], 'errors': result['error']}
             logger.debug('Not subscribe campaign')
        else:
            response = {'status': StatusCodes['success'], 'results': result}
            logger.debug('Subscribe campaign')


    except (Exception, psycopg2.DatabaseError) as error:
        logger.error(error)
        response = {'status': StatusCodes['internal_error'], 'errors': str(error)}

        # an error occurred, rollback
        conn.rollback()
    finally:
        if conn is not None:
            conn.close()
    
    return flask.jsonify(response)


##
## Rate a product
##

@app.route('/dbproj/rating/<product_id>',methods = ['POST'])
def rate_product(product_id):


    payload = flask.request.get_json()

    conn = db_connection()
    cur = conn.cursor()

    logger.info(f'Rating the product {product_id}')

    #ler token inserido em Header Postman (authorization->Bearer Token)
    global token
    header=flask.request.headers
    if 'Authorization' not in header:
        response = {'status': StatusCodes['api_error'], 'errors': 'Missing auth token'}
        return flask.jsonify(response)
    else:
        token=(header['Authorization'].split(" ")[1])


    #Decode Token
    decode_token = jwt.decode(token,jwt_key,'HS256')

    #Check payload arguments
    if 'rating' not in payload or 'comment' not in payload:
        response = {'status': StatusCodes['api_error'], 'errors': 'Missing Rating or Comment'}
        return flask.jsonify(response)


    try:

        values = ( decode_token['id'], str(product_id), str(payload['rating']), payload['comment'])
        cur.execute("call create_rating(%s::INTEGER,%s::INTEGER,%s::INTEGER,%s::VARCHAR)",values)

        response = {'status': StatusCodes['success']}
        conn.commit()

    except (Exception, psycopg2.DatabaseError) as error:
        logger.error(error)
        response = {'status': StatusCodes['internal_error'], 'errors': str(error)}

        # an error occurred, rollback
        conn.rollback()

    finally:
        if conn is not None:
            conn.close()


    return flask.jsonify(response)


##
## Get notifications
##

@app.route('/dbproj/notification',methods = ['GET'])
def get_notifications():


    conn = db_connection()
    cur = conn.cursor()

    logger.info(f'Get notification')

    #ler token inserido em Header Postman (authorization->Bearer Token)
    global token
    header=flask.request.headers
    if 'Authorization' not in header:
        response = {'status': StatusCodes['api_error'], 'errors': 'Missing auth token'}
        return flask.jsonify(response)
    else:
        token=(header['Authorization'].split(" ")[1])


    #Decode Token
    decode_token = jwt.decode(token,jwt_key,'HS256')

    try:
        
        cur.execute("select get_notifications(%s::INTEGER)",(decode_token['id']))

        notifications = cur.fetchall()
        
        if notifications[0][0] is None:
            response = {'status': StatusCodes['success'],'results': 'No new notifications' }
        else:
            response = {'status': StatusCodes['success'],'results': notifications[0][0] }
        
        conn.commit()

    except (Exception, psycopg2.DatabaseError) as error:
        logger.error(error)
        response = {'status': StatusCodes['internal_error'], 'errors': str(error)}

        # an error occurred, rollback
        conn.rollback()

    finally:
        if conn is not None:
            conn.close()


    return flask.jsonify(response)

##
## Make a comment
##

@app.route('/dbproj/questions/<product_id>', defaults = {'parent_id': None}, methods = ['POST'])
@app.route('/dbproj/questions/<product_id>/<parent_id>', methods = ['POST'])
def make_comment(product_id,parent_id):


    payload = flask.request.get_json()

    conn = db_connection()
    cur = conn.cursor()

    logger.info(f'Make Comment')

    #ler token inserido em Header Postman (authorization->Bearer Token)
    global token
    header=flask.request.headers
    if 'Authorization' not in header:
        response = {'status': StatusCodes['api_error'], 'errors': 'Missing auth token'}
        return flask.jsonify(response)
    else:
        token=(header['Authorization'].split(" ")[1])


    #Decode Token
    decode_token = jwt.decode(token,jwt_key,'HS256')

    #check payload
    if 'question' not in payload:
        response = {'status': StatusCodes['api_error'], 'errors': 'Missing question'}
        return flask.jsonify(response)


    try:
        
        if parent_id is None:
            values = (int(product_id),-1,decode_token['id'],payload['question'])
        else:
            values = (int(product_id), int(parent_id),decode_token['id'],payload['question'])

        cur.execute("select make_comment(%s::INTEGER,%s::INTEGER,%s::INTEGER,%s::VARCHAR)",values)
        #TODO funcao SQL e ajustar esta call

        response = cur.fetchall()  

        response = {'status': StatusCodes['success'],'results': response}
        conn.commit()

    except (Exception, psycopg2.DatabaseError) as error:
        logger.error(error)
        response = {'status': StatusCodes['internal_error'], 'errors': str(error)}

        # an error occurred, rollback
        conn.rollback()

    finally:
        if conn is not None:
            conn.close()


    return flask.jsonify(response)



def check_user_type(id):
    
    conn = db_connection()
    cur = conn.cursor()

    try:
        cur.execute("select check_user_type(%s::INTEGER)",id)
        conn.commit()

        result=cur.fetchone()
        return result[0]
        
    except (psycopg2.DatabaseError) as error:
        logger.error(f'GET /customer/ - error: {error}')
        response = {'status': StatusCodes['internal_error'], 'errors': str(error)}

    finally:
        if conn is not None:
            conn.close()

    return flask.jsonify(response)



if __name__ == '__main__':
    
    # set up logging
    logging.basicConfig(filename='log_file.log')
    logger = logging.getLogger('logger')
    logger.setLevel(logging.DEBUG)
    ch = logging.StreamHandler()
    ch.setLevel(logging.DEBUG)

    # create formatter
    formatter = logging.Formatter('%(asctime)s [%(levelname)s]:  %(message)s', '%H:%M:%S')
    ch.setFormatter(formatter)
    logger.addHandler(ch)

    host = '127.0.0.1'
    port = 8080
    app.run(host=host, debug=True, threaded=True, port=port)
    logger.info(f'API v1.0 online: http://{host}:{port}')