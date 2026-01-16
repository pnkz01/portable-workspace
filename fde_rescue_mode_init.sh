#!/bin/bash
set -euo pipefail

# prepare existing filesystem for luks encryption
DISK="${1:-}"

if [ -z "$DISK" ]; then
        echo "Usage: $0 /dev/sdXY"
        exit 1
fi

# Run a filesystem check
e2fsck -f "$DISK"

# install cryptsetup
apt update && apt install cryptsetup -y

# Make the filesystem slightly smaller to make space for the LUKS header
BLOCK_SIZE=`dumpe2fs -h $DISK | grep "Block size" | cut -d ':' -f 2 | tr -d ' '`
BLOCK_COUNT=`dumpe2fs -h $DISK | grep "Block count" | cut -d ':' -f 2 | tr -d ' '`
SPACE_TO_FREE=$((1024 * 1024 * 32)) # 16MB should be enough, but add a safety margin
NEW_BLOCK_COUNT=$(($BLOCK_COUNT - $SPACE_TO_FREE / $BLOCK_SIZE))
resize2fs -p "$DISK" "$NEW_BLOCK_COUNT"

# encrypt disk
cryptsetup reencrypt --encrypt --reduce-device-size 16M "$DISK"

# Resize the filesystem to fill up the remaining space (i.e. remove the safety margin from earlier)
cryptsetup open "$DISK" recrypt
resize2fs /dev/mapper/recrypt
cryptsetup close recrypt

# PBKDF:      pbkdf2
# should be pbkdf2 not argon2id for grub to unlock using correct key format
cryptsetup luksDump "$DISK"
cryptsetup luksConvertKey --pbkdf pbkdf2 "$DISK"
cryptsetup luksDump "$DISK"
cryptsetup --verbose open --test-passphrase "$DISK"
