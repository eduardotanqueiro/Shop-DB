--- check user type
create or replace function check_user_type(user_id utilizador.id%type)
returns VARCHAR
language plpgsql
as $$
declare
begin
select utilzador_id from customer 
where utilizador_id=user_id
if found then return 'custumer'
end if;

select utilizador_id from administrador
where utilizador_id=user_id;
if found then return 'administrador'
end if;

select utilizador_id from vendedor
where utilizador_id=user_id;
if found then return 'vendedor'
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
create or replace procedure add_to_order(customer_id utilizador.id%type, product_id produto.id%type, quantdade transacao_compra.quantidade%type)
language plpgsql
as $$
declare
    total_compra compra_notificacao.valor_pago%type;
    id_prod produto.id%type;
    preco_prod produto.preco%type;
    stock_prod produto.stock%type;

    cur_id_compra cursor for
        select id
        from compra_notificacao
        for update;

    cur_info_prod cursor(id_prod INTEGER) for
        select id, preco, stock
        from produto;

begin


end:
$$
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
