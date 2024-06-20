#!/bin/bash
set -e

# Adiciona configuração para o mysql
echo "[mysqld]" > /etc/mysql/conf.d/serverid.cnf
echo "server-id=$RANDOM" >> /etc/mysql/conf.d/serverid.cnf
echo "log_bin=binlog" >> /etc/mysql/conf.d/serverid.cnf

docker-entrypoint.sh mysqld &

# Espera o MySQL estar disponível
until mysqladmin ping --silent; do
  sleep 2
done

# Cria o usuário de replicação
mysql -uroot <<-EOSQL
  CREATE USER IF NOT EXISTS '$REPLICA_USER'@'%' IDENTIFIED WITH mysql_native_password BY '$REPLICA_PASSWORD';
  GRANT REPLICATION SLAVE ON *.* TO '$REPLICA_USER'@'%';
EOSQL

# Manter o container rodando
wait
