#!/bin/sh -xe

cd ../the_hard_way/

for instance in worker-0 worker-1 worker-2; do
  gcloud compute scp ca.pem ${instance}-key.pem ${instance}.pem ${instance}:~/
done

gcloud compute scp scripts/createRBACforKubeletAuthorization.sh controller-0:/tmp/

for instance in controller-0 controller-1 controller-2; do
  gcloud compute scp ca.pem ca-key.pem kubernetes-key.pem kubernetes.pem \
    service-account-key.pem service-account.pem ${instance}:~/
done

for instance in worker-0 worker-1 worker-2; do
  gcloud compute scp ${instance}.kubeconfig kube-proxy.kubeconfig ${instance}:~/
done

for instance in controller-0 controller-1 controller-2; do
  gcloud compute scp admin.kubeconfig kube-controller-manager.kubeconfig kube-scheduler.kubeconfig ${instance}:~/
done

for instance in controller-0 controller-1 controller-2; do
  gcloud compute scp encryption-config.yaml ${instance}:~/
done

for instance in controller-0 controller-1 controller-2; do
  gcloud compute scp scripts/setup_etcd.sh scripts/setup_KubernetesControlPlane.sh ${instance}:/tmp/
done

for instance in worker-0 worker-1 worker-2; do
  gcloud compute scp scripts/install_Soft_to_Worker_Nodes.sh  ${instance}:/tmp/
done

cd -

