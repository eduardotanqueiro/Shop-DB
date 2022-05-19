--- check if token is valid
create or replace procedure check_token_type(token_in login_token.token%type,utilizador_in login_token.utilizador_id%type)
language plpgsql
as $$
declare
begin
PERFORM utilizador_id from login_token
where token=token_in and utilizador_id=utilizador_in;
if not found then
    raise exception 'Token invalid!';
end if;
end;
$$;


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
    dat_inicio campanha.data_inicio%type;
    dat_fim campanha.data_fim%type;

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
        select campanha.desconto,campanha.data_inicio,campanha.data_fim into percentagem_desconto,dat_inicio,dat_fim;
        from campanha
        where campanha.id = (select campanha_id from cupao where id = id_cupao_var);

        if current_date < dat_inicio or current_date > dat_fim then
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
$$;


---GET PRODUTCT (PRECISA DE ALTERACOES VER MAX VERSAO E + INFORMACOES )
create or replace function get_product_id(id_produto integer)
returns json
language plpgsql
as $$
declare
    prod_return json;
    json_aux json;
    precos TEXT[];
    comentarios TEXT[];
    r TEXT;
    max_version produto.versao%type;

    cursor_avg_rating cursor (id_p integer) for
        select row_to_json(a) from (
            select avg(classificacao) as "media rating" from rating
            group by produto_id having produto_id=id_p
            ) as a;
    
    

begin

    --ir buscar versão do produto a pesquisar
    select max(produto.versao)into max_version from produto
    group by produto.id having produto.id=id_produto;
    if not found then 
        raise notice 'id produto nao encontrado';
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
        for r in 
            select texto from comentario
            where produto_id=id_produto
            LOOP
                comentarios=comentarios||r;
            END LOOP;
        for r in
            select descricao from rating
            where produto_id = id_produto
            loop comentarios = comentarios||r;
            end loop;
        prod_return=prod_return::jsonb||json_build_object('comentarios',comentarios)::jsonb;

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
        for r in 
            select texto from comentario
            where produto_id=id_produto
            LOOP
                comentarios=comentarios||r;
            END LOOP;
			for r in
            select descricao from rating
            where produto_id = id_produto
            loop comentarios = comentarios||r;
            end loop;
        prod_return=prod_return::jsonb||json_build_object('comentarios',comentarios)::jsonb;
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
        for r in 
            select texto from comentario
            where produto_id=id_produto
            LOOP
                comentarios=comentarios||r;
            END LOOP;
			for r in
            select descricao from rating
            where produto_id = id_produto
            loop comentarios = comentarios||r;
            end loop;
        prod_return=prod_return::jsonb||json_build_object('comentarios',comentarios)::jsonb;
        return prod_return;
    end if;
end;
$$;

--- INSERT CAMPAIGN PROCEDURE
-- verificar ao inserir campanha se data de inicio maior do q todas as outras datas de fim
create or replace function insert_campaign(descon campanha.desconto%type, n_cupoes campanha.numero_cupoes%type, data_ini campanha.data_inicio%type, data_f campanha.data_fim%type,validade_cup campanha.validade_cupao%type, admin_id campanha.administrador_utilizador_id%type)
returns integer
language plpgsql
as $$
declare 
	
	data_final campanha.data_fim%type;
	id_campanha campanha.id%type;
begin    
    
    --verificar se a campanha que estamos a inserir entra em conflito com outra
    select data_fim into data_final
    from campanha
    where (data_ini >= data_inicio and data_ini <= data_fim) or (data_f >= data_inicio and data_f <= data_fim);
    if found then raise exception 'ERRO: Data da campanha a inserir entra em conflito com campanhas existentes';
    end if;
    
    --inserir campanha 
    
    insert into campanha(desconto,numero_cupoes,data_inicio,data_fim,validade_cupao,administrador_utilizador_id) values (descon,n_cupoes,data_ini,data_f,validade_cup,admin_id) returning id into id_campanha;
	return id_campanha;
     
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
    data_fim_campaign campanha.data_fim%type;

    cur_cupao_maximo cursor for
    select MAX(numero)
    from cupao
    group by campanha_id having campanha_id=campaign_id;

    cur_procura_campanha cursor for
    select numero_cupoes,data_fim
    from campanha
    where id=campaign_id and current_date >= data_inicio and current_date <= data_fim; --ver se a data de hoje esta entre as datas

    cur_check_coupouns cursor (camp_id INTEGER) for
        select COUNT(*)
        from customer_cupao
        where id_cupao in (select id from cupao where cupao.campanha_id = camp_id)
        group by customer_utilizador_id;


begin
open cur_procura_campanha;
fetch cur_procura_campanha
into numero_cupoes_permitidos, data_fim_campaign;
close cur_procura_campanha;

if not found then 
    -- campanha nao exixte
    return json_build_object('error','campanha nao encontrada'); --erro

elsif data_fim_campaign < current_date  then
    --campanha já passou o dia de fim
    return json_build_object('error','campanha já está inativa'); --erro

else
    open cur_cupao_maximo;
    fetch cur_cupao_maximo
    into n_cupao_maximo;
    close cur_cupao_maximo;

    --verificar se o user já tem cupao daquela campanha
    open cur_check_coupouns(campaign_id);
    fetch cur_check_coupouns into nr_cupoes_atribuidos_campanha;

    if nr_cupoes_atribuidos_campanha is not NULL then
        return json_build_object('error','o user já subscreveu esta campanha!'); --erro
    end if;
    close cur_check_coupouns;

    --quando ainda não foi atribuído nenhum cupão
    if n_cupao_maximo is NULL then
        n_cupao_maximo = 0;
    end if;

    if (n_cupao_maximo+1<=numero_cupoes_permitidos) then
        insert into cupao(numero,cupao_ativo,data_atribuicao,campanha_id) values(n_cupao_maximo+1,'true',current_date,campaign_id) returning id into id_cupao_var_maximo;
        insert into customer_cupao (customer_utilizador_id,id_cupao) values (customer_id,id_cupao_var_maximo);

        return json_build_object('campanha subscrita id_cupao_var',id_cupao_var_maximo); --erro
    else
        return json_build_object('error','campanha nao pode ser subscrita, maximo cupoes'); 
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


end;
$$;

create or replace function update_product_id(id_produto integer, detalhes_update json, vendedor_id integer)
returns json
language plpgsql
as $$
declare
    prod_details json;
    max_version integer;
	keys_aux text;
begin

    --ir buscar versão do produto a pesquisar
    select max(produto.versao) into max_version from produto
    where produto.vendedor_utilizador_id=vendedor_id and produto.id=id_produto;
    if max_version is null then 
        raise exception 'Id produto nao encontrado para este vendedor';
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
    vendedores_json json:='{}'::json;
	texto_notificacao varchar(512) := CONCAT('User ',new.customer_utilizador_id,' comprou:');
	vendedor_text text;
	
    cur_produtos_comprados cursor (id_compra INTEGER)for
        select produto_id,quantidade,produto.vendedor_utilizador_id
        from transacao_compra,produto
        where compra_id = id_compra and produto_id = produto.id;
begin 

    open cur_produtos_comprados(new.id);

    loop

        fetch cur_produtos_comprados into id_prod,quantidade_prod,vendedor_id;
        exit when not found;

        vendedor_text=cast(vendedor_id as text);
		
        --TODO FAZER NOTIFICAÇÃO PARA CADA VENDEDOR COM JSON

        if vendedores_json->vendedor_text is NULL then
		    vendedores_json=vendedores_json::jsonb || json_build_object(vendedor_text,concat('  produto:',id_prod, ' quantidade:',quantidade_prod))::jsonb ;
        else 
			vendedores_json = vendedores_json::jsonb || json_build_object(vendedor_text,concat(vendedores_json->>vendedor_text , concat('  produto:',id_prod, 'quantidade:',quantidade_prod)))::jsonb ;
        end if;

        texto_notificacao = CONCAT( texto_notificacao, ' produto:',id_prod, ' quantidade:',quantidade_prod,',');
    end loop;

    --notificacao customer
    insert into notificacao_compra(descricao,lida,data_notificacao,user_id) values (texto_notificacao,0,current_date,new.customer_utilizador_id);


    for vendedor_text in 
        select json_object_keys(vendedores_json)
    LOOP
        insert into notificacao_compra(descricao,lida,data_notificacao,user_id) values (vendedores_json->>vendedor_text,0,current_date,cast(vendedor_text as INTEGER));
    END LOOP;

	return new;
end;
$$;

create trigger trig_compra
after update on compra
for each row
execute procedure notificacao_compra();

--stats 12 meses
create or replace function stats_year(year_in INTEGER)
returns json
language plpgsql
as $$
begin
    return json_agg(t) from (
                                    select extract(month from compra.data_compra) as "Month", COUNT(*) as "orders", SUM(compra.valor_pago) as "total_value"
                                    from compra
						 			where extract(year from compra.data_compra)=year_in
                                    GROUP BY extract(month from compra.data_compra)
                                    ) AS t;

end;
$$;


--get notificaçoes
create or replace function get_notifications(id_user utilizador.id%type)
returns jsonb[]
language plpgsql
as $$
declare
	
	notificacao_row json;
	all_notifications jsonb[];
    
begin

	for notificacao_row in 
				select row_to_json(a) from (select data_notificacao,descricao 
				from notificacao_compra
				where user_id = id_user and lida = 0
				union
				select data_notificacao,descricao 
				from notificacao_comentario
				where user_id = id_user  and lida = 0) as a
	loop
		all_notifications = array_append(all_notifications, notificacao_row::jsonb);
	end loop;


    --Set notificacoes como lidas
    update notificacao_compra set lida = 1 where user_id = id_user and lida = 0;
    update notificacao_comentario set lida = 1 where user_id = id_user and lida = 0;
	
    return all_notifications;
end;
$$;
	
--create a new comment
create or replace function make_comment(id_product produto.id%type, id_last_comment comentario.id_anterior%type, id_user utilizador.id%type, comment comentario.texto%type )
returns INTEGER
language plpgsql
as $$
declare
    id_vendedor utilizador.id%type;
    version produto.versao%type;
    id_new_comment comentario.id%type;

    c_check_product cursor(id_prod produto.id%type) for
        select vendedor_utilizador_id,MAX(versao)
        from produto
        where produto.id = id_prod
        group by vendedor_utilizador_id;

begin

    --check if product exists
    open c_check_product(id_product);
    fetch c_check_product into id_vendedor,version;
    if not found then raise EXCEPTION 'Product does not exist!';
    end if;
    close c_check_product;

    --insert into comments table
    if id_last_comment = -1 then
        insert into comentario (id_anterior,texto,utilizador_id,vendedor_utilizador_id,produto_id,produto_versao) values (NULL,comment,id_user,id_vendedor,id_product,version) returning id into id_new_comment;
    else
        insert into comentario (id_anterior,texto,utilizador_id,vendedor_utilizador_id,produto_id,produto_versao) values (id_last_comment,comment,id_user,id_vendedor,id_product,version) returning id into id_new_comment;
    end if;
	
	return id_new_comment;
end;
$$;

--trigger notificação comentario
create or replace function notificacao_comentario() returns trigger
language plpgsql
as $$
declare
    parent_question_user comentario.utilizador_id%type;

begin 

    --notificacao vendedor
    insert into notificacao_comentario(descricao,lida,data_notificacao,user_id,comentario_id) values (concat('Comentaram no teu produto com id ',new.produto_id,': ',new.texto),0,current_date,new.vendedor_utilizador_id,new.id);

    --verificar se é uma resposta a outro comentario, se sim, notificar o utilizador do comentario anterior
    if new.id_anterior is not NULL then
        select utilizador_id into parent_question_user from comentario where comentario.id_anterior = new.id_anterior;
        insert into notificacao_comentario(descricao,lida,data_notificacao,user_id,comentario_id) values (concat('Responderam ao teu comentario no produto ',new.produto_id,': ',new.texto),0,current_date,parent_question_user,new.id);
    end if;

	return new;
end;
$$;

create trigger trig_comment
after insert on comentario
for each row
execute procedure notificacao_comentario();



create or replace function stats_campaign()
returns json
language plpgsql
as $$
begin
    return json_agg(t) from (
        select distinct t1.id as "campaign_id", coalesce(max(t2.numero),0) as "generated_coupons", count(t3.id_cupao) as "used_coupons", coalesce(sum(t4.valor_do_desconto),0) as "total_discount_value"
                from campanha as t1
                left join cupao  as t2 on t1.id = t2.campanha_id
                left join compra_cupao as t3 on  t2.id = t3.id_cupao
                left join compra as t4 on t3.id_compra = t4.id 
                group by t1.id
                --t2 cupao
                --t3 compra cupao
                --t4 compra         
     ) AS t;

end;
$$;