--INSERT ADMIN
INSERT INTO utilizador (username,password,mail,nome) VALUES ('user_admin1','pw_admin1','admin1@gmail.com','nome_admin1');
INSERT INTO administrador (utilizador_id) SELECT id FROM utilizador WHERE nome = 'nome_admin1';

--INSERT SELLER
INSERT INTO utilizador (username,password,mail,nome) VALUES ('user_vendedor1','pw_vendedor1','vendedor1@gmail.com','nome_vendedor1');
INSERT INTO vendedor (nif,pais,cidade,rua,utilizador_id) SELECT 594837264,'Portugal','Coimbra','Rua da Baixa',id FROM utilizador WHERE nome = 'nome_vendedor1';