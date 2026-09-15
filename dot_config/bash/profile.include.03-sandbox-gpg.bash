#! /usr/bin/env bash

# KiroCrew sandbox: point GPG at the persistent keyring.
# The sandbox bind-mounts an empty dir over ~/.gnupg and scrubs GNUPGHOME,
# so gopass/gpg can't find the real keys. /mnt/persistent/cpaton/.gnupg
# is the same keyring on the persistent EBS volume, outside the mask list.
if [ "$KIROCREW_SANDBOX_ACTIVE" = "1" ]; then
    export GNUPGHOME=/mnt/persistent/cpaton/.gnupg
fi
