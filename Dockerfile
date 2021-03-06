# Use the standard Nginx image from Docker Hub which is based on debian:stretch-slim
FROM nginx

# build with 
# sudo docker build -t shimwell/nginx .
# run with
# sudo docker run -p 8080:8080 --network host -u 143 shimwell/nginx
# navigate to http://127.0.0.1:8080/

ENV HOME=/opt/repo

# install python, uwsgi, and supervisord
RUN apt-get update && apt-get install -y supervisor uwsgi python3 python3-pip procps vim
    
RUN pip3 install uwsgi
    
RUN pip3 install flask

RUN pip3 install pymongo 
RUN pip3 install Flask-Cors



# Source code file
RUN echo 'copying updated srsc'
RUN echo 'copying updated src'
COPY src ${HOME}/src

# Copy the configuration file from the current directory and paste 
# it inside the container to use it as Nginx's default config.
COPY deployment/nginx.conf /etc/nginx/nginx.conf

# setup NGINX config
RUN mkdir -p /spool/nginx /run/pid && \
    chmod -R 777 /var/log/nginx /var/cache/nginx /etc/nginx /var/run /run /run/pid /spool/nginx && \
    chgrp -R 0 /var/log/nginx /var/cache/nginx /etc/nginx /var/run /run /run/pid /spool/nginx && \
    chmod -R g+rwX /var/log/nginx /var/cache/nginx /etc/nginx /var/run /run /run/pid /spool/nginx && \
    rm /etc/nginx/conf.d/default.conf

# Copy the base uWSGI ini file to enable default dynamic uwsgi process number
# RUN echo recopy
COPY deployment/uwsgi.ini /etc/uwsgi/apps-available/uwsgi.ini
RUN ln -s /etc/uwsgi/apps-available/uwsgi.ini /etc/uwsgi/apps-enabled/uwsgi.ini

COPY deployment/supervisord.conf /etc/supervisor/conf.d/supervisord.conf
RUN touch /var/log/supervisor/supervisord.log

EXPOSE 8080:8080

# setup entrypoint
COPY deployment/docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh

# access to /dev/stdout
# https://github.com/moby/moby/issues/31243#issuecomment-406879017
RUN ln -s /usr/local/bin/docker-entrypoint.sh / && \
    chmod 777 /usr/local/bin/docker-entrypoint.sh && \
    chgrp -R 0 /usr/local/bin/docker-entrypoint.sh && \
    chown -R nginx:root /usr/local/bin/docker-entrypoint.sh

# https://docs.openshift.com/container-platform/3.3/creating_images/guidelines.html
RUN chgrp -R 0 /var/log /var/cache /run/pid /spool/nginx /var/run /run /tmp /etc/uwsgi /etc/nginx && \
    chmod -R g+rwX /var/log /var/cache /run/pid /spool/nginx /var/run /run /tmp /etc/uwsgi /etc/nginx && \
    chown -R nginx:root ${HOME} && \
    chmod -R 777 ${HOME} /etc/passwd

# from flask import Flask
# from flask import Flask, jsonify, render_template, request, Response, send_file



# import requests
# import json
# from bson import json_util
# from bson.objectid import ObjectId
# import requests
# import re
# from flask import Flask
# from flask import Flask, jsonify, render_template, request, Response
# from flask_cors import CORS, cross_origin
# import os
# from data_formatting_tools import *
# from database_tools import *
# from io import BytesIO
# from io import StringIO



# enter
WORKDIR ${HOME}
ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["supervisord"]