--- check user type
create or replace function check_user_type(user_id utilizador.id%type)
returns text
language plpgsql
as $$
declare
begin
PERFORM utilizador_id from customer 
where utilizador_id=user_id;
if found then return 'custumer';
end if;

PERFORM utilizador_id from administrador
where utilizador_id=user_id;
if found then return 'administrador';
end if;

PERFORM utilizador_id from vendedor
where utilizador_id=user_id;
if found then return 'vendedor';
end if;
end;
$$;


create or replace procedure insert_customer(username utilizador.username%type, pw utilizador.password%type, mail utilizador.mail%type, nome utilizador.nome%type, pais customer.pais%type, cidade customer.cidade%type, rua customer.rua%type )
language plpgsql
as $$
declare
    id_inserido INT;

    cur_id cursor (uname utilizador.username%type) for
        select id
        from utilizador
        where utilizador.username = uname;
begin

    --inserir na tabela users
    insert into utilizador(username,password,mail,nome) values (username,pw,mail,nome);

    --buscar id inserido
    open cur_id(username);
    fetch cur_id
    into id_inserido;
    close cur_id;

    --inserir na tabela dos customers
    insert into customer(utilizador_id,pais,cidade,rua) values (id_inserido,pais,cidade,rua);

end;
$$;


create or replace procedure insert_smartphone(descricao produto.descricao%type, preco produto.preco%type, stock produto.stock%type, vendedor_user_id produto.vendedor_utilizador_id%type, tamanho smartphone.tamanho%type, marca smartphone.marca%type, ram smartphone.ram%type, rom smartphone.rom%type)
language plpgsql
as $$
declare
    id_max produto.id%type;

    cur_max_id cursor for
        select MAX(id)
        from produto;

begin

    --ir buscar o ultimo id inserido
    open cur_max_id;
    fetch cur_max_id
    into id_max;
    close cur_max_id;

    if id_max IS NOT NULL then

        --inserir na tabela produto
        insert into produto(id,descricao,preco,stock,versao,vendedor_utilizador_id) values (id_max+1,descricao,preco,stock,1,vendedor_user_id);

        --inserir na tabela smartphone
        insert into smartphone(tamanho,marca,ram,rom,produto_id,produto_versao) values (tamanho,marca,ram,rom,id_max +1,1);
    
    else

        --inserir na tabela produto
        insert into produto(id,descricao,preco,stock,versao,vendedor_utilizador_id) values (0,descricao,preco,stock,1,vendedor_user_id);

        --inserir na tabela smartphone
        insert into smartphone(tamanho,marca,ram,rom,produto_id,produto_versao) values (tamanho,marca,ram,rom,0,1);

    end if;
end;
$$;

create or replace procedure insert_tv(descricao produto.descricao%type, preco produto.preco%type, stock produto.stock%type, vendedor_user_id produto.vendedor_utilizador_id%type, tamanho tv.tamanho%type, marca tv.marca%type)
language plpgsql
as $$
declare
    id_max produto.id%type;

    cur_max_id cursor for
        select MAX(id)
        from produto;

begin

    --ir buscar o ultimo id inserido
    open cur_max_id;
    fetch cur_max_id
    into id_max;

    if id_max IS NOT NULL then
        
        --inserir na tabela produto
        insert into produto(id,descricao,preco,stock,versao,vendedor_utilizador_id) values (id_max+1,descricao,preco,stock,1,vendedor_user_id);

        --inserir na tabela tv
        insert into tv(tamanho,marca,produto_id,produto_versao) values (tamanho,marca,id_max +1,1);
    
    else
        --inserir na tabela produto
        insert into produto(id,descricao,preco,stock,versao,vendedor_utilizador_id) values (0,descricao,preco,stock,1,vendedor_user_id);

        --inserir na tabela tv
        insert into tv(tamanho,marca,produto_id,produto_versao) values (tamanho,marca,0,1);

    end if;

    close cur_max_id;

end;
$$;

create or replace procedure insert_pc(descricao produto.descricao%type, preco produto.preco%type, stock produto.stock%type, vendedor_user_id produto.vendedor_utilizador_id%type, cpu pc.cpu%type, ram pc.ram%type, rom pc.rom%type, marca pc.marca%type)
language plpgsql
as $$
declare
    id_max produto.id%type;

    cur_max_id cursor for
        select MAX(id)
        from produto;

begin

    --ir buscar o ultimo id inserido
    open cur_max_id;
    fetch cur_max_id
    into id_max;
    close cur_max_id;

    if id_max IS NOT NULL then

        --inserir na tabela produto
        insert into produto(id,descricao,preco,stock,versao,vendedor_utilizador_id) values (id_max+1,descricao,preco,stock,1,vendedor_user_id);

        --inserir na tabela pc
        insert into pc(cpu,ram,rom,marca,produto_id,produto_versao) values (cpu,ram,rom,marca,id_max +1,1);

    else
        --inserir na tabela produto
        insert into produto(id,descricao,preco,stock,versao,vendedor_utilizador_id) values (0,descricao,preco,stock,1,vendedor_user_id);

        --inserir na tabela pc
        insert into pc(cpu,ram,rom,marca,produto_id,produto_versao) values (cpu,ram,rom,marca,0,1);
    end if;

end;
$$;


--NÃO ESTÁ ACABADO/REFAZER
create or replace procedure make_order(customer_id utilizador.id%type, cart numeric[][])
language plpgsql
as $$
declare
    nr_produtos NUMERIC(10,0);

    id_compra INTEGER;
    total_compra compra_notificacao.valor_pago%type;

    versao_prod produto.versao%type;
    preco_prod produto.preco%type;
    stock_prod produto.stock%type;

    cur_id_compra cursor for
        select MAX(id)
        from compra_notificacao
        for update;

    cur_info_prod cursor(id_prod INTEGER) for
        select MAX(versao), preco, stock
        from produto;
        where produto.id = id_prod;

begin

    nr_produtos = array_lenght(cart,1);

    --gerar nova compra
    insert into compra_notificacao(data_compra,valor_pago,valor_do_desconto,customer_utilizador_id,notificacao_descricao) values (,0,0,customer_id,"");

    open cur_id_compra;
    fetch cur_id_compra into id_compra;
    close cur_id_compra;


    if nr_produtos > 0 then

        --Correr todos os produtos
        for i in 1..nr_produtos loop

            --ir buscar versao do produto e o preco
            open cur_info_prod( cart[i][1] );
            fetch cur_id_compra into versao_prod,preco_prod,stock_prod;
            close cur_info_prod;

            --check se o produto existe/verificar stock

            --insert tabela transacao
            insert into transacao_compra(quantidade,compra_id,produto_id,produto_versao) values ( cart[i][2], id_compra, cart[i][1] , versao_prod);

            --atualizar stock do produto

        end loop


    --atualizar informacoes da compra
    


end:
$$


---GET PRODUTCT (PRECISA DE ALTERACOES VER MAX VERSAO E + INFORMACOES )
create or replace function get_product_id(id_produto integer)
returns json
language plpgsql
as $$
declare
prod_return json;
json_aux json;
max_version produto.versao%type;
cursor_avg_rating cursor (id_p integer) for
select row_to_json(a) from (
  select avg(classificacao)"media_rating" from rating
  group by produto_id having produto_id=id_p
) as a;
begin
select max(produto.versao) into max_version from produto
group by produto.id having produto.id=id_produto;
if not found then return json_build_object('error','id produto nao encontrado');
end if;

select row_to_json(a) into prod_return from (
	select * from produto join tv on produto.id=tv.produto_id and produto.versao=tv.produto_versao
	where produto.id=id_produto and produto.versao=max_version
) as a;
if found then
    open cursor_avg_rating (id_produto);
    fetch cursor_avg_rating into json_aux;
    if found then prod_return=prod_return::jsonb||json_aux::jsonb;
    end if;
    close cursor_avg_rating;
    return prod_return;
end if;

select row_to_json(a) into prod_return from (
	select * from produto join smartphone on produto.id=smartphone.produto_id and produto.versao=smartphone.produto_versao
	where produto.id=id_produto and produto.versao=max_version
) as a;
if found then 
    open cursor_avg_rating (id_produto);
    fetch cursor_avg_rating into json_aux;
    if found then prod_return=prod_return::jsonb||json_aux::jsonb;
    end if;
    close cursor_avg_rating;
    return prod_return;
end if;

select row_to_json(a) into prod_return from (
	select * from produto join pc on produto.id=pc.produto_id and produto.versao=pc.produto_versao
	where produto.id=id_produto and produto.versao=max_version
) as a;
if found then
    open cursor_avg_rating (id_produto);
    fetch cursor_avg_rating into json_aux;
    if found then prod_return=prod_return::jsonb||json_aux::jsonb;
    end if;
    close cursor_avg_rating;
    return prod_return;
end if;

end;
$$;

--- INSERT CAMPAIGN PROCEDURE
create or replace procedure insert_campaign(desconto campanha.desconto%type, numero_cupoes campanha.numero_cupoes%type, data_inicio campanha.data_inicio%type, data_fim campanha.data_fim%type,validade_cupao campanha.validade_cupao%type, admin_id campanha.administrador_utilizador_id)
language plpgsql
as $$
begin
        update campanha_aux set campanha_ativa='false' where id = (select id from campanha_aux where campanha_ativa='true');
        insert into campanha(desconto,numero_cupoes,data_inicio,data_fim,campanha_ativa,validade_cupao,administrador_utilizador_id) values (desconto,numero_cupoes,data_inicio,data_fim,'True',validade_cupao,admin_id);        
end;
$$;
--- SUBSCRIBE CAMPAIGN
create or replace function subscribe_campaign(campaign_id cupao.campanha%type,data_atribuicao cupao.data_atribuicao%type,customer_id customer_cupao.customer_utilizador_id%type)
returns BOOLEAN
language plpgsql
as $$
declare
n_cupao_maximo cupao.cupao_numero%type;
numero_cupoes_permitidos campanha.numero_cupoes%type;

cur_cupao_maximo cursor for
select MAX(numero)
from cupao
group by id having id=campaign_id;

cur_procura_campanha cursor for
select numero_cupoes
from campanha
where id=campaign_id and campanha_ativa=True;

begin
open cur_procura_campanha;
fetch cur_procura_campanha
into numero_cupoes_permitidos;
close cur_procura_campanha;

if not found then 
    return false;
else
    open cur_cupao_maximo;
    fetch cur_cupao_maximo
    into n_cupao_maximo;
    close cur_cupao_maximo;

    if (n_cupao_maximo+1<=numero_cupoes_permitidos) then
        insert into cupao(numero,cupao_ativo,data_atribuicao,campanha_id) values(n_cupao_maximo+1,'True',select current_date,campaign_id);
        insert into customer_cupao (customer_utilizador_id,cupao_numero,cupao_campanha_id) values (customer_id,n_cupao_maximo+1,campaign_id);
        return true;
    else return false;
    end if;
end if;
end;
$$;
