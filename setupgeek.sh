#/bin/bash

cd ~
echo && echo && echo
echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
echo "!                                                 !"
echo "! Make sure you double check before hitting enter !"
echo "!                                                 !"
echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
echo && echo && echo

echo "Do you want to install all needed dependencies (no if you did it before)? [y/n]"
read DOSETUP

if [ $DOSETUP = "y" ]
then
  sudo apt-get update
  sudo apt-get -y upgrade
  sudo apt-get -y dist-upgrade
  sudo apt-get update
  sudo apt-get install -y zip unzip

  cd /var
  sudo touch swap.img
  sudo chmod 600 swap.img
  sudo dd if=/dev/zero of=/var/swap.img bs=1024k count=2000
  sudo mkswap /var/swap.img
  sudo swapon /var/swap.img
  sudo free
  sudo echo "/var/swap.img none swap sw 0 0" >> /etc/fstab
  cd

  wget https://github.com/GeekCash/geekcash/releases/download/v1.0.1.2/geekcash-1.0.1-x86_64-linux-gnu.tar.gz
  unzip geekcash-1.0.1-x86_64-linux-gnu.tar.gz
  chmod +x Geek/bin/*
  sudo mv  Geek/bin/* /usr/local/bin
  rm -rf geekcash-1.0.1-x86_64-linux-gnu.tar.gz Windows Linux Mac

  sudo apt-get install -y ufw
  sudo ufw allow ssh/tcp
  sudo ufw limit ssh/tcp
  sudo ufw logging on
  echo "y" | sudo ufw enable
  sudo ufw status

  mkdir -p ~/bin
  echo 'export PATH=~/bin:$PATH' > ~/.bash_aliases
  source ~/.bashrc
fi

 ## Setup conf
 echo ""
 echo "What interface do you want to use? (4 For ipv4 or 6 for ipv6)"
 read INTERFACE
if [ $INTERFACE = "6" ]
then
 echo ""
 echo "Enter the ipv6 that you want to use (Format: [xxxxxxxxxxxxx::x])"
 read IP
 echo ""
 echo "Your selected ip is:$IP"
 CHANGEIP="n"
elif [ $INTERFACE = "4" ]
then
 IP=$(curl -s4 api.ipify.org)
 echo ""
 echo "Your ipv4 is:'$IP', do you want to change it? [y/n]"
 read CHANGEIP
 RPCPORT=68890
 else
  echo ""
  echo "Invalid interface, aborting"
  exit
fi
if [ $CHANGEIP = "y" ]
then
 echo ""
 echo "Enter the ipv4 you want to use"
 read IP
fi
if [ $CHANGEIP = "n" -o $CHANGEIP = "y" ]
then
 echo ""
 echo "Enter RPC port for node$ALIAS (Usually 68890)"
 read RPCPORT
 echo ""
 echo "Enter alias for new node"
 read ALIAS

 echo ""
 echo "Enter masternode private key for node $ALIAS"
 read PRIVKEY
  PORT=6889
  ALIAS=${ALIAS}
  CONF_DIR=~/.geekcash_$ALIAS

  # Create scripts
  echo '#!/bin/bash' > ~/bin/geekcash_$ALIAS.sh
  echo "transcendenced -daemon -conf=$CONF_DIR/geekcash.conf -datadir=$CONF_DIR "'$*' >> ~/bin/geekcash_$ALIAS.sh
  echo '#!/bin/bash' > ~/bin/geekcash-cli_$ALIAS.sh
  echo "geekcash-cli -conf=$CONF_DIR/geekcash.conf -datadir=$CONF_DIR "'$*' >> ~/bin/geekcash-cli_$ALIAS.sh
  echo '#!/bin/bash' > ~/bin/geekcash-tx_$ALIAS.sh
  echo "geekcash-tx -conf=$CONF_DIR/geekcash.conf -datadir=$CONF_DIR "'$*' >> ~/bin/geekcash-tx_$ALIAS.sh
  chmod 755 ~/bin/geekcash*.sh

  mkdir -p $CONF_DIR
  echo "rpcuser=user"`shuf -i 100000-10000000 -n 1` >> geekcash.conf_TEMP
  echo "rpcpassword=pass"`shuf -i 100000-10000000 -n 1` >> geekcash.conf_TEMP
  echo "rpcallowip=127.0.0.1" >> geekcash.conf_TEMP
  echo "rpcport=$RPCPORT" >> geekcash.conf_TEMP
  echo "listen=1" >> geekcash.conf_TEMP
  echo "server=1" >> geekcash.conf_TEMP
  echo "daemon=1" >> geekcash.conf_TEMP
  echo "logtimestamps=1" >> geekcash.conf_TEMP
  echo "maxconnections=256" >> geekcash.conf_TEMP
  echo "masternode=1" >> geekcash.conf_TEMP
  echo "" >> geekcash.conf_TEMP

  echo "" >> geekcash.conf_TEMP
  echo "bind=$IP" >> geekcash.conf_TEMP
  echo "port=$PORT" >> geekcash.conf_TEMP
  echo "masternodeaddr=$IP:$PORT" >> geekcash.conf_TEMP
  echo "masternodeprivkey=$PRIVKEY" >> geekcash.conf_TEMP
  sudo ufw allow $PORT/tcp

  mv geekcash.conf_TEMP $CONF_DIR/geekcash.conf
  sh  ~/bin/geekcashd_$ALIAS.sh
fi
exit
