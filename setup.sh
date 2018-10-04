#!/bin/bash

dpkg --add-architecture i386
apt-get update
sudo apt-get install g++-multilib
