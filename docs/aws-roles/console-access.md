# AWS Console Access

## Obtain an Account

1. A team member who can assume the `myteam-admin` role will need to give you access to assume one of the already present roles [iam-admin](../../iam-admin). 

2. The team member will then create a password for your user in the AWS console (you must change the password to something you remember when you log in, according the password policy)

## MFA

One you are able to successfully log into the AWS Console (https://123456789012.signin.aws.amazon.com/console) with your password, you must **enable MFA** to interact with any of the AWS services: 

* Navigate to **Services** > **IAM** > **Users** > **(choose your username)** > **Security Credentials** > **Assign MFA device** (Virtual or YubiKey)
* **NOTE**: you will need to log out and back in again for the MFA to take effect (which will in turn allow you to access the resources denoted by your new role)


## Switching Roles in Accounts

In order to make manual console changes to the resources to which a role is allowed to make changes, you must switch roles in the console (https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_use_switch-role-console.html)