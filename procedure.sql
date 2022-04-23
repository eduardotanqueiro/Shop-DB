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

--- INSERT CAMPAIGN PROCEDURE
create or replace procedure insert_campaign(desconto campanha.desconto%type, numero_cupoes campanha.numero_cupoes%type, data_inicio campanha.data_inicio%type, data_fim campanha.data_fim%type,validade_cupao campanha.validade_cupao%type, admin_id campanha.administrador_utilizador_id)
language plpgsql
as $$
declare
    id_max campanha.id%type;

    cur_max_id cursor for
        select MAX(id)
        from campanha;
begin

    --ir buscar o ultimo id inserido
    open cur_max_id;
    fetch cur_max_id
    into id_max;
    close cur_max_id;

    if id_max IS NOT NULL then
        -- campanha que esteja ativa passa a falsa
        update campanha_aux set campanha_ativa='false' where id = (select id from campanha_aux where campanha_ativa='true');
        --inserir na tabela campanha
        insert into campanha(id,desconto,numero_cupoes,data_inicio,data_fim,campanha_ativa,validade_cupao,administrador_utilizador_id) values (id_max+1,desconto,numero_cupoes,data_inicio,data_fim,'True',validade_cupao,admin_id);        
    else
        insert into campanha(id,desconto,numero_cupoes,data_inicio,data_fim,campanha_ativa,validade_cupao,administrador_utilizador_id) values (0,desconto,numero_cupoes,data_inicio,data_fim,'True',validade_cupao,admin_id);        

    end if;

end;
$$;

