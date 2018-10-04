#!/bin/bash

sudo dpkg --add-architecture i386
apt-get update
sudo apt-get install -y g++-multilib
