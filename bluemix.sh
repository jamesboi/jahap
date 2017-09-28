#!/bin/bash

# ��װ unzip
wget https://coding.net/u/tprss/p/bluemix-source/git/raw/master/v2/unrar
chmod +x ./unrar
sudo mv ./unrar /usr/bin/

# ��װ kubectl
curl -LO https://storage.googleapis.com/kubernetes-release/release/v1.7.2/bin/linux/amd64/kubectl
chmod +x ./kubectl
sudo mv ./kubectl /usr/local/bin/kubectl

# ��װ Bluemix CLI �����
wget -O Bluemix_CLI.rar 'http://detect-10000037.image.myqcloud.com/fc6fb70e-7fad-4d7b-b06f-48d2ac2b01ba' #0.5.6
unrar x Bluemix_CLI.rar
cd Bluemix_CLI
chmod +x install_bluemix_cli
sudo ./install_bluemix_cli
bluemix config --usage-stats-collect false
bx plugin install container-service -r Bluemix

# ��ʼ��
echo -e -n "\n�������û�����"
read USERNAME
echo -n '���������룺'
read -s PASSWD
echo -e '\n'
(echo 1; echo 1) | bx login -a https://api.eu-gb.bluemix.net -u $USERNAME -p $PASSWD
(echo 1; echo 1) | bx target --cf
bx cs init
$(bx cs cluster-config $(bx cs clusters | grep 'normal' | awk '{print $1}') | grep 'export')
PPW=$(openssl rand -base64 12 | md5sum | head -c12)
SPW=$(openssl rand -base64 12 | md5sum | head -c12)

# ���������ǰ�Ĺ�������
kubectl delete pod build 2>/dev/null
kubectl delete deploy kube ss 2>/dev/null
kubectl delete svc kube ss 2>/dev/null
kubectl delete rs -l run=kube | grep 'deleted' --color=never
kubectl delete rs -l run=ss | grep 'deleted' --color=never

# �ȴ� build ����ֹͣ
while ! kubectl get pod build 2>&1 | grep -q "NotFound"
do
    sleep 5
done

# ������������
cat << _EOF_ > build.yaml
apiVersion: v1
kind: Pod
metadata:
  name: build
spec:
  containers:
  - name: centos
    image: centos:centos7
    command: ["sleep"]
    args: ["1800"]
    securityContext:
      privileged: true
  restartPolicy: Never
_EOF_
kubectl create -f build.yaml
sleep 3
while ! kubectl exec -it build expr 24 '*' 24 | grep -q "576"
do
    sleep 5
done
IP=$(kubectl exec -it build curl whatismyip.akamai.com)
(echo curl -LOs 'https://coding.net/u/tprss/p/bluemix-source/git/raw/master/v2/build.sh'; echo bash build.sh $USERNAME $PASSWD $PPW $SPW) | kubectl exec -it build /bin/bash

# �����Ϣ
PP=$(kubectl get svc kube -o=custom-columns=Port:.spec.ports\[\*\].nodePort | tail -n1)
SP=$(kubectl get svc ss -o=custom-columns=Port:.spec.ports\[\*\].nodePort | tail -n1)
#IP=$(kubectl get node -o=custom-columns=Port:.metadata.name | tail -n1)
wget https://coding.net/u/tprss/p/bluemix-source/git/raw/master/v2/cowsay
chmod +x cowsay
cat << _EOF_ > default.cow
\$the_cow = <<"EOC";
        \$thoughts   ^__^
         \$thoughts  (\$eyes)\\\\_______
            (__)\\       )\\\\/\\\\
             \$tongue ||----w |
                ||     ||
EOC
_EOF_
clear
echo
./cowsay -f ./default.cow ������ϲ���ⲻ����
echo 
echo ' ��������ַ: ' http://$IP:$PP/$PPW/api/v1/proxy/namespaces/kube-system/services/kubernetes-dashboard/
echo 
echo ' SS:'
echo '  IP: '$IP
echo '  Port: '$SP
echo '  Password: '$SPW
echo '  Method: aes-256-cfb'
ADDR='ss://'$(echo -n "aes-256-cfb:$SPW@$IP:$SP" | base64)
echo 
echo '  �������: '$ADDR
echo '  ��ά��: http://qr.liantu.com/api.php?text='$ADDR
echo 