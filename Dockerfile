FROM alpine:latest
RUN apk update
RUN apk upgrade
RUN apk add bash jq httpie py3-setuptools parallel
ADD /lp-api /usr/bin/lp-api
RUN chmod +x /usr/bin/lp-api
ADD /check /opt/resource/check
ADD /out /opt/resource/out
ADD /in /opt/resource/in
RUN chmod +x /opt/resource/*
