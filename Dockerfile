FROM node:12-alpine3.10
ENV NODE_ENV production
WORKDIR /app
COPY package.json .
COPY package-lock.json .
RUN npm install
COPY . .
RUN echo ${version} > ./VERSION
RUN npm run build

# N.B. the image must be run as a non-root user
RUN adduser -D 7654
USER 7654

CMD [ "npm", "start" ]