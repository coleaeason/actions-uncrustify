FROM debian:latest

COPY entrypoint.sh /entrypoint.sh
COPY default.cfg /default.cfg

RUN chmod +x entrypoint.sh
RUN curl -o uncrustify-0.67.tar.gz https://github.com/uncrustify/uncrustify/archive/uncrustify-0.67.tar.gz
RUN tar -xf uncrustify-0.67.tar.gz
RUN cd uncrustify-uncrustify-0.67
RUN mkdir build
RUN cd build
RUN cmake ..
RUN cmake --build .

ENTRYPOINT ["/entrypoint.sh"]
