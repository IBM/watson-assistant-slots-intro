FROM node

RUN apt-get update && apt-get install -y jq

EXPOSE 3000

WORKDIR /app

ADD . /app

RUN npm install

CMD [ "/app/run-server.sh"]
