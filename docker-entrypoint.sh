#!/bin/sh

CERT_PASS=$(openssl rand -base64 9)

# Generate tizen certificate and csr cert for siging the app 
/home/${USER}/tizen-studio/tools/ide/bin/tizen certificate -a TizenCert -p $CERT_PASS -c $CERT_COUNTRY -ct $CERT_CITY -o $CERT_COMPANY -n $CERT_NAME -e $CERT_EMAIL -f tizencert

# See available profiles that are already created - it will give empty list if you just installed Tizen Studio:
/home/${USER}/tizen-studio/tools/ide/bin/tizen security-profiles list

# Create new profile, you may want to replace YourName with something like WillSmith:
/home/${USER}/tizen-studio/tools/ide/bin/tizen security-profiles add -n $CERT_NAME -a /home/${USER}/tizen-studio-data/keystore/author/tizencert.p12 -p $CERT_PASS

# using created profile for signing
tizen cli-config "profiles.path=/home/${USER}/tizen-studio-data/profile/profiles.xml"

# change password from profile
xmlstarlet ed -u '/profiles/profile/profileitem/@password' -v "$CERT_PASS" /home/${USER}/tizen-studio-data/profile/profiles.xml

# fixing ownership after executing commands from root
chown -R $USER:$USER /home/$USER

/usr/sbin/sshd -D
