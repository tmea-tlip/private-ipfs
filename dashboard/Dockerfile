FROM nginx:alpine

# Working DIR
WORKDIR /usr/src/app

# Copy everything from current Folder
COPY . ./

# A minimal NGINX configuration
RUN echo 'server {\
  listen       8080;\
  server_name  localhost;\
  location / {\
  root   /usr/src/app/build;\
  index  index.html index.htm;\
  try_files $uri /index.html;\
  }\
  }' > /etc/nginx/conf.d/default.conf

RUN mkdir /run/nginx
EXPOSE 8080

# Serve the prod build
CMD ["nginx", "-g", "daemon off;"]