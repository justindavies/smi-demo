FROM nginx:latest
COPY ./index.html /usr/share/nginx/html/index.html
COPY ./world.gif /usr/share/nginx/html/world.gif

