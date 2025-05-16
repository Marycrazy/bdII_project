CREATE OR REPLACE PROCEDURE inserir_reserva (r_id_cliente INT, r_id_quarto INT, r_data_checkin DATE, r_data_checkout DATE, OUT r_id_reserva INT)
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO RESERVAS (ID_UTILIZADORES, ID_QUARTOS, DATA_CHECKIN, DATA_CHECKOUT, ESTADO_RESERVA, VALOR_TOTAL, DATA_CRIACAO)
    VALUES (r_id_cliente, r_id_quarto , r_data_checkin, r_data_checkout, 'pendente', (SELECT preco FROM QUARTOS WHERE ID_QUARTOS = r_id_quarto), now())
    RETURNING ID_RESERVAS INTO r_id_reserva;
END;
$$;