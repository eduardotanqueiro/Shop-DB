--- check user type
create or replace function check_user_type(user_id utilizador.id%type)
returns text
language plpgsql
as $$
declare
begin
PERFORM utilizador_id from customer 
where utilizador_id=user_id;
if found then return 'customer';
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


create or replace function insert_customer(username utilizador.username%type, pw utilizador.password%type, mail utilizador.mail%type, nome utilizador.nome%type, pais customer.pais%type, cidade customer.cidade%type, rua customer.rua%type )
returns integer
language plpgsql
as $$
declare
    id_inserido INT;

begin

    --inserir na tabela users
    insert into utilizador(username,password,mail,nome) values (username,pw,mail,nome) returning id into id_inserido;

    --inserir na tabela dos customers
    insert into customer(utilizador_id,pais,cidade,rua) values (id_inserido,pais,cidade,rua);

    return id_inserido;
end;
$$;

create or replace function insert_vendedor(username utilizador.username%type, pw utilizador.password%type, mail utilizador.mail%type, nome utilizador.nome%type, pais customer.pais%type, cidade customer.cidade%type, rua customer.rua%type )
returns integer
language plpgsql
as $$
declare
    id_inserido INT;

begin

    --inserir na tabela users
    insert into utilizador(username,password,mail,nome) values (username,pw,mail,nome) returning id into id_inserido;

    --inserir na tabela dos customers
    insert into vendedor(utilizador_id,pais,cidade,rua) values (id_inserido,pais,cidade,rua);

    return id_inserido;
end;
$$;

create or replace function insert_admin(username utilizador.username%type, pw utilizador.password%type, mail utilizador.mail%type, nome utilizador.nome%type)
returns integer
language plpgsql
as $$
declare
    id_inserido INT;

begin

    --inserir na tabela users
    insert into utilizador(username,password,mail,nome) values (username,pw,mail,nome) returning id into id_inserido;

    --inserir na tabela dos customers
    insert into admin(utilizador_id) values (id_inserido);

    return id_inserido;
end;
$$;


create or replace function insert_smartphone(descricao produto.descricao%type, preco produto.preco%type, stock produto.stock%type, vendedor_user_id produto.vendedor_utilizador_id%type, tamanho smartphone.tamanho%type, marca smartphone.marca%type, ram smartphone.ram%type, rom smartphone.rom%type)
returns integer
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

        return id_max+1;
    else

        --inserir na tabela produto
        insert into produto(id,descricao,preco,stock,versao,vendedor_utilizador_id) values (0,descricao,preco,stock,1,vendedor_user_id);

        --inserir na tabela smartphone
        insert into smartphone(tamanho,marca,ram,rom,produto_id,produto_versao) values (tamanho,marca,ram,rom,0,1);
        return 0;

    end if;

end;
$$;

create or replace function insert_tv(descricao produto.descricao%type, preco produto.preco%type, stock produto.stock%type, vendedor_user_id produto.vendedor_utilizador_id%type, tamanho tv.tamanho%type, marca tv.marca%type)
returns integer
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

        return id_max+1;    
    else
        --inserir na tabela produto
        insert into produto(id,descricao,preco,stock,versao,vendedor_utilizador_id) values (0,descricao,preco,stock,1,vendedor_user_id);

        --inserir na tabela tv
        insert into tv(tamanho,marca,produto_id,produto_versao) values (tamanho,marca,0,1);

        return 0;
    end if;

    close cur_max_id;

end;
$$;

create or replace function insert_pc(descricao produto.descricao%type, preco produto.preco%type, stock produto.stock%type, vendedor_user_id produto.vendedor_utilizador_id%type, cpu pc.cpu%type, ram pc.ram%type, rom pc.rom%type, marca pc.marca%type)
returns integer
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

        return id_max+1;
    else
        --inserir na tabela produto
        insert into produto(id,descricao,preco,stock,versao,vendedor_utilizador_id) values (0,descricao,preco,stock,1,vendedor_user_id);

        --inserir na tabela pc
        insert into pc(cpu,ram,rom,marca,produto_id,produto_versao) values (cpu,ram,rom,marca,0,1);

        return 0;
    end if;

end;
$$;



create or replace function make_order(customer_id utilizador.id%type, cart_json json, id_cupao_var INTEGER)
returns integer
language plpgsql
as $$
declare

    id_compra INTEGER;
    total_compra compra.valor_pago%type;

    id_prod_cart produto.id%type;
    quantidade_prod INTEGER;

    versao_prod produto.versao%type;
    preco_prod produto.preco%type;
    stock_prod produto.stock%type;

    data_compra compra.data_compra%type;

    percentagem_desconto campanha.desconto%type;
    campanha_ativa campanha.campanha_ativa%type;

    cur_id_compra cursor for
        select MAX(id)
        from compra;

    cur_info_prod cursor(id_prod INTEGER) for
        select MAX(versao), preco, stock
        from produto
        where produto.id = id_prod
        group by produto.id,preco,stock;

    cur_prod_cart cursor(cart_js JSON) for
        select * from json_each(cart_js);

begin   

    --gerar nova compra
    select current_date into data_compra;
    insert into compra(data_compra,valor_pago,valor_do_desconto,customer_utilizador_id) values (data_compra,1,0,customer_id);
	total_compra = 0;

    --fazer compra
    open cur_id_compra;
    fetch cur_id_compra into id_compra;
    close cur_id_compra;

    open cur_prod_cart(cart_json);

    --Correr todos os produtos
    loop

        --proximo produto no carrinho
        fetch cur_prod_cart into id_prod_cart,quantidade_prod; 
        exit when not found;

        if quantidade_prod = 0 then
            raise EXCEPTION 'You can''t buy 0 units of a product!';
        end if;

        --ir buscar versao do produto e o preco
        open cur_info_prod( id_prod_cart );
        fetch cur_info_prod into versao_prod,preco_prod,stock_prod;

        IF NOT FOUND THEN --ERRO, PRODUTO NÃO EXISTE
            RAISE EXCEPTION 'Product % doesn''t exist!', id_prod_cart;
        END IF;

        close cur_info_prod;


        --verificar stock
        if stock_prod = 0 then
            RAISE EXCEPTION 'Product % does not have any stock!', id_prod_cart;
        elsif stock_prod - quantidade_prod  < 0 then
            RAISE EXCEPTION 'Product % only has % stock, and you tried to order %!', id_prod_cart, stock_prod, quantidade_prod;
        end if;


        --insert tabela transacao
        insert into transacao_compra(quantidade,compra_id,produto_id,produto_versao) values ( quantidade_prod, id_compra, id_prod_cart , versao_prod);

        --atualizar stock do produto
        update produto set stock = stock - quantidade_prod where id = id_prod_cart and versao = (SELECT MAX(versao) FROM produto where id = id_prod_cart);

        --total da compra
        total_compra = total_compra + preco_prod * quantidade_prod;

    end loop;

    close cur_prod_cart;


    --verificar cupao e atualizar informacoes da compra
    if id_cupao_var = -1 then --sem cupao
        update compra set valor_pago = total_compra,valor_do_desconto = 0 where compra.id = id_compra;
    else
        --com cupao

        --verificar se o cupao existe/pertence ao user
        if not EXISTS( select from customer_cupao where customer_utilizador_id = customer_id and customer_cupao.id_cupao = id_cupao_var) then
            --cupao nao existe ou nao pertence ao utilizador que o introduziu
            raise EXCEPTION 'Given coupon doesn''t exist or doesn''t belong to the user!';
        end if;

        --meter o cupao como usado
        update cupao set cupao_ativo = 'false' where cupao.id = id_cupao_var;

        --cupao existe e pertence ao user
        --verificar desconto/campanha
        select campanha.desconto,campanha.campanha_ativa into percentagem_desconto,campanha_ativa
        from campanha
        where campanha.id = (select campanha_id from cupao where id = id_cupao_var);

        if campanha_ativa is FALSE then
            --campanha inativa
            raise EXCEPTION 'Campaing is not active!';
        end if;

        --inserir na tabela compra-cupao (associar o cupao à compra)
        insert into compra_cupao(id_compra,id_cupao) values (id_compra,id_cupao_var);

        --update das informaçoes da compra
        update compra set valor_pago = total_compra*(1-percentagem_desconto::float/100),valor_do_desconto = total_compra*(percentagem_desconto::float/100) where compra.id = id_compra;

    end if;

    return id_compra;
end;
$$


---GET PRODUTCT (PRECISA DE ALTERACOES VER MAX VERSAO E + INFORMACOES )
create or replace function get_product_id(id_produto integer)
returns json
language plpgsql
as $$
declare
    prod_return json;
    json_aux json;
    precos TEXT[];
    r TEXT;
    max_version produto.versao%type;

    cursor_avg_rating cursor (id_p integer) for
        select row_to_json(a) from (
            select avg(classificacao) from rating
            group by produto_id having produto_id=id_p
            ) as a;

begin

    --ir buscar versão do produto a pesquisar
    select max(produto.versao)into max_version from produto
    group by produto.id having produto.id=id_produto;
    if not found then return json_build_object('error','id produto nao encontrado');
    end if;

    --verificar se é do tipo TV
    select row_to_json(a) into prod_return from (
        select id,descricao,preco,stock,versao,marca,tamanho from produto join tv on produto.id=tv.produto_id and produto.versao=tv.produto_versao
        where produto.id=id_produto and produto.versao=max_version
    ) as a;
    if found then
        open cursor_avg_rating (id_produto);
        fetch cursor_avg_rating into json_aux;
        if found then prod_return=prod_return::jsonb||json_aux::jsonb;
        end if;
        close cursor_avg_rating;
        for r in 
            select concat('versao',versao,' ',preco) from produto
            where produto.id=id_produto
            order by produto.versao DESC
            LOOP
            precos=precos||r;
            END LOOP;
        prod_return=json_build_object('precos',precos)::jsonb||prod_return::jsonb;
        return prod_return;
    end if;

    --- verificar se e smartphone
    select row_to_json(a) into prod_return from (
        select id, descricao,preco,stock,versao,marca,tamanho,rom,ram from produto join smartphone on produto.id=smartphone.produto_id and produto.versao=smartphone.produto_versao
        where produto.id=id_produto and produto.versao=max_version
    ) as a;
    if found then
        open cursor_avg_rating (id_produto);
        fetch cursor_avg_rating into json_aux;
        if found then prod_return=prod_return::jsonb||json_aux::jsonb;
        end if;
        close cursor_avg_rating;
        for r in 
            select concat('versao',versao,' ',preco) from produto
            where produto.id=id_produto
            order by produto.versao DESC
            LOOP
            precos=precos||r;
            END LOOP;
        prod_return=prod_return::jsonb||json_build_object('precos',precos)::jsonb;
        return prod_return;
    end if;

    --- verificar se e pc
    select row_to_json(a) into prod_return from (
        select id, descricao,preco,stock,versao,marca,cpu,rom,ram from produto join pc on produto.id=pc.produto_id and produto.versao=pc.produto_versao
        where produto.id=id_produto and produto.versao=max_version
    ) as a;
    if found then
        open cursor_avg_rating (id_produto);
        fetch cursor_avg_rating into json_aux;
        if found then prod_return=prod_return::jsonb||json_aux::jsonb;
        end if;
        close cursor_avg_rating;
        for r in 
            select concat('versao',versao,' ',preco) from produto
            where produto.id=id_produto
            order by produto.versao DESC
            LOOP
            precos=precos||r;
            END LOOP;
        prod_return=prod_return::jsonb||json_build_object('precos',precos)::jsonb;
        return prod_return;
    end if;
end;
$$;

--- INSERT CAMPAIGN PROCEDURE
create or replace function insert_campaign(desconto campanha.desconto%type, numero_cupoes campanha.numero_cupoes%type, data_inicio campanha.data_inicio%type, data_fim campanha.data_fim%type,validade_cupao campanha.validade_cupao%type, administrador_id campanha.administrador_utilizador_id%type)
returns integer
language plpgsql
as $$
begin	
        update campanha set campanha_ativa='false' where campanha.id = (select id from campanha where campanha_ativa='true');
        insert into campanha(desconto,numero_cupoes,data_inicio,data_fim,campanha_ativa,validade_cupao,administrador_utilizador_id) values (desconto,numero_cupoes,data_inicio,data_fim,'true',validade_cupao,administrador_id);        

        return (select MAX(id) from campanha);
end;
$$;

--- SUBSCRIBE CAMPAIGN
create or replace function subscribe_campaign(campaign_id campanha.id%type,customer_id customer_cupao.customer_utilizador_id%type)
returns json
language plpgsql
as $$
declare
    n_cupao_maximo cupao.numero%type;
    id_cupao_var_maximo cupao.id%type;
    numero_cupoes_permitidos campanha.numero_cupoes%type;
    nr_cupoes_atribuidos_campanha INTEGER;

    cur_cupao_maximo cursor for
    select MAX(numero)
    from cupao
    group by campanha_id having campanha_id=campaign_id;

    cur_procura_campanha cursor for
    select numero_cupoes
    from campanha
    where id=campaign_id and campanha_ativa='true';

    cur_check_coupouns cursor (camp_id INTEGER) for
        select COUNT(*)
        from customer_cupao
        where id_cupao_var in (select id from cupao where cupao.campanha_id = camp_id)
        group by customer_utilizador_id;


begin
open cur_procura_campanha;
fetch cur_procura_campanha
into numero_cupoes_permitidos;
close cur_procura_campanha;

if not found then 
    return json_build_object('error','campanha nao encontrada');
else
    open cur_cupao_maximo;
    fetch cur_cupao_maximo
    into n_cupao_maximo;
    close cur_cupao_maximo;

    --verificar se o user já tem cupao daquela campanha
    open cur_check_coupouns(campaign_id);
    fetch cur_check_coupouns into nr_cupoes_atribuidos_campanha;

    if nr_cupoes_atribuidos_campanha is not NULL then
        return json_build_object('error','o user já subscreveu esta campanha!');
    end if;
    close cur_check_coupouns;

    --quando ainda não foi atribuído nenhum cupão
    if n_cupao_maximo is NULL then
        n_cupao_maximo = 0;
    end if;

    if (n_cupao_maximo+1<=numero_cupoes_permitidos) then
        insert into cupao(numero,cupao_ativo,data_atribuicao,campanha_id) values(n_cupao_maximo+1,'true',current_date,campaign_id) returning id into id_cupao_var_maximo;
        insert into customer_cupao (customer_utilizador_id,id_cupao_var) values (customer_id,id_cupao_var_maximo);
        return json_build_object('campanha subscrita id_cupao_var',id_cupao_var_maximo);
    else return json_build_object('error','campanha nao pode ser subscrita, maximo cupoes');
    end if;
end if;
end;
$$;

--Rate a product
create or replace procedure create_rating(utilizador_id compra.customer_utilizador_id%type, prod_id rating.produto_id%type, rating rating.classificacao%type, descricao rating.descricao%type)
language plpgsql
as $$
declare
    compra_id_search rating.compra_id%type;
    max_ver produto.versao%type;

begin
    

    --check se compra existe
    --escolhe a última compra sem rating
    select MAX(transacao_compra.compra_id) into compra_id_search from transacao_compra where produto_id = prod_id and transacao_compra.compra_id in (select id from compra where customer_utilizador_id = utilizador_id);
    if not found then raise EXCEPTION 'Compra nao encontrada';
    end if;

    select MAX(versao) into max_ver from produto where id = prod_id group by versao;

    --inserir na tabela rating
    insert into rating(classificacao,descricao,compra_id,customer_utilizador_id,produto_id,produto_versao) values(rating,descricao,compra_id_search,utilizador_id,prod_id,max_ver);


end,
$$;

create or replace function update_product_id(id_produto integer, detalhes_update json)
returns json
language plpgsql
as $$
declare
    prod_details json;
    max_version integer;
	keys_aux text;
begin
    --ir buscar versão do produto a pesquisar
    select max(produto.versao)into max_version from produto
    group by produto.id having produto.id=id_produto;
    if not found then return json_build_object('error','id produto nao encontrado');
    end if;

    --verificar se é do tipo TV
    select row_to_json(a) into prod_details from (
        select * from produto join tv on produto.id=tv.produto_id and produto.versao=tv.produto_versao
        where produto.id=id_produto and produto.versao=max_version
    ) as a;
    if found then 
		for keys_aux in 
			select json_object_keys(detalhes_update)
		LOOP
			prod_details=prod_details::jsonb||json_build_object(keys_aux,detalhes_update->>keys_aux)::jsonb;
		END LOOP;
        insert into produto(id,descricao,preco,stock,versao,vendedor_utilizador_id) values (id_produto,prod_details->>'descricao',
		cast(prod_details->>'preco' as FLOAT(8)),cast(prod_details->>'stock' as INTEGER),max_version+1,cast(prod_details->>'vendedor_utilizador_id' as INTEGER));
        insert into tv(tamanho,marca,produto_id,produto_versao) values 
		(cast(prod_details->>'tamanho' as  SMALLINT),cast(prod_details->>'marca' as VARCHAR(50)),id_produto,max_version+1);
	    return json_build_object('success','produto atualizado');
    end if;

    --- verificar se e smartphone
    select row_to_json(a) into prod_details from (
        select * from produto join smartphone on produto.id=smartphone.produto_id and produto.versao=smartphone.produto_versao
        where produto.id=id_produto and produto.versao=max_version
    ) as a;
    if found then
		for keys_aux in 
			select json_object_keys(detalhes_update)
		LOOP
			prod_details=prod_details::jsonb||json_build_object(keys_aux,detalhes_update->>keys_aux)::jsonb;
		END LOOP;
        insert into produto(id,descricao,preco,stock,versao,vendedor_utilizador_id) values (id_produto,prod_details->>'descricao',
		cast(prod_details->>'preco' as FLOAT(8)),cast(prod_details->>'stock' as INTEGER),max_version+1,cast(prod_details->>'vendedor_utilizador_id' as INTEGER));
        insert into smartphone(tamanho,marca,ram,rom,produto_id,produto_versao) values 
		(cast(prod_details->>'tamanho' as  SMALLINT),cast(prod_details->>'marca' as VARCHAR(50)),cast(prod_details->>'ram' as SMALLINT),
		 cast(prod_details->>'rom' as SMALLINT),id_produto,max_version+1);
	return json_build_object('success','produto atualizado');
    end if;

    -- verificar se e pc
    select row_to_json(a) into prod_details from (
        select * from produto join pc on produto.id=pc.produto_id and produto.versao=pc.produto_versao
        where produto.id=id_produto and produto.versao=max_version
    ) as a;
    if found then
		for keys_aux in 
			select json_object_keys(detalhes_update)
		LOOP
			prod_details=prod_details::jsonb||json_build_object(keys_aux,detalhes_update->>keys_aux)::jsonb;
		END LOOP;
        insert into produto(id,descricao,preco,stock,versao,vendedor_utilizador_id) values (id_produto,prod_details->>'descricao',
		cast(prod_details->>'preco' as FLOAT(8)),cast(prod_details->>'stock' as INTEGER),max_version+1,cast(prod_details->>'vendedor_utilizador_id' as INTEGER));
        insert into pc(cpu,ram,rom,marca,produto_id,produto_versao) values 
		(cast(prod_details->>'cpu' as  VARCHAR(60)),cast(prod_details->>'ram' as SMALLINT),cast(prod_details->>'rom' as SMALLINT),
		 cast(prod_details->>'marca' as VARCHAR(50)),id_produto,max_version+1);
	return json_build_object('sucess','produto atualizado');
    end if;
end;
$$;


--trigger notificação compra
create or replace function notificacao_compra() returns trigger
language plpgsql
as $$
declare
    id_prod produto.id%type;
    quantidade_prod INTEGER;
    vendedor_id produto.vendedor_utilizador_id%type;
	texto_notificacao varchar(512) := CONCAT('User ',new.id,' comprou:');
	
    cur_produtos_comprados cursor (id_compra INTEGER)for
        select produto_id,quantidade,produto.vendedor_utilizador_id
        from transacao_compra,produto
        where compra_id = id_compra and produto_id = produto.id;
begin 

    open cur_produtos_comprados(new.id);

    loop

        fetch cur_produtos_comprados into id_prod,quantidade_prod,vendedor_id;
        exit when not found;

        --TODO FAZER NOTIFICAÇÃO PARA CADA VENDEDOR COM JSON

        texto_notificacao = CONCAT( texto_notificacao, ' produto:',id_prod, 'quantidade:',quantidade_prod);
    end loop;

    --notificacao customer
    insert into notificacao_compra(descricao,lida,data_compra,user_id) values (texto_notificacao,0,current_date,new.id);
	
	return new;
end;
$$;

create trigger trig_compra
after update on compra
for each row
execute procedure notificacao_compra();

--stats 12 meses
create or replace function stats_year()
return json
as $$
begin

    return select json_agg(t) from (
                                    select DATE_TRUNC('month', compra.data_compra) as "Month", COUNT(*) as "orders", SUM(compra.valor_pago) as "total_value"
                                    from compra
                                    GROUP BY DATE_TRUNC('month', compra.data_compra) 
                                    ) AS t;

end;
$$;


--get notificaçoes
create or update function get_notifications(id_user utilizador.id%type)
returns json
language plpgsql
as $$
declare

    return_values json;

    cur_notifications cursor(id_us utilizador.id%type) for
        select row_to_json(a) from(
                    select descricao
                    from notificacao_compra
                    where user_id = id_us and lida = 0
                    union
                    select descricao
                    from notificacao_comentario
                    where user_id = id_us  and lida = 0);
        
begin

    open cur_notifications(id_user);
    fetch cur_notifications into return_values;
    close cur_notifications;

    --TODO por verificar
    update notificacao_compra set lida = 1 where user_id = 1 and lida = 0
    update notificacao_comentario set lida = 1 where user_id = 1 and lida = 0

    return return_values;
end;
$$;
