# perkeep

This are configs for my personal perkeep instance hosted on [fly.io](https://fly.io) and exposed into [tailscale](https://tailscale.com) network 

image is built around [s6-overlay](https://github.com/just-containers/s6-overlay) for process supervision

## setup

you need two things:

1. setup gpg identity

i did not figure out how to make perkeep accept my newly generated gpg key, so i am using the one they generate by default

you can generate it by starting `perkeepd` locally, and it will generate a secring in the `.config/perkeep`

then, upload the secring as a secret into fly

```
fly secrets set PERKEEP_IDENTITY_SECRET_RING=$(cat ./var/perkeep/identity-secring.gpg | base64)
```

also, update identity in [server-config.json.template](./etc/perkeep/server-config.json.template)

2. setup tailscale auth key

generate auth key [here](https://login.tailscale.com/admin/settings/keys). make sure key is
- [x] reusable
- [x] ephemeral
- [x] pre-approved (if devide approval is enabled)

```bash
fly secrets set TS_AUTHKEY=<your tailscale auth key>
```

that should be enough, just `fly deploy` now
