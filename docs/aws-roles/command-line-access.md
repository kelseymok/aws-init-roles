# Command Line Access

## One-time Setup

1. Install `awstools` by running the following commands:

```
brew tap sam701/awstools
brew install awstools
```

2. Pull the latest from this repository
   * If it's a fresh clone, follow the instructions to set it up
   * If it's not a fresh clone and it has already been installed, you simply need to start a new terminal session or `source` your `.bash_profile` (or whereever you've installed it)

3. Create a new Access key in AWS. Keep open the access key and secret. ([AWS Documentation][aws-access-key])

4. Run the following command and configure with the access key id and secret along with the default region `eu-central-1` ([AWS Documentation][aws-cli-config]):

```
aws configure --profile myaccount
```

**NOTE**: There is a bug in `awstools` up to version 0.13.1 that does not set
the default region properly, causing problems with `credstash`.
To fix, run this once for each role you want to assume:

```
aws configure set region eu-central-1 --profile "myaccount <role>"
```

For example:

```
aws configure set region eu-central-1 --profile "myaccount myteam-developer"
```

## Assuming Roles

5. Run `aws-assume myaccount myteam-developer` (or whichever roles you've configured). It will prompt you for an MFA and then you should be able to run your normal terraform (etc) commands.

6. Verify which role you have assumed: `aws-whoami`


[aws-access-key]: http://docs.aws.amazon.com/IAM/latest/UserGuide/id_credentials_access-keys.html#Using_CreateAccessKey
[aws-cli-config]: http://docs.aws.amazon.com/cli/latest/userguide/cli-chap-getting-started.html#cli-quick-configuration
