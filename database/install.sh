#!/bin/bash

# Define o caminho da pasta onde estão os arquivos SQL
diretorio_sql="/scripts/install"

# Pega usuário, senha e host do ambiente
usuario="root"
senha=$MYSQL_ROOT_PASSWORD
host=$MYSQL_HOST
database=$MYSQL_DATABASE

# Inicia a transação
echo "Iniciando transação..."
mysql -u $usuario -p$senha -h$host -D$database -e "START TRANSACTION;"

# Variável para controle de erro
erro=0

# Lê cada arquivo SQL na pasta e executa
for arquivo_sql in $diretorio_sql/*.sql; do
  echo "Executando $arquivo_sql..."
  mysql -u $usuario -p$senha -D$database -h $host < "$arquivo_sql" || erro=1

  # Verifica se ocorreu erro na execução
  if [ $erro -ne 0 ]; then
    echo "Erro ao executar $arquivo_sql. Iniciando rollback..."
    mysql -u $usuario -p$senha -D$database -h$host -e "ROLLBACK;"
    exit 1
  fi
done

# Se todos os scripts foram executados com sucesso, faz commit
if [ $erro -eq 0 ]; then
  echo "Todos os scripts executados com sucesso. Fazendo commit..."
  mysql -u $usuario -p$senha -D$database -h$host -e "COMMIT;"
fi
