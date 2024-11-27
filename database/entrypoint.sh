#!/bin/bash
set -e

# Inicia o PostgreSQL em segundo plano
docker-entrypoint.sh postgres &

# Aguarda o PostgreSQL estar pronto
echo "Aguardando o PostgreSQL iniciar..."
until pg_isready -h localhost -p 5432 -U postgres; do
  sleep 2
done

echo "PostgreSQL iniciado. Executando scripts SQL..."

# Executa o script de instalação
bash /scripts/install.sh

# Executa o script de atualização
bash /scripts/update.sh

# Mantém o PostgreSQL em execução no primeiro plano
wait -n
