FROM resin/rpi-raspbian as raspbian


RUN apt-get update \
  && apt-get install -y wget git build-essential libcurl4-openssl-dev libsqlite3-dev \
  && wget https://github.com/ldc-developers/ldc/releases/download/v1.12.0/ldc2-1.12.0-linux-armhf.tar.xz -O ldc2.tar.xz \
  && tar -xf ldc2.tar.xz \
  && mv ldc2-* ldc2 \
  && git clone https://github.com/skilion/onedrive.git \
  && cd onedrive \
  && make DC=../ldc2/bin/ldmd2 \
  && make install


# Primary image
FROM eddible/s6-debian-rpi:latest

RUN apt-get update \
  && apt-get install -y libcurl4-openssl-dev libsqlite3-dev \
  && mkdir /documents \
  && chown abc:abc /documents

COPY --from=raspbian /usr/local/bin/onedrive /usr/local/bin/onedrive
COPY root /

ENV S6_BEHAVIOUR_IF_STAGE2_FAILS 2

CMD ["/start.sh"]
