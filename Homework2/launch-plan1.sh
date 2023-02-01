terraform init
terraform validate
terraform plan -out plan1.tfplan
terraform apply "plan1.tfplan"
terraform destroy