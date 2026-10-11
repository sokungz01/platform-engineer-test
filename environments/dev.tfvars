environment              = "dev"
vpc_cidr                 = "10.20.0.0/16"
metabase_image_tag       = "v0.64.1"
metabase_desired_count   = 1
db_instance_class        = "db.t4g.micro"
db_deletion_protection   = false
db_multi_az              = false
db_backup_retention_days = 1
# Open to all for the challenge reviewer. Finish Metabase setup right after deploy and destroy after review.
allowed_ingress_cidrs = ["0.0.0.0/0"]
