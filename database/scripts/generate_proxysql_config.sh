#!/bin/sh

# Carregar variáveis de ambiente do arquivo .env
set -a
. /etc/environment
set +a

# Gerar o arquivo de configuração proxysql.cnf
cat <<EOF > /etc/proxysql.cnf
datadir="/var/lib/proxysql"

admin_variables=
{
    admin_credentials="admin:admin;cluster:cluster"
    mysql_ifaces="0.0.0.0:6032"
}

mysql_variables=
{
    threads=4
    max_connections=2048
    have_ssl=false
    use_pcre2=false
}

mysql_servers =
(
    { address="${MASTER_HOST}", port=3306, hostgroup=1, max_connections=1000, weight=1 },
    { address="slave-db-1", port=3306, hostgroup=2, max_connections=1000, weight=1 },
    { address="slave-db-2", port=3306, hostgroup=2, max_connections=1000, weight=1 }
)

mysql_users =
(
    { username = "${MYSQL_USER}", password = "${MYSQL_PASSWORD}", default_hostgroup = 1, transaction_persistent = 0 }
)

mysql_query_rules =
(
    {
        rule_id=1
        active=1
        match_pattern="^SELECT"
        destination_hostgroup=2
        apply=1
    }
)
EOF

# Iniciar o ProxySQL
/usr/bin/proxysql --initial -f -c /etc/proxysql.cnf
