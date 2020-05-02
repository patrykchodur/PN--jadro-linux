#!/bin/bash

# variables
clone_link=https://github.com/patrykchodur/PN--jadro-linux.git

script_link=https://raw.githubusercontent.com/patrykchodur/PN--jadro-linux/master/run_chodur_patryk.sh

solution_link=

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

function print_prompt {
	echo -e "\033[36mPROMPT: $1 (y/n)\033[0m"
	proper_answer=false
	while true; do
		read
		if [ "$REPLY" != "${REPLY#[yY]}" ]; then
			return 0
		elif [ "$REPLY" != "${REPLY#[nN]}" ]; then
			return 1
		fi
	done
}

function print_progress_finished {
	echo "  Done!"
}

function user_aborted {
	echo
	print_error "User aborted"
	exit -1
}

trap user_aborted SIGINT
trap user_aborted SIGTERM

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
			print_warning "Newer version of this script is available. Please run update subcommand"
		fi
		rm run_chodur_patryk_tmp.sh
	fi
}

function fun_clone {
	if [ -d PN--jadro-linux ]; then
		print_info "Already cloned"
		return 0
	fi
	print_info "Running git clone"
	git clone $clone_link
	if [ $? = 0 ]; then
		print_info "Cloned successfully"
		return 0
	else
		print_error "Unknown error occured while clonning"
		return -1
	fi
}

function fun_solution {
	if [ -d PN--jadro-linux-rozwiazanie ]; then
		print_info "Already cloned"
		return 0
	fi
	print_info "Running git clone"
	git clone $solution_link
	if [ $? = 0 ]; then
		print_info "Cloned successfully"
		return 0
	else
		print_error "Unknown error occured while clonning"
		return -1
	fi
}

function print_usage {
	print_info  "Usage  ./run_chodur_patryk.sh clone|clean|run|update"
}

function inside_docker {
	if [ -f /.dockerenv ]; then
		return 0
	else
		return -1
	fi
}

function command_exists {
	command -v $1 2>&1 > /dev/null
	return $?
}

function using_docker {
	# checking for files
	if [ -f .usedocker ]; then
		return 0
	elif [ -f .dontusedocker ]; then
		return 1
	fi

	# check if dependencies are available
	if ! { command_exists curl && command_exists gcc ; }; then
		touch .usedocker
		return 0
	fi
	if command_exists nasm ; then
		print_prompt "Do you wish to use docker? All dependencies are available"
	else
		print_prompt "Do you wish to use docker? All required dependencies are available, but optional nasm is not installed (nasm can be used in ex1)"
	fi
	if [ $? -eq 0 ]; then
		touch .usedocker
		return 0
	else
		touch .dontusedocker
		return 1
	fi
}

if [[ $# -ne 1 ]]; then
	print_error "Wrong number of arguments"
	print_usage
	exit -1
fi

if ! [ $1 = "update" ]; then
	check_for_update
fi

# this script should only work above cloned repositories
if [ -d .git ]; then
	print_warning "This script is meant to be used above the repository"
	print_info "Changing scripts working directory"
	cd ..
	changed_directory=true
fi

if [ $1 = "clone" ]; then
	print_info "Downloading project repository"
	fun_clone
	exit $?
fi

if [ $1 = "clean" ]; then
	something_cleaned=false
	if [ -d PN--jadro-linux ]; then
		print_info "Removing PN--jadro-linux repository"
		rm -rf PN--jadro-linux
		something_cleaned=true
	fi
	if [ -d PN--jadro-linux-rozwiazanie ]; then
		print_info "Removing PN--jadro-linux-rozwiazanie repository"
		rm -rf PN--jadro-linux-rozwiazanie
		something_cleaned=true
	fi

	if using_docker; then
		# removing docker
		docker ps -a -q -f status=exited | xargs docker rm
		docker rmi patrykchodur:1.0
		docker rmi debian:10
	fi

	rm -f .usedocker .dontusedocker

	if [ "$something_cleaned" = false ]; then
		print_info "Nothing to clean"
	fi
	exit 0
fi

if [ $1 = "run" ]; then
	if ! [ -d PN--jadro-linux ]; then
		print_error "No repository found"
		exit -1
	fi
	inside_docker
	if [ $? -eq 0 ]; then
		print_error "Already running inside docker"
		exit -1
	fi
	if using_docker; then
		print_info "Running docker"
		docker build -t patrykchodur:1.0 -f ./PN--jadro-linux/Dockerfile .
		docker run -it --rm=true patrykchodur:1.0
	fi
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
		cp run_chodur_patryk_tmp.sh run_chodur_patryk.sh
		print_info "Script updated successfully"
	fi
	rm run_chodur_patryk_tmp.sh
	if [ "$changed_directory" = true ]; then
		cd ..
	fi
	exit 0
fi


if [ $1 = "solution" ]; then
	if [ -z "$solution_link" ]; then
		print_error "solution subcommand not allowed"
		exit -1
	fi
	print_info "Downloading project repository"
	fun_clone
	if [ $? -ne 0 ]; then
		exit -1
	fi
	print_info "Downloading solution repository"
	fun_solution
	if [ $? -ne 0 ]; then
		exit -1
	fi

	if ! inside_docker && using_docker; then
		print_info "Running docker"
		# niestety parser dockera to jest porażka i nie potrafi czytać ze strumieni
		#sed '$ a\
			#ENTRYPOINT ["./run_chodur_patryk.sh", "solution"]\
			#' PN--jadro-linux/Dockerfile | docker build -t patrykchodur:1.0 -
		cp PN--jadro-linux/Dockerfile Dockerfiletmp
		echo 'ENTRYPOINT ["./run_chodur_patryk.sh", "solution"]' >> Dockerfiletmp
		docker build -t patrykchodur:1.0 -f ./Dockerfiletmp .
		rm Dockerfiletmp
		docker run -it --rm=true  patrykchodur:1.0
		exit $?
	else

		# copying sollutions
		print_info "Copying files"
		print_progress_begin

		cp PN--jadro-linux-rozwiazanie/solutions/zadanie1/* PN--jadro-linux/zadanie1/
		print_progress
		cp PN--jadro-linux-rozwiazanie/solutions/zadanie2/* PN--jadro-linux/zadanie2/
		print_progress
		cp PN--jadro-linux-rozwiazanie/solutions/zadanie3/* PN--jadro-linux/zadanie3/
		print_progress
		# copying testing scripts
		cp PN--jadro-linux-rozwiazanie/test_scripts/zadanie1/* PN--jadro-linux/zadanie1/
		print_progress
		cp PN--jadro-linux-rozwiazanie/test_scripts/zadanie2/* PN--jadro-linux/zadanie2/
		print_progress
		cp PN--jadro-linux-rozwiazanie/test_scripts/zadanie3/* PN--jadro-linux/zadanie3/
		print_progress_finished
		# run testing scripts
		( cd PN--jadro-linux/zadanie1 && ./test1.sh )
		( cd PN--jadro-linux/zadanie2 && ./test2.sh )
		( cd PN--jadro-linux/zadanie3 && ./test3.sh )

		print_info "Source files for solutions are provided in solutions/ directory"

	fi
	
	exit 0
fi

print_error "Unknown option - $1"
print_usage
exit -1
