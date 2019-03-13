myproject-aws-assume() {
  config_dir="${HOME}/.config/myteam-aws-helper"

  creds_file=$(mktemp)
  awstools --config ${config_dir}/awstools.toml assume --export ${creds_file} --export-profile $@
  source ${creds_file}
  rm ${creds_file}
}

myproject-aws-accounts() {
  n=$(cat ${config_dir}/awstools.toml | grep -n '\[accounts\]' | cut -d':' -f1)
  n=$((n+1))
  cat ${config_dir}/awstools.toml | awk "FNR>=${n}" | sed 's/ = / /g' | sed 's/"//g'
}

myproject-aws-whoami() {
  arn=$(aws sts get-caller-identity | jq -r .Arn)
  user=$(echo ${arn} | rev | cut -d'/' -f 1 | rev)
  account_id=$(echo ${arn} | cut -d':' -f 5)
  account_name=$(myproject-aws-accounts | grep ${account_id} | cut -d" " -f 1)
  role=$(echo ${arn} | grep "assumed-role" | rev | cut -d'/' -f 2 | rev)
  echo "${user}, ${role} @ ${account_name} (${account_id})"
}
