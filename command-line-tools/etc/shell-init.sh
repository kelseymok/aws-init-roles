# Determine which shell we are running in.
if [ -n "$BASH_VERSION" ]; then
    PROJECT_SHELL=bash
elif [ -n "$ZSH_VERSION" ]; then
    PROJECT_SHELL=zsh
else
    echo "shell-init.sh: warning: could not determine shell, assuming bash" >&2
    PROJECT_SHELL=bash
fi
export PROJECT_SHELL

# Get the path to this script.
if [ -z "$PROJECT_INIT" ]; then
    case $PROJECT_SHELL in
        bash)
            PROJECT_INIT="${BASH_SOURCE[0]}"
            ;;
        zsh)
            # https://stackoverflow.com/questions/9901210/bash-source0-equivalent-in-zsh
            PROJECT_INIT="${(%):-%N}" ;; esac fi

# Get the full path to this repository.
# https://stackoverflow.com/questions/59895/getting-the-source-directory-of-a-bash-script-from-within
export THIS_ROOT_DIR="$(cd "$(dirname "$PROJECT_INIT")/.." >/dev/null && pwd)"


# Configure myproject-aws-assume
config_dir="${HOME}/.config/myproject-aws-helper"
mkdir -p ${config_dir}
cp $THIS_ROOT_DIR/command-line-tools/etc/awstools.toml ${config_dir}/

# Add 'bin' directory to the PATH.
export PATH=$THIS_ROOT_DIR/bin:$PATH

# Load functions.
. "$THIS_ROOT_DIR/etc/shell-functions.sh"

