# AWS Init Roles

The purpose of this repository to be a project template for aws accounts that don't yet have a AWS role-strategy plan.

## Contents

1. [Define the Roles](#define-the-roles)
2. [Using AWS Roles](#using-aws-roles)
3. [Permissions Boundaries: Limiting the Power of Roles](#permissions-Boundaries:-limiting-the-power-of-roles)

### File Structure

```
.
+-- command-line-tools
|   +-- etc/
|   +-- bin/
|   +-- README.md
+-- docs
|   +-- aws-roles/
|   +-- +-- command-line-access.md
|   +-- +-- console-access.md
|   +-- +-- README.md
+-- iam-admin
|   +-- role-myteam-admin/
|   +-- role-myteam-developer/
|   +-- role-myteam-readonly/
|   +-- users.tf
|   +-- main.tf
|   +-- iam-myteam-admin.tf
|   +-- iam-myteam-developer.tf
|   +-- iam-myteam-readonly.tf
```

## Define the Roles

Within `/iam-admin` there is a standard interface for the file structure which looks like the following:

```
+-- iam-admin
|   +-- role-myteam-<some-role>/
|   +-- +-- group.tf
|   +-- +-- group-policies.tf
|   +-- +-- role.tf
|   +-- +-- role-policies.tf
|   +-- +-- policy-self-service-aws-access-key.tf
|   +-- +-- policy-self-service-aws-list-iam-users.tf
|   +-- +-- policy-self-service-aws-mfa.tf
|   +-- +-- policy-<some-policy-name>.tf
|   +-- +-- variables.tf
|   +-- users.tf
|   +-- main.tf
|   +-- iam-myteam-<some-role>.tf

```

1. **Users** (outside the interface) get assigned to **groups** (`group.tf`)
2. A **group** gets a sts:AssumeRole **policy** attached to it (`group-policy.tf`)
3. A **role** is assigned to a **group** (`role.tf`)
4. A **role** gets a sts:AssumeRole **policy** with the AWS principal attached to it (`role-policy.tf`)
5. A **role** gets **self-service policies** (manage own account password, mfa device) attached to it (`policy-self-service-*.tf`)
6. A **role** gets any **other policies** allowing it to access certain AWS resources attached to it (`policy-*.tf`)



The reason behind his interface is:

* **Decouple and Isolate**
  * Ensure that the AWS resources defining any role (including the policies, group, and attachments) are completely isolated (Separation of Concerns and SRP) such that the role can be moved to different AWS accounts in the near future. Additionally, there is no need to figure out where "shared policies" might live.
  * Ensure that the reader can grasp meaning (what resources are involved) from the file structure. The flat structure means that everything is there. Nothing is hidden.
* **Open for Extension (and no need to modify)**
  * Should an administrator need to add a additional permissions via a policy to this role, he/she needs to simply add a new file `policy-<some-policy-name>.tf` containing the terraform resources for `aws_iam_policy_document`, `aws_iam_policy`, and `aws_iam_policy_attachment`. 
  * Should an administrator need to delete a policy, he/she simply needs to remove that file.
* **Inject the Dependencies**
  * The module depends on users that exist. `users.tf` exists outside of a `role-myteam-<some-role>` module and gets injected when the module is called in `iam-myteam-<some-role>.tf`
* **Just About Liskov-friendly**
  * Each role module walks, talks, and acts like a role. While they are the same type of unit and only differ by their list of permissions defined at `policy-*.tf` (and of course, some have more powers than the others, ie `my team-admin`). But at the end of the day, it's a role.



## Using AWS Roles

This project also offers an example of command line tools around changing roles. These [command line tools](./command-line-tools/README.md) are a bash wrapper around [sam701/awstools](github.com/sam701/awstools). 

* [Learn how to set it up](./command-line-tools/README.md)
* [Learn how to use it](./docs/aws-roles/README.md)

There are a few benefits by using `awstools` as a base. It was built by three developers who are still active: Alexei S. (former Scout24, now Proseiben), Moritz H. (TW), Serge G. (former TW, now Scout24). Additionally, this tool enforces important security measures including: 

1. AWS Multi-Factor Authentication (MFA)
2. Rotation of Access Keys


## Permissions Boundaries: Limiting the Power of Roles
### Creating a Permissions Boundary for an Assumed Role (by a human user)

Within the team, a developer should only need to use the `myteam-developer` role to do his/her daily work, which could include bringing up EC2 instances, ECR repositories, and creating users/roles for onboarded teams. We can enable the role to do these things (and only these things) by creating a Permissions Boundary.

This Permission Boundary is simply a set  of possible actions that a `myteam-developer` can take and what resources the actions can be applied to. It is important to note that the Permissions Boundary itself does not give permissions to a particular IAM entity (in this case, an IAM role myteam-developer) because it is simply a bubble of limitations: a Identity-Based Policy (which  is the resource that actually grants permissions to the IAM entity) must be created and the intersection of the Permissions Boundary and the Identity-Based Policy then determines the final set of actions and resources the IAM Entity can interact with.



#### Building a Permissions Boundary (Theoretics)

A Permissions Boundary looks exactly like an IAM Policy:

    data "aws_iam_policy_document" "myteam-developer-boundary" {
        statement = {
            actions = [
                "ec2:*
            ]
            
            resources = [
                "*"
            ]
        }
    }
    
    resource "aws_iam_policy" "myteam-developer-boundary" {
      name = "myteam-developer-boundary"
      policy = "${data.aws_iam_policy_document.myteam-developer-boundary.json}"
    }

The permissions boundary must be attached to the myteam-developer role.

    resource "aws_iam_role" "myteam-developer-role" {
      name = "myteam-developer"
      assume_role_policy = "<assume-role-policy-json>"
      permissions_boundary = "${aws_iam_policy.myteam-developer-boundary.arn}"
    }


Additionally, an Identity-based policy must be created and attached to the myteam-developer role:

    data "aws_iam_policy_document" "myteam-developer-change-ec2" {
        statement = {
            actions = [
                "ec2:*
            ]
            
            resources = [
                "*"
            ]
        }
        
        statement = {
            actions = [
                "ecr:*",
            ]
            
            resources = [
                "*"
            ]
        }
    }
    
    resource "aws_iam_policy" "myteam-developer-change-ec2" {
      name = "myteam-developer-change-ec2"
      policy = "${data.aws_iam_policy_document.myteam-developer-change-ec2.json}"
    }
    
    resource "aws_iam_policy_attachment" "myteam-developer-change-ec2" {
      name       = "myteam-developer-change-ec2-policy-attachment"
      roles      = ["${aws_iam_role.role.name}"]
      policy_arn = "${aws_iam_policy.myteam-developer-change-ec2.arn}"
    }

According to this example, the entity that has assumed the myteam-developer role, can do anything ("*") to ec2 resources (because the boundary has allowed it) but cannot do anything to ecr resources (because it is not in the set of permissions supplied in the permissions boundary/not in the intersection of permissions between the Permissions Boundary and the Identity-based policy). To allow the myteam-developer to perform actions on ecr resources, the following statement must be added to the myteam-developer-boundary:

    statement = {
    	actions = [
    		"ecr:*
        ]
            
    	resources = [
    		"*"
    	]
    }

#### Implement a Permissions Boundary for a Role

1. Switch to the `myteam-admin` role

2. Change into the directory where your roles are defined (ie. `/iam-admin` per the example)

3. Create a boundary for `myteam-developer` (assuming the role already exists -- follow the instructions in [Define the Roles](#define-the-roles) if it doesn't) in `/role-myteam-admin/myteam-developer-boundaries.tf  `which sets the boundary the `myteam-developer` role.     

  ```
  data "aws_iam_policy_document" "myteam-developer-boundary" {
  	statement {
  		actions = ["iam:*"]
  		effect = "Deny"
  		resources = [
  			"arn:aws:iam::1234567890:group/super-important-group-you-should-not-delete",
  			"arn:aws:iam::1234567890:user/super-important-user-you-should-not-delete"
  		]
  	}
  
  	statement {
  		actions = ["ec2:*"]
  		resources = ["*"]
   	}
   }
   
   resource "aws_iam_policy" "myteam-developer-boundary" {
     name = "myteam-developer-boundary"
     policy = "${data.aws_iam_policy_document.myteam-developer-boundary.json}"
   }
  ```

4. In `/iam-admin/role-myteam-developer`:

  - Create an Identity-based Policy to allow ec2 actions (this will allow the role to ec2:DescribeInstances) in `/iam-admin/role-myteam-developer/policy-do-the-work.tf`

    ```
    data "aws_iam_policy_document" "myteam-developer-do-the-work" {
    	statement {
    		actions = ["ec2:DescribeInstances"]
    		resources = ["*"]
    	}
    }
    
    resource "aws_iam_policy" "myteam-developer-do-the-work" {
      name = "myteam-developer-do-the-work"
      policy = "${data.aws_iam_policy_document.myteam-developer-do-the-work.json}"
    }
    
    resource "aws_iam_policy_attachment" "myteam-developer-do-the-work" {
      name       = "myteam-developer-do-the-work-policy-attachment"
      roles      = ["${aws_iam_role.role.name}"]
      policy_arn = "${aws_iam_policy.myteam-developer-change-ec2.arn}"
    }
    ```

5. Initialise that module in `/iam-admin/iam-myteam-developer.tf`

  ```
  module "myteam-developer" {
  	source = "role-myteam-developer"
  	account-id = "${data.aws_caller_identity.current.account_id}"
  	team-name = "myteam"
  	role = "developer"
  	permissions-boundary-arn = "${module.myteam-admin.myteam-developer-boundary-arn}"
  	team-members = [
  		"${aws_iam_user.you.name}"
  	]
   }
  ```

6. Create users if they don't already exist in `/iam-admin/users.tf`:

      resource "aws_iam_user" "you" {
      	name = "you@super-cool-dev.com"
      }

7. In `/iam-admin`, terraform apply after assuming the `myteam-admin` role

8. Change to the `myteam-developer` role by using `myproject-aws-assume myaccount myteam-developer`. Verify by calling [describe-instances cli method](https://docs.aws.amazon.com/cli/latest/reference/ec2/describe-instances.html).

### Creating a Permissions Boundary for a Role Created By A myteam-developer

Since creating users and roles for teams might be a part of the `myteam-developer` daily work, the `myteam-developer` should be able to perform basic iam actions such as:

    iam:AttachRolePolicy
    iam:CreateRole
    iam:DeleteRolePolicy
    iam:DetachRolePolicy
    iam:PutRolePermissionsBoundary
    iam:PutRolePolicy



#### Building a Permissions Boundary (Theoretics)

Modify the original `myteam-developer-boundary` from the above section by adding a statement (the first statement block below) to the original policy document, which would allow the `myteam-developer role` to perform the above actions, provided that a new boundary separately created for that role is attached to the role. 

**NOTE**: not all iam actions have the variable `iam:PermissionsBoundary` and will be ignored in the final IAM permissions evaluation. View the complete [list](https://docs.aws.amazon.com/IAM/latest/UserGuide/list_identityandaccessmanagement.html). 

    data "aws_iam_policy_document" "myteam-developer-boundary" {
      statement {
        sid = "CreateOrChangeRoleOnlyWithBoundary"
        actions = [
          "iam:AttachRolePolicy",
          "iam:CreateRole",
          "iam:DeleteRolePolicy",
          "iam:DetachRolePolicy",
          "iam:PutRolePermissionsBoundary",
          "iam:PutRolePolicy",
        ]
        resources = ["*"]
    
        condition {
          variable = "iam:PermissionsBoundary"
          test = "StringEquals"
          values = ["${aws_iam_policy.cat-herder-role-boundary.arn}"]
        }
      }
      
      statement = {
            actions = [
                "ec2:*
            ]
            
            resources = [
                "*"
            ]
        }
        
        statement = {
            actions = [
                "ecr:*",
            ]
            
            resources = [
                "*"
            ]
        }
    }


The separately created permissions boundary for that role is defined as follows (which sets the permission limits of the role):

    resource "aws_iam_policy" "cat-herder-role-boundary" {
      name = "cat-herder-role-boundary"
      policy = "${data.aws_iam_policy_document.cat-herder-role-boundary.json}"
    }
    
    data "aws_iam_policy_document" "cat-herder-role-boundary" {
      statement {
        sid = "AllowReadFromSecretManager"
        actions = [
          "secretsmanager:DescribeSecret",
          "secretsmanager:GetSecretValue",
          "secretsmanager:ListSecrets",
        ]
        resources = ["*"]
      }
    }

Then the new permissions boundary must be attached to the new role (`cat-herder`) that the `myteam-developer` is creating.

    resource "aws_iam_role" "cat-herder-role" {
      name = "cat-herder"
      assume_role_policy = "<assume-role-policy-json>"
      permissions_boundary = "${aws_iam_policy.cat-herder-role-boundary.arn}"
    }


 Additionally, an Identity-based policy must be created and attached to the `myteam-developer` role:

    data "aws_iam_policy_document" "cat-herder-read-secrets" {
        statement = {
            actions = [
          		"secretsmanager:DescribeSecret",
          		"secretsmanager:GetSecretValue",
          		"secretsmanager:ListSecrets",
        	]
        	resources = ["*"]
        }
    }
    
    resource "aws_iam_policy" "cat-herder-read-secrets" {
      name = "cat-herder-read-secrets"
      policy = "${data.aws_iam_policy_document.cat-herder-read-secrets.json}"
    }
    
    resource "aws_iam_policy_attachment" "cat-herder-read-secrets" {
      name       = "cat-herder-read-secrets-policy-attachment"
      roles      = ["${aws_iam_role.role.name}"]
      policy_arn = "${aws_iam_policy.cat-herder-read-secrets.arn}"
    }

#### Implement a Permissions Boundary for a Role Created By myteam-developer

1. Switch to the `myteam-admin` role

2. `cd iam-admin/`

3. Create a boundary for a role `cat-herder` in `/role-myteam-admin/create-cat-herder-role.tf`
      resource "aws_iam_policy" "myteam-developer-create-cat-herder-role-boundary" {
      	name = "myteam-developer-create-cat-herder-role-boundary"
      	policy = "${data.aws_iam_policy_document.myteam-developer-create-cat-herder-role-boundary.json}"
      }
      
      data "aws_iam_policy_document" "myteam-developer-create-cat-herder-role-boundary" {
      	statement {
           sid = "AllowReadFromSecretManager"
           actions = [
             "secretsmanager:DescribeSecret",
             "secretsmanager:GetSecretValue",
             "secretsmanager:ListSecrets",
           ]
           resources = ["*"]
         }
       }

4. Update the `myteam-developer` boundary to include the following statement in `myteam-developer-boundaries.tf` 
       
      data "aws_iam_policy_document" "myteam-developer-boundary" {
      	statement {
      		sid = "CreateOrChangeCatHerderRoleOnlyWithBoundary"
      		actions = [
      			"iam:AttachRolePolicy",
                 	"iam:CreateRole",
                 	"iam:DeleteRolePolicy",
                 	"iam:DetachRolePolicy",
                 	"iam:PutRolePermissionsBoundary",
                 	"iam:PutRolePolicy",
               ]
               resources = ["*"]
           
          condition {
          	variable = "iam:PermissionsBoundary"
            	test = "StringEquals"
            	values = ["${aws_iam_policy.myteam-developer-create-cat-herder-role-boundary.arn}"]
          }
      }

5. In `/iam-admin`, `terraform apply` after assuming the `myteam-admin` role

6. Change to the `myteam-developer` role. Change into the directory holding the code you'd like to `terraform-apply` the creation of your new role (`cat-herder`) and add the following and then `terraform-apply`

      ```
      data "terraform_remote_state" "myteam_iam" {
      backend = "s3"
          config {
            key = "myteam_iam-admin"
            region = "eu-central-1"
            bucket = "myteam-terraform-state"
            dynamodb_table = "TerraformLocks"
          }
      }
      
      resource "aws_iam_role" "example" {
            name = "{local.team_name}-ci" // or -developer
            permissions_boundary = "{data.terraform_remote_state.myteam_iam.myteam-developer-create-cat-herder-role-boundary-arn}"
      }
      
      data "aws_iam_policy_document" "read-secrets" {
          statement = {
              actions = [
            		"secretsmanager:DescribeSecret",
            		"secretsmanager:GetSecretValue",
            		"secretsmanager:ListSecrets",
          	]
          	resources = ["*"]
          }
      }
      
      resource "aws_iam_policy" "read-secrets" {
        name = "read-secrets"
        policy = "${data.aws_iam_policy_document.read-secrets.json}"
      }
      
      resource "aws_iam_policy_attachment" "read-secrets" {
        name       = "read-secrets-policy-attachment"
        roles      = ["{aws_iam_role.role.name}"]
        policy_arn = "{aws_iam_policy.read-secrets.arn}"
      }
      
      ```

      

      




