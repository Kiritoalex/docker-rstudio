#name of container: docker-rstudio
#versison of container: 0.6.1
FROM quantumobject/docker-baseimage:15.04
MAINTAINER Angel Rodriguez "angel@quantumobject.com"

#add repository and update the container
#Installation of nesesary package/software for this containers...
RUN echo "deb http://archive.ubuntu.com/ubuntu `cat /etc/container_environment/DISTRIB_CODENAME`-backports main restricted universe" >> /etc/apt/sources.list
RUN (echo "deb http://cran.mtu.edu/bin/linux/ubuntu `cat /etc/container_environment/DISTRIB_CODENAME`/" >> /etc/apt/sources.list && apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E084DAB9)
RUN apt-get update && apt-get install -y -q r-base \
                                              r-base-dev \
                                              gdebi-core \
                                              libapparmor1  \
                                              sudo \
                                              libcurl4-openssl-dev \
                                              libssl0.9.8 \
                  && apt-get clean \
                  && rm -rf /tmp/* /var/tmp/* \
                  && rm -rf /var/lib/apt/lists/*
                  
RUN update-locale
RUN wget http://download2.rstudio.org/rstudio-server-0.99.896-amd64.deb \
                                              && gdebi -n rstudio-server-0.99.896-amd64.deb \
                                              && rm /rstudio-server-0.99.896-amd64.deb
    
##startup scripts
#Pre-config scrip that maybe need to be run one time only when the container run the first time .. using a flag to don't
#run it again ... use for conf for service ... when run the first time ...
RUN mkdir -p /etc/my_init.d
COPY startup.sh /etc/my_init.d/startup.sh
RUN chmod +x /etc/my_init.d/startup.sh

##Adding Deamons to containers
RUN mkdir /etc/service/rserver /var/log/rserver ; sync
RUN mkdir /etc/service/rserver/log
COPY rserver.sh /etc/service/rserver/run
COPY rserver-log.sh /etc/service/rserver/log/run
RUN chmod +x /etc/service/rserver/run /etc/service/rserver/log/run \
    && cp /var/log/cron/config /var/log/rserver/ \
    && chown -R rstudio-server /var/log/rserver

#add files and script that need to be use for this container
#include conf file relate to service/daemon
#additionsl tools to be use internally
#RUN (adduser --disabled-password --gecos "" guest && echo "guest:guest"|chpasswd)

# to allow access from outside of the container to the container service
# at that ports need to allow access from firewall if need to access it outside of the server.
EXPOSE 8787

# Use baseimage-docker's init system.
CMD ["/sbin/my_init"]
