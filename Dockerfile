FROM consul:0.7.1

RUN apk add --update bash bind-tools \
    && rm -rf /var/cache/apk/*
COPY swarm-configure.sh /usr/local/bin/

ENTRYPOINT ["/usr/local/bin/swarm-configure.sh"]
CMD ["agent"]
