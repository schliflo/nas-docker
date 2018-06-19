FROM nextcloud:fpm

# install tesseract for OCR capabilities
RUN set -ex; \
    \
    apt-get update; \
    apt-get install -y --no-install-recommends \
        tesseract-ocr \
        tesseract-ocr-eng \
        tesseract-ocr-deu \
    ; \
    \
    apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false; \
    rm -rf /var/lib/apt/lists/*;

# configure redis
COPY redis.config.php /usr/src/nextcloud/config/redis.config.php
