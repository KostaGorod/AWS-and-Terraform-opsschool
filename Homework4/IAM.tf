
# Nginx instances
resource "aws_iam_role" "nginx_role" {
  name               = "nginx_role"
  assume_role_policy = file("${path.module}/assumerolepolicy.json")
}

resource "aws_iam_instance_profile" "nginx_instances" {
  name = "s3_access_profile"
  role = aws_iam_role.nginx_role.name
}

# resource "aws_iam_role_policy" "nginx_s3_access_policy" {
#   name   = "s3_role_policy"
#   role   = aws_iam_role.nginx_role.id
#   policy = aws_iam_policy.nginx_S3_access.policy
# }

# resource "aws_iam_policy" "nginx_S3_access" {
#   policy = {
#     "Version" : "2012-10-17",
#     "Statement" : [
#       {
#         Effect : "Allow",
#         Action : "s3:*",
#         Resource : "${aws_s3_bucket.nginx_access_log.arn}/*"
#       }
#     ]
#   }
# }
