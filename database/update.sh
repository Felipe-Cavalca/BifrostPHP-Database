#!/bin/bash

# Define o caminho das pastas onde estão os arquivos SQL
dir_install="/scripts/update"

# Pega usuário, senha, host, e banco do ambiente
user="root"
password=$MYSQL_ROOT_PASSWORD
host=$MYSQL_HOST
database=$MYSQL_DATABASE

# Inicia a transação
echo "bfr [Info] Iniciando transação..."
mysql -u $user -p$password -h$host -D$database -e "START TRANSACTION;"

# Variável para controle de erro
error=0

# Função para executar scripts SQL
executar_scripts() {
    local dir_sql=$1
    local ignore_validation=$2
    local error=0
    for file_sql in $dir_sql/*.sql; do
        # Extrai o nome do arquivo para verificar na tabela de migration
        name_file=$(basename "$file_sql")

        if [ "$ignore_validation" != "true" ]; then
            # Verifica se o arquivo já foi executado
            executed=$(mysql -u $user -p$password -D$database -h $host -sse "SELECT COUNT(*) FROM bfr_migration WHERE file='$name_file'")
        else
            executed=0
        fi

        if [ "$executed" -eq 0 ]; then
            echo "bfr [Info] Executando $file_sql..."
            mysql -u $user -p$password -D$database -h $host < "$file_sql" || error=1

            # Verifica se ocorreu error na execução
            if [ $error -ne 0 ]; then
                echo "bfr [Info] Erro ao executar $file_sql. Iniciando rollback..."
                mysql -u $user -p$password -D$database -h $host -e "ROLLBACK;"
                exit 1
            else
                # Insere o nome do arquivo na tabela de migration após a execução bem-sucedida
                mysql -u $user -p$password -D$database -h $host -e "INSERT INTO bfr_migration (file) VALUES ('$name_file');"
            fi
        else
            echo "bfr [Info] $file_sql já foi executado. Ignorando..."
        fi
    done
}

# Executar scripts de instalação com verificação
executar_scripts $dir_install false

# Se todos os scripts foram executados com sucesso, faz commit
if [ $error -eq 0 ]; then
    echo "bfr [Info] Todos os scripts executados com sucesso. Fazendo commit..."
    mysql -u $user -p$password -D$database -h $host -e "COMMIT;"
fi
