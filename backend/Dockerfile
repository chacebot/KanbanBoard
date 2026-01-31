FROM node:20-slim

WORKDIR /app

COPY package.json package-lock.json ./
RUN npm ci --omit=dev

COPY migrations ./migrations
COPY src ./src
COPY tsconfig.json ./

EXPOSE 8000

CMD ["npm", "run", "start"]
