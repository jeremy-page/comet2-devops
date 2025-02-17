
# when runnign from individual accounts
data "aws_route53_zone" "comet_zone" {
  name         = "black.icf-comet-cc.com"  # Replace with your account domain name
  private_zone = false                
}
