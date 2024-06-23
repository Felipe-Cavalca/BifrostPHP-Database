#!/bin/bash

# Configura o master
mysql -uroot -p$MYSQL_ROOT_PASSWORD <<-EOSQL
    STOP SLAVE;
    CHANGE MASTER TO
        MASTER_HOST='$MASTER_HOST',
        MASTER_USER='$REPLICA_USER',
        MASTER_PASSWORD='$REPLICA_PASSWORD';
    START SLAVE;
EOSQL

sleep 5

# Coloca para ignorar erros
mysql -uroot -p$MYSQL_ROOT_PASSWORD <<-EOSQL
    STOP SLAVE;
    SET GLOBAL sql_slave_skip_counter = 1;
    START SLAVE;
EOSQL
