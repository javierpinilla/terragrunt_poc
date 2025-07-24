data "aws_caller_identity" "current" {}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }
}

resource "aws_iam_role" "ec2_backend_role" {
  name = "${local.ec2_name}-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = "ec2.amazonaws.com"
      },
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_policy" "policy_secrets_access" {
  name = "${local.ec2_name}-rl"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect   = "Allow",
      Action   = ["secretsmanager:GetSecretValue"],
      Resource = local.app_secret_name
    }]
  })
}

resource "aws_iam_role_policy_attachment" "attach_policy" {
  role       = aws_iam_role.ec2_backend_role.name
  policy_arn = aws_iam_policy.policy_secrets_access.arn
}

resource "aws_iam_role_policy_attachment" "ec2_ssm_attach_policy" {
  role       = aws_iam_role.ec2_backend_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "ec2_ecrRO_attach_policy" {
  role       = aws_iam_role.ec2_backend_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

resource "aws_iam_instance_profile" "ec2_instance_profile" {
  name = "${local.ec2_name}-profile"
  role = aws_iam_role.ec2_backend_role.name
}

data "template_file" "user_data" {
  template = file("${path.module}/scripts/user_data.sh")
  vars = {
    hostname_ec2 = local.ec2_name
  }
}

#resource "random_shuffle "select_one_subnets" {
#  input        = var.subnet_id
#  result_count = 1
#}

# Instancia EC2
resource "aws_instance" "ec2_instance" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = var.instance_type
  subnet_id                   = var.subnet_id[0]
  vpc_security_group_ids      = [var.security_group_id]
  associate_public_ip_address = false
  iam_instance_profile        = aws_iam_instance_profile.ec2_instance_profile.name
  key_name                    = local.ec2_name

  ebs_block_device {
    device_name = "/dev/xvda"
    volume_type = "gp3"
    volume_size = 30
    tags = merge(var.common_tags, {
      Name = "${local.ec2_name}-ebs-root"
    })
    delete_on_termination = true
    encrypted             = true
  }

  user_data = base64encode(data.template_file.user_data.rendered)

  tags = merge(var.common_tags, {
    Name = local.ec2_name
  })
}

resource "aws_lb_target_group_attachment" "ec2_to_alb_tg" {
  target_group_arn = var.target_group_arn
  target_id        = aws_instance.ec2_instance.id
  port             = 80
}

resource "aws_lb_listener_rule" "api_rule" {
  listener_arn  = data.aws_lb_listener.alb_listener_https.arn
  #priority      = local.next_priority
  priority      = var.alb_prioriry_rules

  lifecycle {
    ignore_changes = [priority]
  }

  action {
    type             = "forward"
    target_group_arn = var.target_group_arn
  }

  condition {
    host_header {
      values = [var.host_header]
    }
  }

  tags = merge(var.common_tags, {
    Name = local.rule_name
  })
}