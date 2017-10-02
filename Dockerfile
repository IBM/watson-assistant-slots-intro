FROM node
EXPOSE 3000

RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app

ADD . /usr/src/app

RUN npm install 

CMD [ "/usr/src/app/run-server.sh"]
