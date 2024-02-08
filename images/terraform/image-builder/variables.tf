variable "name" {
  type        = string
  description = "(Required) Name of the image-builder"
}

variable "vpc_id" {
  type        = string
  description = "(Required) VPC ID to deploy the EC2 Image Builder Environment."
}

variable "aws_region" {
  type        = string
  description = "(Required) AWS Region to deploy the resources"
}

variable "subnet_id" {
  type        = string
  description = "(Required) Subnet ID to deploy the EC2 Image Builder Environment."
}

variable "source_cidr" {
  type        = list(string)
  description = "(Required) Source CIDR block which will be allowed to RDP or SSH to EC2 Image Builder Instances"
}

variable "tags" {
  description = "(Optional) A map of resource tags to associate with the resource"
  type        = map(string)
  default     = {}
}

variable "attach_custom_policy" {
  type        = bool
  description = "(Required) Attach custom policy to the EC2 Instance Profile, if true, ARN of the custom policy needs to be specified on the variable custom_policy_arn"
  default     = false
}

variable "custom_policy_arn" {
  type        = string
  description = "(Optional) ARN of the custom policy to be attached to the EC2 Instance Profile"
  default     = null
}

variable "instance_types" {
  type        = list(string)
  description = <<-EOD
  (Optional) Instance type for the EC2 Image Builder Instances. 
  Will be set by default to c5.large. Please check the AWS Pricing for more information about the instance types.
  EOD
  default     = ["c5.large"]
}

variable "terminate_on_failure" {
  default     = true
  description = "(Optional) Change to false if you want to connect to a builder for debugging after failure"
  type        = bool
}

variable "schedule_expression" {
  type = list(object({
    pipeline_execution_start_condition = string,
    scheduleExpression                 = string
  }))
  description = <<-EOD
  "(Optional) pipeline_execution_start_condition = The condition configures when the pipeline should trigger a new image build. 
  Valid Values: EXPRESSION_MATCH_ONLY | EXPRESSION_MATCH_AND_DEPENDENCY_UPDATES_AVAILABLE
  scheduleExpression = The cron expression determines how often EC2 Image Builder evaluates your pipelineExecutionStartCondition.
  e.g.:  "cron(0 0 * * ? *)"
  EOD
  default     = []
}

variable "recipe_version" {
  type        = string
  description = "(Required) The semantic version of the image recipe. This version follows the semantic version syntax. e.g.: 0.0.1"
  default     = "0.0.1"
}

# variable "recipe_volume_size" {
#   default     = 100
#   description = "(Optional) Volume Size of Imagebuilder Image Recipe Block Device Mapping"
#   type        = string
# }

# variable "recipe_volume_type" {
#   default     = "gp3"
#   description = "(Optional) Volume Type of Imagebuilder Image Recipe Block Device Mapping"
#   type        = string
# }

variable "build_component_arn" {
  type        = list(string)
  description = "(Required) List of ARNs for the Build EC2 Image Builder Build Components"
  default     = []
}

variable "source_ami_id" {
  type        = string
  description = "(Required) The ID of the source AMI"
}