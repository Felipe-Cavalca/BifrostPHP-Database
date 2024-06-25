FROM mysql:8.0

COPY ./scripts/install.sh /install.sh
COPY ./scripts/entrypoint.sh /scripts/entrypoint.sh

RUN chmod +x /scripts/entrypoint.sh

ENTRYPOINT ["/scripts/entrypoint.sh"]
