# AWS EBS Storage Specifications (Optional / Future Deployment)

These manifests define persistent dynamic EBS storage for PostgreSQL using the AWS EBS CSI driver.

## Files
- `ebs-sc.yaml`: Defines StorageClass `ebs-gp3-sc` using `ebs.csi.aws.com` with `volumeBindingMode: WaitForFirstConsumer` and gp3 parameters.
- `postgres-pvc.yaml`: Defines PersistentVolumeClaim `postgres-pvc` requesting 5 GiB `ReadWriteOnce` storage from `ebs-gp3-sc`.

## Why These Are Excluded from Initial Deployment
- The initial deployment runs PostgreSQL using an `emptyDir` volume to allow testing the voting application without installing the AWS EBS CSI driver and associated IAM policies.
- If these manifests were kept in the root `k8s-specifications/` directory, running `kubectl apply -f k8s-specifications/` would create the PVC, which would remain in `Pending` state indefinitely because `ebs.csi.aws.com` is not currently installed on the EKS cluster.

## How to Enable EBS Persistent Storage Later
1. Provision the AWS EBS CSI driver IAM role with `AmazonEBSCSIDriverPolicy` (via IRSA or node IAM).
2. Install the `aws-ebs-csi-driver` EKS add-on.
3. Apply these manifests:
   ```bash
   kubectl apply -f k8s-specifications/ebs-storage/
   ```
4. Update `k8s-specifications/db-deployment.yaml` to reference `postgres-pvc` instead of `emptyDir`.

