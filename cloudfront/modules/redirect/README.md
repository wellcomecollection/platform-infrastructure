# Terraform Route53 / S3 redirect

Creates a DNS (A) record for the `from` URL, pointing at an S3 website endpoint, which redirects to the `to` URL.

This is an easy way of getting a one-off redirect without having to maintain our own infrastructure for it. 
