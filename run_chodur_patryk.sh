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
		echo "Info: cleaning"
		rm -rf zadanie1 zadanie2 zadanie3 .git README.md .gitignore
		exit 0
	elif [ -d PN--jadro-linux ]; then
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
fi

if [ $1 = "update" ]; then
	echo "Info: updating run_chodur_patryk.sh"
	wget https://raw.githubusercontent.com/patrykchodur/PN--jadro-linux/master/run_chodur_patryk.sh -o /dev/null -O run_chodur_patryk_tmp.sh
	chmod 755 run_chodur_patryk_tmp.sh
	mv run_chodur_patryk_tmp.sh run_chodur_patryk.sh
fi
