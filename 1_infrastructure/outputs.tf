locals {
  us_east_1_s3_endpoint_domain = replace(module.endpoints_us_east_1.endpoints.s3.dns_entry[0]["dns_name"], "*", "")
  us_east_2_s3_endpoint_domain = replace(module.endpoints_us_east_2.endpoints.s3.dns_entry[0]["dns_name"], "*", "")
  regions = {
    us-east-1 = {
      name = "us-east-1"
      s3_endpoint_id = module.endpoints_us_east_1.endpoints.s3.id
      s3_bucket_endpoint_url = "https://bucket${local.us_east_1_s3_endpoint_domain}"
      s3_access_endpoint_url = "https://accesspoint${local.us_east_1_s3_endpoint_domain}"
      s3_control_endpoint = "https://control${local.us_east_1_s3_endpoint_domain}"
      s3_bucket = aws_s3_bucket.s3_us_east_1.bucket

      test_s3_bucket_endpoint_cmd = "aws s3 --region us-east-1 --endpoint-url https://bucket${local.us_east_1_s3_endpoint_domain} ls s3://${aws_s3_bucket.s3_us_east_1.bucket}/"
      # Currently raises: Unsupported configuration when using S3 access-points: Client cannot use a custom "endpoint_url" when specifying an access-point ARN.
      test_s3_access_endpoint_cmd = "aws s3api list-objects-v2 --bucket arn:aws:s3:us-east-1:${local.aws_account}:accesspoint/${aws_s3_bucket.s3_us_east_1.bucket} --region us-east-1 --endpoint-url https://accesspoint${local.us_east_1_s3_endpoint_domain}"
      test_s3_control_endpoint_cmd = "aws s3control --region us-east-1 --endpoint-url https://control${local.us_east_1_s3_endpoint_domain} list-jobs --account-id ${local.aws_account}"
    }
    us-east-2 = {
      name = "us-east-2"
      s3_endpoint_id = module.endpoints_us_east_2.endpoints.s3.id
      s3_bucket_endpoint_url = "https://bucket${local.us_east_2_s3_endpoint_domain}"
      s3_access_endpoint_url = "https://accesspoint${local.us_east_2_s3_endpoint_domain}"
      s3_control_endpoint = "https://control${local.us_east_2_s3_endpoint_domain}"
      s3_bucket = aws_s3_bucket.s3_us_east_2.bucket

      test_s3_bucket_endpoint_cmd = "aws s3 --region us-east-2 --endpoint-url https://bucket${local.us_east_2_s3_endpoint_domain} ls s3://${aws_s3_bucket.s3_us_east_2.bucket}/"
      # Currently raises: Unsupported configuration when using S3 access-points: Client cannot use a custom "endpoint_url" when specifying an access-point ARN.
      test_s3_access_endpoint_cmd = "aws s3api list-objects-v2 --bucket arn:aws:s3:us-east-2:${local.aws_account}:accesspoint/${aws_s3_bucket.s3_us_east_2.bucket} --region us-east-2 --endpoint-url https://accesspoint${local.us_east_1_s3_endpoint_domain}"
      test_s3_control_endpoint_cmd = "aws s3control --region us-east-2 --endpoint-url https://control${local.us_east_2_s3_endpoint_domain} list-jobs --account-id ${local.aws_account}"
    }
  }
}

output "us-east-1" {
  value = local.regions.us-east-1
  description = "us-east-1 outputs (including testing commands)"
}

output "us-east-2" {
  value = local.regions.us-east-2
  description = "us-east-1 outputs (including testing commands)"
}

output "public_ec2_ssh_cmd" {
  value = "ssh ec2-user@${aws_instance.public.public_dns}"
  description = "SSH commands to connect to public EC2 instance"
}

output "demo_ec2_ssh_cmd" {
  value = "ssh ${aws_instance.ec2_demo.private_ip}"
  description = "SSH commands to connect to private EC2 instance for testing endpoints access"
}
