# ROSA STS Privatelink Quickstart

This Terraform module is a quickstart for provisioning an existing VPC to install a ROSA cluster with STS and PrivateLink features in for demonstration purposes.

See [examples](./examples) and [https://docs.openshift.com/container-platform/4.10/installing/installing_aws/installing-aws-vpc.html](https://docs.openshift.com/container-platform/4.10/installing/installing_aws/installing-aws-vpc.html) for full requirements.

The module can be used like so:

```hcl
module "rosa_sts_privatelink_networking" {
  source = "github.com/mjlshen/rosa-sts-privatelink"

  name     = "rosa-sts-pl"
  cidr     = "10.0.0.0/16"
  multi_az = true
}
```

After the resources are created with Terraform, ROSA cluster installation can proceed with the ROSA cli:

```bash
rosa create cluster --cluster-name "${CLUSTER_NAME}"
rosa create operator-roles --cluster "${CLUSTER_NAME}" --mode auto -y
rosa create oidc-provider --cluster "${CLUSTER_NAME}" --mode auto -y
rosa logs install -c "${CLUSTER_NAME}" --watch
```
