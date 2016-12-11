FROM consul:0.7.1

RUN apk add --update bash bind-tools
COPY configure.sh /usr/local/bin/
ENTRYPOINT ["/usr/local/bin/configure.sh"]
CMD ["agent"]
