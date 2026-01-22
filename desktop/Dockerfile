ARG VERSION=12

FROM debian:${VERSION}-slim
LABEL maintainer="codex"

ARG DEBIAN_FRONTEND=noninteractive

WORKDIR /tmp

ENV USER=debaian \
    SUDO_GROUP=sudo

# Install dependencies.
RUN apt update && apt upgrade -y \
    && apt install -y --no-install-recommends \
       sudo systemd systemd-sysv \
       build-essential libffi-dev libssl-dev procps ca-certificates \
       python3-dev curl wget nano git \
       iproute2 \
       xfce4 xfce4-goodies

# Install VNC Service
RUN wget -O kasmvnc.deb https://github.com/kasmtech/KasmVNC/releases/download/v1.4.0/kasmvncserver_bookworm_1.4.0_amd64.deb \
    && apt install -y ./kasmvnc.deb \
    && rm -f /tmp/kasmvnc.deb

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
COPY ./cont_setup.sh /tmp/cont_setup.sh
RUN chmod +x /tmp/cont_setup.sh && /tmp/cont_setup.sh && rm -f /tmp/cont_setup.sh

COPY ./cont_startup.sh /usr/bin/cont_startup.sh
RUN chmod +x /usr/bin/cont_startup.sh

WORKDIR /home/${USER}

ENTRYPOINT ["/usr/bin/cont_startup.sh"]

CMD [""]

