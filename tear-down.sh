variable=$1

if ! [[ "$variable" =~ ^[0-9]+$ ]]; then
  echo "Error: A numeric variable must be passed."
  exit 1
fi

aws eks --region eu-west-2 update-kubeconfig --name filevault-eks-filevault-pr-$variable

kubectl delete -f k8s/public-lb.yaml

kubectl delete -f k8s/deployment.yaml

cd terraform

terraform workspace select filevault-pr-$variable

terraform destroy -auto-approve