CREATE TABLE customer (
	pais		 VARCHAR(30) NOT NULL,
	cidade	 VARCHAR(35) NOT NULL,
	rua		 VARCHAR(130) NOT NULL,
	nif		 INTEGER,
	utilizador_id BIGINT UNIQUE,
	PRIMARY KEY(utilizador_id)
);

CREATE TABLE vendedor (
	nif		 INTEGER UNIQUE NOT NULL,
	pais		 VARCHAR(30) NOT NULL,
	cidade	 VARCHAR(35) NOT NULL,
	rua		 VARCHAR(130) NOT NULL,
	utilizador_id BIGINT UNIQUE,
	PRIMARY KEY(utilizador_id)
);

CREATE TABLE administrador (
	utilizador_id BIGINT UNIQUE,
	PRIMARY KEY(utilizador_id)
);

CREATE TABLE produto (
	id		 BIGINT UNIQUE,
	descricao		 VARCHAR(512),
	preco			 FLOAT(8) NOT NULL,
	stock			 INTEGER NOT NULL,
	versao		 SMALLINT UNIQUE,
	vendedor_utilizador_id BIGINT NOT NULL,
	PRIMARY KEY(id,versao)
);

CREATE TABLE smartphone (
	tamanho	 SMALLINT NOT NULL,
	marca		 VARCHAR(50) NOT NULL,
	ram		 SMALLINT NOT NULL,
	rom		 SMALLINT NOT NULL,
	produto_id	 BIGINT UNIQUE,
	produto_versao SMALLINT UNIQUE,
	PRIMARY KEY(produto_id,produto_versao)
);

CREATE TABLE tv (
	tamanho	 SMALLINT NOT NULL,
	marca		 VARCHAR(50) NOT NULL,
	produto_id	 BIGINT UNIQUE,
	produto_versao SMALLINT UNIQUE,
	PRIMARY KEY(produto_id,produto_versao)
);

CREATE TABLE pc (
	cpu		 VARCHAR(60) NOT NULL,
	ram		 SMALLINT NOT NULL,
	rom		 SMALLINT NOT NULL,
	marca		 VARCHAR(50) NOT NULL,
	produto_id	 BIGINT UNIQUE,
	produto_versao SMALLINT UNIQUE,
	PRIMARY KEY(produto_id,produto_versao)
);

CREATE TABLE comentario_notificacao_com (
	id			 INTEGER UNIQUE,
	id_anterior INTEGER,
	texto			 VARCHAR(512) NOT NULL,
	utilizador_id		 BIGINT NOT NULL,
	vendedor_utilizador_id BIGINT NOT NULL,
	produto_id		 BIGINT NOT NULL,
	produto_versao	 SMALLINT NOT NULL,
	notificacao_descricao	 VARCHAR(512),
	PRIMARY KEY(id)
);

CREATE TABLE campanha (
	id				 INTEGER UNIQUE,
	desconto			 INTEGER NOT NULL,
	numero_cupoes		 INTEGER NOT NULL,
	data_inicio		 DATE NOT NULL,
	data_fim			 DATE NOT NULL,
	campanha_ativa		 BOOL NOT NULL,
	validade_cupao		 SMALLINT NOT NULL,
	administrador_utilizador_id BIGINT NOT NULL,
	PRIMARY KEY(id)
);

CREATE TABLE cupao (
	id		 INTEGER UNIQUE,
	cupao_ativo	 BOOL NOT NULL,
	data_atribuicao DATE NOT NULL,
	campanha_id	 INTEGER UNIQUE,
	PRIMARY KEY(id,campanha_id)
);

CREATE TABLE compra_notificacao_c (
	id			 INTEGER,
	data_compra		 DATE NOT NULL,
	valor_pago		 FLOAT(8) NOT NULL,
	valor_desconto	 FLOAT(8) NOT NULL,
	vendedor_utilizador_id BIGINT NOT NULL,
	customer_utilizador_id BIGINT NOT NULL,
	notificacao_descricao	 VARCHAR(512),
	PRIMARY KEY(id)
);

CREATE TABLE utilizador (
	id	 BIGINT UNIQUE,
	username VARCHAR(25) UNIQUE NOT NULL,
	password VARCHAR(100) NOT NULL,
	mail	 VARCHAR(512) UNIQUE NOT NULL,
	nome	 VARCHAR(30) NOT NULL,
	PRIMARY KEY(id)
);

CREATE TABLE rating (
	id			 INTEGER UNIQUE,
	classificacao		 INTEGER NOT NULL,
	descricao		 VARCHAR(512),
	compra_id		 INTEGER UNIQUE,
	customer_utilizador_id BIGINT NOT NULL,
	produto_id		 BIGINT NOT NULL,
	produto_versao	 SMALLINT NOT NULL,
	PRIMARY KEY(id,compra_id)
);

CREATE TABLE login_token (
	token	 VARCHAR(512),
	utilizador_id BIGINT NOT NULL,
	PRIMARY KEY(token)
);

CREATE TABLE transacaocompra (
	quantidade	 INTEGER,
	compra_id	 INTEGER UNIQUE,
	produto_id	 BIGINT UNIQUE,
	produto_versao SMALLINT UNIQUE,
	PRIMARY KEY(compra_id,produto_id,produto_versao)
);

CREATE TABLE compra_notificacao_c_cupao (
	cupao_id		 INTEGER UNIQUE NOT NULL,
	cupao_campanha_id INTEGER UNIQUE NOT NULL
);

CREATE TABLE customer_cupao (
	customer_utilizador_id BIGINT NOT NULL,
	cupao_id		 INTEGER UNIQUE,
	cupao_campanha_id	 INTEGER UNIQUE,
	PRIMARY KEY(cupao_id,cupao_campanha_id)
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
ALTER TABLE smartphone ADD CONSTRAINT smartphone_fk1 FOREIGN KEY (produto_id) REFERENCES produto(id);
ALTER TABLE smartphone ADD CONSTRAINT smartphone_fk2 FOREIGN KEY (produto_versao) REFERENCES produto(versao);
ALTER TABLE tv ADD CONSTRAINT tv_fk1 FOREIGN KEY (produto_id) REFERENCES produto(id);
ALTER TABLE tv ADD CONSTRAINT tv_fk2 FOREIGN KEY (produto_versao) REFERENCES produto(versao);
ALTER TABLE pc ADD CONSTRAINT pc_fk1 FOREIGN KEY (produto_id) REFERENCES produto(id);
ALTER TABLE pc ADD CONSTRAINT pc_fk2 FOREIGN KEY (produto_versao) REFERENCES produto(versao);
ALTER TABLE comentario_notificacao_com ADD CONSTRAINT comentario_notificacao_com_fk1 FOREIGN KEY (utilizador_id) REFERENCES utilizador(id);
ALTER TABLE comentario_notificacao_com ADD CONSTRAINT comentario_notificacao_com_fk2 FOREIGN KEY (vendedor_utilizador_id) REFERENCES vendedor(utilizador_id);
ALTER TABLE comentario_notificacao_com ADD CONSTRAINT comentario_notificacao_com_fk3 FOREIGN KEY (produto_id) REFERENCES produto(id);
ALTER TABLE comentario_notificacao_com ADD CONSTRAINT comentario_notificacao_com_fk4 FOREIGN KEY (produto_versao) REFERENCES produto(versao);
ALTER TABLE comentario_notificacao_com ADD CONSTRAINT comentario_notificacao_com_fk5 FOREIGN KEY (id_anterior) REFERENCES comentario_notificacao_com(id);
ALTER TABLE campanha ADD CONSTRAINT campanha_fk1 FOREIGN KEY (administrador_utilizador_id) REFERENCES administrador(utilizador_id);
ALTER TABLE campanha ADD CONSTRAINT desconto CHECK (desconto < 100 AND desconto > 0);
ALTER TABLE campanha ADD CONSTRAINT numero_cupoes CHECK (numero_cupoes > 0);
ALTER TABLE campanha ADD CONSTRAINT validade CHECK (validade_cupao > 0);
ALTER TABLE campanha ADD CONSTRAINT data CHECK (data_inicio < data_fim);
ALTER TABLE cupao ADD CONSTRAINT cupao_fk1 FOREIGN KEY (campanha_id) REFERENCES campanha(id);
ALTER TABLE compra_notificacao_c ADD CONSTRAINT compra_notificacao_c_fk1 FOREIGN KEY (vendedor_utilizador_id) REFERENCES vendedor(utilizador_id);
ALTER TABLE compra_notificacao_c ADD CONSTRAINT compra_notificacao_c_fk2 FOREIGN KEY (customer_utilizador_id) REFERENCES customer(utilizador_id);
ALTER TABLE compra_notificacao_c ADD CONSTRAINT valor_pago CHECK (valor_pago > 0);
ALTER TABLE compra_notificacao_c ADD CONSTRAINT valor_desconto CHECK (valor_desconto >= 0);
ALTER TABLE utilizador ADD CONSTRAINT username CHECK (length(username) > 6);
ALTER TABLE utilizador ADD CONSTRAINT pw CHECK (length(password) > 8);
ALTER TABLE utilizador ADD CONSTRAINT nome CHECK (length(nome) > 3);
ALTER TABLE utilizador ADD CONSTRAINT mail CHECK (mail LIKE '%@%.com');
ALTER TABLE rating ADD CONSTRAINT rating_fk1 FOREIGN KEY (compra_id) REFERENCES compra_notificacao_c(id);
ALTER TABLE rating ADD CONSTRAINT rating_fk2 FOREIGN KEY (customer_utilizador_id) REFERENCES customer(utilizador_id);
ALTER TABLE rating ADD CONSTRAINT rating_fk3 FOREIGN KEY (produto_id) REFERENCES produto(id);
ALTER TABLE rating ADD CONSTRAINT rating_fk4 FOREIGN KEY (produto_versao) REFERENCES produto(versao);
ALTER TABLE rating ADD CONSTRAINT classificacao CHECK (classificacao >= 0 AND classificacao <= 5);
ALTER TABLE login_token ADD CONSTRAINT login_token_fk1 FOREIGN KEY (utilizador_id) REFERENCES utilizador(id);
ALTER TABLE transacaocompra ADD CONSTRAINT transacaocompra_fk1 FOREIGN KEY (compra_id) REFERENCES compra_notificacao_c(id);
ALTER TABLE transacaocompra ADD CONSTRAINT transacaocompra_fk2 FOREIGN KEY (produto_id) REFERENCES produto(id);
ALTER TABLE transacaocompra ADD CONSTRAINT transacaocompra_fk3 FOREIGN KEY (produto_versao) REFERENCES produto(versao);
ALTER TABLE transacaocompra ADD CONSTRAINT quantidade CHECK (quantidade > 0);
ALTER TABLE compra_notificacao_c_cupao ADD CONSTRAINT compra_notificacao_c_cupao_fk1 FOREIGN KEY (cupao_id) REFERENCES cupao(id);
ALTER TABLE compra_notificacao_c_cupao ADD CONSTRAINT compra_notificacao_c_cupao_fk2 FOREIGN KEY (cupao_campanha_id) REFERENCES cupao(campanha_id);
ALTER TABLE customer_cupao ADD CONSTRAINT customer_cupao_fk1 FOREIGN KEY (customer_utilizador_id) REFERENCES customer(utilizador_id);
ALTER TABLE customer_cupao ADD CONSTRAINT customer_cupao_fk2 FOREIGN KEY (cupao_id) REFERENCES cupao(id);
ALTER TABLE customer_cupao ADD CONSTRAINT customer_cupao_fk3 FOREIGN KEY (cupao_campanha_id) REFERENCES cupao(campanha_id);

