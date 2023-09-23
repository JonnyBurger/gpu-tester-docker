Image (search in Community images in AMI marketplace): **ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-20220609**

Instance type: g4dn.xlarge

Reference: https://dev.to/perrocontodo/run-playwright-tests-with-hardware-acceleration-on-a-gpu-enabled-ec2-instance-with-docker-support-4j2

```bash
sudo apt-get update -y && sudo apt upgrade -y
sudo reboot
wget https://us.download.nvidia.com/tesla/515.65.01/nvidia-driver-local-repo-ubuntu2204-515.65.01_1.0-1_amd64.deb
sudo dpkg -i nvidia-driver-local-repo-ubuntu2204-515.65.01_1.0-1_amd64.deb
sudo cp /var/nvidia-driver-local-repo-ubuntu2204-515.65.01/nvidia-driver-local-22D4AC2B-keyring.gpg /usr/share/keyrings/
sudo apt-get update && sudo apt-get -y install cuda-drivers
sudo reboot
sudo apt-get -y install vulkan-tools
sudo apt-get remove docker docker.io containerd runc
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update && sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
sudo docker run hello-world
sudo usermod -aG docker $USER
exit
sudo systemctl enable docker.service && sudo systemctl enable containerd.service
distribution=$(. /etc/os-release;echo $ID$VERSION_ID)
sudo docker run -it --gpus all nvidia/cuda:11.6.2-base-ubuntu20.04 nvidia-smi
apt-key adv --fetch-keys https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004/x86_64/3bf863cc.pub
sudo docker build -t gputester .
sudo docker run --gpus all -e "NVIDIA_DRIVER_CAPABILITIES=all" gputester
```
