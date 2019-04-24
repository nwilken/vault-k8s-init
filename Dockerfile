FROM alpine:3.9
LABEL maintainer="Nate Wilken <wilken@asu.edu>"

WORKDIR /home/app
RUN addgroup -g 1000 app \
 && adduser -D -h /home/app -s /bin/bash -u 1000 -G app app \
 && chmod 755 . \
 && chown -R app:app .

RUN apk update \
 && apk add --no-cache ca-certificates openssl curl jq

WORKDIR /bin
COPY entrypoint.sh .
RUN chmod 555 entrypoint.sh

ENTRYPOINT ["/bin/entrypoint.sh"]

USER app:app
