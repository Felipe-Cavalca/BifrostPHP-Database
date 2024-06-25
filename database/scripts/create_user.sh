#!/bin/bash

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
