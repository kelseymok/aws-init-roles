# Setting up AWS Access

## Follow the instructions in order
1. [Logging into the AWS console](console-access.md)
2. [Authenticating via command-line](command-line-access.md)

## Account Structure
* `myteam-admin` can make changes to `iam` resources (for example, changing user policies) for HUMAN users
* `myteam-developer` at the moment has read only `iam` resources (while still allowing changes to ECR IAM policies for teams' ci users) and can change everything else.
* `myteam-readonly` has read-only access to everything according to the AWS IAM ReadOnly Policy

