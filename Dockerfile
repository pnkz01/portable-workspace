ARG VERSION=13

FROM debian:${VERSION}-slim
LABEL maintainer="khodex"

ARG DEBIAN_FRONTEND=noninteractive

WORKDIR /tmp

ENV USER=dubian \
    SUDO_GROUP=sudo

# Install dependencies.
RUN apt update && apt upgrade -y \
    && apt install -y --no-install-recommends \
       sudo systemd systemd-sysv \
       build-essential libffi-dev libssl-dev procps ca-certificates wget curl \
       python3-dev nano git \
       iproute2

# Remove data to reduce image size
RUN rm -rf /var/lib/apt/lists/* \
    && apt clean \
# Make sure systemd doesn't start agettys on tty[1-6].
    && rm -f /lib/systemd/system/multi-user.target.wants/getty.target \
# Create non-root user with sudo access
    && set -xe \
    && groupadd -r ${USER} \
    && useradd -m -g ${USER} ${USER} \
    && usermod -aG ${SUDO_GROUP} ${USER} \
    && sed -i "/^%${SUDO_GROUP}/s/ALL\$/NOPASSWD:ALL/g" /etc/sudoers

# Setup VNC Service
COPY ./cont_setup.sh /tmp/cont_setup.sh
RUN chmod +x /tmp/cont_setup.sh && /tmp/cont_setup.sh && rm -f /tmp/cont_setup.sh

COPY ./cont_startup.sh /usr/bin/cont_startup.sh
RUN chmod +x /usr/bin/cont_startup.sh

WORKDIR /home/${USER}

ENTRYPOINT ["/usr/bin/cont_startup.sh"]

CMD [""]

