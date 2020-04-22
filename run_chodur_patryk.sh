#!/bin/bash

if [ $1 = "clone" ]; then
	if [ -d .git ]; then
		echo "Error: already inside repository"
		exit -1
	fi
	git clone https://github.com/patrykchodur/PN--jadro-linux.git
fi

if [ $1 = "clean" ]; then
	if [ -d .git ]; then
		git list-files
	elif [ -d PN--jadro-linux ]; then
		echo "cleaning"
		rm -rf PN--jadro-linux
	else
		echo "Error: already cleaned"
		exit -1
	fi
fi