# images
FROM ubuntu:latest

# source files
ADD . /opt/crawlab

# install python
RUN apt-get update
RUN apt-get install -y python3 python3-pip net-tools iputils-ping git nginx

# soft link
RUN ln -s /usr/bin/pip3 /usr/local/bin/pip
RUN ln -s /usr/bin/python3 /usr/local/bin/python

# install backend
RUN pip install -U setuptools
RUN pip install -r /opt/crawlab/crawlab/requirements.txt

# install nvm
RUN curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.33.11/install.sh | bash
RUN export NVM_DIR="$HOME/.nvm"
RUN [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
RUN nvm install 8.12
RUN nvm use 8.12

# install frontend
WORKDIR /opt/crawlab/frontend
RUN npm install -g yarn pm2
RUN yarn install

# nginx config & start frontend
RUN cp /opt/crawlab/crawlab.conf /etc/nginx/conf.d
RUN service nginx reload

# start backend
WORKDIR /opt/crawlab/crawlab
CMD pm2 start app.py
CMD pm2 start flower.py
CMD pm2 start worker.py
