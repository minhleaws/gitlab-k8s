# ---------------------------------------------------------------------------------------------------------------------
# Create S3 bucket
# ---------------------------------------------------------------------------------------------------------------------

data "aws_caller_identity" "current" {}

resource "aws_s3_bucket" "gitlab-runner-cache" {
  bucket = "${data.aws_caller_identity.current.account_id}-${var.region}-${var.env}-runner-cache"
  acl    = "private"

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  force_destroy = true

  tags = merge(
    { Name = "Gitlab Runner Cache" },
    var.common_tags,
  )
}

resource "aws_s3_bucket" "gitlab-backups" {
  bucket = "${data.aws_caller_identity.current.account_id}-${var.region}-${var.env}-gitlab-backups"
  acl    = "private"

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  force_destroy = true

  tags = merge(
    { Name = "Gitlab Backups" },
    var.common_tags,
  )

}

resource "aws_s3_bucket" "gitlab-tmp" {
  bucket = "${data.aws_caller_identity.current.account_id}-${var.region}-${var.env}-gitlab-tmp"
  acl    = "private"

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  force_destroy = true

  tags = merge(
    { Name = "Gitlab tmp" },
    var.common_tags,
  )

}


resource "aws_s3_bucket" "gitlab-pseudo" {
  bucket = "${data.aws_caller_identity.current.account_id}-${var.region}-${var.env}-gitlab-pseudo"
  acl    = "private"

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  force_destroy = true

  tags = merge(
    { Name = "Gitlab Pseudo" },
    var.common_tags,
  )

}

resource "aws_s3_bucket" "git-lfs" {
  bucket = "${data.aws_caller_identity.current.account_id}-${var.region}-${var.env}-git-lfs"
  acl    = "private"

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  force_destroy = true

  tags = merge(
    { Name = "Git Large File Storage" },
    var.common_tags,
  )

}

resource "aws_s3_bucket" "gitlab-artifacts" {
  bucket = "${data.aws_caller_identity.current.account_id}-${var.region}-${var.env}-gitlab-artifacts"
  acl    = "private"

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  force_destroy = true

  tags = merge(
    { Name = "Gitlab Artifacts" },
    var.common_tags,
  )
}

resource "aws_s3_bucket" "gitlab-uploads" {
  bucket = "${data.aws_caller_identity.current.account_id}-${var.region}-${var.env}-gitlab-uploads"
  acl    = "private"

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  force_destroy = true

  tags = merge(
    { Name = "Gitlab Uploads" },
    var.common_tags,
  )

}

resource "aws_s3_bucket" "gitlab-packages" {
  bucket = "${data.aws_caller_identity.current.account_id}-${var.region}-${var.env}-gitlab-packages"
  acl    = "private"

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  force_destroy = true

  tags = merge(
    { Name = "Gitlab Packages" },
    var.common_tags,
  )
}

resource "aws_s3_bucket" "gitlab-mr-diffs" {
  bucket = "${data.aws_caller_identity.current.account_id}-${var.region}-${var.env}-gitlab-mr-diffs"
  acl    = "private"

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  force_destroy = true

  tags = merge(
    { Name = "Gitlab MR diffs" },
    var.common_tags,
  )
}

resource "aws_s3_bucket" "gitlab-terraform-state" {
  bucket = "${data.aws_caller_identity.current.account_id}-${var.region}-${var.env}-gitlab-terraform-state"
  acl    = "private"

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  force_destroy = true

  tags = merge(
    { Name = "Gitlab Terraform State" },
    var.common_tags,
  )
}

resource "aws_s3_bucket" "gitlab-dependency-proxy" {
  bucket = "${data.aws_caller_identity.current.account_id}-${var.region}-${var.env}-gitlab-dependency-proxy"
  acl    = "private"

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  force_destroy = true

  tags = merge(
    { Name = "Gitlab Dependency Proxy" },
    var.common_tags,
  )
}


resource "aws_s3_bucket" "gitlab-pages" {
  bucket = "${data.aws_caller_identity.current.account_id}-${var.region}-${var.env}-gitlab-pages"
  acl    = "private"

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  force_destroy = true

  tags = merge(
    { Name = "Gitlab Pages" },
    var.common_tags,
  )
}


resource "aws_s3_bucket" "gitlab-registry" {
  bucket = "${data.aws_caller_identity.current.account_id}-${var.region}-${var.env}-gitlab-registry"
  acl    = "private"

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  force_destroy = true

  tags = merge(
    { Name = "Gitlab Registry" },
    var.common_tags,
  )
}
