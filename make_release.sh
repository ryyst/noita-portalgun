#!/bin/sh

OUTPUT="portalgun_$(date -I)_$(git rev-parse --short HEAD).zip"

echo "Zipping HEAD to archive $OUTPUT..."

git archive -o $OUTPUT --prefix=portalgun/ --format=zip HEAD
echo "Done!"
