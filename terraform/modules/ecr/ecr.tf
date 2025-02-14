resource "aws_ecr_repository" "comet2" {
  name                 = "comet2"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}
