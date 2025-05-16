CREATE OR REPLACE FUNCTION is_available(num_quarto int, data date)
RETURNS boolean AS $$
DECLARE
    quarto_id INT;
BEGIN
    SELECT id_quartos
    INTO quarto_id
    FROM quartos
    WHERE numero = num_quarto;

    IF quarto_id IS NULL THEN
        RETURN false;
    END IF;

    RETURN NOT EXISTS (
        SELECT 1
        FROM reservas
        WHERE
            id_quartos = quarto_id AND
            data BETWEEN data_checkin AND data_checkout AND
            estado_reserva NOT IN ('cancelada')
    );
END;
$$ LANGUAGE plpgsql;