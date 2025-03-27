#!/bin/bash

sudo apt-get update -y
sudo apt install npm -y
sudo apt install nodejs -y
sudo apt install git -y

cd /home/ubuntu
git clone https://github.com/raynardmiot/514-2245-2-team7.git
cd /home/ubuntu/514-2245-2-team7/my-app
sudo npm i
sudo npm start