#!/bin/bash

echo "wait for node to register"
sleep 30

# création des CRD de prometheus-operator
kubectl create ns observability
kubectl apply -f https://raw.githubusercontent.com/coreos/prometheus-operator/master/example/prometheus-operator-crd/alertmanager.crd.yaml
kubectl apply -f https://raw.githubusercontent.com/coreos/prometheus-operator/master/example/prometheus-operator-crd/prometheus.crd.yaml
kubectl apply -f https://raw.githubusercontent.com/coreos/prometheus-operator/master/example/prometheus-operator-crd/prometheusrule.crd.yaml
kubectl apply -f https://raw.githubusercontent.com/coreos/prometheus-operator/master/example/prometheus-operator-crd/servicemonitor.crd.yaml
kubectl apply -f https://raw.githubusercontent.com/coreos/prometheus-operator/master/example/prometheus-operator-crd/podmonitor.crd.yaml

kubectl apply -f ./mon-network/prometheus.yaml
kubectl apply -f ./mon-network/grafana-datasource.yaml

# on installe le CNI
if [ "$NETWORK_TYPE" == "calico" ]; then
    echo "Installation de calico"
    kubectl apply -f https://raw.githubusercontent.com/aws/amazon-vpc-cni-k8s/release-1.6/config/v1.5/calico.yaml
    kubectl apply -f ./mon-network/calico-sm.yaml
else
    echo "Installation de cilium"
    if [ ! -d "cilium-v1.6.3" ]; then
        wget -O cilium.tar.gz http://releases.cilium.io/v1.6.3/v1.6.3.tar.gz
        tar -xf cilium.tar.gz
        rm -f cilium.tar.gz
    fi

    helm install \
        --namespace kube-system \
        --values ./helm_values/cilium.yaml \
        cilium cilium-v1.6.3/install/kubernetes/cilium

    # la création des SM dans cilium est désactivé
    kubectl apply -f ./mon-network/agent-sm.yaml
    kubectl apply -f ./mon-network/operator-sm.yaml
    kubectl apply -f ./mon-network/cilium-dashboard.yaml
fi

# installation du prometheus operator
helm install \
    --namespace observability \
    --values ./helm_values/prometheus-operator.yaml \
    --version 6.21.0 \
    --wait \
    prometheus-operator stable/prometheus-operator

# installation des IngressController
helm install \
    --namespace kube-system \
    --values ./helm_values/traefik-public.yaml \
    --set dashboard.domain=private.$PLATEFORM_NAME.aws-wescale.slavayssiere.fr \
    --wait \
    public-ingress stable/traefik
helm install \
    --namespace kube-system \
    --values ./helm_values/traefik-private.yaml \
    --set dashboard.domain=private.$PLATEFORM_NAME.aws-wescale.slavayssiere.fr \
    --wait \
    private-ingress stable/traefik

# add ingress
kubectl apply -f $WORKDIR/../terraform/component-eks/ingress/traefik-private.yaml
kubectl apply -f $WORKDIR/../terraform/component-eks/ingress/traefik-public.yaml
kubectl apply -f $WORKDIR/../terraform/component-eks/ingress/grafana.yaml
kubectl apply -f $WORKDIR/../terraform/component-eks/ingress/prometheus-k8s.yaml