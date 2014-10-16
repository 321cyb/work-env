#!/bin/bash


echo 'deb http://www.rabbitmq.com/debian/ testing main' | sudo tee /etc/apt/sources.list.d/rabbitmq.list

wget http://www.rabbitmq.com/rabbitmq-signing-key-public.asc
sudo apt-key add rabbitmq-signing-key-public.asc
rm rabbitmq-signing-key-public.asc

sudo apt-get update
sudo apt-get install -y rabbitmq-server

sudo rabbitmq-plugins enable rabbitmq_management
