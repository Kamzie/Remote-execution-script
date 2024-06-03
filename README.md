# Remote Execution Script

The idea behind this script is to allow a Linux admin to avoid repetition by using this script to carry out commands on a large network of servers through automation, which improves time efficiency and reduces human errors.

This script allows you to execute commands on multiple servers listed in a file, with various options for control and feedback.

## Features

- Run commands on multiple servers defined in a server file.
- Increase verbosity to display server names before executing commands.
- Enable root privileges on remote servers for command execution (requires `-s` flag).
- Perform a dry run to simulate execution without actually running commands (using `-n` flag).
- Specify a custom server file location using the `-f` flag.

## Installation

1. Save the script content as `08_remote_execution.sh`.
2. Grant executable permissions to the script:

   ```bash
   chmod +x 08_remote_execution.sh
   ```

## Usage

```bash
./08_remote_execution.sh [-vsn] [-f SERVER_FILE] COMMAND
```

### Options

- `-v`: Enables verbose mode, displaying server names before executing commands.
- `-s`: Enables execution of commands with root privileges on the remote servers. (**Use with caution!**)
- `-n`: Performs a dry run, simulating command execution without actually running them.
- `-f SERVER_FILE`: Specifies a custom server file location. (Default: `/vagrant/servers`)
- `COMMAND`: The command you want to execute on all the servers. (Required)

### Server File

The script expects a file containing a list of server hostnames (one per line). By default, it looks for a file named `servers` located at `/vagrant/servers`.

### Example Usage

1. Update package lists on all servers (dry run):

   ```bash
   ./08_remote_execution.sh -n apt update
   ```

2. Reboot all servers with root privileges:

   ```bash
   ./08_remote_execution.sh -s reboot
   ```

3. Run a custom command with verbosity enabled:

   ```bash
   ./08_remote_execution.sh -v df -h
   ```

## Script Details

### Error Handling

- The script checks if the `SERVER_FILE` exists and is readable. If not, it outputs an error message and exits.
- The script verifies that it is not being run as the superuser (root) directly. Instead, it requires the `-s` option to enable root privileges for remote commands.
- Connection attempts to each server are made with a 2-second timeout. If the connection fails, an error message is displayed.
- If command execution on a server fails, the script captures the exit status and reports the failure.

### Message Outputs

- When verbosity is enabled (`-v`), the script logs messages indicating successful connections and command execution.
- In dry run mode (`-n`), the script simulates the command execution and logs the intended actions without performing them.
- Error messages are sent to standard error (`stderr`) to distinguish them from regular output.

This script provides a convenient way to manage and execute commands on multiple servers simultaneously. Remember to adjust the script and server file according to your environment and security best practices.
