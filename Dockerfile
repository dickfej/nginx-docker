FROM debian:bookworm-slim AS nxbuild
WORKDIR /
RUN apt-get update && \
    apt-get install -y \ 
    build-essential libpcre3-dev zlib1g-dev libssl-dev git && \
    rm -rf /var/lib/apt/lists/* && \
    git clone https://github.com/nginx/nginx.git && \
    cd  /nginx && \
    cp /nginx/auto/configure /nginx/ && \
    ./configure \
    --with-http_ssl_module \
    --with-stream \
    --with-stream_ssl_preread_module &&\
    make && make install

FROM debian:bookworm-slim
LABEL Name=nginx-slim
EXPOSE 80 443
COPY --from=nxbuild /usr/local/nginx/ /usr/local/nginx/
RUN apt-get update && \
    apt-get install -y \
    libpcre3 zlib1g libssl3 \
    --no-install-recommends &&\
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    mkdir -p /usr/local/nginx/logs/
VOLUME /usr/local/nginx/html /usr/local/nginx/conf /usr/local/nginx/logs
ENV PATH=/usr/local/nginx/sbin
ENTRYPOINT ["nginx"]
CMD ["-g","daemon off;"]


