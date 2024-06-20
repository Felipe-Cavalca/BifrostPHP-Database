#!/bin/bash
set -e

# Configurar o ID do servidor MySQL
echo "[mysqld]" > /etc/mysql/conf.d/serverid.cnf
echo "server-id=$RANDOM" >> /etc/mysql/conf.d/serverid.cnf

docker-entrypoint.sh mysqld &

until mysqladmin ping --silent; do
    sleep 2
done

# Verifica a conectividade com o MASTER_HOST usando mysqladmin ping
until mysqladmin ping -h "$MASTER_HOST" --silent; do
    sleep 2
done

# Configura o slave para se conectar ao master
mysql -uroot -p$MYSQL_ROOT_PASSWORD <<-EOSQL
    CHANGE MASTER TO
        MASTER_HOST='$MASTER_HOST',
        MASTER_USER='$REPLICA_USER',
        MASTER_PASSWORD='$REPLICA_PASSWORD';
EOSQL

# iniciando o slave
mysql -uroot -p$MYSQL_ROOT_PASSWORD <<-EOSQL
    START SLAVE;
EOSQL

sleep 2

# coloca para ignorar erros
mysql -uroot -p$MYSQL_ROOT_PASSWORD <<-EOSQL
    STOP SLAVE;
    SET GLOBAL sql_slave_skip_counter = 1;
    START SLAVE;
EOSQL

# Manter o container rodando
wait
