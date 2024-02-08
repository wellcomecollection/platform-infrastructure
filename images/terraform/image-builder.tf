resource "aws_s3_bucket" "image-builder" {
  bucket = "wellcomecollection-imagebuilder"
}

locals {
    image_builder_source_ami_filter = "amzn2-ami-ecs-hvm-2.0.*-x86_64-ebs"
    image_builder_aws_region = "eu-west-1"
    image_builder_vpc_id   = "SET_THIS_VALUE_FROM_CONFIG"
    image_builder_subnet_id = "SET_THIS_VALUE_FROM_CONFIG"
    image_builder_source_cidr = ["SET_THIS_VALUE_FROM_CONFIG"]
    example_component = {
        phases = [{
        name = "build"
        steps = [{
            action = "ExecuteBash"
            inputs = {
            commands = ["echo 'hello world'"]
            }
            name      = "example"
            onFailure = "Continue"
        }]
        }]
        schemaVersion = 1.0
  }
}

resource "aws_s3_object" "example" {
  bucket = aws_s3_bucket.image-builder.bucket
  key    = "components/example.yaml"
  content = yamlencode(local.example_component)
}

resource "aws_imagebuilder_component" "example" {
  name     = "example"
  platform = "Linux"
  uri      = "s3://${aws_s3_object.example.bucket}/${aws_s3_object.example.key}"
  version  = "1.0.1"

  depends_on = [ aws_s3_object.example ]
}

data "aws_ami" "source_ami" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = [local.image_builder_source_ami_filter]
  }
}

module "ec2-image-builder" {
  source              = "./image-builder"
  name                = "amazon-linux-2-ecs-collection-x86"
  vpc_id              = local.image_builder_vpc_id
  subnet_id           = local.image_builder_subnet_id
  aws_region          = local.image_builder_aws_region
  source_cidr         = local.image_builder_source_cidr
  source_ami_id       = data.aws_ami.source_ami.id
  # ami_name            = "amazon-linux-2-ecs-collection-x86" 
  # ami_description     = "Wellcome Collection Amazon Linux x86 AMI for ECS" 
  recipe_version      = "0.0.1"
  build_component_arn = [aws_imagebuilder_component.example.arn]
}