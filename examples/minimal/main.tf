resource "aws_vpc" "es_vpc" {
  cidr_block = "1.2.3.0/24"
}

resource "aws_subnet" "es_subnet" {
  vpc_id     = aws_vpc.es_vpc.id
  cidr_block = "1.2.3.0/24"
}

module "sg-ports" {
  #source = "git::https://github.com/Datatamer/terraform-aws-es.git//modules/es-ports?ref=2.0.0"
  source = "../../modules/es-ports"
}

module "aws-sg" {
  source = "git::git@github.com:Datatamer/terraform-aws-security-groups.git?ref=0.1.0"
  vpc_id = aws_vpc.es_vpc.id
  ingress_cidr_blocks = [
    "1.2.3.0/24"
  ]
  egress_cidr_blocks = [
    "0.0.0.0/0"
  ]
  ingress_ports  = module.sg-ports.ingress_ports
  sg_name_prefix = var.name-prefix
}

module "tamr-es-cluster" {
  source      = "../../"
  vpc_id      = aws_vpc.es_vpc.id
  domain_name = format("%s-elasticsearch", var.name-prefix)
  subnet_ids  = [aws_subnet.es_subnet.id]
  # Only needed once per account, so may need to set this to false
  create_new_service_role = true
  security_group_ids      = module.aws-sg.security_group_ids
}
