CREATE OR REPLACE PROCEDURE inserir_reserva (r_id_cliente INT, r_id_quarto INT, r_data_checkin DATE, r_data_checkout DATE)
LANGUAGE plpgsql
AS $$
DECLARE
    r_id_reserva INT; -- variavel para guardar o id da reserva para depois associar ao pagamento
BEGIN
    -- Inserir reserva com estado 'pendente'
    INSERT INTO RESERVAS (ID_UTILIZADORES, ID_QUARTOS, DATA_CHECKIN, DATA_CHECKOUT, ESTADO_RESERVA, VALOR_TOTAL, DATA_CRIACAO) 
    VALUES (r_id_cliente, r_id_quarto , r_data_checkin, r_data_checkout,'pendente', (SELECT preco FROM QUARTOS WHERE ID_QUARTOS = r_id_quarto) ,now()) RETURNING ID_RESERVAS INTO r_id_reserva;
    call inserir_pagamento(r_id_reserva, 'multibanco');

END;
$$;
--@block inserir pagamentos
CREATE OR REPLACE PROCEDURE inserir_pagamento(p_id_reserva INT, p_metodo VARCHAR(50))
LANGUAGE plpgsql
AS $$
DECLARE
    p_id_pagamento INT; -- variavel para guardar o id do pagamento para depois associar a reserva
BEGIN
    INSERT INTO PAGAMENTOS (ID_RESERVAS, VALOR_PAGO, METODO, DATA_PAGAMENTO, ESTADO_PAGAMENTO) 
    VALUES (p_id_reserva, (SELECT valor_total FROM RESERVAS WHERE ID_RESERVAS = p_id_reserva), p_metodo, now(), 'pago') RETURNING ID_PAGAMENTOS INTO p_id_pagamento;
    UPDATE RESERVAS SET ESTADO_RESERVA = 'confirmada', ID_PAGAMENTOS = p_id_pagamento WHERE ID_RESERVAS = p_id_reserva;
END;
$$;
--@block
--Procedimento para validar inserçao de utilizadores
CREATE OR REPLACE PROCEDURE validat_user (u_email VARCHAR(50) DEFAULT NULL, u_tipo_utilizador VARCHAR(50) DEFAULT NULL)
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


--@block 
DROP PROCEDURE IF EXISTS inserir_pagamento(INT, VARCHAR);
DROP PROCEDURE IF EXISTS inserir_reserva(INT, INT, DATE, DATE);
--@block
DELETE FROM PAGAMENTOS;
DELETE FROM reservas;