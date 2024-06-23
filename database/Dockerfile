FROM mysql:8.0

COPY ./install.sh /install.sh
COPY ./entrypoint.sh /scripts/entrypoint.sh

RUN chmod +x /scripts/entrypoint.sh

ENTRYPOINT ["/scripts/entrypoint.sh"]
