CREATE OR REPLACE FUNCTION create_log_trigger(table_name TEXT)
RETURNS VOID AS $$
DECLARE
    trigger_name TEXT;
BEGIN
    -- Defina o nome do trigger com base no nome da tabela
    trigger_name := table_name || '_trigger';

    -- Crie o trigger dinamicamente
    EXECUTE format('
        CREATE TRIGGER %I
        AFTER INSERT OR UPDATE OR DELETE ON %I
        FOR EACH ROW EXECUTE FUNCTION log_changes();',
        trigger_name, table_name);
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION log_changes()
RETURNS TRIGGER AS $$
DECLARE
    log_table_name TEXT;
    system_identifier TEXT := current_setting('bifrost.system_identifier', true); -- Obtém o identificador do sistema
BEGIN
    log_table_name := TG_TABLE_NAME || '_log';

    -- Crie a tabela de log se não existir
    EXECUTE format('
        CREATE TABLE IF NOT EXISTS %I (
            id SERIAL PRIMARY KEY,
            action_type TEXT, -- Tipo de ação (INSERT, UPDATE, DELETE)
            old_data JSONB,
            new_data JSONB,
            changed_at TIMESTAMPTZ DEFAULT current_timestamp,
            system_identifier TEXT -- Identificador do sistema, pode ser NULL
        )', log_table_name);

    -- Insere os dados na tabela de log
    EXECUTE format('
        INSERT INTO %I (action_type, old_data, new_data, changed_at, system_identifier)
        VALUES ($1, $2, $3, current_timestamp, $4)',
        log_table_name)
    USING TG_OP, row_to_json(OLD), row_to_json(NEW), system_identifier;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
