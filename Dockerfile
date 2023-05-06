FROM ubuntu:jammy

COPY entrypoint.sh /entrypoint.sh
COPY default.cfg /default.cfg
RUN chmod +x entrypoint.sh

RUN apt-get update
RUN apt-get -y install uncrustify=0.72.0+dfsg1-2 colordiff

ENTRYPOINT ["/entrypoint.sh"]
