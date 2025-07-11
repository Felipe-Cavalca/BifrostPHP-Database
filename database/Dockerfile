# Dockerfile.database
FROM postgres:12.22-bookworm

COPY ./src /scripts/src
COPY ./install /scripts/install
COPY ./update.sh /scripts/update.sh
COPY ./update /scripts/update
COPY ./entrypoint.sh /scripts/entrypoint.sh

# Instala o dos2unix
RUN apt-get update && apt-get install -y dos2unix

RUN dos2unix /scripts/update.sh /scripts/entrypoint.sh

RUN chmod +x /scripts/entrypoint.sh

ENTRYPOINT ["/scripts/entrypoint.sh"]
