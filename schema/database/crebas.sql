/*==============================================================*/
/* DBMS name:      PostgreSQL 8                                 */
/* Created on:     26/02/2025 18:27:22                          */
/*==============================================================*/

DROP TYPE IF EXISTS TIPO_UTILIZADOR;
DROP TYPE IF EXISTS ESTADO_RESERVA;
DROP TYPE IF EXISTS ESTADO_PAGAMENTO;
DROP TYPE IF EXISTS ESTADO_QUARTO;

drop index UTILIZADORES_AUDITORIAS_FK;

drop index AUDITORIAS_PK;

drop table AUDITORIAS;

drop index RESERVAS_PAGAMENTOS2_FK;

drop index PAGAMENTOS_PK;

drop table PAGAMENTOS;

drop index QUARTOS_PK;

drop table QUARTOS;

drop index QUARTOS_QUARTOS_FK;

drop index QUARTO_IMAGEM_PK;

drop table QUARTO_IMAGEM;

drop index RESERVAS_PAGAMENTOS_FK;

drop index RESERVAS_QUARTOS_FK;

drop index UTILIZADORES_RESERVAS_FK;

drop index RESERVAS_PK;

drop table RESERVAS;

drop index UTILIZADORES_PK;

drop table UTILIZADORES;

--@block
CREATE TYPE TIPO_UTILIZADOR AS ENUM ('cliente', 'recepcionista', 'administrador');
CREATE TYPE ESTADO_RESERVA AS ENUM ('pendente', 'confirmada', 'cancelada');
CREATE TYPE ESTADO_PAGAMENTO AS ENUM ('pendente', 'pago', 'cancelado');
CREATE TYPE ESTADO_QUARTO AS ENUM ('livre', 'ocupado', 'manutencao');
CREATE EXTENSION IF NOT EXISTS pgcrypto;
/*==============================================================*/
/* Table: AUDITORIAS                                            */
/*==============================================================*/
create table AUDITORIAS (
    ID_AUDITORIAS        SERIAL                 ,
    ID_UTILIZADORES      INT4                 ,
    TIMESTAMP           TIMESTAMP                 ,
    DETALHES_ACAO        TEXT                 ,
    constraint PK_AUDITORIAS primary key (ID_AUDITORIAS)
);

/*==============================================================*/
/* Index: AUDITORIAS_PK                                         */
/*==============================================================*/
create unique index AUDITORIAS_PK on AUDITORIAS (
    ID_AUDITORIAS
);

/*==============================================================*/
/* Index: UTILIZADORES_AUDITORIAS_FK                            */
/*==============================================================*/
create  index UTILIZADORES_AUDITORIAS_FK on AUDITORIAS (
    ID_UTILIZADORES
);

/*==============================================================*/
/* Table: PAGAMENTOS                                            */
/*==============================================================*/
create table PAGAMENTOS (
    ID_PAGAMENTOS        SERIAL                 ,
    ID_RESERVAS          INT4                 ,
    VALOR_PAGO           DECIMAL              ,
    METODO               VARCHAR(50)          ,
    DATA_PAGAMENTO       DATE                 ,
    ESTADO_PAGAMENTO     ESTADO_PAGAMENTO          ,
    constraint PK_PAGAMENTOS primary key (ID_PAGAMENTOS)
);

/*==============================================================*/
/* Index: PAGAMENTOS_PK                                         */
/*==============================================================*/
create unique index PAGAMENTOS_PK on PAGAMENTOS (
    ID_PAGAMENTOS
);

/*==============================================================*/
/* Index: RESERVAS_PAGAMENTOS2_FK                               */
/*==============================================================*/
create  index RESERVAS_PAGAMENTOS2_FK on PAGAMENTOS (
    ID_RESERVAS
);

/*==============================================================*/
/* Table: QUARTOS                                               */
/*==============================================================*/
create table QUARTOS (
    ID_QUARTOS           SERIAL                 ,
    NUMERO               INT4                 ,
    TIPO_QUARTO          VARCHAR(20)          ,
    DESCRICAO            TEXT                 ,
    PRECO                DECIMAL              ,
    ESTADO_QUARTO        ESTADO_QUARTO          ,
    constraint PK_QUARTOS primary key (ID_QUARTOS)
);

/*==============================================================*/
/* Index: QUARTOS_PK                                            */
/*==============================================================*/
create unique index QUARTOS_PK on QUARTOS (
    ID_QUARTOS
);

/*==============================================================*/
/* Table: QUARTO_IMAGEM                                         */
/*==============================================================*/
create table QUARTO_IMAGEM (
    ID_IMAGEM            SERIAL                 ,
    ID_QUARTOS           INT4                ,
    IMAGE                BYTEA            ,
    constraint PK_QUARTO_IMAGEM primary key (ID_IMAGEM)
);

/*==============================================================*/
/* Index: QUARTO_IMAGEM_PK                                      */
/*==============================================================*/
create unique index QUARTO_IMAGEM_PK on QUARTO_IMAGEM (
    ID_IMAGEM
);

/*==============================================================*/
/* Index: QUARTOS_QUARTOS_FK                                    */
/*==============================================================*/
create  index QUARTOS_QUARTOS_FK on QUARTO_IMAGEM (
    ID_QUARTOS
);

/*==============================================================*/
/* Table: RESERVAS                                              */
/*==============================================================*/
create table RESERVAS (
    ID_RESERVAS          SERIAL                 ,
    ID_UTILIZADORES      INT4                 ,
    ID_QUARTOS           INT4                 ,
    ID_PAGAMENTOS        INT4                 ,
    DATA_CHECKIN         DATE                 ,
    DATA_CHECKOUT        DATE                 ,
    ESTADO_RESERVA       ESTADO_RESERVA          ,
    VALOR_TOTAL          DECIMAL              ,
    DATA_CRIACAO         DATE                 ,
    constraint PK_RESERVAS primary key (ID_RESERVAS)
);

/*==============================================================*/
/* Index: RESERVAS_PK                                           */
/*==============================================================*/
create unique index RESERVAS_PK on RESERVAS (
    ID_RESERVAS
);

/*==============================================================*/
/* Index: UTILIZADORES_RESERVAS_FK                              */
/*==============================================================*/
create  index UTILIZADORES_RESERVAS_FK on RESERVAS (
    ID_UTILIZADORES
);

/*==============================================================*/
/* Index: RESERVAS_QUARTOS_FK                                   */
/*==============================================================*/
create  index RESERVAS_QUARTOS_FK on RESERVAS (
    ID_QUARTOS
);

/*==============================================================*/
/* Index: RESERVAS_PAGAMENTOS_FK                                */
/*==============================================================*/
create  index RESERVAS_PAGAMENTOS_FK on RESERVAS (
    ID_PAGAMENTOS
);

/*==============================================================*/
/* Table: UTILIZADORES                                          */
/*==============================================================*/
create table UTILIZADORES (
    ID_UTILIZADORES      SERIAL               ,
    NOME                 VARCHAR(30)          ,
    EMAIL                VARCHAR(256)         ,
    PASSWORD             TEXT                 ,
    TIPO_UTILIZADOR      TIPO_UTILIZADOR          ,
    DATA_REGISTO         DATE                 ,
    constraint PK_UTILIZADORES primary key (ID_UTILIZADORES)
);

/*==============================================================*/
/* Index: UTILIZADORES_PK                                       */
/*==============================================================*/
create unique index UTILIZADORES_PK on UTILIZADORES (
    ID_UTILIZADORES
);

alter table AUDITORIAS
    add constraint FK_AUDITORI_UTILIZADO_UTILIZAD foreign key (ID_UTILIZADORES)
        references UTILIZADORES (ID_UTILIZADORES)
        on delete restrict on update restrict;

alter table PAGAMENTOS
    add constraint FK_PAGAMENT_RESERVAS__RESERVAS foreign key (ID_RESERVAS)
        references RESERVAS (ID_RESERVAS)
        on delete restrict on update restrict;

alter table QUARTO_IMAGEM
    add constraint FK_QUARTO_I_QUARTOS_Q_QUARTOS foreign key (ID_QUARTOS)
        references QUARTOS (ID_QUARTOS)
        on delete restrict on update restrict;

alter table RESERVAS
    add constraint FK_RESERVAS_RESERVAS__PAGAMENT foreign key (ID_PAGAMENTOS)
        references PAGAMENTOS (ID_PAGAMENTOS)
        on delete restrict on update restrict;

alter table RESERVAS
    add constraint FK_RESERVAS_RESERVAS__QUARTOS foreign key (ID_QUARTOS)
        references QUARTOS (ID_QUARTOS)
        on delete restrict on update restrict;

alter table RESERVAS
    add constraint FK_RESERVAS_UTILIZADO_UTILIZAD foreign key (ID_UTILIZADORES)
        references UTILIZADORES (ID_UTILIZADORES)
        on delete restrict on update restrict;