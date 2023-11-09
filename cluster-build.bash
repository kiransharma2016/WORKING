#!/bin/bash
# Directory Initializations
BASE_DIR="/opt/openshift4"
SCRIPT_DIR="${BASE_DIR}/scripts"
CLUSTER_BUILDS_DIR="${BASE_DIR}/cluster-builds"
SOFTWARE_DIR="${BASE_DIR}/software"
CA_DIR="${BASE_DIR}/BipraTechCA"
CA_CERT="${CA_DIR}/ca.crt"
LOG_DIR="/tmp"
BOOT_STRAP_LOCATION=

FILE_PERMISSION=644

#
print_variables() {
    echo "BASE_DIR: $BASE_DIR"
    echo "CLUSTER_DIR: $CLUSTER_DIR"
    echo "SCRIPT_DIR: $SCRIPT_DIR"
    echo "CLUSTER_BUILDS_DIR: $CLUSTER_BUILDS_DIR"
    echo "SOFTWARE_DIR: $SOFTWARE_DIR"
    echo "CA_DIR: $CA_DIR"
    echo "CA_CERT: $CA_CERT"
    echo "LOG_DIR: $LOG_DIR"
    echo "BOOTSTRAP_DIR: $BOOTSTRAP_DIR"
    echo "LOG_FILE: $LOG_FILE"
}

log_message() {
    local MESSAGE=$1
    echo "$(date): $MESSAGE" | tee -a $LOG_FILE
}

# ... [Rest of your variables and functions]

# Function to parse and validate the input parameters
usage() {
    local missing_param="$1"
    echo "Error: Missing or blank parameter for $missing_param."
    echo "Usage: $0 --mode|-m <mode> --cluster-name|-n <name> --cluster-version|-v <version>"
    exit 1
}

# Parse command-line arguments
MODE=""
CLUSTER_NAME=""
OCP_VERSION=""

parse_parameters() {
while [[ $# -gt 0 ]]; do
    key="$1MISSION

    case $key in
        --mode|-m)
            MODE="$2"
            shift
            shift
            ;;
        --cluster-name|-n)
            CLUSTER_NAME="$2"
            shift
            shift
            ;;
        --cluster-version|-v)
            OCP_VERSION="$2"
            shift
            shift
            ;;
        *)
            usage "$key"
            ;;
    esac
done

# Check if all parameters are set and not blank
[[ -z "$MODE" ]] && usage "--mode|-m"
[[ -z "$CLUSTER_NAME" ]] && usage "--cluster-name|-n"
[[ -z "$OCP_VERSION" ]] && usage "--cluster-version|-v"

    # Initialization of variables that depend on CLUSTER_NAME
    CLUSTER_DIR="${BASE_DIR}/${CLUSTER_NAME}"
    BOOTSTRAP_DIR="/var/www/html/ignition/${CLUSTER_NAME}"
    LOG_FILE="/tmp/$CLUSTER_NAME/${CLUSTER_NAME}-install.log"

    # Ensure the directory exists
    mkdir -p "/tmp/$CLUSTER_NAME"

    # Printing the variable values to the console
    echo "$MODE, $CLUSTER_NAME, $OCP_VERSION"

    # Appending the variable values to the log file
    echo "$MODE, $CLUSTER_NAME, $OCP_VERSION" >> "$LOG_FILE"
}

# Function to check the validity of the provided parameters
check_parameters() {
    # Checking mode
    if [[ "$MODE" != "build" && "$MODE" != "rebuild" ]]; then
        log_message "Invalid mode. Supported modes are 'build' or 'rebuild'."
        exit 1
    fi

    # Checking cluster name
    if [[ -z "$CLUSTER_NAME" ]]; then
        log_message "Cluster name cannot be blank."
        exit 1
    fi

    # Checking cluster version
    if [[ -z "$OCP_VERSION" ]]; then
        log_message "Cluster version cannot be blank."
        exit 1
    fi

    # Additional checks if needed

    log_message "Parameters validation passed."
}


init_check() {
    log_message "Starting initialization checks..."
    if [[ ! -f "${CA_CERT}" ]]; then
        log_message "Error: ca.crt does not exist."
        exit 1
    fi

    if [[ ! -f "${SOFTWARE_DIR}/pull-secret.json" ]]; then
        log_message "Error: pull-secret.json does not exist in ${SOFTWARE_DIR}."
        exit 1
    fi

    # Check if files with substrings "openshift-install" and "openshift-client-" exist
    if [[ ! $(ls ${SOFTWARE_DIR}/*openshift-install*) ]] || [[ ! $(ls ${SOFTWARE_DIR}/*openshift-client-*) ]]; then
        log_message "Error: Required software (openshift-install or openshift-client-) not found in ${SOFTWARE_DIR}."
        exit 1
    fi

    log_message "Initialization checks passed."
    sleep 1
}

#
prepare_directories() {
    local mode=$1
    log_message "Preparing directories..."

   if [[ "$mode" == "rebuild" ]]; then
       if [[ ! -d "${CLUSTER_DIR}" ]]; then
           log_message "You chose 'rebuild', but the cluster directory does not exist. Please run with 'build' option."
           exit 1
       fi
   fi
    
    # If mode is set to "rebuild"
    if [[ "$mode" == "rebuild" ]]; then
        # Delete specified files for rebuild mode
        rm -f "${CLUSTER_DIR}/master.ign" "${CLUSTER_DIR}/worker.ign" "${CLUSTER_DIR}/metadata.json" "${CLUSTER_DIR}/.openshift_install.log" "${CLUSTER_DIR}/.openshift_install_state.json"
        log_message "Removed specific files for rebuild mode."
        echo "deleted files-------------------------------------" 
        # Delete the auth directory
        if [[ -d "${CLUSTER_DIR}/auth" ]]; then
            log_message "Deleting auth directory for rebuild..."
            rm -rf "${CLUSTER_DIR}/auth"

        echo "deleted auth-------------------------------------" 
        else
            echo " not deleted auth"
            log_message "auth directory not found. It might have been deleted already."
        fi
    
        # Check for the existence of root-ssh-key directory
        if [[ -d "${CLUSTER_DIR}/root-ssh-key" ]]; then
            log_message "root-ssh-key directory is preserved."
        else
            log_message "root-ssh-key was not found."
        fi
    
    elif [[ "$mode" == "build" ]]; then
        if [[ -d "${CLUSTER_DIR}" ]]; then
            read -p "Are you sure you want to delete the existing cluster directory? [y/N]: " confirm
            if [[ "$confirm" == "y" || "$confirm" == "Y" ]]; then
                rm -rf "${CLUSTER_DIR}"
                log_message "Deleted existing cluster directory."
            else
                log_message "User canceled the operation. Exiting."
                exit 1
            fi
        fi
        mkdir -p "${CLUSTER_DIR}"
        log_message "Building cluster directory from scratch."
    fi


    # Create other necessary directories if they do not exist
    local DIRS_TO_CREATE=(
        "${CLUSTER_DIR}/config-files"
        "${BOOTSTRAP_DIR}"
        "${LOG_DIR}/${CLUSTER_NAME}"
    )

    for DIR in "${DIRS_TO_CREATE[@]}"; do
        if [[ ! -d $DIR ]]; then
            mkdir -p $DIR
            log_message "Created directory $DIR."
        fi
    done

    log_message "Directories preparation successful."
    sleep 1
}

#

#
generate_ssh_key() {
    local mode=$1

    if [[ $mode != "build" ]]; then
        log_message "Mode is 'rebuild'. Skipping SSH key generation."
        return
    fi

    SSH_DIR="/opt/openshift4/${CLUSTER_NAME}/root-ssh-key"

    # Check if the directory exists
    if [[ ! -d ${SSH_DIR} ]]; then
        log_message "${SSH_DIR} doesn't exist. Creating directory..."
        mkdir -p ${SSH_DIR}
    else
        log_message "${SSH_DIR} already exists."
    fi

    log_message "Generating SSH key..."
    ssh-keygen -t rsa -b 4096 -f ${SSH_DIR}/id_rsa -N '' -C ''

    if [ $? -eq 0 ]; then
        log_message "SSH key generation successful."
    else
        log_message "Error generating SSH key. Exiting."
        exit 1
    fi

    sleep 3
}

#
certificate=$(cat /opt/openshift4/Bipratech/ca.crt)

generate_install_config() {
    local mode=$1

    if [[ $mode != "build" ]]; then
        log_message "Mode is 'rebuild'. Skipping install-config generation."
        return
    fi
    log_message "Generating install-config.yaml..."
    # Sample install config. Modify based on your requirements.
    cat > ${CLUSTER_DIR}/install-config.yaml <<EOL
apiVersion: v1
baseDomain: example.com
compute:
- hyperthreading: Enabled
  name: worker
  replicas: 3
controlPlane:
  hyperthreading: Enabled
  name: master
  replicas: 3
metadata:
  name: ${CLUSTER_NAME}
networking:
  clusterNetwork:
  - cidr: 10.128.0.0/14
    hostPrefix: 23
  networkType: OpenShiftSDN
  serviceNetwork:
  - 172.30.0.0/16
platform:
    none: {}
pullSecret: '$(cat ${SOFTWARE_DIR}/pull-secretv2.json)'
sshKey: '$(cat ${CLUSTER_DIR}/root-ssh-key/id_rsa.pub)'
additionalTrustBundle: |
$(echo "$certificate" | sed 's/^/  /')
EOL
    log_message "install-config.yaml generation successful."
    sleep 1
}
#
# Assuming CLUSTER_DIR is an environment variable, or you can directly provide its value here
#
create_ignition_files() {
    local mode=$1

    if [[ $mode == "rebuild" ]]; then
        log_message "Copying backup file to install-config.yaml..."
        cp ${CLUSTER_DIR}/install-config.yaml.backup ${CLUSTER_DIR}/install-config.yaml
        ls -ltr ../osenp-rotn11 
    else
        log_message "Copying install-config.yaml..."
        cp ${CLUSTER_DIR}/install-config.yaml ${CLUSTER_DIR}/install-config.yaml.backup
    fi

    log_message "Creating ignition files..."
    ${SOFTWARE_DIR}/openshift-install create ignition-configs --dir=${CLUSTER_DIR}

    if [ $? -eq 0 ]; then
        log_message "Ignition file creation successful."
        # Setting permissions to 644 only for *.ign files in the directory
        chmod 644 ${CLUSTER_DIR}/*.ign
        log_message "Set permissions to 644 for all *.ign files in ${CLUSTER_DIR}"
    else
        log_message "Error creating ignition files. Exiting."
        exit 1
    fi

    sleep 1
}

move_bootstrap() {
    log_message "Moving bootstrap.ign..."
    mv ${CLUSTER_DIR}/bootstrap.ign ${BOOTSTRAP_DIR}
    log_message "bootstrap.ign moved successfully."

    # Setting permissions to 644 for the moved bootstrap.ign
    chmod 644 ${BOOTSTRAP_DIR}/bootstrap.ign
    log_message "Set permissions to 644 for ${BOOTSTRAP_DIR}/bootstrap.ign"

    sleep 1
}

#
create_append_bootstrap() {
    local mode="$1"

    if [[ "$mode" == "rebuild" ]]; then
        log_message "Mode is 'rebuild'. Skipping append-bootstrap.ign creation."
        return
    fi

    log_message "Creating append-bootstrap.ign..."

    # The JSON content for the file
    local content='{
  "ignition": {
    "config": {
      "merge": [
        {
          "source": "http://${HTTP_SERVER}:8080/ignition/bootstrap.ign"
        }
      ]
    },
    "version": "3.1.0"
  }
}'

    echo "$content" > "${CLUSTER_DIR}/append-bootstrap.ign"
    log_message "append-bootstrap.ign creation successful."

    # Setting permissions to 644 for the created append-bootstrap.ign
    chmod 644 "${CLUSTER_DIR}/append-bootstrap.ign"
    log_message "Set permissions to 644 for ${CLUSTER_DIR}/append-bootstrap.ign"

    sleep 1
}

#

prebuild_validation() {
    log_message "Starting prebuild validation..."
    local ERR=0
    
    # Checking file permissions
    for FILE in "${CLUSTER_DIR}/master.ign" "${CLUSTER_DIR}/worker.ign" "${BOOTSTRAP_DIR}/bootstrap.ign" "${CLUSTER_DIR}/append-bootstrap.ign"; do
        if [[ $(stat -c %a "$FILE") -ne "644" ]]; then
            log_message "Error: Invalid permissions for $FILE. Expected 644."
            ERR=1
        fi
    done
    
    # Checking if HTTP server is running
    if ! netstat -tuln | grep ':80 ' > /dev/null; then
        log_message "Error: HTTP server is not running. Turning it on..."
        
        # Enabling and starting the HTTP server
        systemctl enable httpd || log_message "Failed to enable the HTTP server."
        systemctl start httpd || log_message "Failed to start the HTTP server."
        ERR=1
    fi
    
    # Checking and removing HTTPS_PROXY if defined
    if [[ ! -z "${HTTPS_PROXY}" ]]; then
        log_message "Detected HTTPS_PROXY. Removing it..."
        unset HTTPS_PROXY
    fi
    
    # Exiting if any error was detected
    if [[ $ERR -eq 1 ]]; then
        log_message "Prebuild validation failed."
        exit 1
    else
        log_message "Prebuild validation successful."
    fi
    
    sleep 1
}



create_cluster() {
    log_message "Starting cluster creation..."

    # Invoke the Ansible playbook for cluster creation
    if ansible-playbook ${PLAYBOOK_DIR}/create_cluster.yml; then
        log_message "Cluster creation successful."
    else
        log_message "Error encountered during cluster creation."
        exit 1
    fi
    
    sleep 1
}

validate() {
    log_message "Starting cluster validation..."
    if oc get nodes 2>&1 | tee -a $LOG_FILE; then
        log_message "Cluster validation successful."
    else
        log_message "Error encountered during cluster validation."
        exit 1
    fi
    sleep 1
}

cleanup() {
    log_message "Starting cleanup..."
    rm -rf $CLUSTER_DIR/bootstrap.ign
    log_message "Cleaned up temporary files."
    sleep 1
}

# Parse input parameters
parse_parameters $@

# Validate parameters
check_parameters

# Initialize global variables
PARAMETERS_FILE="${CLUSTER_BUILDS_DIR}/${CLUSTER_NAME}-parameters.conf"

# Execute the functions
init_check $@
prepare_directories  $MODE
source $PARAMETERS_FILE

# Conditional execution of create_ssh_key based on MODE
generate_ssh_key $MODE
#print_variables
generate_install_config  $MODE
create_ignition_files  $MODE
move_bootstrap
create_append_bootstrap $MODE
prebuild_validation
create_cluster
validate
cleanup
