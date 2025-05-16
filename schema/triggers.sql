CREATE OR REPLACE FUNCTION trg_audit_reservas()
    RETURNS TRIGGER
    LANGUAGE plpgsql
AS $$
BEGIN
    IF (TG_OP = 'INSERT') THEN
        INSERT INTO AUDITORIAS (ID_UTILIZADORES, TIMESTAMP, DETALHES_ACAO)
        VALUES (
            NEW.ID_UTILIZADORES,
            now(),
            'Reserva criada: ID=' || NEW.ID_RESERVAS
        );

    ELSIF (TG_OP = 'UPDATE') THEN
        INSERT INTO AUDITORIAS (ID_UTILIZADORES, TIMESTAMP, DETALHES_ACAO)
        VALUES (
            NEW.ID_UTILIZADORES,
            now(),
            'Reserva alterada: ID=' || NEW.ID_RESERVAS ||
            ', de estado ' || OLD.ESTADO_RESERVA ||
            ' para ' || NEW.ESTADO_RESERVA
        );
    END IF;

    RETURN NULL;
END;
$$;

CREATE TRIGGER audit_reservas_insert
    AFTER INSERT ON RESERVAS
    FOR EACH ROW
    EXECUTE FUNCTION trg_audit_reservas();

CREATE TRIGGER audit_reservas_update
    AFTER UPDATE ON RESERVAS
    FOR EACH ROW
    EXECUTE FUNCTION trg_audit_reservas();
