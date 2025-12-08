FROM alpine:3.22
LABEL maintainer="Nikita Galaiko nikita@galaiko.rocks"
# Install s6-overlay
ARG S6_OVERLAY_VERSION=3.2.1.0
ADD "https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-noarch.tar.xz" /tmp
ADD "https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-aarch64.tar.xz" /tmp
ADD "https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-x86_64.tar.xz" /tmp
RUN \
    sha256sum "/tmp/s6-overlay-noarch.tar.xz"; \
    echo "4b0c0907e6762814c31850e0e6c6762c385571d4656eb8725852b0b1586713b6  /tmp/s6-overlay-noarch.tar.xz" | sha256sum -c; \
    tar -C / -Jxpf /tmp/s6-overlay-noarch.tar.xz; \
    \
    case "$(uname -m)" in \
        "x86_64") \
            sha256sum "/tmp/s6-overlay-x86_64.tar.xz"; \
            echo "868973e98210257bba725ff5b17aa092008c9a8e5174499e38ba611a8fc7e473  /tmp/s6-overlay-x86_64.tar.xz" | sha256sum -c; \
            tar -C / -Jxpf /tmp/s6-overlay-x86_64.tar.xz; \
            ;; \
        "aarch64") \
            sha256sum "/tmp/s6-overlay-aarch64.tar.xz"; \
            echo "868973e98210257bba725ff5b17aa092008c9a8e5174499e38ba611a8fc7e473  /tmp/s6-overlay-aarch64.tar.xz" | sha256sum -c; \
            tar -C / -Jxpf /tmp/s6-overlay-aarch64.tar.xz; \
            ;; \
        *) \
          echo "Cannot build, missing valid build platform." \
          exit 1; \
    esac; \
    rm -rf "/tmp/*";
COPY init-wrapper /
# install dependencies
# - gettext for envsubst 
# - libjpeg-turbo-utils for djpeg (pekeep wants it)
RUN apk add --no-cache gettext libjpeg-turbo-utils
# install perkeep
ADD "https://github.com/perkeep/perkeep/releases/download/v0.12/perkeep-linux-amd64.tar.gz" /tmp
RUN sha256sum /tmp/perkeep-linux-amd64.tar.gz && \
	echo "548c4d490c1ca3d65fef84a16c9c03b43f6a8bd8a33a8fea75d018d9b1510bf4  /tmp/perkeep-linux-amd64.tar.gz" | sha256sum -c && \
	tar -C /tmp -xzf /tmp/perkeep-linux-amd64.tar.gz && \
    mv /tmp/perkeepd /usr/local/bin/perkeepd && \
    chmod +x /usr/local/bin/perkeepd && \
    rm -rf /tmp/*
# install tailscale
COPY --from=ghcr.io/tailscale/tailscale:latest /usr/local/bin/tailscale  /usr/local/bin/tailscale
COPY --from=ghcr.io/tailscale/tailscale:latest /usr/local/bin/tailscaled /usr/local/bin/tailscaled
# add config files files
COPY etc/ /etc/
# add user for perkeep process
# and sure it owns perkeep's directories
RUN addgroup --system --gid 1001 perkeep && \
	adduser --system --uid 1001 --ingroup perkeep keeper && \
	mkdir -p /var/perkeep && \
	chown -R keeper:perkeep /var/perkeep && \
	chown -R keeper:perkeep /etc/perkeep
ENTRYPOINT ["/init-wrapper"]
