--Funçao para inserir utilizador
CREATE OR REPLACE FUNCTION inserir_utilizador (u_nome VARCHAR(50), u_email VARCHAR(50), u_password VARCHAR(50), u_tipo_utilizador VARCHAR(50))
RETURNS void AS $$
BEGIN
    call validat_user(u_email, u_tipo_utilizador);
    INSERT INTO utilizadores(NOME, EMAIL, PASSWORD, TIPO_UTILIZADOR, DATA_REGISTO) VALUES (u_nome, u_email, crypt(u_password,  gen_salt('bf')), u_tipo_utilizador::TIPO_UTILIZADOR, CURRENT_DATE);
END;
$$ LANGUAGE plpgsql;

--@block
--Função para autenticar utilizador
CREATE OR REPLACE FUNCTION autenticar_utilizador (u_email VARCHAR(50), u_password VARCHAR(50))
RETURNS INTEGER AS $$
BEGIN
    RETURN (SELECT ID_UTILIZADORES FROM utilizadores WHERE email = u_email AND password = crypt(u_password,  password));
END;
$$ LANGUAGE plpgsql;

