FROM debian:10

RUN apt-get update -y
RUN apt-get install -y nasm vim gcc g++ nano man-db

COPY PN--jadro-linux* /home/root/
COPY run_chodur_patryk.sh /home/root/

WORKDIR /home/root
RUN find /home/root -name '*.sh' | xargs chmod 755
