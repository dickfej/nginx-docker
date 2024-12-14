FROM alpine:latest as nxbuild
WORKDIR /
RUN apk add build-base git pcre pcre-dev openssl openssl-dev zlib zlib-dev wget && \
  git clone https://github.com/nginx/nginx.git && \
  cd ./nginx && \
  cp ./auto/configure . && \
  ./configure --with-http_ssl_module --with-stream --with-stream_ssl_preread_module && \
  make && make install

FROM alpine:latest
LABEL Name=nginx-docker
EXPOSE 80 443
COPY --from=nxbuild /usr/local/nginx/ /usr/local/nginx/
RUN apk add pcre openssl zlib 
VOLUME /usr/local/nginx/html /usr/local/nginx/conf /usr/local/nginx/logs
ENV PATH /usr/local/nginx/sbin:$PATH
ENTRYPOINT ["nginx"]
CMD ["-g","daemon off;"]


