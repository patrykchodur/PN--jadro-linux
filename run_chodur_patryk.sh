#!/bin/bash

# variables
clone_link=https://github.com/patrykchodur/PN--jadro-linux.git

script_link=https://raw.githubusercontent.com/patrykchodur/PN--jadro-linux/master/run_chodur_patryk.sh

changed_directory=false
start_directory=$(pwd)

function print_error {
	echo -e "\033[31mERROR: $1\033[0m"
}

function print_warning {
	echo -e "\033[33mWARNING: $1\033[0m"
}

function print_info {
	echo -e "\033[32mINFO: $1\033[0m"
}

function print_progress_begin {
	printf "Progress: "
}

function print_progress {
	printf "#"
}

function print_progress_finished {
	echo "  Done!"

}

function download_script {
	curl -s $script_link > $1
	result=$?
	if [ $result -eq 0 ]; then
		chmod 755 $1
	fi
	return $result
}

function check_for_update {
	download_script run_chodur_patryk_tmp.sh
	if [ $? -eq 0 ]; then
		git diff --no-index --exit-code run_chodur_patryk_tmp.sh run_chodur_patryk.sh > /dev/null
		if [ $? -ne 0 ]; then
			print_warning "Newer version of script available. Please run ./run_chodur_patryk.sh update"
		fi
		rm run_chodur_patryk_tmp.sh
	fi
}


if [[ $# -ne 1 ]]; then
	print_error "Wrong arguments"
	print_info  "Usage  ./run_chodur_patryk.sh clone|clean|run|update"
	exit -1
fi

if ! [ $1 = "update" ]; then
	check_for_update
fi

# this script should only work above cloned repositories
if [ -d .git ]; then
	cd ..
	print_warning "This script is meant to be used in directory above"
	print_warning "Changed working directory"
	changed_directory=true
fi

if [ $1 = "clone" ]; then
	if [ -d PN--jadro-linux ]; then
		print_error "Already cloned"
		exit -1
	fi
	print_info "Running git clone"
	git clone $clone_link
	if [ $? = 0 ]; then
		print_info "Cloned successfully"
		exit 0
	else
		print_error "Unknown error while clonning"
		exit -1
	fi
fi

if [ $1 = "clean" ]; then
	something_cleaned=false
	if [ -d PN--jadro-linux ]; then
		print_info "Removing PN--jadro-linux"
		rm -rf PN--jadro-linux
		something_cleaned=true
	fi
	if [ "$something_cleaned" = false ]; then
		print_info "Nothing to clean"
	fi
	exit 0
fi

if [ $1 = "run" ]; then
	print_info "Run does not do anything"
	exit 0
fi


if [ $1 = "update" ]; then
	print_info "Updating run_chodur_patryk.sh"
	if [ "$changed_directory" = true ]; then
		cd $start_directory
	fi
	download_script run_chodur_patryk_tmp.sh
	if [ $? -ne 0 ]; then
		print_error "Unknown error, please check your connection"
		exit -1
	fi
	chmod 755 run_chodur_patryk_tmp.sh
	git diff --no-index --exit-code run_chodur_patryk_tmp.sh run_chodur_patryk.sh > /dev/null
	if [ $? -eq 0 ]; then
		print_info "Already up to date"
	else
		print_info "Updated correctly"
	fi
	mv run_chodur_patryk_tmp.sh run_chodur_patryk.sh
	if [ "$changed_directory" = true ]; then
		cd ..
	fi
fi


if [ $1 = "solution" ]; then
	print_error "This version does not support this option"
fi

