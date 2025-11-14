#!/command/with-contenv sh
echo "$PERKEEP_IDENTITY_SECRET_RING" | base64 -d > /var/perkeep/identity-secring.gpg
chown keeper:perkeep /var/perkeep/identity-secring.gpg
chmod 600 /var/perkeep/identity-secring.gpg
