INSERT INTO utilizadores (nome, email, password, tipo_utilizador, DATA_REGISTO) VALUES ('Maria', 'maria@gmail.com', '123456789', 'administrador', now());
INSERT INTO utilizadores (nome, email, password, tipo_utilizador, DATA_REGISTO) VALUES ('Joao', 'joao@gmail.com', '123456789', 'recepcionista', now());
INSERT INTO utilizadores (nome, email, password, tipo_utilizador, DATA_REGISTO) VALUES ('Pedro', 'pedro@gmail.com', '123456789', 'cliente', now());
--@block inserir utilizadores
SELECT inserir_utilizador('Ana', 'ana@gmail.com', '123456789', 'cliente', now());
--@block
--@block inserir utilizadores recepcionista
INSERT INTO inserir_utilizador (nome, email, password, tipo_utilizador, DATA_REGISTO) VALUES ('Carlos', 'carlos@gmail.com', '123456789', 'recepcionista', now());
--@block inserir quartos
INSERT INTO quartos (numero, tipo_quarto, descricao, preco, imagem, estado_quarto) VALUES (101, 'single', 'Quarto com vista para o mar', 50.00, 'quarto1.jpg', 'livre');
INSERT INTO quartos (numero, tipo_quarto, descricao, preco, imagem, estado_quarto) VALUES (102, 'single', 'Quarto com vista para a piscina', 50.00, 'quarto2.jpg', 'ocupado');
--@block inserir reservas
CALL inserir_reserva(3, 1, '2021-06-01', '2021-06-05');
--@block
CALL inserir_reserva(3, 2, '2021-06-01', '2021-06-05');

--@block inserir pagamentos
call inserir_pagamento(4, 'multibanco', true);