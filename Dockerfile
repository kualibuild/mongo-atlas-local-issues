FROM node:20-alpine

# Needed for bcrypt
# RUN apk --no-cache add --virtual builds-deps build-base python2

# Create app directory
RUN mkdir -p /app && chown node:node /app
USER node
WORKDIR /app

# Install dependencies
COPY --chown=node:node package*.json ./
RUN npm ci

# Bundle app source
COPY --chown=node:node index.js ./

# Exports
EXPOSE 3000
CMD [ "node", "index.js" ]
