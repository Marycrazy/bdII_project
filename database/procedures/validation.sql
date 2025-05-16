--Procedimento para validar inserçao de utilizadores
CREATE OR REPLACE PROCEDURE validate_user (u_email VARCHAR(50) DEFAULT NULL, u_tipo_utilizador VARCHAR(50) DEFAULT NULL)
LANGUAGE plpgsql
AS $$
BEGIN
    -- Verificação do email
    IF u_email IS NOT NULL THEN
        -- Verifica se o email é válido
        IF NOT (u_email ~* '^[a-z0-9]+@[a-z0-9]+\.[a-z]{2,}$') THEN
            RAISE EXCEPTION 'O email "%" não é válido.', u_email;
        END IF;
        -- Verifica se o email já existe
        IF EXISTS(SELECT EMAIL FROM UTILIZADORES WHERE EMAIL = u_email) THEN
            RAISE EXCEPTION 'O email "%" já existe.', u_email;
        END IF;
    END IF;
    IF u_tipo_utilizador IS NOT NULL THEN
        -- Verifica se o tipo de utilizador é válido
        IF NOT (u_tipo_utilizador IN ('cliente', 'recepcionista', 'administrador')) THEN
            RAISE EXCEPTION 'O tipo de utilizador "%" não é válido.', u_tipo_utilizador;
        END IF;
    END IF;
END;
$$;