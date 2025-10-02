# My homelab setup
## Ingress
The `ingress/` folder contains a compose setup with Tailscale and Traefik. With this I can expose other apps running on the server to either my tailnet or the internet.
- The `compose.yaml` file contains the container configurations for the two services and the **traefik** docker network definition.
  I put all the services I want to expose in the **traefik** docker network so that the Traefik container can see them.
- Another file in here is `.env` which 
- Inside the `config/` folder are the base configuration files for Traefik.
