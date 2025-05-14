CREATE OR REPLACE VIEW reservas_do_cliente AS
SELECT
    r.ID_RESERVAS AS reserva_id,
    r.DATA_CHECKIN AS checkin,
    r.DATA_CHECKOUT AS checkout,
    r.VALOR_TOTAL AS valor_total,
    r.ESTADO_RESERVA AS estado_reserva,
    q.NUMERO AS numero_quarto,
    q.TIPO_QUARTO AS tipo_quarto,
    q.PRECO AS preco_diario,
    p.VALOR_PAGO AS valor_pago,
    p.METODO AS metodo_pagamento,
    p.ESTADO_PAGAMENTO AS estado_pagamento
FROM
    RESERVAS r, QUARTOS q, PAGAMENTOS p
WHERE
    r.ID_QUARTOS = q.ID_QUARTOS
    AND
    r.ID_RESERVAS = p.ID_RESERVAS
    AND
    r.ID_UTILIZADORES = CURRENT_SETTING('app.user_id')::INTEGER;

--@block
--eservas do cliente
SET app.user_id = 1;
SELECT * FROM reservas_do_cliente;

--@block
SELECT * FROM 
    RESERVAS r, QUARTOS q, PAGAMENTOS p
WHERE
    r.ID_QUARTOS = q.ID_QUARTOS
    AND
    r.ID_RESERVAS = p.ID_RESERVAS
    AND
    r.ID_UTILIZADORES = 1;