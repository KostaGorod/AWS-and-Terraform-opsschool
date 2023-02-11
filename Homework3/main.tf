module "vpc_module" {
  source                    = "./modules/vpc-module"
  vpc_cidr_block            = "10.0.0.0/16"
  private_subnets_cidr_list = ["10.0.2.0/24", "10.0.3.0/24"]
  public_subnets_cidr_list  = ["10.0.100.0/24", "10.0.101.0/24"]
  APP_NAME                  = "Whiskey-Website"
  ENV                       = "stg"
}
