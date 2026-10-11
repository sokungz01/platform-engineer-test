environment              = "prod"
vpc_cidr                 = "10.30.0.0/16"
metabase_image_tag       = "REPLACE_WITH_PINNED_TAG_IN_TASK_6"
metabase_desired_count   = 2
metabase_cpu             = 2048
metabase_memory          = 4096
db_instance_class        = "db.t4g.medium"
db_allocated_storage     = 50
db_deletion_protection   = true
db_multi_az              = true
db_backup_retention_days = 14
# Set to the office or VPN CIDR before applying. Do not leave 0.0.0.0/0 in prod.
allowed_ingress_cidrs = ["203.0.113.0/24"]
# certificate_arn     = "arn:aws:acm:ap-southeast-1:ACCOUNT:certificate/ID"
