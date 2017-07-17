# Download and install docker-engine and docker-compose
echo "deb https://apt.dockerproject.org/repo ubuntu-trusty main" | sudo tee /etc/apt/sources.list.d/docker.list
apt-get update
apt-get install -y linux-image-extra-$(uname -r) linux-image-extra-virtual
apt-get install -y --allow-unauthenticated docker-engine
              
mkdir /opt/docker
curl -L https://github.com/docker/compose/releases/download/1.9.0/docker-compose-`uname -s`-`uname -m` > /opt/docker/docker-compose
chmod +x /opt/docker/docker-compose
              
# Set the MTU size of docker containers to the minimum MTU size supported by vNICs. OpenStack deployments may need to know the external DNS IP
MTU=$(/sbin/ifconfig | grep MTU | sed 's/.*MTU://' | sed 's/ .*//' | sort -n | head -1)

cp /lib/systemd/system/docker.service /etc/systemd/system
sed -i "/ExecStart/s/$/ --mtu=$MTU/g" /etc/systemd/system/docker.service
service docker restart

# DNS IP address configuration
echo "nameserver "$DNS_IP_ADDR >> /etc/resolvconf/resolv.conf.d/head
resolvconf -u

echo "Downloading Docker Image and Run"
sudo docker login -u meenakshi2017 -p ril123
docker pull meenakshi2017/vprovserv:1.0
docker pull meenakshi2017/oracle1.0
docker-compose up
              
