FROM debian:buster-slim
COPY ./setup.sh /setup.sh
CMD ["/usr/local/lib/rstudio-server/bin/rserver", "--server-daemonize=0", "--server-app-armor-enabled=0"]
EXPOSE 8787
