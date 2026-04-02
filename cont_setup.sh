#!/bin/bash
set -e

echo "Custom container setup commands here..."

CONT_USER="dubian"

# Setup services
su $CONT_USER -c /bin/bash <<EOF
cd /home/$CONT_USER

# vs-code cli
curl -Lk 'https://code.visualstudio.com/sha/download?build=stable&os=cli-alpine-x64' --output vscode_cli.tar.gz
tar -xf vscode_cli.tar.gz
rm vscode_cli.tar.gz

EOF
