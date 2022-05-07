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

    #verify arguments
    if 'username' not in payload or 'mail' not in payload or 'password' not in payload or 'pais' not in payload or 'cidade' not in payload or 'rua' not in payload:
        response = {'status': StatusCodes['api_error'], 'results': 'Missing value(s) in the payload'}
        return flask.jsonify(response)

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
    
    
    #If user is not admin
    if decode_token['user_type'] == user_type_hashed['customer'] or decode_token['user_type'] == user_type_hashed['vendedor']:
        response = {'status': StatusCodes['api_error'], 'errors': 'You don\'t have permission to execute this task!'}
        return flask.jsonify(response)


    #hashing da password
    bin_pw = str(payload['password']).encode('ascii')
    hash_pw = hs.md5( bin_pw ).hexdigest()

    values = (payload['username'], hash_pw , payload['mail'] , payload['nome'], payload['pais'], payload['cidade'], payload['rua'])

    #TODO -> FAZER A VERIFICAÇÃO SE VIER COM NIF OU NÃO

    try:
        cur.execute("call insert_customer(%s,%s,%s,%s,%s,%s,%s)",values)

        # commit the transaction
        conn.commit()

        response = {'status': StatusCodes['success'], 'results': f'Inserted user {payload["nome"]}'}
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

            cur.execute("call insert_smartphone(%s::VARCHAR,%s::FLOAT(8),%s::INTEGER,%s::INTEGER,%s::SMALLINT,%s::VARCHAR,%s::SMALLINT,%s::SMALLINT)", values)

        elif payload['tipo'] == 'tv':

            values = ((payload['descricao']),(payload['preco']),(payload['stock']), (decode_token['id']) ,(payload['tamanho']),(payload['marca']))
            print(values)

            cur.execute("call insert_tv(%s::VARCHAR(512),%s::FLOAT(8),%s::INTEGER,%s::INTEGER,%s::SMALLINT,%s::VARCHAR(50))", values)

        elif payload['tipo'] == 'pc':

            values = (payload['descricao'],payload['preco'],payload['stock'], decode_token['id'],payload['cpu'],payload['ram'],payload['rom'],payload['marca'])

            cur.execute("call insert_pc(%s::VARCHAR,%s::FLOAT(8),%s::INTEGER,%s::INTEGER,%s::VARCHAR,%s::SMALLINT,%s::SMALLINT,%s::VARCHAR)", values)


        conn.commit()

        response = {'status': StatusCodes['success'], 'results': f'Added new product'}
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
    
    try:
        #compra
        if 'coupon' not in payload:
            values = (token['id'], json.dumps(payload['cart']),'-1')
            cur.execute("select make_order(%s::INTEGER,select json_array_elements(%s::json),%s::INTEGER);",values)

        else:
            values = (token['id'], json.dumps(payload['cart']),payload['coupon'])
            cur.execute("select make_order(%s::INTEGER,select json_array_elements(%s::json),%s::INTEGER);",values)

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
            print('error')
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
## ADD CAMPAIGN
##
@app.route('/dbproj/campaign/', methods=['POST'])
def add_campaign():
    logger.info('User Login Campaign Insertion')
    payload=flask.request.get_json()

    conn=db_connection()
    cur=conn.cursor()

    #Check if auth token was received
    if 'token' not in payload:
        response = {'status': StatusCodes['api_error'], 'errors': 'Missing auth token'}
        return flask.jsonify(response)
    #Chek id user customer, seller or admin

    decode_token = jwt.decode(payload['token'],jwt_key,'HS256')

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

        cur.execute("call insert_campaign(%s::INTEGER,%s::INTEGER,%s::DATE,%s::DATE,%s::SMALLINT,%s::INTEGER)",values)

        conn.commit()

        response = {'status': StatusCodes['success'], 'results': f'Added new campaign'}
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
@app.route('/dbproj/subscribe/', methods=['POST'])
def subscribe_campaign():
    logger.info('User Login Campaign Subscribe')
    payload=flask.request.get_json()

    conn=db_connection()
    cur=conn.cursor()

    #Check if auth token was received
    if 'token' not in payload:
        response = {'status': StatusCodes['api_error'], 'errors': 'Missing auth token'}
        return flask.jsonify(response)
    #Chek id user customer, seller or admin

    decode_token = jwt.decode(payload['token'],jwt_key,'HS256')

    #If user is not customer
    if decode_token['user_type'] == user_type_hashed['administrador'] or decode_token['user_type'] == user_type_hashed['vendedor']:
        response = {'status': StatusCodes['api_error'], 'errors': 'You don\'t have permission to execute this task!'}
        return flask.jsonify(response)
    
    #Ckeck is payload parameters are correct
    if 'id_campanha' not in payload:
         response = {'status': StatusCodes['api_error'], 'errors': 'Missing values for product in the payload'}
         return flask.jsonify(response) 

    #Insert campaign

    decode_token['id']=int(decode_token['id'])

    try:
        values=(payload['id_campanha'],decode_token['id'])

        cur.execute("select subscribe_campaign(%s::INTEGER,%s::INTEGER)",values)
        result=cur.fetchone()
        conn.commit()

        if result[0]==True:
            response = {'status': StatusCodes['success'], 'results': f'Subscribe campaign'}
            logger.debug('Subscribe campaign')
        else:
             response = {'status': StatusCodes['api_error'], 'errors':'Not subscribe campaign!Invalid campaign!'}
             logger.debug('Not subscribe campaign')
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
        cur.execute("select create_rating(%s::INTEGER,%s::INTEGER,%s::INTEGER,%s::VARCHAR)",values)

        response=cur.fetchone()
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