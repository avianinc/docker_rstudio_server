FROM ubuntu:latest
## Must add `DEBIAN_FRONTEND=noninteractive` to prevent any os waiting for user input situations
  ## see --> https://askubuntu.com/questions/909277/avoiding-user-interaction-with-tzdata-when-installing-certbot-in-a-docker-contai
ARG DEBIAN_FRONTEND=noninteractive

## Update server
## See https://support.rstudio.com/hc/en-us/articles/206794537-Common-dependencies-for-RStudio-Workbench-and-RStudio-Server
## for RStudion depenencies
RUN apt-get --quiet --yes update
RUN apt-get install -y git zip unzip wget apt-utils \
    r-base \
    lib32gcc-s1 \
    lib32stdc++6 \
    libc6-i386 \
    libclang-10-dev \
    libclang-common-10-dev \
    libclang-dev \
    libclang1-10 libgc1c2 \
    libllvm10 \
    libobjc-9-dev \
    libobjc4 \
    libpq5 \
    psmisc \
    sudo \
    libapparmor1 \
    libedit2 \
    libc6 \
    rrdtool

# Install rstudio server -- use -n for non interactive gdebi installation
WORKDIR /tmp
RUN wget https://download2.rstudio.org/server/bionic/amd64/rstudio-server-2021.09.2-382-amd64.deb
# see --> https://stackoverflow.com/questions/41180704/dockerfile-and-dpkg-command
RUN apt install -y ./rstudio-server-2021.09.2-382-amd64.deb

# clean up the image docker
RUN apt-get -y clean all && \
	apt-get -y purge && \
	rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# See --> https://stackoverflow.com/questions/27701930/how-to-add-users-to-docker-container#27703359
RUN useradd -rm -d /home/ubuntu -s /bin/bash -g root -G sudo -u 1001 -p "$(openssl passwd -6 rstudio)" rstudio
USER rstudio
WORKDIR /home/rstudio

# RUN git clone "add a remote folder here..." [Note: better for a set of static files but this shows how to dot it.]
# create a local volume if you like
COPY user-settings /home/rstudio/.rstudio/monitored/user-settings/user-settings
COPY .Rprofile /home/rstudio/

USER root
# Expose the working port and execute command
EXPOSE 8787

# See --> https://community.rstudio.com/t/dockerfile-for-rstudio-server/10753
CMD ["/usr/lib/rstudio-server/bin/rserver", "--server-daemonize=0", "--server-app-armor-enabled=0"]
