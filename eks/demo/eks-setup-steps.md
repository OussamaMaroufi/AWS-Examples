AWS console -> Eks service 
1 - Create a Cluster:
Name
Api Version

2 - Cluster service Role

```
aws iam create-role \
    --role-name MyEKSClusterRole \
    --assume-role-policy-document '{
      "Version": "2012-10-17",
      "Statement": [
        {
          "Effect": "Allow",
          "Principal": {
            "Service": "eks.amazonaws.com"
          },
          "Action": "sts:AssumeRole"
        }
      ]
    }'
```
Verify Role creation using aws cli 

```
aws iam get-role --role-name MyEKSClusterRole
```
Attach the required IAM policy to the role.


 - aws iam attach-role-policy \
  --policy-arn arn:aws:iam::aws:policy/AmazonEKSClusterPolicy \
  --role-name MyEKSClusterRole

- aws iam attach-role-policy \
    --role-name MyEKSClusterRole \
    --policy-arn arn:aws:iam::aws:policy/AmazonEKSBlockStoragePolicy

- aws iam attach-role-policy \
    --role-name MyEKSClusterRole \
    --policy-arn arn:aws:iam::aws:policy/AmazonEKSComputePolicy

- aws iam attach-role-policy \
    --role-name MyEKSClusterRole \
    --policy-arn arn:aws:iam::aws:policy/AmazonEKSLoadBalancingPolicy

- aws iam attach-role-policy \
    --role-name MyEKSClusterRole \
    --policy-arn arn:aws:iam::aws:policy/AmazonEKSNetworkingPolicy

Verify the attached policies to cluster service role MyEKSClusterRole

```
aws iam list-attached-role-policies --role-name MyEKSClusterRole
```

Cluster role’s trust policy is missing the sts:TagSession action. This action is required for EKS Auto Mode to tag AWS resources created by the cluster.
So we need to update the trust policy 

```
aws iam update-assume-role-policy \
    --role-name MyEKSClusterRole \
    --policy-document '{
      "Version": "2012-10-17",
      "Statement": [
        {
          "Effect": "Allow",
          "Principal": {
            "Service": "eks.amazonaws.com"
          },
          "Action": [
            "sts:AssumeRole",
            "sts:TagSession"
          ]
        }
      ]
    }'
```

Verify the trust policy

```
aws iam get-role --role-name  MyEKSClusterRole
```

- Amazon EKS node IAM role:

``` aws iam create-role \
    --role-name MyEKSNodeRole \
    --assume-role-policy-document '{
      "Version": "2012-10-17",
      "Statement": [
        {
          "Effect": "Allow",
          "Principal": {
            "Service": "ec2.amazonaws.com"
          },
          "Action": "sts:AssumeRole"
        }
      ]
    }' ```

- Verify role creation 
````aws iam get-role --role-name MyEKSNodeRole````

- Attaching policies tp created role 

** Grants permissions for worker nodes to interact with the EKS control plane.
 aws iam attach-role-policy \
    --role-name MyEKSNodeRole \
    --policy-arn arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy


** Grants read-only access to Amazon ECR, allowing worker nodes to pull container images

aws iam attach-role-policy \
    --role-name MyEKSNodeRole \
    --policy-arn arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly

** Grants permissions for managing networking resources (e.g., ENIs, IP addresses) in the VPC.
Required if you’re using the AWS VPC CNI plugin for Kubernetes networking.

aws iam attach-role-policy \
    --role-name MyEKSNodeRole \
    --policy-arn arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy


Verify attached policies to eks cluster node role
```aws iam list-attached-role-policies --role-name MyEKSNodeRole``` 



Create the Node Groupe where we gonna launch our workloads 


## Ingress with Application Load Balancer via AWS Load Balancer Controller

The AWS Load Balancer Controller will run as Pods inside the EKS cluster, and these controller Pods need IAM permissions to access the AWS Services.

```curl -O https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.11.0/docs/install/iam_policy.json
```

export POLICY_NAME=AWSLoadBalancerControllerIAMPolicy
aws iam create-policy \
    --policy-name ${POLICY_NAME} \
    --policy-document file://iam_policy.json


Verify the policy creation

Get the policy ARN 
export POLICY_ARN=$(aws iam list-policies --query "Policies[?PolicyName=='${POLICY_NAME}'].Arn" --output text)
aws iam get-policy --policy-arn arn:aws:iam::<Account id>:policy/AWSLoadBalancerControllerIAMPolicy

I am creating this Trust Policy for the Pod Identity Agent so only the Pod Identity Agent can assume this IAM Role.
Create the trust policy 

cat <<EOF > trust-policy.json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "pods.eks.amazonaws.com"
      },
      "Action": [
        "sts:AssumeRole",
        "sts:TagSession"
      ]
    }
  ]
}
EOF



Create an IAM Role AmazonEKSLoadBalancerControllerRole with the Trust Policy

aws iam create-role \
  --role-name AmazonEKSLoadBalancerControllerRole \
  --assume-role-policy-document file://"trust-policy.json"
get role
aws iam  get-role --iam-role AmazonEKSLoadBalancerControllerRole
export ROLE_NAME=AmazonEKSLoadBalancerControllerRole
get the role ARN 

export ROLE_ARN=$(aws iam get-role --role-name $ROLE_NAME --query "Role.Arn" --output text)
Now we need to attach to policy that  we create to the role that will assumed by the pod of load balancer controller
aws iam attach-role-policy --policy-arn ${POLICY_ARN}  --role-name ${ROLE_NAME} 

ws eks update-kubeconfig --region eu-west-3 --name myCluster
We need to associate the IAM Role with the Service Account using the Pod Identity Association.

Create the service Account
export SERVICE_ACCOUNT=aws-load-balancer-controller
export NAMESPACE=kube-system
export REGION=eu-west-3

cat >lbc-sa.yaml <<EOF
apiVersion: v1
kind: ServiceAccount
metadata:
  labels:
    app.kubernetes.io/component: controller
    app.kubernetes.io/name: aws-load-balancer-controller
  name: ${SERVICE_ACCOUNT}
  namespace: ${NAMESPACE}
EOF

kubectl apply -f lbc-sa.yaml
kubectl -n kube-system get sa


** List Eks clusters in a specific region 
aws eks list-clusters --region ${REGION}

*** List All available adds-on in my cluster
aws eks list-addons --cluster-name $CLUSTER_NAME

Output
{
    "addons": [
        "coredns",
        "eks-pod-identity-agent",
        "kube-proxy",
        "vpc-cni"
    ]
}
If there is missing adds-on we can add it using the follwing command  
aws eks create-addon --cluster-name $CLUSTER_NAME --addon-name eks-pod-identity-agent


The Service Account is ready; we can perform the Pod Identity Association.

eksctl create podidentityassociation \
    --cluster $CLUSTER_NAME \
    --namespace $NAMESPACE \
    --service-account-name $SERVICE_ACCOUNT \
    --role-arn $ROLE_ARN

After the successful association, we can list the Pod Identity Associations.

aws eks list-pod-identity-associations --cluster-name $CLUSTER_NAME


Install the AWS Load Balancer Controller

helm repo add eks https://aws.github.io/eks-charts
helm repo update eks

Install the AWS Load Balancer Controller.

helm install aws-load-balancer-controller eks/aws-load-balancer-controller \
  -n kube-system \
  --set clusterName=${CLUSTER_NAME} \
  --set serviceAccount.create=false \
  --set serviceAccount.name=aws-load-balancer-controller

Issue here 
debugging 
kubectl cluster-info dump

kubectl logs -n kube-system aws-load-balancer-controller-xxxxxxxxxxx

The error was in retieving VPC ID From instance metadata service IMDS1 which was deprecated so i manually update the version of woker node 


kubectl get crds | grep -iE "elbv2"

ingressClassParams – This CRD can able to add optional deployment configurations for the Ingress Class object.
targetgroupbindings – This CRD helps to map the existing Target Group to the Kubernetes Service object to route the traffic.


Create an Ingress Object

We have to tag kubernetes.io/role/elb = 1 the Subnets of the EKS cluster for the Load Balancer Controller service discovery

Getting subnets ids 
SUBNET_IDS=$(aws eks describe-cluster --name $CLUSTER_NAME --query "cluster.resourcesVpcConfig.subnetIds" --output text | tr '\t' ' ')
SUBNET_IDS_ARRAY=($(echo $SUBNET_IDS))
for subnet in "${SUBNET_IDS_ARRAY[@]}"; do
    aws ec2 create-tags --resources "$subnet" --tags Key=kubernetes.io/role/elb,Value="1"
done

this is required for the Load Balancer Controller to discover the subnets to provision the Load Balancer.