#!/bin/bash

# Default list of servers.
SERVER_FILE='/vagrant/own_servers'

# Function to display usage options
usage() {
  cat << EOF

Usage: ${0} [-vsn] [-f SERVER_FILE] COMMAND

Options:
  -v              Optional: Increase verbosity. Display server name before executing command.
  -s              Optional: Enable root privileges on the remote server.
  -n              Optional: Allow dry run.
  -f SERVER_FILE  Optional: Specify an alternate server file.
  COMMAND         Required: Executes a single command on every server.

Examples:
  ${0} -v uptime
  ${0} -v -s useradd user1
  ${0} -v -f /path/to/server_file uptime
  ${0} -n -f /path/to/server_file cat /etc/passwd

Notes:
  - This script requires a server file; the default list is stored in ${SERVER_FILE}.
  - Options -v, -s, -n, and -f are optional.
  - COMMAND is required.

EOF
    exit 1  
}

# Function to echo messages if verbosity is enabled.
log() {
  local MESSAGE="${@}"
  if [[ "${VERBOSE}" = 'true' ]]; then
    echo "${MESSAGE}"
  fi
}

# Check to superuser is enabled.
if [[ ${UID} -eq 0 ]]; then
  echo "Please exit superuser mode and enable root privileges using the -s option instead."
  usage
  exit 1
fi

# Initailsing variables.
VERBOSE='false'
SUDO=""
DRY_RUN='false'

# Parsing options.
while getopts vsnf: OPTION; do
  case ${OPTION} in
    v)
      VERBOSE='true';;
    s)
      SUDO='sudo';;
    n)
      DRY_RUN='true';;
    f)
      SERVER_FILE="${OPTARG}";;
    ?)
      usage;;
  esac
done

# Shift the parsed options away, leaving the command as the remaining arguments.
shift $((OPTIND - 1))

# Check ifi a command is provided.
if [[ $# -lt 1 ]]; then
  usage
fi

# Assign remaining arguments as commands.
COMMAND="${@}"

# Check if SERVER_FILE file exists.
if [[ ! -e $SERVER_FILE ]]; then
  echo
  echo "Cannot open file $SERVER_FILE." >&2
  echo
  usage
  exit 1
fi

# Iterate through each server and execute the command.
for SERVER in $(cat ${SERVER_FILE}); do
  if  ssh -o ConnectTimeout=2 -n $SERVER 2>/dev/null; then
    log "Connection to $SERVER - successful."
    if [[ $DRY_RUN = 'true' ]]; then
      echo "DRY RUN: ssh -n $SERVER $COMMAND."
      echo
    else
      echo
      ssh -n $SERVER $SUDO $COMMAND 2>/dev/null
      SSH_EXIT_STATUS="${?}"
        if [[ "${SSH_EXIT_STATUS}" -ne 0 ]]; then
          EXIT_STATUS="${SSH_EXIT_STATUS}"
          echo "Failed to execute: '$COMMAND'."
        else
          echo "Command: $COMMAND successful."
        fi
      echo
    fi
else
    echo "Connecting to $SERVER - failed." >&2
    echo
fi
done

exit ${EXIT_STATUS}
