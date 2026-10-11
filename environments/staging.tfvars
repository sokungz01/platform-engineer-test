environment              = "staging"
vpc_cidr                 = "10.21.0.0/16"
metabase_image_tag       = "v0.64.1"
metabase_desired_count   = 2
db_instance_class        = "db.t4g.small"
db_deletion_protection   = false
db_multi_az              = false
db_backup_retention_days = 7
# Set to the office or VPN CIDR before applying. Do not leave 0.0.0.0/0 in staging.
allowed_ingress_cidrs = ["203.0.113.0/24"]
