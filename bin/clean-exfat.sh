#!/bin/bash
# ~/bin/clean-exfat.sh

VOLUMES=$(diskutil list | grep 'Microsoft Basic Data' | awk '{print $NF}')

for V in $VOLUMES; do
    MOUNT="/Volumes/$V"
    if [ -d "$MOUNT" ]; then
        echo "🧹 Cleaning $MOUNT"
        dot_clean -m "$MOUNT"
        find "$MOUNT" -name '._*' -delete
    fi
done
