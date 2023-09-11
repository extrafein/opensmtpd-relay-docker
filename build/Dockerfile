FROM alpine:latest

RUN apk update && \
    apk add \
        supervisor \
        opensmtpd && \
    rm -rf /var/cache/apk/*

VOLUME ["/etc/smtpd"]

EXPOSE 25 587

COPY entrypoint.sh /
RUN chmod 755 /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]

CMD ["/usr/bin/supervisord", "--nodaemon", "--configuration", "/etc/supervisord.conf"]
