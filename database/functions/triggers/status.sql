create or replace function status_trigger_func()
returns trigger as $status_trigger$
begin
    if new.estado_reserva = 'confirmada' then
        update quartos
            set estado_quarto = 'ocupado'
            where id_quartos = new.id_quartos;
    elseif new.estado_reserva = 'cancelada' then
        update quartos
            set estado_quarto = 'livre'
            where id_quartos = new.id_quartos;
    end if;
    return new;
end;
$status_trigger$ language plpgsql;

create trigger status_trigger
after insert or update on reservas
for each row
execute procedure status_trigger_func();