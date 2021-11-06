#!/bin/bash



# Terraform Setup
apt update -y && apt install -y curl unzip jq
curl -# -LO https://releases.hashicorp.com/terraform/1.0.8/terraform_1.0.8_linux_amd64.zip
unzip *.zip
rm -rf *.zip
cp terraform /usr/bin/
cp terraform /usr/local/bin
rm -rf terraform



# Install AWS Cli

apt update -y
apt  install awscli -y
apt install python3-pip -y
pip3 install --upgrade --user awscli


# EKSCTL

# 1. Download and extract the latest release of eksctl with the following command.
curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp

# 2. Move the extracted binary to /usr/bin

mv /tmp/eksctl /usr/local/bin

# 3. Test that your installation was successful with the following command.
eksctl version

# Kubectl Installation
curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl

chmod +x ./kubectl

mv ./kubectl /usr/bin/kubectl


curl -o aws-iam-authenticator https://amazon-eks.s3-us-west-2.amazonaws.com/1.14.6/2019-08-22/bin/linux/amd64/aws-iam-authenticator


chmod +x ./aws-iam-authenticator

mkdir -p $HOME/bin && cp ./aws-iam-authenticator $HOME/bin/aws-iam-authenticator && export PATH=$HOME/bin:$PATH

cp ./aws-iam-authenticator /usr/local/bin/aws-iam-authenticator && export PATH=$HOME/usr/local/bin:$PATH

echo 'export PATH=$HOME/usr/local/bin:$PATH' >> ~/.bashrc

rm -rf aws-iam-authenticator

# Helm Installation
# https://helm.sh/docs/intro/install/

curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
chmod 700 get_helm.sh
./get_helm.sh
rm -f get_helm.sh
