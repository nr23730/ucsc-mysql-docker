ARG VERSION=10.10.2
FROM mariadb:${VERSION} as builder

COPY $PWD/docker-entrypoint.sh /home/docker-entrypoint.sh

# needed for intialization
RUN export MYSQL_ROOT_PASSWORD=$(echo $RANDOM | md5sum | head -c 20; echo;)
ENV MYSQL_DATABASE=hg19
ENV MYSQL_USER=genome
ENV MYSQL_ALLOW_EMPTY_PASSWORD=yes

RUN apt-get update && apt-get install -y wget

WORKDIR /docker-entrypoint-initdb.d/
RUN wget https://hgdownload.soe.ucsc.edu/goldenPath/hg19/database/refGene.sql

WORKDIR /home
RUN wget https://hgdownload.soe.ucsc.edu/goldenPath/hg19/database/refGene.txt.gz
RUN gunzip refGene.txt.gz

RUN ["/home/docker-entrypoint.sh", "mysqld", "--datadir", "/initialized-db", "--aria-log-dir-path", "/initialized-db"]

RUN ["rm", "-rf", "/home"]

FROM mariadb:${VERSION}

COPY --from=builder /initialized-db /var/lib/mysql