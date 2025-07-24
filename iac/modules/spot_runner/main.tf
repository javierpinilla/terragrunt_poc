data "aws_caller_identity" "current" {}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }
}

resource "aws_iam_role" "github_runner" {
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

resource "aws_iam_policy" "secrets_access" {
  name = "GitHubRunnerSecretsAccess"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect   = "Allow",
      Action   = ["secretsmanager:GetSecretValue"],
      Resource = local.gh_secret_name
    }]
  })
}

resource "aws_iam_role_policy_attachment" "attach_policy" {
  role       = aws_iam_role.github_runner.name
  policy_arn = aws_iam_policy.secrets_access.arn
}

resource "aws_iam_role_policy_attachment" "ec2_ssm_attach_policy" {
  role       = aws_iam_role.github_runner.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "runner_profile" {
  name = "${local.ec2_name}-profile"
  role = aws_iam_role.github_runner.name
}

data "template_file" "user_data" {
  template = file("${path.module}/scripts/user_data.sh")
  vars = {
    secret_name = var.github_runner_secret_name
  }
}

resource "aws_launch_template" "github_runner_lt" {
  name_prefix            = "${local.ec2_name}-"
  image_id               = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  vpc_security_group_ids = var.security_group_id

  # Habilitar spot
  instance_market_options {
    market_type = "spot"
    spot_options {
      instance_interruption_behavior = "terminate" # o "stop" creo que era para retener el estado, no me acuerdo
    }
  }

  iam_instance_profile {
    name = aws_iam_instance_profile.runner_profile.name
  }
  user_data = base64encode(data.template_file.user_data.rendered)

  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      volume_type           = "gp3"
      volume_size           = 20
      delete_on_termination = true
      encrypted             = true
    }
  }

  tag_specifications {
    resource_type = "instance"
    tags = merge(var.common_tags, {
      Name = "${local.ec2_name}"
    })
  }

  tag_specifications {
    resource_type = "volume"
    tags = merge(var.common_tags, {
      Name = "${local.ec2_name}-volume"
    })
  }
}

resource "aws_autoscaling_group" "github_runner_asg" {
  name_prefix         = "${local.ec2_name}-"
  min_size            = 1
  max_size            = 1
  desired_capacity    = 1
  vpc_zone_identifier = var.subnet_id
  launch_template {
    id      = aws_launch_template.github_runner_lt.id
    version = "$Latest"
  }
  tag {
    key                 = "Name"
    value               = local.ec2_name
    propagate_at_launch = true
  }

  dynamic "tag" {
    for_each = var.common_tags
    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }
}