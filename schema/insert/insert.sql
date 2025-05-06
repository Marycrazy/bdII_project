insert into quartos (id_quartos, numero, tipo_quarto, descricao, preco, imagem, estado_quarto)
values
    (1, 123, 'afdg', 'dasfg', 999, 'dafsgdh', 'livre'),
    (2, 321, 'asfafew', 'qerfwe', 998, 'asfgfdh', 'ocupado');

--@block
insert into utilizadores (id_utilizadores, nome, email, password, tipo_utilizador, data_registo)
values
    (1, 'asdfdg', 'ADSFD', '1234', 'cliente', '2020-01-01');

insert into reservas (id_reservas, id_utilizadores, id_quartos, id_pagamentos, data_checkin, data_checkout, estado_reserva, valor_total, data_criacao)
values
    (1, 1, 2, 1, '2020-01-01', '2020-01-02', 'confirmada', 998, '2020-01-01');

insert into pagamentos (id_pagamentos, id_reservas, valor_pago, metodo, data_pagamento, estado_pagamento)
values
    (1, 1, 998, 'efew', '2020-01-01', 'pago');

