#!/bin/bash
set -e

echo "id: $MYSQL_ID"

# Adiciona configuração para o mysql
if [ ! -f /etc/mysql/conf.d/serverid.cnf ]; then
    echo "[mysqld]" > /etc/mysql/conf.d/serverid.cnf
    echo "server-id=$MYSQL_ID" >> /etc/mysql/conf.d/serverid.cnf
    echo "auto_increment_increment=1" >> /etc/mysql/conf.d/serverid.cnf
    echo "auto_increment_offset=$MYSQL_ID" >> /etc/mysql/conf.d/serverid.cnf
fi

# Inicia o mysql
docker-entrypoint.sh mysqld &

# Manter o container rodando
wait
