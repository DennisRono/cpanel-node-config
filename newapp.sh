#! /bin/bash

ROOTDIR=$(cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd)
read -p "Name of your project: " NEWPROJ

#create new project folder
mkdir "${ROOTDIR}/${NEWPROJ}"

# copy node to the new project
cp -R node "${NEWPROJ}/"