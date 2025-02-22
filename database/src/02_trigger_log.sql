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
    has_id_column BOOLEAN;
BEGIN
    log_table_name := TG_TABLE_NAME || '_log';

    -- Verifica se a tabela tem um campo "id"
    SELECT EXISTS (
        SELECT 1
        FROM information_schema.columns
        WHERE table_name = TG_TABLE_NAME
        AND column_name = 'id'
    ) INTO has_id_column;

    -- Crie a tabela de log se não existir
    IF has_id_column THEN
        EXECUTE format('
            CREATE TABLE IF NOT EXISTS %I (
                id SERIAL PRIMARY KEY,
                original_id INT,
                action TEXT, -- Tipo de ação (INSERT, UPDATE, DELETE)
                old_data JSONB,
                new_data JSONB,
                changed TIMESTAMPTZ DEFAULT current_timestamp,
                system_identifier TEXT -- Identificador do sistema, pode ser NULL
            )', log_table_name, TG_TABLE_NAME);
    ELSE
        EXECUTE format('
            CREATE TABLE IF NOT EXISTS %I (
                id SERIAL PRIMARY KEY,
                action TEXT, -- Tipo de ação (INSERT, UPDATE, DELETE)
                old_data JSONB,
                new_data JSONB,
                changed TIMESTAMPTZ DEFAULT current_timestamp,
                system_identifier TEXT -- Identificador do sistema, pode ser NULL
            )', log_table_name);
    END IF;

    -- Insere os dados na tabela de log
    IF has_id_column THEN
        EXECUTE format('
            INSERT INTO %I (action, old_data, new_data, changed, system_identifier, original_id)
            VALUES ($1, $2, $3, current_timestamp, $4, $5)',
            log_table_name)
        USING TG_OP, jsonb_diff(row_to_json(OLD)::jsonb, row_to_json(NEW)::jsonb), jsonb_diff(row_to_json(NEW)::jsonb, row_to_json(OLD)::jsonb), system_identifier, COALESCE(NEW.id, OLD.id, NULL);
    ELSE
        EXECUTE format('
            INSERT INTO %I (action, old_data, new_data, changed, system_identifier)
            VALUES ($1, $2, $3, current_timestamp, $4)',
            log_table_name)
        USING TG_OP, jsonb_diff(row_to_json(OLD)::jsonb, row_to_json(NEW)::jsonb), jsonb_diff(row_to_json(NEW)::jsonb, row_to_json(OLD)::jsonb), system_identifier;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
