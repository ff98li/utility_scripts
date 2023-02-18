#!/bin/bash

####################################################################
# Many thanks to vigo332 for sharing his HPC installation script.  #
# This scirpt is modified based on Compute Canada HPC specs.       #
# Installing in other places may fail.                             #
# Please login to a compute node before running this script.       #
# Original repo: https://github.com/vigo332/cryosparc_onthefly.git #
####################################################################

# == CryoSPARC install config ===================
CSPARC_MASTER_DIR=~/scratch/software/cryosparc/cryosparc_master
CSPARC_WORKER_DIR=~/scratch/software/cryosparc/cryosparc_worker
CSPARC_DB_DIR=~/scratch/software/cryosparc/cryosparc_database
EMAIL=""
LOGIN_NAME=""
SURNAME=""
GIVEN_NAME=""

set -u
set -o pipefail

echoinfo () 
{
	echo -e "\e[32m[INFO] $@\e[0m"
}

echoerror ()
{
	echo -e "\e[31m[ERROR] $@\e[0m"
}

#check_patch ()
#{
#	if [[ ! -f install.09102019.patch ]]
#	then
#		echoerror "  Patch file install.09102019.patch is not found. Please download it to $PWD. "
#		exit 1;
#	fi
#
#	if [[ ! -f bin_cryosparcm.11262019.patch ]]
#	then
#		echoerror "  Patch file bin_cryosparcm.11262019.patch is not found. Please download it to $PWD. "
#		exit 1;
#	fi
#}


# set install_dir
## DEPECATED
set_paths () 
{
	echoinfo "  ==================="
	echoinfo "  Setting up installation paths. "
	#echoinfo "  Please specificy the installation directory. "
	#echoinfo "  The installation path should not be your \$HOME. "
	#echoinfo "  If you set to your \$HOME, it will be automatically set to \$HOME/software/cryosparc. "

	#read -p "  Press Enter for the current working directory: " install_dir
	#printf "\n"

	#if [[ $install_dir == "" ]]
	#then
	#	if [[ $PWD == $HOME ]]
	#	then
	#		install_dir=$install_dir
	#	else
	#		install_dir=$PWD
	#	fi
	#else
	#	if [[ ! -d $install_dir ]]
	#	then
	#		mkdir -p $install_dir
	#	fi
	#fi
	if [[ ! -d $INSTALL_PATH ]]
	then
		mkdir -p $INSTALL_PATH
	fi
	

	## Depreciated in 4.0
	#DB_PATH=$INSTALL_PATH/$CSPARC_DB_NAME

	#if [[ ! -d $DB_PATH ]]
	#then
	#	mkdir $DB_PATH
	#fi

	#echoinfo "  Setting installation path to $INSTALL_PATH."
	#echoinfo "  Setting database path to $DB_PATH."

}


# Set license ID
set_license ()
{
	echoinfo "  Please obtain your license id from cryosparc.com "
	echoinfo "  and export LICENSE_ID in .bashrc "
	#read -p "  CryoSparc license ID (UUID): " LICENSE_ID
	
	while [[ ! $LICENSE_ID =~ [a-f0-9]{8}-[a-f0-9]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12} ]];
	do
		echoerror "  The license id does not seem to be a valid uuid string. Please check. "
		read -p "  Please input a valid UUID license: " LICENSE_ID
		printf "\n"
	done
}


# set login email
set_email ()
{
	while [[ ! "$EMAIL" =~ ^[a-zA-Z0-9.]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$ ]];
	do
		read -p "  Your Login Email Address: (@example.com, lower case. ): " EMAIL
		printf "\n"
	done
}


# set password
set_user ()
{

	if [[ $LOGIN_NAME == "" ]];
	then
	    read -p "  Set a username for CryoSparc web: " LOGIN_NAME
	    printf "\n"
	fi
	while [[ $LOGIN_NAME == "" ]]
	do
	    echoerror "  Login username is empty, please input again... "
	    read -p "  Set a username for CryoSparc web: " LOGIN_NAME
	    printf "\n"
	done

	PASSWORD1='114'
	PASSWORD2='514'

	read -sp "  Set a password for CryoSparc web: " PASSWORD1
	printf "\n"
	while [[ $PASSWORD1 == "" ]]
	do
		echoerror "  Password is empty, please input again... "
	done

	counter=0
	while [[ $PASSWORD1 != $PASSWORD2 ]];
	do
		read -sp "  Confirm password for CryoSparc web: " PASSWORD2
		printf "\n"

		if [[ $PASSWORD1 != $PASSWORD2 ]];
		then
			echoerror "  Passwords do not agree, try again..."
			let counter+=1

			if [[ $counter -lt 3 ]];
			then
				continue;
			else
				echoerror "  Failed 3 times, aborting..."
				exit 1;
			fi
		fi	
	done

	PASSWORD=$PASSWORD1
}


# set cuda path
set_cuda_path () 
{
	# check if exists
	nvcc=`command -v nvcc`
	if [[ $? -ne 0 ]];
	then
		echoinfo "  Cuda (nvcc) is not found in environment, loading cuda as a module... "
		module load cuda
		
		if [[ $? -ne 0 ]];
		then
			echoerror "  Loading cuda failed. Quitting. "
			exit 1;
		fi

		echoinfo "  Current loaded modules are "
		module list
	fi


	CUDA_PATH=$(dirname $(dirname `which nvcc`))
	echoinfo "  Setting installation path to $CUDA_PATH."
}

set_port ()
{
	echoinfo "  The base port number for this CryoSPARC instance."
	echoinfo "  Do not install cryosparc master on the same machine multiple times with the same port number."
	echoinfo "  39000 is the default, which will be used if you don't specify this option."
	read -p "  Enter your base port number (enter nothing for default): " PORT_NUMBER_TMP
	if [[ $PORT_NUMBER_TMP = "" ]]
	then
		PORT_NUMBER=39000
	else
		while [[ ! "$PORT_NUMBER" =~ ^[0-9.]+$ ]];
		do
			read -p "  Enter your base port number: " PORT_NUMBER_TMP
			printf "\n"
		done
		PORT_NUMBER=$PORT_NUMBER_TMP
	fi
}

set_names ()
{
    while [[ $SURNAME = "" ]];
    do
        read -p "  Enter your last name: " SURNAME
        printf "\n"
    done

    while [[ $GIVEN_NAME = "" ]];
    do
        read -p "  Enter your first name: " GIVEN_NAME
        printf "\n"
    done
}

check_config ()
{
	echoinfo "  #####################"
	echoinfo "  Finishing input setup"
	echoinfo "  Variables are: "
        echoinfo "  --worker_path " $CSPARC_WORKER_DIR
	echoinfo "  --license: " $LICENSE_ID
	echoinfo "  --email: " $EMAIL
	echoinfo "  --cuda_path: " $CUDA_PATH
	echoinfo "  --port " $PORT_NUMBER
        echoinfo "  --initial_username " $LOGIN_NAME
        echoinfo "  --initial_firstname " $GIVEN_NAME 
        echoinfo "  --initial_lastname " $SURNAME 

	echo
	
	while true; do
            read -r -n 1 -p "Continue? [y/n]: " REPLY
            case $REPLY in
                [yY]) echo ; break ;;
                [nN]) echo ; return 1 ;;
              *) printf " \033[31m %s \n\033[0m" "invalid input"
            esac 
        done  

}


install_master () 
{
	## Where to find the hash of latest CryoSPARC sh?
	#install_sh_hash='b373d447e662fec40e050cab297e4806'
	#bin_cryosparcm_hash='d300f06a820d454c77d77f635aba7f76'

	#md5_install=`md5sum install.sh | awk '{ print $1 }'`
	#if [[ $md5_install != $install_sh_hash ]]
	#then
	#	echoinfo "  Patching install.sh file for security."
	#	patch -N -s install.sh < ../install.09102019.patch
	#fi
	#
	#md5_cryosparcm=`md5sum bin/cryosparcm | awk '{ print $1 }'`
	#if [[ $md5_cryosparcm != $bin_cryosparcm_hash ]]
	#then
	#	echoinfo "  Patching bin/cryosparcm for security."
	#	patch -N -s bin/cryosparcm < ../bin_cryosparcm.11262019.patch
	#fi

	#echoinfo "  Installing master with command:"
	bash $CSPARC_MASTER_DIR/install.sh \
	        --standalone \
                --license $LICENSE_ID \
                --worker_path $CSPARC_WORKER_DIR \
                --cudapath $CUDA_PATH \
                --nossd \
                --initial_email $EMAIL \
                --initial_username $LOGIN_NAME \
                --initial_firstname $GIVEN_NAME \
                --initial_lastname $SURNAME \
                --port $PORT_NUMBER \
                --initial_password $PASSWORD
	
	# get name from email
	#name=`echo $email | awk -F@ '{ print $1}'`

	#echoinfo "  Starting master daemon as test"
	#$CSPARC_MASTER_DIR/bin/cryosparcm start &

	#sleep 20 
	## check status for installation debug.
	#$CSPARC_MASTER_DIR/bin/cryosparcm status
}


prepare_master_files ()
{

	#echoinfo "  Installing master in $CSPARC_MASTER_DIR."

	# Just download the package in case of pollution 
	curl -L https://get.cryosparc.com/download/master-latest/$LICENSE_ID -o cryosparc_master.tar.gz
	tar -xf cryosparc_master.tar.gz -C $CSPARC_MASTER_DIR

	#md5value=`md5sum $master_tar | awk '{ print $1 }'`

	#if [[ $md5value == $master_hash ]]
	#then
	#	echoinfo "  md5 hash value is $md5value, file checksum matches. "
	#	echoinfo "  Unzipping $master_tar file, this might take a while..."
	#	tar zxf $master_tar
	#	echoinfo "  Proceed to worker install"
	#	install_master
	#else
	#	echoerror "  Downloaded $master_tar does not match hash $master_hash, aborting..."
	#	exit 1;
	#fi
}


install_worker () 
{
	echoinfo "  Installing worker with: ./install.sh --license $LICENSE_ID --cudapath $CUDA_PATH"
	bash $CSPARC_WORKER_DIR/install.sh --license $LICENSE_ID --cudapath $CUDA_PATH --yes
}


prepare_worker_files ()
{

	echoinfo "  Installing worker in $CSPARC_WORKER_DIR in cluster mode."
	curl -L https://get.cryosparc.com/download/worker-latest/$LICENSE_ID -o cryosparc_worker.tar.gz
	tar -xf cryosparc_worker.tar.gz -C $CSPARC_WORKER_DIR
	#wget -q --no-check-certificate https://get.cryosparc.com/download/worker-latest/$LICENSE_ID -O $worker_tar

	#md5value=`md5sum $worker_tar | awk '{ print $1 }'`

	#if [[ $md5value == $worker_hash ]]
	#then
	#	echoinfo "  md5 hash value is $md5value, file checksum matches. "
	#	echoinfo "  Unzipping $worker_tar file, this might take a while..."
	#	tar zxf $worker_tar
	#	echoinfo "  Proceed to worker install"
	#	install_worker
	#else
	#	echoerror "  Downloaded $worker_tar does not match hash $worker_hash, aborting..."
	#	exit 1;
	#fi
}


generate_worker_cluster_files ()
{

cat <<'EOF' > $CSPARC_WORKER_DIR/cluster_script.sh
#!/bin/bash
#### cryoSPARC cluster submission script template for SLURM
## Available variables:
## {{ run_cmd }}            - the complete command string to run the job
## {{ num_cpu }}            - the number of CPUs needed
## {{ num_gpu }}            - the number of GPUs needed. 
##                            Note: the code will use this many GPUs starting from dev id 0
##                                  the cluster scheduler or this script have the responsibility
##                                  of setting CUDA_VISIBLE_DEVICES so that the job code ends up
##                                  using the correct cluster-allocated GPUs.
## {{ ram_gb }}             - the amount of RAM needed in GB
## {{ job_dir_abs }}        - absolute path to the job directory
## {{ project_dir_abs }}    - absolute path to the project dir
## {{ job_log_path_abs }}   - absolute path to the log file for the job
## {{ worker_bin_path }}    - absolute path to the cryosparc worker command
## {{ run_args }}           - arguments to be passed to cryosparcw run
## {{ project_uid }}        - uid of the project
## {{ job_uid }}            - uid of the job
## {{ job_creator }}        - name of the user that created the job (may contain spaces)
## {{ cryosparc_username }} - cryosparc username of the user that created the job (usually an email)
## {{ job_type }}           - CryoSPARC job type
##
## What follows is a simple SLURM script:

#SBATCH --job-name cryosparc_{{ project_uid }}_{{ job_uid }}
#SBATCH -n {{ num_cpu }}
#SBATCH --gres=gpu:{{ num_gpu }}
#SBATCH --partition=gpu
#SBATCH --mem={{ (ram_gb*1000)|int }}MB
#SBATCH --output={{ job_log_path_abs }}
#SBATCH --error={{ job_log_path_abs }}

{{ run_cmd }}

EOF


cat <<EOF > $CSPARC_WORKER_DIR/cluster_info.json 
{
    "name" : "SLURM_CLUSTER",
    "worker_bin_path" : "$CSPARC_WORKER_DIR/bin/cryosparcw",
    "cache_path" : "$SLURM_TMPDIR",
    "send_cmd_tpl" : "ssh loginnode {{ command }}",
    "qsub_cmd_tpl" : "sbatch {{ script_path_abs }}",
    "qstat_cmd_tpl" : "squeue -j {{ cluster_job_id }}",
    "qdel_cmd_tpl" : "scancel {{ cluster_job_id }}",
    "qinfo_cmd_tpl" : "sinfo",
    "transfer_cmd_tpl" : "scp {{ src_path }} loginnode:{{ dest_path }}"
}

EOF

}

# Latest installer does this for you already.
add_cryosparc_path_to_bashrc () 
{
	echoinfo "  To get CryoSparc cluster work on CryoHPC across nodes, the paths need to be added to your $HOME/.bashrc."

	echo "#   CryoSparc path" >> $HOME/.bashrc
	echo "export PATH=$CSPARC_MASTER_DIR/bin:\$PATH" >> $HOME/.bashrc
	echo "export PATH=$CSPARC_WORKER_DIR/bin:\$PATH" >> $HOME/.bashrc
	echo "export CRYOSPARC_BASE_PORT=$PORT_NUMBER" >> $HOME/.bashrc
	echo "export CRYOSPARC_DB_PATH=$CSPARC_DB_DIR" >> $HOME/.bashrc
	#echo "# Add libcuda to LD_LIBRARY_PATH so that cryosparc workers can use GPU." >> $HOME/.bashrc
	#echo "export LD_LIBRARY_PATH=/cm/local/apps/cuda/libs/current/lib64:\$LD_LIBRARY_PATH" >> $HOME/.bashrc

}

test_cryosparc () 
{
	echoinfo "  Testing CryoSparc installation..."

	# Test master
	echoinfo "  Testing master installation..."
	$CSPARC_MASTER_DIR/bin/cryosparcm --version

	# Test worker
	echoinfo "  Testing worker installation..."
	$CSPARC_WORKER_DIR/bin/cryosparcw --version

	# Test cluster
	#echoinfo "  Testing cluster installation..."
	#$CSPARC_WORKER_DIR/bin/cryosparcw cluster --info

}

#check_patch

#set_paths

set_license

set_email

set_names

set_user

set_cuda_path

set_port

check_config

prepare_master_files

prepare_worker_files

install_master

install_worker

generate_worker_cluster_files

add_cryosparc_path_to_bashrc

test_cryosparc

echo "##########################"
echo "# Installation Finished! #"
echo "##########################"
echo "Remember to source $HOME/.bashrc after installation"

