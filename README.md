# DevOps test task

## Prerequisites

You will be provided with AWS credentials with this account.
You should be using Terraform with version specified in the [provider.tf](./provider.tf) file.

This repository already contains a skeleton Terraform project with some base resources provisioned:

- S3 bucket for terraform state
- Dynamo DB table for terraform state locking
- Route53 zone `httpbin-ft.etvnet.com`, already delegated to this account

Please reduce modifications to the existing files and resources to a minimum, unless you have a good reason to do so. You may add new files and resources as you see fit.

You should create a new branch for your work and push it to this repository. There is not need for a pull request.

## Task objective

Application of this Terraform project should ideally produce a running and publicly acessible
[httpbin](http://httpbin.org/) service. No manual intervention is required.

- The service responds to the `www.httpbin-ft.etvnet.com` hostname
- The service is fault tolerant and running on AWS ECS/Fargate (preferrably spot)
- HTTPS protocol is used, HTTP redirects to HTTPS with the same hostname
- `httpbin-ft.etvnet.com` redirects to `https://www.httpbin-ft.etvnet.com` (on both http and https)
- ECS tasks send their logs to Cloudwatch (bonus points: the log expires in 7 days)
- Please add comments where you think Terraform code could be improved or nice/useful features added, no need to implement everthing at once
- While you may use KMS encryption for some parts of the stack (cloudwatch log group comes to mind), it's not necessary for this sample project

## Tips

- The zone `httpbin-ft.etvnet.com` is delegated to this account and its ID could be accessed as `aws_route53_zone.this.zone_id`
- Use the [official httbin Docker image](https://hub.docker.com/r/kennethreitz/httpbin/)
- Use [AWS ACM](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/acm_certificate_validation) for SSL certificate generation. DNS validation should be the best
- Please use your editor's plugin to [format](https://www.terraform.io/language/syntax/style) terraform files
- [aws_ecs_task_definition](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_task_definition)'s `container_definitions` requires
  JSON data. It's not necessary to include JSON file or ugly HERE document, you can [jsonencode()](https://www.terraform.io/docs/configuration/functions/jsonencode.html) a
  terraform list of maps:

  ```terraform
  resource "aws_ecs_task_definition" "service" {
    family                = "service"
    container_definitions = jsonencode([{
      name = "httpbin"
      image = "kennethreitz/httpbin"
      ...
    }])
    ...
  }
  ```

- You may create a VPC using the standard [vpc module](https://registry.terraform.io/modules/terraform-aws-modules/vpc/aws). Only public subnets are required. This is not
  strictly necessary however, you may use the default VPC.
- If any part of the task proves to be too hard, don't be stressed -- add a comment about that and skip it, we'll discuss that later and find a solution

## Useful links

- [Terraform AWS provider documentation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [ECS Container Definition](https://docs.aws.amazon.com/AmazonECS/latest/APIReference/API_ContainerDefinition.html)
