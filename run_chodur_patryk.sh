#!/bin/bash

if [[ $# -ne 1 ]]; then
	echo "Error: wrong usage"
	echo "./run_chodur_patryk.sh clone|clean|run|update"
	exit -1
fi
# this script should only work above cloned repositories
if [ -d .git ]; then
	if ! [ -d ../run_chodur_patryk.sh ]; then
		cp run_chodur_patryk.sh ..
	fi
	cd ..
	echo "Info: this script is meant to use above cloned directory"
fi

if [ $1 = "clone" ]; then
	if [ -d .git ]; then
		echo "Error: already inside repository"
		exit -1
	fi
	git clone https://github.com/patrykchodur/PN--jadro-linux.git
	exit 0
fi

if [ $1 = "clean" ]; then
	if [ -d PN--jadro-linux ]; then
		echo "Info: cleaning"
		rm -rf PN--jadro-linux
		exit 0
	else
		echo "Error: already cleaned"
		exit -1
	fi
fi

if [ $1 = "run" ]; then
	echo "Info: run does not do anything"
	exit 0
fi

if [ $1 = "update" ]; then
	echo "Info: updating run_chodur_patryk.sh"
	wget https://raw.githubusercontent.com/patrykchodur/PN--jadro-linux/master/run_chodur_patryk.sh -o /dev/null -O run_chodur_patryk_tmp.sh
	chmod 755 run_chodur_patryk_tmp.sh
	mv run_chodur_patryk_tmp.sh run_chodur_patryk.sh
	exit 0
fi
