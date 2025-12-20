# Step 1: use nodejs as the base image 
# repo.jfrog.hsbc.com/digital/node:18
FROM node:18

# Step 2 : Set working directory for my application 
WORKDIR /app

# Step 3 : Copy dependecies file 
COPY package*.json .

# Step 4 : Install Dependencies
RUN npm install 

# Step 5 : Copy app source code 
COPY app.js .

# Step 6: Inform docker about the port our app uses 
EXPOSE 3000

# Step 7 : Start the application
CMD ["npm", "start"]

