CREATE TABLE customer (
	pais		 VARCHAR(30) NOT NULL,
	cidade	 VARCHAR(35) NOT NULL,
	rua		 VARCHAR(130) NOT NULL,
	nif		 INTEGER, --tirar nif??? muito trabalho
	utilizador_id INTEGER UNIQUE,
	PRIMARY KEY(utilizador_id)
);

CREATE TABLE vendedor (
	nif		 INTEGER UNIQUE NOT NULL, --tirar nif??? muito trabalho
	pais		 VARCHAR(30) NOT NULL,
	cidade	 VARCHAR(35) NOT NULL,
	rua		 VARCHAR(130) NOT NULL,
	utilizador_id INTEGER UNIQUE NOT NULL,
	PRIMARY KEY(utilizador_id)
);

CREATE TABLE administrador (
	utilizador_id INTEGER UNIQUE NOT NULL,
	PRIMARY KEY(utilizador_id)
);

CREATE TABLE produto (
	id		 BIGINT NOT NULL,
	descricao		 VARCHAR(512),
	preco			 FLOAT(8) NOT NULL,
	stock			 INTEGER NOT NULL,
	versao		 SMALLINT NOT NULL,
	vendedor_utilizador_id BIGINT NOT NULL,
	PRIMARY KEY(id,versao)
);

CREATE TABLE smartphone (
	tamanho	 SMALLINT NOT NULL,
	marca		 VARCHAR(50) NOT NULL,
	ram		 SMALLINT NOT NULL,
	rom		 SMALLINT NOT NULL,
	produto_id	 BIGINT NOT NULL,
	produto_versao SMALLINT NOT NULL,
	PRIMARY KEY(produto_id,produto_versao)
);

CREATE TABLE tv (
	tamanho	 SMALLINT NOT NULL,
	marca		 VARCHAR(50) NOT NULL,
	produto_id	 BIGINT NOT NULL,
	produto_versao SMALLINT NOT NULL,
	PRIMARY KEY(produto_id,produto_versao)
);

CREATE TABLE pc (
	cpu		 VARCHAR(60) NOT NULL,
	ram		 SMALLINT NOT NULL,
	rom		 SMALLINT NOT NULL,
	marca		 VARCHAR(50) NOT NULL,
	produto_id	 BIGINT NOT NULL,
	produto_versao SMALLINT NOT NULL,
	PRIMARY KEY(produto_id,produto_versao)
);

CREATE TABLE notificacao_comentario (

	descricao	 VARCHAR(512) NOT NULL,
	lida INTEGER NOT NULL,
	data_notificacao DATE NOT NULL,
	user_id BIGINT NOT NULL, --FALTA FOREIGN KEY
	comentario_id			INTEGER NOT NULL --FALTA FOREIGN KEY
);

CREATE TABLE comentario(
	id			 SERIAL UNIQUE NOT NULL,
	id_anterior INTEGER,
	texto			 VARCHAR(512) NOT NULL,
	utilizador_id		 BIGINT NOT NULL,
	vendedor_utilizador_id BIGINT NOT NULL,
	produto_id		 BIGINT NOT NULL,
	produto_versao	 SMALLINT NOT NULL,

	PRIMARY KEY(id)
);

CREATE TABLE campanha (
	id				 SERIAL UNIQUE,
	desconto			 INTEGER NOT NULL,
	numero_cupoes		 INTEGER NOT NULL,
	data_inicio		 DATE NOT NULL,
	data_fim			 DATE NOT NULL,
	campanha_ativa		 BOOL NOT NULL,
	validade_cupao		 SMALLINT NOT NULL,
	administrador_utilizador_id BIGINT NOT NULL,
	PRIMARY KEY(id)
);

--------------------------------------VER
CREATE TABLE cupao (
	id SERIAL UNIQUE,
	numero	INTEGER NOT NULL ,
	cupao_ativo	 BOOL NOT NULL,
	data_atribuicao DATE NOT NULL, 
	campanha_id	 INTEGER NOT NULL,
	PRIMARY KEY(id)
);

CREATE TABLE notificacao_compra(

	descricao	 VARCHAR(512) NOT NULL,
	lida INTEGER NOT NULL,
	data_notificacao DATE NOT NULL,
	user_id BIGINT NOT NULL --FALTA FOREIGN KEY

);

CREATE TABLE compra(
	id			 SERIAL UNIQUE NOT NULL,
	data_compra		 DATE NOT NULL,
	valor_pago		 FLOAT(8) NOT NULL,
	valor_do_desconto	 FLOAT(8) NOT NULL,
	customer_utilizador_id BIGINT NOT NULL,

	PRIMARY KEY(id)
);

CREATE TABLE utilizador (
	id	 SERIAL UNIQUE NOT NULL,
	username VARCHAR(25) UNIQUE NOT NULL,
	password VARCHAR(100) NOT NULL,
	mail	 VARCHAR(512) UNIQUE NOT NULL,
	nome	 VARCHAR(30) NOT NULL,
	PRIMARY KEY(id)
);

CREATE TABLE rating (
	classificacao		 INTEGER NOT NULL,
	descricao		 VARCHAR(512),
	compra_id		 INTEGER NOT NULL,
	customer_utilizador_id BIGINT NOT NULL,
	produto_id		 BIGINT NOT NULL,
	produto_versao	 SMALLINT NOT NULL,
	PRIMARY KEY(compra_id,produto_id,produto_versao)
);

CREATE TABLE login_token (
	token	 VARCHAR(512) NOT NULL,
	utilizador_id BIGINT NOT NULL,
	PRIMARY KEY(token)
);

CREATE TABLE transacao_compra (
	quantidade	 INTEGER NOT NULL,
	compra_id	 INTEGER NOT NULL,
	produto_id	 BIGINT NOT NULL,
	produto_versao SMALLINT NOT NULL,
	PRIMARY KEY(compra_id,produto_id,produto_versao)
);

CREATE TABLE compra_cupao (
	id_compra 			INTEGER NOT NULL,
	id_cupao			INTEGER NOT NULL
);

CREATE TABLE customer_cupao (
	customer_utilizador_id BIGINT NOT NULL,
	id_cupao 				INTEGER NOT NULL
);

ALTER TABLE customer ADD CONSTRAINT customer_fk1 FOREIGN KEY (utilizador_id) REFERENCES utilizador(id);
ALTER TABLE customer ADD CONSTRAINT pais CHECK (length(pais) > 3 );
ALTER TABLE customer ADD CONSTRAINT cidade CHECK (length(cidade) > 3 );
ALTER TABLE customer ADD CONSTRAINT rua CHECK (length(rua) > 4);
ALTER TABLE vendedor ADD CONSTRAINT vendedor_fk1 FOREIGN KEY (utilizador_id) REFERENCES utilizador(id);
ALTER TABLE vendedor ADD CONSTRAINT pais CHECK (length(pais) > 3 );
ALTER TABLE vendedor ADD CONSTRAINT cidade CHECK (length(cidade) > 3 );
ALTER TABLE vendedor ADD CONSTRAINT rua CHECK (length(rua) > 4);
ALTER TABLE administrador ADD CONSTRAINT administrador_fk1 FOREIGN KEY (utilizador_id) REFERENCES utilizador(id);
ALTER TABLE produto ADD CONSTRAINT produto_fk1 FOREIGN KEY (vendedor_utilizador_id) REFERENCES vendedor(utilizador_id);
ALTER TABLE produto ADD CONSTRAINT preco CHECK (preco > 0);
ALTER TABLE produto ADD CONSTRAINT stock CHECK (stock >= 0);
ALTER TABLE produto ADD CONSTRAINT versao CHECK (versao >= 0);
ALTER TABLE smartphone ADD CONSTRAINT smartphone_fk1 FOREIGN KEY (produto_id,produto_versao) REFERENCES produto(id,versao); 
ALTER TABLE tv ADD CONSTRAINT tv_fk1 FOREIGN KEY (produto_id,produto_versao) REFERENCES produto(id,versao); 
ALTER TABLE pc ADD CONSTRAINT pc_fk1 FOREIGN KEY (produto_id,produto_versao) REFERENCES produto(id,versao);
ALTER TABLE notificacao_comentario ADD CONSTRAINT notificacao_comentario_fk1 FOREIGN KEY (comentario_id) REFERENCES comentario(id);
ALTER TABLE comentario ADD CONSTRAINT comentario_fk1 FOREIGN KEY (utilizador_id) REFERENCES utilizador(id);
ALTER TABLE comentario ADD CONSTRAINT comentario_fk2 FOREIGN KEY (vendedor_utilizador_id) REFERENCES vendedor(utilizador_id);
ALTER TABLE comentario ADD CONSTRAINT comentario_fk3 FOREIGN KEY (produto_id,produto_versao) REFERENCES produto(id,versao); 
ALTER TABLE comentario ADD CONSTRAINT comentario_fk4 FOREIGN KEY (id_anterior) REFERENCES comentario(id);
ALTER TABLE campanha ADD CONSTRAINT campanha_fk1 FOREIGN KEY (administrador_utilizador_id) REFERENCES administrador(utilizador_id);
ALTER TABLE campanha ADD CONSTRAINT desconto CHECK (desconto < 100 AND desconto > 0);
ALTER TABLE campanha ADD CONSTRAINT numero_cupoes CHECK (numero_cupoes > 0);
ALTER TABLE campanha ADD CONSTRAINT validade CHECK (validade_cupao > 0);
ALTER TABLE campanha ADD CONSTRAINT data CHECK (data_inicio < data_fim);
ALTER TABLE cupao ADD CONSTRAINT cupao_fk1 FOREIGN KEY (campanha_id) REFERENCES campanha(id); 
ALTER TABLE notificacao_compra ADD CONSTRAINT notificacao_compra_fk1 FOREIGN KEY (compra_id) REFERENCES compra(id);
ALTER TABLE compra ADD CONSTRAINT compra_fk2 FOREIGN KEY (customer_utilizador_id) REFERENCES customer(utilizador_id);
ALTER TABLE compra ADD CONSTRAINT valor_pago CHECK (valor_pago > 0);
ALTER TABLE compra ADD CONSTRAINT valor_do_desconto CHECK (valor_do_desconto >= 0);
ALTER TABLE utilizador ADD CONSTRAINT username CHECK (length(username) > 6);
ALTER TABLE utilizador ADD CONSTRAINT pw CHECK (length(password) > 8);
ALTER TABLE utilizador ADD CONSTRAINT nome CHECK (length(nome) > 3);
ALTER TABLE utilizador ADD CONSTRAINT mail CHECK (mail LIKE '%@%.com');
ALTER TABLE rating ADD CONSTRAINT rating_fk1 FOREIGN KEY (compra_id) REFERENCES compra(id);
ALTER TABLE rating ADD CONSTRAINT rating_fk2 FOREIGN KEY (customer_utilizador_id) REFERENCES customer(utilizador_id);
ALTER TABLE rating ADD CONSTRAINT rating_fk3 FOREIGN KEY (produto_id,produto_versao) REFERENCES produto(id,versao);
ALTER TABLE rating ADD CONSTRAINT classificacao CHECK (classificacao >= 0 AND classificacao <= 5);
ALTER TABLE login_token ADD CONSTRAINT login_token_fk1 FOREIGN KEY (utilizador_id) REFERENCES utilizador(id);
ALTER TABLE transacao_compra ADD CONSTRAINT transacao_compra_fk1 FOREIGN KEY (compra_id) REFERENCES compra(id); 
ALTER TABLE transacao_compra ADD CONSTRAINT transacao_compra_fk2 FOREIGN KEY (produto_id,produto_versao) REFERENCES produto(id,versao);
ALTER TABLE transacao_compra ADD CONSTRAINT quantidade CHECK (quantidade > 0);
ALTER TABLE compra_cupao ADD CONSTRAINT compra_cupao_fk1 FOREIGN KEY (id_cupao) REFERENCES cupao(id); 
ALTER TABLE compra_cupao ADD CONSTRAINT compra_cupao_fk2 FOREIGN KEY (id_compra) REFERENCES compra(id);
ALTER TABLE customer_cupao ADD CONSTRAINT customer_cupao_fk1 FOREIGN KEY (customer_utilizador_id) REFERENCES customer(utilizador_id);
ALTER TABLE customer_cupao ADD CONSTRAINT customer_cupao_fk2 FOREIGN KEY (id_cupao) REFERENCES cupao(id);

--GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO ProjetoBD;

/*

CREATE SEQUENCE utilizador_id;
ALTER TABLE utilizador ALTER id SET DEFAULT NEXTVAL('utilizador_id');

CREATE SEQUENCE compra_id;
ALTER TABLE compra_notificacao_c ALTER id SET DEFAULT NEXTVAL('compra_id');

CREATE SEQUENCE produto_id;
ALTER TABLE produto ALTER id SET DEFAULT NEXTVAL('produto_id');

CREATE SEQUENCE rating_id;
ALTER TABLE rating ALTER id SET DEFAULT NEXTVAL('rating_id');

CREATE SEQUENCE cupao_id;
ALTER TABLE cupao ALTER id SET DEFAULT NEXTVAL('cupao_id');

CREATE SEQUENCE campanha_id;
ALTER TABLE campanha ALTER id SET DEFAULT NEXTVAL('campanha_id');

CREATE SEQUENCE com_not_id;
ALTER TABLE comentario_notificacao_com ALTER id SET DEFAULT NEXTVAL('com_not_id');

GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO ProjetoBD
*/