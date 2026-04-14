variable "vpc_cidr" {
    description = "This is Variable is Used for VPC_CIDR"
    type = string
    default= "10.0.0.0/16"
  
}

// This will Prompt the User to Enter the Value for Project Name when we run the terraform apply Command. This is a Required Variable as there is no Default Value Provided for this Variable.
variable "project_name" {
    description = "Your Project Name"
    type = string
  
}