#!/usr/bin/env bash


# Verify Docker is installed
dockerVersion=$(docker --version 2>/dev/null)
dockerInstalled=$?
if [ $dockerInstalled == 0 ]; then
    echo 'Docker installed'
    echo $dockerVersion
else
    echo 'No Docker installation found'
    echo 'Please install it using your prefered package manager.'
    echo 'e.g. on ubuntu: apt-get install docker.io -y'
    exit 1
fi

# alternative version --- Check if Docker is installed and install it if not ---
#echo "Check if docker is installed..."
#echo
#if [ $(dpkg -l | grep -c "ii  docker") == 0 ]; then
#  echo "Installing Docker..."
#  sudo DEBIAN_FRONTEND=noninteractive apt-get install -qq docker.io > /dev/null
#else
#  echo "Docker already installed -> OK"
#  docker --version
#  echo
#fi

# Install packages
packages=("net-tools" "openjdk-21-jdk-headless")
for package in "${packages[@]}";
do
  if [ $(sudo dpkg -l | grep -c "ii  ${package}") == 0 ]; then
    echo "Installing package ${package}..."
    sudo DEBIAN_FRONTEND=noninteractive apt install -qq ${package} > /dev/null # 2>&1 > /dev/null
  else
    echo "Package ${package} already installed"
  fi
done

# Install Arkade
if [ -x /usr/local/bin/arkade ]; then
    echo 'Arkade already installed'
else
    curl -sLS https://get.arkade.dev | sudo sh
    echo 'export PATH=$PATH:$HOME/.arkade/bin/' >> ~/.profile
    source ~/.profile
    sudo bash -c 'arkade completion bash > /etc/bash_completion.d/arkade'
fi
# # Install Arkade prerelease (not required animore, but keep it here just in case)
# if [ $(arkade  version | grep Version: | cut -d " " -f 2) == "0.8.14" ]; then
#     echo 'Install Arkade prerelease'
#     sudo curl -o /usr/local/bin/arkade -sLS https://github.com/alexellis/arkade/releases/download/0.8.15/arkade
# fi

# Install tools using Arkade
arkadeTools=("kubectl" "k3d" "k9s" "helm")
for arkadeTool in "${arkadeTools[@]}";
do
    if [ -x "$HOME/.arkade/bin/${arkadeTool}" ]; then
        echo "${arkadeTool} already installed."
    else
        arkade get ${arkadeTool}
    fi
done

# add bash completions for tools
for tool in "${arkadeTools[@]}";
do
    if [ -x "$HOME/.arkade/bin/${tool}" ]; then
        sudo bash -c "~ubuntu/.arkade/bin/${tool} completion bash > /etc/bash_completion.d/${tool}"
    fi
done

