FROM php:8.2-cli

# Install MySQL PDO driver
RUN docker-php-ext-install pdo_mysql

# Install Python + pip for YOLO inference and common deps
RUN apt-get update \
  && apt-get install -y --no-install-recommends python3 python3-pip \
  && pip3 install --no-cache-dir ultralytics pillow numpy \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY . /app

EXPOSE 8080

CMD ["sh", "-c", "php -S 0.0.0.0:${PORT:-8080} -t ."]
