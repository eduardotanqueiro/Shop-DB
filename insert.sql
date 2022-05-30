--INSERT ADMIN user_admin1/pw_admin1
INSERT INTO utilizador (username,password,mail,nome) VALUES ('user_admin1','f36fad597d1bdde835a645d3b66d1d40','admin1@gmail.com','nome_admin1');
INSERT INTO administrador (utilizador_id) SELECT id FROM utilizador WHERE nome = 'nome_admin1';

--INSERT SELLER user_vendedor1/pw_vendedor1
INSERT INTO utilizador (username,password,mail,nome) VALUES ('user_vendedor1','8f6a08e882be0f16d38e54cca33a1cb9','vendedor1@gmail.com','nome_vendedor1');
INSERT INTO vendedor (pais,cidade,rua,utilizador_id) SELECT 'Portugal','Coimbra','Rua da Baixa',id FROM utilizador WHERE nome = 'nome_vendedor1';