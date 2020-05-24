#!/bin/bash

function util_done()
{
    local sleeptime=$1
    shift
    while true
    do
        "$@"
        if [ $? -eq 0 ]; then
            echo "add kube-proxy......."
            kubectl create -f /root/k8s/yaml/kube-proxy.yaml
            echo "add istio-system namespaces......."
            kubectl create namespace istio-system
            echo "add addons......."
            #kubectl create -f /root/k8s/yaml/flannel.yaml
            #kubectl create -f /root/k8s/yaml/snap.yaml
            kubectl create -f /root/k8s/yaml/heapster.yaml
            kubectl create -f /root/k8s/yaml/fluentd-es.yaml
            kubectl create -f /root/k8s/yaml/coredns.yaml
            kubectl create -f /root/k8s/yaml/tiller.yaml
            kubectl create -f /root/k8s/yaml/tiller-service.yaml
            kubectl create -f /root/k8s/yaml/istio.yaml

            #kubectl create -f /root/k8s/yaml/cluster-admin.yaml
            break
        fi
        sleep $sleeptime
    done
}

function init()
{
        url=$1
        sleeptime=5
        echo "checking api server"
        util_done $sleeptime curl $url
}

init $1
#kubectl create serviceaccount --namespace kube-system tiller
#kubectl create clusterrolebinding tiller-cluster-rule --clusterrole=cluster-admin --serviceaccount=kube-system:tiller
#helm init --service-account tiller
