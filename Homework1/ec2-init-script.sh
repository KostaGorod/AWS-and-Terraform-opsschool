#!/bin/bash

sudo amazon-linux-extras install -y nginx1
sudo service nginx start
sudo rm /usr/share/nginx/html/index.html
echo "<html><head></head><body><p style=\"text-align: center;\">Welcome to Grandpa's Whiskey</p></body></html>" | sudo tee /usr/share/nginx/html/index.html
