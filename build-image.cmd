docker build -t nginx-docker:latest .
docker save nginx-docker:latest | gzip > .\images\nginx-docker.tar.gz