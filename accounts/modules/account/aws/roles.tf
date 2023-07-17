# This defines a couple of standard roles in our account which are
# used by the InfoSec team in D&T.
#
# These roles are used by automated scanning tools to check certain aspects
# of our accounts, e.g. scanning EC2 instances for known vulnerabilities.
#
# See the indiviudal role modules for detailed permission sets.
#
# Note: we sometimes apply slightly more restrictive permission sets
# than in the D&T-supplied roles; see individual roles for details.

module "cloudhealth" {
  source = "../../roles/cloudhealth"
}

module "qualys" {
  source = "../../roles/qualys"
}

module "threataware" {
  source = "../../roles/threataware"
}
