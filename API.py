import flask
import logging
import psycopg2
import time

app = flask.Flask(__name__)

StatusCodes = {
    'success': 200,
    'api_error': 400,
    'internal_error': 500
}

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

    # do not forget to validate every argument, e.g.,:
    if 'username' not in payload or 'mail' not in payload or 'password' not in payload or 'pais' not in payload or 'cidade' not in payload or 'rua' not in payload:
        response = {'status': StatusCodes['api_error'], 'results': 'Missing value(s) in the payload'}
        return flask.jsonify(response)



    # parameterized queries, good for security and performance
    cur.execute("SELECT MAX(id) FROM utilizador")
    get_highest_id = cur.fetchall()
    
    if get_highest_id == []:
        id = 0
    else:        
        id = get_highest_id[0][0] + 1
    


    statement1 ='INSERT INTO utilizador (id,username,password,mail,nome) VALUES (%s, %s, %s,%s, %s)'
    values1 = (id, payload['username'], payload['password'], payload['mail'] , payload['nome'])


    if len(payload) == 7:
        statement2 = 'INSERT INTO customer (utilizador_id,pais,cidade,rua) VALUES (%s,%s, %s, %s)'
        values2 =  (id,payload['pais'], payload['cidade'], payload['rua'] )
    else:
        statement2 = 'INSERT INTO customer (utilizador_id,pais,cidade,rua,NIF) VALUES (%s,%s, %s, %s,%s)'
        values2 =  (id,payload['pais'], payload['cidade'], payload['rua'], payload['nif'])


    try:
        cur.execute(statement1,values1)
        cur.execute(statement2, values2)

        # commit the transaction
        conn.commit()
        response = {'status': StatusCodes['success'], 'results': f'Inserted user {payload["nome"]}'}
        logger.debug(f'New user inserted with id {id}')

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
        cur.execute('SELECT descricao,preco FROM produto WHERE produto.id = %s AND produto.versao = (SELECT MAX(produto.versao) FROM produto WHERE produto.id = %s )', product_id  )
        rows = cur.fetchall()

        if rows == []:
            raise Exception("There are no products to sell")
        else:
            row = rows[0]

        logger.debug('GET /product/<product_id> - parse')
        logger.debug(row)
        content = {'descricao': row[0], 'preco': row[1]}

        response = {'status': StatusCodes['success'], 'results': content}

    except (Exception, psycopg2.DatabaseError) as error:
        logger.error(f'GET /product/<product_id> - error: {error}')
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