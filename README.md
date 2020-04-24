# AWS Init Roles

Managing your AWS IAM strategy is the first step towards securing your AWS account and is often the first line of defence to preventing unauthorised access.  AWS offers some basic guidelines in their [Well Architected Framework whitepaper ("Security" pillar)](https://d1.awsstatic.com/whitepapers/architecture/AWS_Well-Architected_Framework.pdf). 

However, implementing a secure IAM strategy to securing AWS access can be tricky and requires a learning curve, especially it is your first time doing so. There are many such strategies, and choosing one requires you to fully understand what human actors you have and what they are expected to do in their daily line of work and how that translates to the appropriate IAM permissions.

For example:

* **Administrator** (you) - manages IAM human users
* **Infrastructure Developers** - provisions compute machines but requires a subset of IAM permissions to create machine roles (e.g. instance profiles for EC2, Lambda execution roles)
* **Application Developers** - does not provision compute machines but needs access to other AWS services, such as AWS Secrets Manager or AWS ECR.

This repository offers one of many IAM strategy solutions and is based on the assumption that you, as an administrator of an AWS IAM account, wants to manage IAM entities but you have a trusted team of Infrastructure Developers who provision compute machines but need access to create IAM roles for those compute machines.

## The Use Case

You, as an **Administrator**, want to manage IAM for your AWS Account. What's most important to you is that <u>you manage the human users that have access to the AWS account</u>. You also have a team of **Infrastructure Developers** who need to <u>provision compute devices and create IAM roles for those compute devices</u>. You want to allow them to create those IAM roles without you needing to interfere (merge PRs, apply changes, answer angry "this is blocking the team" emails), but you also want to ensure that those IAM Roles (for compute devices) are only allowed to perform actions and resources within a certain boundary.

<IMAGE: Admin vs. Developer>

### The Resulting Separation of Responsibilities

* **Administrator:** Creates and manages IAM human users and sets the boundaries of what those users can do via permissions boundaries
* **Developer:** Provisions Compute Machines on AWS and creates IAM roles within the permissions boundary set for them by the Administrator

What makes this separation of responsibilities possible are [Permissions Boundaries](#permissions-boundaries).

### Permissions Boundaries

AWS provides quite a bit of helpful documentation about Permissions Boundaries and I encourage you to get an in-depth overview of [how Permissions Boundaries work](https://docs.aws.amazon.com/IAM/latest/UserGuide/access_policies_boundaries.html) and [how to apply them](https://docs.aws.amazon.com/IAM/latest/UserGuide/list_identityandaccessmanagement.html) and [how they are evaluated with respect to other IAM Policies](https://docs.aws.amazon.com/IAM/latest/UserGuide/reference_policies_evaluation-logic.html). This section assumes that you already have the knowledge encapulated by the AWS docs.

The most relevent aspects of Permissions Boundaries for this module are:

* An Administrator can create a Permissions Boundary
* An Administrator can allow a Developer to create IAM roles by requiring them to attach a Permissions Boundary to the IAM role, which limits the effective permissions of the IAM role
* A Developer assigns identity-based policies to the IAM role. Only the permissions that are within the Permissions Boundary become effective (any identity-based policies defined outside of the Permissions Boundaries are ignored)

![effective-boundaries](https://docs.aws.amazon.com/IAM/latest/UserGuide/images/EffectivePermissions-scp-boundary-id.png)
From: https://docs.aws.amazon.com/IAM/latest/UserGuide/access_policies_boundaries.html

## Usage
```hcl-terraform
module "iam" {
  source = "git::ssh://kelseymok@github.com/aws-init-roles.git"

  administrator-trusted-entities = [
    aws_iam_user.admin-user.arn
  ]
  
  developer-trusted-entities = [
    aws_iam_user.developer-user.arn
  ]
  
  org = "myOrg"
}

module "developer-user" {
  source = "git::ssh://git@github.com/kelseymok/aws-init-roles.git//user?ref=v1.2.0"
  username = "number-zero-developer"
}

module "admin-user" {
  source = "git::ssh://git@github.com/kelseymok/aws-init-roles.git//user?ref=v1.2.0"
  username = "the-enabler"
}
```

#### Inputs

| Field                              | Description                                                  | Type                   | Default         |
| :--------------------------------- | ------------------------------------------------------------ | ---------------------- | --------------- |
| **developer-role-name**            | The role name of the developer                               | optional, string       | "developer"     |
| **developer-trusted-entities**     | A list of AWS IAM user ARNs, representing those who are Developers | required, list(string) | []              |
| **administrator-role-name**        | The role name of the administrator                           | optional, string       | "administrator" |
| **administrator-trusted-entities** | A list of AWS IAM user ARNs, representing those who are Administrators | required, list(string) | []              |
| **org**                            | The name of the group of managed users                       | optional, string       | "managed-users" |

#### Outputs

| Field                        | Description                                                  | Type   |
| ---------------------------- | ------------------------------------------------------------ | ------ |
| **permissions-boundary-arn** | The ARN of the Permissions Boundary for Developers to attach to their compute machines' IAM roles | string |
| **administrator-role-arn**   | The ARN of the administrator role which authorised IAM users (defined by administrator-trusted-entities) can assume | string |
| **developer-role-arn**       | The ARN of the developer role which authorised IAM users (defined by developer-trusted-entities) can assume | string |

## Assuming a Role

### Console

```
https://signin.aws.amazon.com/switchrole?account=<your-account_id_number>&roleName=<role_name>
```

### CLI

Set up your AWS CLI credentials according to the [AWS CLI docs](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-configure.html). You should have the following files with the profile `base`:

```bash
# ~/.aws/config

[profile base]                                            
region = eu-central-1                                          
mfa_serial = arn:aws:iam::<your-aws-account-number>:mfa/<your-username>
```

```bash
# ~/.aws/credentials

[base]
aws_access_key_id = <some-access-key-id>
aws_secret_access_key = <some-secret-access-key>
```

I have provided a couple of Docker Images to help with assuming a role. First build the image: `./go build`

There are two ways you can run the Docker Image:

1. As a tool to assume a role: `./go assume-role <Role Name>`
2. As a tool to assume a role and as a development environment (comes with Terraform and a few base libraries): `./go run` (and then `assume-role <Role Name>` once dropped into a bash session)

Both methods update your Shared Credentials file (`~/.aws/credentials`) with a profile named `<Role Name>`. 

If you use Terraform, make sure to add a profile to your provider configuration:
```hcl-terraform
provider "aws" {
  region = "eu-central-1"
  profile = "Your Role Name"
}
```

#### Notes

I'll let the code self-describe the effective policies of the boundary and resulting Administrator and Developer roles. Something that might not be very transparent is that the two roles require the IAM user to have a valid MFA session. If a user does not have a valid MFA session to start with, one common gotcha is that they will need to set it up in the AWS Console, then log out, then log back in before they can assume a role.



### An Argument for Wide Boundaries

Some of the more eagle-eyed among you might have spotted that the IAM Permissions Boundary for compute device roles is currently set at Power User Access, which is roughly the same as the permissions as the Developer role. This is by design.   If we recall, a Permissions Boundary is used so that a Developer role cannot create an IAM Role for a compute machine that has the permissions to manage IAM access or make Organizational/AWS Account-wide changes. Additionally, a problem meant to be solved by the separation of responsibilities and permissions boundaries is to ensure that you as an Administrator is not blocking a development team from provisioning infrastructure, especially if you do not care to know what compute machine roles are created (because any permissions outside of a permissions boundary will never become effective).

Of course, one can make an argument for many boundaries, but this means you as an administrator will have to define with the team what those boundaries are and how they map to IAM compute machine roles, which again means that you are in the direct line of interaction with your team (merging PRs, applying changes, answering angry "this is blocking the team" emails).


