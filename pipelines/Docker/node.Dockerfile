FROM node:22-apline

RUN apk add -update nodejs nvm yarn \
	apk upgrade --availible \
	npm install npm@10.9.0 -g
