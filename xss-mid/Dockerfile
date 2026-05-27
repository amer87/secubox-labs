FROM kasmweb/kali-rolling:1.16.0
USER root

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENV CTF_FLAG=FLAG{placeholder}
ENV VNC_PW=secubox
ENV NO_SSL=true

EXPOSE 6901
ENTRYPOINT ["/entrypoint.sh"]