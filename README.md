## EKS cluster

This repo is responsible for creating 2 eks clusters, one utility cluster and one app cluster
the utility cluster contains tool use by the CI/CD of the application such as Jenkins and Sonarqube
and the app cluster contains a java 11 application with 2 replicas that recive traffic through a load
balancer created by the aws load balancer controller

## How to use

Since we deploy 2 clusters with this repo that means that we have to use workspaces and we are
saving our state in a remote backend, in my case i choose terraform cloud sinse is very team friendly
here are the commands use to operate the clusters:

To list clusters:

```terraform workspace list```

To deploy utility cluster run:

```terraform workspace select utility-cluster```

```terraform apply```

```aws eks --region us-east-1  update-kubeconfig --name utility-cluster-eks-cluster-dev```

```kubectl apply -f utility_cluster_yml```

To deploy app cluster run:

```terraform workspace select app-cluster```

```terraform apply```

```aws eks --region us-east-1  update-kubeconfig --name app-cluster-eks-cluster-dev```

```kubectl apply -f app_cluster_yml```

