#!/bin/sh

CERT_PASS=$(openssl rand -base64 9)

echo $CERT_PASS > /home/${USER}/certpass

# Generate tizen certificate and csr cert for siging the app 
/home/${USER}/tizen-studio/tools/ide/bin/tizen certificate -a TizenCert -p ${CERT_PASS} -c ${CERT_COUNTRY} -ct ${CERT_CITY} -o ${CERT_COMPANY} -n ${CERT_NAME} -e ${CERT_EMAIL} -f ${USER}cert

# See available profiles that are already created - it will give empty list if you just installed Tizen Studio:
/home/${USER}/tizen-studio/tools/ide/bin/tizen security-profiles list

# Create new profile, you may want to replace YourName with something like WillSmith:
/home/${USER}/tizen-studio/tools/ide/bin/tizen security-profiles add -n ${CERT_NAME} -a /home/${USER}/tizen-studio-data/keystore/author/${USER}cert.p12 -p ${CERT_PASS}

# using created profile for signing
/home/${USER}/tizen-studio/tools/ide/bin/tizen cli-config "profiles.path=/home/${USER}/tizen-studio-data/profile/profiles.xml"

cat <<EOF > /home/${USER}/tizen-studio-data/profile/profiles.xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<profiles active="${USER}" version="3.1">
<profile name="${USER}">
<profileitem ca="" distributor="0" key="/home/${USER}/tizen-studio-data/keystore/author/tizencert.p12" password="${CERT_PASS}" rootca=""/>
<profileitem ca="/home/${USER}/tizen-studio/tools/certificate-generator/certificates/distributor/tizen-distributor-ca.cer" distributor="1" key="/home/${USER}/tizen-studio/tools/certificate-generator/certificates/distributor/tizen-distributor-signer.p12" password="tizenpkcs12passfordsigner" rootca=""/>
<profileitem ca="" distributor="2" key="" password="" rootca=""/>
</profile>
</profiles>
EOF

# change password from profile
# xmlstarlet ed -u '/profiles/profile/profileitem/@password' -v "$CERT_PASS" /home/${USER}/tizen-studio-data/profile/profiles.xml

# fixing ownership after executing commands from root
chown -R $USER:$USER /home/$USER

/usr/sbin/sshd -D
