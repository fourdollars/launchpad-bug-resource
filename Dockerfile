FROM alpine:latest
RUN apk update
RUN apk upgrade
RUN apk add bash jq httpie py3-setuptools
ADD /launchpad-api /usr/bin/launchpad-api
RUN chmod +x /usr/bin/launchpad-api
ADD /check /opt/resource/check
ADD /out /opt/resource/out
ADD /in /opt/resource/in
RUN chmod +x /opt/resource/*
