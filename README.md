# AWS Init Roles

The purpose of this repository to be a project template for aws accounts that don't yet have a AWS role-strategy plan.

## Contents

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
|   +-- iam-myteam-<some-role>.tf
```

## iam-admin

Within `iam-admin` there is a standard interface for the file structure which looks like the following:

```
+-- iam-admin
|   +-- role-myteam-<some-role>
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



