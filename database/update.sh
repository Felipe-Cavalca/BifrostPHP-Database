#!/bin/bash

# Define o caminho das pastas onde estão os arquivos SQL
dir_src="/scripts/src"
dir_install="/scripts/install"
dir_update="/scripts/update"

# Pega usuário, senha, host, e banco do ambiente
user=$POSTGRES_USER
password=$POSTGRES_PASSWORD
host="localhost"
database=$POSTGRES_DB

# Função para executar scripts SQL
run_scripts() {
    local dir_sql=$1
    local ignore_validation=$2
    for file_sql in $dir_sql/*.sql; do
        # Extrai o nome do arquivo para verificar na tabela de migration
        name_file=$(basename "$file_sql")

        if [ "$ignore_validation" != "true" ]; then
            # Verifica se o arquivo já foi executado
            executed=$(PGPASSWORD=$password psql -U "$user" -h "$host" -d "$database" -t -c "SELECT COUNT(*) FROM bfr_migration WHERE file='$name_file';")
        else
            executed=0
        fi

        if [ "$executed" -eq 0 ]; then
            echo "[BFR][Info] Executando $file_sql..."

            # Executa o arquivo SQL, suprimindo saídas padrão
            PGPASSWORD=$password psql -U "$user" -h "$host" -d "$database" -q -X -f "$file_sql" > /dev/null
            if [ $? -ne 0 ]; then
                echo "[BFR][Info] Erro ao executar $file_sql. Iniciando rollback..."
                exit 1
            else
                # Insere o nome do arquivo na tabela de migration após a execução bem-sucedida
                PGPASSWORD=$password psql -U "$user" -h "$host" -d "$database" -q -c "INSERT INTO bfr_migration (file) VALUES ('$name_file') ON CONFLICT DO NOTHING;"
            fi
        else
            echo "[BFR][Info] $file_sql já foi executado. Ignorando..."
        fi
    done
}

# Executar scripts do core sem verificar se já foram executados
run_scripts $dir_src true

# Executar scripts de instalação com verificação
run_scripts $dir_install false

# Executar scripts de instalação com verificação
run_scripts $dir_update false

echo "[BFR][Info] Todos os scripts executados com sucesso."
