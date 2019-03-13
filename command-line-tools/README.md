# Command Line Tools
...around assuming a role (using aws tools)

## Setup
Add this to your `~/.profile` / `.bash_profile` / `~/.zshrc` (depending
on your shell and setup):
```bash
MYPROJECT_INIT=path/to/dev-tools/etc/shell-init.sh
[ -f $MYPROJECT_INIT ] && . $MYPROJECT_INIT
```

The initialization script assumes that you have a directory where you
check out all project repositories, including this one

## Available commands

* `myproject-aws-assume`: Assumes a user for an account in the format (for example) `myproject-aws-assume myaccount myteam-developer`

* `myproject-aws-accounts`: Lists accounts for which roles can be assumed in

* `myproject-aws-whoami`: Returns information about what role (and in which account) you've assumed
