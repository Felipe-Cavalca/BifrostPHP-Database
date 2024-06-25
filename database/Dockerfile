FROM mysql:8.0

COPY ./scripts/config_master.sh /config_master.sh
COPY ./scripts/create_user.sh /create_user.sh
COPY ./scripts/entrypoint.sh /entrypoint.sh

RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
