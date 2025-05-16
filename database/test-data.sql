-- Inserir Quartos
INSERT INTO QUARTOS (NUMERO, TIPO_QUARTO, DESCRICAO, PRECO, ESTADO_QUARTO) VALUES
(101, 'Standard', 'Quarto com cama de solteiro, Wi-Fi e TV', 85.00, 'livre'),
(102, 'Deluxe', 'Quarto com vista para o mar e varanda privativa', 150.00, 'livre'),
(201, 'Suite', 'Suíte presidencial com sala de estar separada', 300.00, 'livre'),
(202, 'Familiar', 'Quarto com duas camas de casal e beliche', 120.00, 'livre');

-- Inserir Utilizadores
INSERT INTO UTILIZADORES (NOME, EMAIL, PASSWORD, TIPO_UTILIZADOR) VALUES
('João Silva', 'joao.silva@example.com', crypt('cliente123', gen_salt('bf')), 'cliente'),
('Maria Santos', 'maria.santos@example.com', crypt('recepcionista123', gen_salt('bf')), 'recepcionista'),
('Admin User', 'admin@example.com', crypt('admin123', gen_salt('bf')), 'administrador');