-- ==============================================================
-- Drop everything that depends on these types/tables
-- ==============================================================

DROP TABLE IF EXISTS AUDITORIAS CASCADE;
DROP TABLE IF EXISTS QUARTO_IMAGEM CASCADE;
DROP TABLE IF EXISTS PAGAMENTOS CASCADE;
DROP TABLE IF EXISTS RESERVAS CASCADE;
DROP TABLE IF EXISTS QUARTOS CASCADE;
DROP TABLE IF EXISTS UTILIZADORES CASCADE;

DROP TYPE IF EXISTS TIPO_UTILIZADOR;
DROP TYPE IF EXISTS ESTADO_RESERVA;
DROP TYPE IF EXISTS ESTADO_PAGAMENTO;
DROP TYPE IF EXISTS ESTADO_QUARTO;

-- ==============================================================
-- Extensions and ENUM types
-- ==============================================================

CREATE EXTENSION IF NOT EXISTS pgcrypto;

CREATE TYPE TIPO_UTILIZADOR AS ENUM ('cliente', 'recepcionista', 'administrador');
CREATE TYPE ESTADO_RESERVA AS ENUM ('pendente', 'confirmada', 'cancelada');
CREATE TYPE ESTADO_PAGAMENTO AS ENUM ('pendente', 'pago', 'cancelado');
CREATE TYPE ESTADO_QUARTO AS ENUM ('livre', 'ocupado', 'manutencao');


-- ==============================================================
-- Table: UTILIZADORES
-- ==============================================================

CREATE TABLE UTILIZADORES (
    ID_UTILIZADORES  SERIAL PRIMARY KEY,
    NOME             VARCHAR(30) NOT NULL,
    EMAIL            VARCHAR(256) UNIQUE NOT NULL,
    PASSWORD         TEXT NOT NULL,
    TIPO_UTILIZADOR  TIPO_UTILIZADOR NOT NULL,
    DATA_REGISTO     DATE NOT NULL DEFAULT CURRENT_DATE
);

-- ==============================================================
-- Table: QUARTOS
-- ==============================================================

CREATE TABLE QUARTOS (
    ID_QUARTOS     SERIAL PRIMARY KEY,
    NUMERO         INT UNIQUE NOT NULL,
    TIPO_QUARTO    VARCHAR(20) NOT NULL,
    DESCRICAO      TEXT,
    PRECO          DECIMAL(10,2) NOT NULL,
    ESTADO_QUARTO  ESTADO_QUARTO NOT NULL DEFAULT 'livre'
);

-- ==============================================================
-- Table: RESERVAS
-- ==============================================================

CREATE TABLE RESERVAS (
    ID_RESERVAS      SERIAL PRIMARY KEY,
    ID_UTILIZADORES  INT NOT NULL REFERENCES UTILIZADORES,
    ID_QUARTOS       INT NOT NULL REFERENCES QUARTOS,
    DATA_CHECKIN     DATE NOT NULL,
    DATA_CHECKOUT    DATE NOT NULL,
    ESTADO_RESERVA   ESTADO_RESERVA NOT NULL DEFAULT 'pendente',
    VALOR_TOTAL      DECIMAL(10,2) NOT NULL,
    DATA_CRIACAO     DATE NOT NULL DEFAULT CURRENT_DATE
);

-- ==============================================================
-- Table: PAGAMENTOS
-- ==============================================================

CREATE TABLE PAGAMENTOS (
    ID_PAGAMENTOS      SERIAL PRIMARY KEY,
    ID_RESERVAS        INT NOT NULL REFERENCES RESERVAS,
    VALOR_PAGO         DECIMAL(10,2) NOT NULL,
    METODO             VARCHAR(50) NOT NULL,
    DATA_PAGAMENTO     DATE NOT NULL DEFAULT CURRENT_DATE,
    ESTADO_PAGAMENTO   ESTADO_PAGAMENTO NOT NULL DEFAULT 'pendente'
);

-- ==============================================================
-- Table: QUARTO_IMAGEM
-- ==============================================================

CREATE TABLE QUARTO_IMAGEM (
    ID_IMAGEM   SERIAL PRIMARY KEY,
    ID_QUARTOS  INT NOT NULL REFERENCES QUARTOS,
    IMAGE       BYTEA NOT NULL
);

-- ==============================================================
-- Table: AUDITORIAS
-- ==============================================================

CREATE TABLE AUDITORIAS (
    ID_AUDITORIAS    SERIAL PRIMARY KEY,
    ID_UTILIZADORES  INT NOT NULL REFERENCES UTILIZADORES,
    TIMESTAMP        TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    DETALHES_ACAO    TEXT NOT NULL
);

-- ==============================================================
-- Indexes
-- ==============================================================

CREATE INDEX auditorias_utilizador_idx ON AUDITORIAS (ID_UTILIZADORES);
CREATE INDEX pagamentos_reserva_idx ON PAGAMENTOS (ID_RESERVAS);
CREATE INDEX reservas_utilizador_idx ON RESERVAS (ID_UTILIZADORES);
CREATE INDEX reservas_quarto_idx ON RESERVAS (ID_QUARTOS);
CREATE INDEX quarto_imagens_idx ON QUARTO_IMAGEM (ID_QUARTOS);