CREATE OR REPLACE FUNCTION insert_room_image(
    room_id INT,
    image_data BYTEA
)
RETURNS INT
LANGUAGE plpgsql
AS $$
DECLARE
    inserted_id INT;
BEGIN
    IF NOT EXISTS (SELECT 1 FROM QUARTOS WHERE ID_QUARTOS = room_id) THEN
        RAISE EXCEPTION 'Room does not exist';
    END IF;

    INSERT INTO QUARTO_IMAGEM (ID_QUARTOS, IMAGE)
    VALUES (room_id, image_data)
    RETURNING ID_IMAGEM INTO inserted_id;

    RETURN inserted_id;
END;
$$;

CREATE OR REPLACE FUNCTION get_room_image_ids(room_id INT)
RETURNS INT[]
LANGUAGE plpgsql
AS $$
DECLARE
    image_ids INT[];
BEGIN
    SELECT ARRAY_AGG(ID_IMAGEM)
    INTO image_ids
    FROM QUARTO_IMAGEM
    WHERE ID_QUARTOS = room_id;

    IF image_ids IS NULL THEN
        RAISE EXCEPTION 'No images found for this room';
    END IF;

    RETURN image_ids;
END;
$$;

CREATE OR REPLACE FUNCTION get_image_by_room_and_id(room_id INT, image_id INT)
RETURNS BYTEA
LANGUAGE plpgsql
AS $$
DECLARE
    img BYTEA;
BEGIN
    SELECT IMAGE INTO img
    FROM QUARTO_IMAGEM
    WHERE ID_QUARTOS = room_id AND ID_IMAGEM = image_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Image not found';
    END IF;

    RETURN img;
END;
$$;