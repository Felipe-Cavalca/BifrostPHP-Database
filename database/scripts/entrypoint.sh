#!/bin/bash
set -e

echo "id: $MYSQL_ID"

# Adiciona configuração para o mysql
echo "[mysqld]" > /etc/mysql/conf.d/serverid.cnf
echo "server-id=$MYSQL_ID" >> /etc/mysql/conf.d/serverid.cnf
echo "auto_increment_increment=2" >> /etc/mysql/conf.d/serverid.cnf
echo "auto_increment_offset=$MYSQL_ID" >> /etc/mysql/conf.d/serverid.cnf

# Inicia o mysql
docker-entrypoint.sh mysqld &

# Aguarda o mysql subir
until mysqladmin ping --silent; do
    echo "Aguardando o mysql subir..."
    sleep 5
done

# Tenta criar o usuário de replicação sem senha
if ! mysql -uroot <<-EOSQL
  CREATE USER IF NOT EXISTS '$REPLICA_USER'@'%' IDENTIFIED WITH mysql_native_password BY '$REPLICA_PASSWORD';
  GRANT REPLICATION SLAVE ON *.* TO '$REPLICA_USER'@'%';
EOSQL
then
  # Se a tentativa sem senha falhar, tenta novamente com a senha
  mysql -uroot -p$MYSQL_ROOT_PASSWORD <<-EOSQL
    CREATE USER IF NOT EXISTS '$REPLICA_USER'@'%' IDENTIFIED WITH mysql_native_password BY '$REPLICA_PASSWORD';
    GRANT REPLICATION SLAVE ON *.* TO '$REPLICA_USER'@'%';
EOSQL
fi

# Manter o container rodando
wait
