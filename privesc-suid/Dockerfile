FROM kasmweb/core-ubuntu-focal:1.16.0

USER root

# Install only what the lab needs
RUN apt-get update && apt-get install -y --no-install-recommends \
    bash \
    findutils \
    && rm -rf /var/lib/apt/lists/*

# Set SUID bit on /usr/bin/find — the intentional vulnerability
# kasm-user is the low-priv user the student lands as
RUN chmod u+s /usr/bin/find

# Write a motd so the player knows where to start
RUN printf '\n\
  ██████╗ ██████╗ ██╗██╗   ██╗███████╗███████╗ ██████╗\n\
  ██╔══██╗██╔══██╗██║██║   ██║██╔════╝██╔════╝██╔════╝\n\
  ██████╔╝██████╔╝██║██║   ██║█████╗  ███████╗██║     \n\
  ██╔═══╝ ██╔══██╗██║╚██╗ ██╔╝██╔══╝  ╚════██║██║     \n\
  ██║     ██║  ██║██║ ╚████╔╝ ███████╗███████║╚██████╗\n\
  ╚═╝     ╚═╝  ╚═╝╚═╝  ╚═══╝  ╚══════╝╚══════╝ ╚═════╝\n\
\n\
  Lab: Linux Privilege Escalation\n\
  User: player  |  Goal: read /root/flag.txt\n\
  Hint: look for binaries with unusual permissions\n\
' > /etc/motd

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENV CTF_FLAG=FLAG{placeholder}
ENV VNC_PW=vncpassword
# Disable Kasm's self-signed TLS — nginx ingress terminates TLS externally
ENV NO_SSL=true

EXPOSE 6901

ENTRYPOINT ["/entrypoint.sh"]
