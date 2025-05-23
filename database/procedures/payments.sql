CREATE OR REPLACE PROCEDURE inserir_pagamento(p_id_reserva INT, p_metodo VARCHAR(50))
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO PAGAMENTOS (ID_RESERVAS, VALOR_PAGO, METODO, DATA_PAGAMENTO, ESTADO_PAGAMENTO)
    VALUES (p_id_reserva, (SELECT valor_total FROM RESERVAS WHERE ID_RESERVAS = p_id_reserva), p_metodo, NOW(), 'pago');
    UPDATE RESERVAS SET ESTADO_RESERVA = 'confirmada' WHERE ID_RESERVAS = p_id_reserva;
END;
$$;