FROM nginx:alpine
COPY index.html /usr/share/nginx/html/index.html
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENV CTF_FLAG=FLAG{placeholder}
EXPOSE 80
ENTRYPOINT ["/entrypoint.sh"]
