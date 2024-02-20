# ~/.awsにクレデンシャルを設置

```bash
cat <<EOF > ~/.aws/config
[default]
region=ap-northeast-1
output=json
EOF


cat <<EOF > ~/.aws/credentials
[default]
aws_access_key_id = xxxxxxxxxxxxxxxxxxxx
aws_secret_access_key = xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
EOF
```

# EKS Clusterの構築

```bash
# EKS Clusterの構築
# ~/.aws配下にcredentialを設置しないと動かないので注意
eksctl create cluster \
  --name eks-cluster \
  --version 1.23 \
  --with-oidc \
  --nodegroup-name eks-cluster-node-group \
  --node-type c5.large \
  --nodes 1 \
  --nodes-min 1

# クラスタを作成すると ~/.kube/config にClusterの接続に必要となる認証情報を自動で追加する
# Nodeの情報が取得できればEKSクラスタの作成は完了
kubectl get node
```