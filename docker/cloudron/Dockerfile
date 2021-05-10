FROM moonmeister/photoprism-build as build
# Same base image as photoprism/development
FROM cloudron/base:3.0.0@sha256:455c70428723e3a823198c57472785437eb6eab082e79b3ff04ea584faf46e92

# Set environment variables
ENV DEBIAN_FRONTEND noninteractive

# Configure apt-get
RUN echo 'Acquire::Retries "10";' > /etc/apt/apt.conf.d/80retry && \
    echo 'APT::Install-Recommends "false";' > /etc/apt/apt.conf.d/80recommends && \
    echo 'APT::Install-Suggests "false";' > /etc/apt/apt.conf.d/80suggests && \
    echo 'APT::Get::Assume-Yes "true";' > /etc/apt/apt.conf.d/80forceyes && \
    echo 'APT::Get::Fix-Missing "true";' > /etc/apt/apt.conf.d/80fixmissin

# Install additional distribution packages
RUN apt-get update && apt-get install -y --no-install-recommends \
        wget \
        curl \
        davfs2 \
        ca-certificates \
        mariadb-client \
        sqlite3 \
        tzdata \
        libheif-examples \
        gnupg \
        gpg-agent \
        apt-utils \
        add-apt-key \
        exiftool \
        darktable \
        rawtherapee \
        ffmpeg \
        ffmpegthumbnailer \
        libavcodec-extra && \
        apt-get update && \
        apt-get dist-upgrade && \
        apt-get autoremove && \
        apt-get clean && \
        rm -rf /var/lib/apt/lists/*

# Copy dependencies
# COPY --from=build /go/bin/gosu /bin/gosu
COPY --from=build /usr/lib/libtensorflow.so /usr/lib/libtensorflow.so
COPY --from=build /usr/lib/libtensorflow_framework.so /usr/lib/libtensorflow_framework.so
RUN ldconfig

# Set default umask and create photoprism user
# RUN umask 0000 && useradd photoprism -m -d /photoprism
WORKDIR /app/code

ENV TF_CPP_MIN_LOG_LEVEL 2

# ENV PATH /photoprism/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
ENV PATH /app/code/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

ENV TMPDIR /tmp

# Storage path names
ENV PHOTOPRISM_ASSETS_PATH="/app/code/assets" \
    PHOTOPRISM_STORAGE_PATH="/app/data/storage" \
    PHOTOPRISM_BACKUP_PATH="/app/data/backup" \
    PHOTOPRISM_ORIGINALS_PATH="/app/data/originals" \
    PHOTOPRISM_IMPORT_PATH="/app/data/import" \
    PHOTOPRISM_LOG_FILENAME="/dev/stdout" \
    PHOTOPRISM_PID_FILENAME="/run/photoprism.pid"

# Defaults for common config values
# See https://docs.photoprism.org/getting-started/config-options/
ENV PHOTOPRISM_DEBUG="false" \
    PHOTOPRISM_PUBLIC="false" \
    PHOTOPRISM_READONLY="false" \
    PHOTOPRISM_UPLOAD_NSFW="true" \
    PHOTOPRISM_DETECT_NSFW="false" \
    PHOTOPRISM_EXPERIMENTAL="false" \
    PHOTOPRISM_SITE_TITLE="PhotoPrism" \
    PHOTOPRISM_SITE_CAPTION="Browse Your Life" \
    PHOTOPRISM_SITE_DESCRIPTION="" \
    PHOTOPRISM_SITE_AUTHOR="" \
    PHOTOPRISM_HTTP_HOST="0.0.0.0" \
    PHOTOPRISM_HTTP_PORT=2342 \
    PHOTOPRISM_DATABASE_DRIVER="mysql" \
    PHOTOPRISM_DISABLE_WEBDAV="false" \
    PHOTOPRISM_DISABLE_SETTINGS="false" \
    PHOTOPRISM_DISABLE_BACKUPS="true" \
    PHOTOPRISM_DISABLE_EXIFTOOL="false" \
    PHOTOPRISM_DISABLE_PLACES="false" \
    PHOTOPRISM_DISABLE_TENSORFLOW="false" \
    PHOTOPRISM_DARKTABLE_PRESETS="false" \
    PHOTOPRISM_THUMB_FILTER="lanczos" \
    PHOTOPRISM_THUMB_UNCACHED="false" \
    PHOTOPRISM_THUMB_SIZE=2048 \
    PHOTOPRISM_THUMB_SIZE_UNCACHED=7680 \
    PHOTOPRISM_JPEG_SIZE=7680 \
    PHOTOPRISM_JPEG_QUALITY=92 \
    PHOTOPRISM_WORKERS=0 \
    PHOTOPRISM_WAKEUP_INTERVAL=900 \
    PHOTOPRISM_AUTO_INDEX=300 \
    PHOTOPRISM_AUTO_IMPORT=300 \
    PHOTOPRISM_ADMIN_PASSWORD="change_me"

# Copy files to /photoprism
COPY --from=build /root/.local/bin/photoprism /app/code/bin/photoprism
COPY --from=build /root/.photoprism/assets /app/code/assets
COPY --chown=root:root --chmod=755 /docker/scripts/heif-convert.sh /usr/local/bin/heif-convert

# Create directories
RUN mkdir -p \
    /tmp/photoprism \ && \
    chown -Rf cloudron:cloudron /tmp/photoprism && \
    chmod -Rf a+rw /tmp/photoprism

# Show photoprism version
RUN photoprism -v

# Expose http port
EXPOSE 2342

# Configure entrypoint
# COPY --chown=root:root /docker/scripts/entrypoint.sh /entrypoint.sh
# ENTRYPOINT ["/entrypoint.sh"]
# VOLUME /var/lib/photoprism

# Run server
# CMD ["photoprism", "start"]
ADD /docker/cloudron/start.sh /app/code/start.sh
CMD [ "/app/code/start.sh" ]