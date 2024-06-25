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

# Manter o container rodando
wait
