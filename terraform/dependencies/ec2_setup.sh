#!/bin/bash

sudo apt-get update -y
sudo apt install npm -y
sudo apt install nodejs -y
sudo apt install git -y

cd /home/ubuntu
git clone https://github.com/raynardmiot/514-2245-2-team7.git
cd /home/ubuntu/514-2245-2-team7/my-app
touch .env.development
echo "REACT_APP_BASE_API_URL = '${api_url}'" >> .env.development
sudo npm i
sudo npm start