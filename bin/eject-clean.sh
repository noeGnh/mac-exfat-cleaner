#!/bin/bash
# Usage: ./eject-clean.sh MyDriveName

VOLUME="$1"
MOUNT="/Volumes/$VOLUME"

if [ -z "$VOLUME" ] || [ ! -d "$MOUNT" ]; then
  echo "❌ Volume not found."
  exit 1
fi

echo "🧼 Cleaning $MOUNT..."
dot_clean -m "$MOUNT"
find "$MOUNT" -name '._*' -delete

echo "⏏️ Ejecting $VOLUME..."
diskutil eject "$MOUNT"
