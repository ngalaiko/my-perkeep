#!/command/with-contenv sh
tailscale up --auth-key "$TS_AUTHKEY" --ssh
tailscale serve set-config --all /etc/tailscale/serveconfig.json
tailscale serve get-config --all
tailscale serve advertise svc:perkeep
