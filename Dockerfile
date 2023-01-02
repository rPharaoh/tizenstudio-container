# to check for local .bin package
# remote has extremely slow download rate
ARG INSTALL_FROM=local

FROM ubuntu AS base

RUN apt update; apt -y upgrade; apt clean
RUN apt install openjdk-19-jdk -y

RUN apt install -y git
RUN apt install -y curl

RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash -
RUN apt install -y nodejs

RUN npm install yarn -g

# openssh-server to keep the container running
RUN apt -qq install -y openssh-server passwd
RUN apt update; apt install wget zip -y
RUN apt install vim nano -y
RUN apt install xmlstarlet -y
RUN apt update; apt -y upgrade; apt clean

# main user to be created to install tizan studio under
ARG USER=tizen

# certificate args
ENV CERT_PASS=CertPassShouldBeAutoGenerated
ENV CERT_COUNTRY="EG"
ENV CERT_CITY="CA"
ENV CERT_COMPANY="${USER}"
ENV CERT_NAME="${USER}"
ENV CERT_EMAIL="${USER}@${CERT_COMPANY}.server"

# Set JAVA_HOME variable
RUN echo export JAVA_HOME=`echo -ne '\n' | echo \`update-alternatives --config java\` | cut -d "(" -f2 | cut -d ")" -f1 | sed 's/.........$//'` >> /etc/bashrc
RUN mkdir /var/run/sshd

# to use ssh if needed 
RUN ["/bin/bash", "-c", "ssh-keygen -t rsa -f /etc/ssh/ssh_host_rsa_key -N '' <<<y"]

RUN ssh-keygen -A
# Configure SSH daemon to allow root login
RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config

RUN useradd -ms /bin/bash ${USER}
WORKDIR /home/${USER}

RUN mkdir tizen

# Should check for local .bin else get from internet
# ==================
FROM base as install_from_local
WORKDIR /installer
ONBUILD COPY web-cli_Tizen_Studio_5.0_ubuntu-64.bin ./web-cli_Tizen_Studio_5.0_ubuntu-64.bin

FROM base as install_from_remote
WORKDIR /installer
ONBUILD RUN wget https://download.tizen.org/sdk/Installer/tizen-studio_5.0/web-cli_Tizen_Studio_5.0_ubuntu-64.bin

# ==================
FROM install_from_${INSTALL_FROM} as final
WORKDIR /home/${USER}
RUN cp /installer/web-cli_Tizen_Studio_5.0_ubuntu-64.bin ./tizen/web-cli_Tizen_Studio_5.0_ubuntu-64.bin
RUN rm -rf /installer
RUN chmod a+x ./tizen/web-cli_Tizen_Studio_5.0_ubuntu-64.bin

# Path for the tools after installation
ARG TizenToolsPath="export PATH=$PATH:/home/${USER}/tizen-studio/tools/ide/bin:/home/tizen/tizen-studio/tools"

USER ${USER}

# install tizen app
RUN echo "y" | bash ./tizen/web-cli_Tizen_Studio_5.0_ubuntu-64.bin --accept-license --no-java-check

# add path for the tools in tizen shell
RUN echo "${TizenToolsPath}" >> ~/.bashrc

# Generate tizen certificate
# and csr cert for siging the app 

# generate certificate
RUN /home/${USER}/tizen-studio/tools/ide/bin/tizen certificate -a TizenCert -p $CERT_PASS -c $CERT_COUNTRY -ct $CERT_CITY -o $CERT_COMPANY -n $CERT_NAME -e $CERT_EMAIL -f tizencert

# See available profiles that are already created - it will give empty list if you just installed Tizen Studio:
RUN /home/${USER}/tizen-studio/tools/ide/bin/tizen security-profiles list

# Create new profile, you may want to replace YourName with something like WillSmith:
RUN /home/${USER}/tizen-studio/tools/ide/bin/tizen security-profiles add -n $CERT_NAME -a /home/${USER}/tizen-studio-data/keystore/author/tizencert.p12 -p $CERT_PASS

# RUN xmlstarlet ed -u '/profiles/profile/profileitem/@password' -v "$CERT_PASS" /home/${USER}/tizen-studio-data/profile/profiles.xml > /home/${USER}/tizen-studio-data/profile/profiles.xml

USER root
RUN rm -rf /home/$USER/tizen

# add path for the tools in root shell
RUN echo "${TizenToolsPath}" >> ~/.bashrc

COPY docker-entrypoint.sh /usr/share/host/docker-entrypoint.sh
ENTRYPOINT ["/usr/share/host/docker-entrypoint.sh"]