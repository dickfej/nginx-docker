FROM cgr.dev/chainguard/wolfi-base AS nxbuild
WORKDIR /
RUN apk add --no-cache \
    build-base \
    openssl-dev \
    pcre-dev \
    zlib-dev \
    git

RUN git clone https://github.com/nginx/nginx.git
RUN cd  /nginx && \
    LATEST_RELEASE=$(git tag -l --sort=-v:refname | grep -E '^release-' | head -n 1) && \
    echo "最新 Release 标签为: $LATEST_RELEASE" && \
    git checkout $LATEST_RELEASE
RUN cp /nginx/auto/configure /nginx/
RUN ./configure \
    --with-http_ssl_module \
    --with-stream \
    --with-stream_ssl_preread_module
RUN make && make install

FROM cgr.dev/chainguard/wolfi-base
LABEL Name=nginx-slim
EXPOSE 80 443
COPY --from=nxbuild /usr/local/nginx/ /usr/local/nginx/
RUN apk add --no-cache \
    pcre \
    openssl \
    zlib &&\
    mkdir -p /usr/local/nginx/logs/
VOLUME /usr/local/nginx/html /usr/local/nginx/conf /usr/local/nginx/logs
ENV PATH=/usr/local/nginx/sbin
ENTRYPOINT ["nginx"]
CMD ["-g","daemon off;"]


