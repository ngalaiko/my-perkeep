# perkeep

This are configs for my personal perkeep instance hosted on [fly.io](https://fly.io) and exposed into [tailscale](https://tailscale.com) network 

image is built around [s6-overlay](https://github.com/just-containers/s6-overlay) for process supervision

## setup

### [fly](https://fly.io)

```bash
fly auth login
```

### gpg identity

i did not figure out how to make perkeep accept my newly generated gpg key, so i am using the one they generate by default

you can generate it by starting `perkeepd` locally, and it will generate a secring in the `.config/perkeep`

then, upload the secring as a secret into fly

```
fly secrets set PERKEEP_IDENTITY_SECRET_RING=$(cat ./var/perkeep/identity-secring.gpg | base64)
```

also, update identity in [server-config.json.template](./etc/perkeep/server-config.json.template)

### [tailscale](https://tailscale.com)

generate auth key [here](https://login.tailscale.com/admin/settings/keys). make sure key is
- [x] reusable
- [x] ephemeral
- [x] pre-approved (if devide approval is enabled)

```bash
fly secrets set TS_AUTHKEY=<your tailscale auth key>
```

then go to "services" and create service named "prekeep". ports are 80, 443.
container will advertise this service for stable hostname like `perkeep.<network name>.ts.net`


### [backblaze](https://www.backblaze.com/)

make sure `b2` is up to date in [server-config.template.json](./etc/perkeep/server-config.json.template), format is `accessKey:secretKey:bucketName[/optional/dir]:hostname`

```bash
fly secrets set BACKBLAZE_SECRET_KEY=<secret key>
```

### [neon](https://neon.com)

make sure `postgres` is up to date in [server-config.template.json](./etc/perkeep/server-config.json.template), format is `user@host:password`

note that you'll need to make sure that database exists with the same name as `user`

```bash
fly secrets set NEONTECH_PASSWORD=<secret key>
```

that should be enough, just `fly deploy` now
