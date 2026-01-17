ARG VERSION=12

FROM debian:${VERSION}-slim
LABEL maintainer="khodex"

ARG DEBIAN_FRONTEND=noninteractive

WORKDIR /tmp

ENV USER=dubian \
    SUDO_GROUP=sudo \
    VNC_VER=1.4.0 \
    VNC_PKG=kasmvncserver_bookworm_1.4.0_amd64.deb

# Install dependencies.
RUN apt update && apt upgrade -y \
    && apt install -y --no-install-recommends \
       sudo systemd systemd-sysv \
       build-essential wget curl libffi-dev libssl-dev procps ca-certificates \
       python3-dev nano git \
       iproute2 \
       xfce4 xfce4-goodies

# Install VNC Service
RUN wget https://github.com/kasmtech/KasmVNC/releases/download/v${VNC_VER}/${VNC_PKG} \
    && apt install -y ./${VNC_PKG} \
    && rm -f /tmp/${VNC_PKG}

# Install additional services
# Firebox
RUN sudo install -d -m 0755 /etc/apt/keyrings \
    && wget -q https://packages.mozilla.org/apt/repo-signing-key.gpg -O- | sudo tee /etc/apt/keyrings/packages.mozilla.org.asc > /dev/null \
    && gpg -n -q --import --import-options import-show /etc/apt/keyrings/packages.mozilla.org.asc | awk '/pub/{getline; gsub(/^ +| +$/,""); if($0 == "35BAA0B33E9EB396F59CA838C0BA5CE6DC6315A3") print "\nThe key fingerprint matches ("$0").\n"; else print "\nVerification failed: the fingerprint ("$0") does not match the expected one.\n"}' \
    && echo "deb [signed-by=/etc/apt/keyrings/packages.mozilla.org.asc] https://packages.mozilla.org/apt mozilla main" | sudo tee -a /etc/apt/sources.list.d/mozilla.list > /dev/null \
    && echo '\
Package: *\
Pin: origin packages.mozilla.org\
Pin-Priority: 1000\
' | sudo tee /etc/apt/preferences.d/mozilla \
   && apt update && apt install firefox -y

# VS Code
RUN apt install gpg apt-transport-https -y \
    && wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg \
    && sudo install -D -o root -g root -m 644 microsoft.gpg /usr/share/keyrings/microsoft.gpg \
    && rm -f microsoft.gpg \
    && echo 'deb [signed-by=/usr/share/keyrings/microsoft.gpg] https://packages.microsoft.com/repos/code stable main' | sudo tee /etc/apt/sources.list.d/vscode.sources.list \
    && apt update && apt install code -y && rm -f /etc/apt/sources.list.d/vscode.sources.list

# Remove data to reduce image size
RUN rm -rf /var/lib/apt/lists/* \
    && rm -Rf /usr/share/doc && rm -Rf /usr/share/man \
    && apt clean \
# Make sure systemd doesn't start agettys on tty[1-6].
    && rm -f /lib/systemd/system/multi-user.target.wants/getty.target \
# Create non-root user with sudo access
    && set -xe \
    && groupadd -r ${USER} \
    && useradd -m -g ${USER} ${USER} \
    && usermod -aG ${SUDO_GROUP} ${USER} \
    && sed -i "/^%${SUDO_GROUP}/s/ALL\$/NOPASSWD:ALL/g" /etc/sudoers \
# Add user to ssl-cert group
    && adduser ${USER} ssl-cert

# Setup VNC Service
COPY ./setup.sh /tmp/setup.sh
RUN chmod +x /tmp/setup.sh && /tmp/setup.sh && rm -f /tmp/setup.sh

CMD ["/lib/systemd/systemd"]

WORKDIR /home/${USER}
