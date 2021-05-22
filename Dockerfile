# Use nodejs image on Alpine as our base builder image - it has all the packages we need
# FROM node:14.0.0-alpine3.10 AS builder
FROM node:14.0.0-alpine AS builder

WORKDIR /app
ADD . /app

# Install dependencies
RUN npm install

# Build our deployable image based on UBI
FROM registry.access.redhat.com/ubi8/nodejs-14:1-31 
COPY --from=builder /app .

# Start app
EXPOSE 3000

CMD [ "npm","start"]

# Add label information that will be associated with our image. This is another
# requirement for building a certifiable image.
LABEL name="dev-rh/watson-assistant-slots-intro" \
  vendor="IBM" \
  version="0.0.8" \
  release="" \
  summary="Pizza chatbot" \
  description="This chatbot allows users to order pizza."