#!/bin/bash

# Install dependencies
sudo yum install epel-release && sudo yum -y update
sudo yum install -y nodejs curl GraphicsMagick npm mongodb-org gcc-c++

# Configure MongoDB
sudo bash -c 'cat > /etc/yum.repos.d/mongodb.repo <<EOF
[mongodb-org-3.4]
name=MongoDB Repository
baseurl=https://repo.mongodb.org/yum/redhat/7/mongodb-org/3.4/x86_64/
gpgcheck=1
enabled=1
gpgkey=https://www.mongodb.org/static/pgp/server-3.4.asc
EOF'

# Configure npm
sudo npm install -g inherits n
sudo n 4.5

# Build Rocketchat
sudo mkdir /opt/rocketchat
sudo curl -L https://rocket.chat/releases/latest/download -o /opt/rocketchat/rocket.chat.tgz
echo "This next part takes a few minutes, everything is okay...go have a scone."
sudo tar zxf /opt/rocketchat/rocket.chat.tgz -C /opt/rocketchat/
sudo mv /opt/rocketchat/bundle /opt/rocketchat/Rocket.Chat
cd /opt/rocketchat/Rocket.Chat/programs/server
sudo npm install

# Create the Rocketchat service
sudo bash -c 'cat > /usr/lib/systemd/system/rocketchat.service <<EOF
[Unit]
Description=The Rocket.Chat server
After=network.target remote-fs.target nss-lookup.target nginx.target mongod.target
[Service]
ExecStart=/usr/local/bin/node /opt/rocketchat/Rocket.Chat/main.js
StandardOutput=syslog
StandardError=syslog
SyslogIdentifier=rocketchat
User=root
Environment=MONGO_URL=mongodb://localhost:27017/rocketchat ROOT_URL=http://localhost:3000/ PORT=3000
[Install]
WantedBy=multi-user.target
EOF'

# Configure the firewall
sudo firewall-cmd --add-port=3000/tcp --permanent
sudo firewall-cmd --reload
sudo chkconfig mongod on
sudo systemctl enable rocketchat.service
sudo systemctl start mongod
sudo systemctl start rocketchat.service
cat << "EOF"
.:+ossyysss+/-.                                   
`+yyyyyyyyyyyyys/.                                
  .oyyyyyyyyyyyyyyo++oossssoo++/:-.`              
    +yyyyyyyyyyyyyyyyyssssssyyyyyyyys+:.          
     syyyyyyyyo+:-.`         ``.-:+oyyyys+-       
    `oyyyyo:.                        .:oyyys/`    
   -syys/`                              `/syys-   
  /yyy/                                    /yyy/  
 :yyy-                                      -yyy: 
 yyy/        ./+/.     :++:     ./+/.        /yyy 
`yyy-       .yyyyy`   +yyyy+   `yyyyy.       -yyy`
 syy/        +yyy+    -syys-    +yyy+        /yys 
 :yyy-         `        ``        `         :yyy: 
  /yyy/                                   .+yyy/  
   -syys/                              `-+syys-   
     oyyy`                       ``..:+syyys:     
     syyo       .:::-........-::/+osyyyys+-       
    +yys.   `..:oyyyyyssssssyyyyyyyys+:.          
  .syys-..--:+syyyo++ooossooo++/:-.               
.+yyyy+++ooyyyys/.                                
.:+osssssso+/-`  
EOF
echo "Rocketchat has been successfully deployed. Browse to http://rocketchat_server:3000 to begin using the service."
