FROM mongo:4.2
ADD ./data/mongodb/init.sh /docker-entrypoint-initdb.d/
ENTRYPOINT ["docker-entrypoint.sh"]
