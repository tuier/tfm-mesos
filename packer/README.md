
# AMI

[Packer](https://www.packer.io/) is used to create the AMI

# Mesos Master

### Build

To build the image using packer
```
packer build packer/mesos-master-debian.json

```

### Variable

* Mesos URL is a link to the Mesos deb package that we wanted to be installed
* Region: is the region where the AMI is created
* Version: is the version used in the nae of the AMI
* AWS AMI: is the source AMI your creation is based on
Also AWS credentials must be configured.


### Name

The AMI will be named base on the version and the time of the build following 
that pattern
simple-mesos-master-<version>-<build_time>
Where version is the **version** specified in input and **build_time** the 
time, following that pattern *2006-01-02_15_04*, when the images is build

# Zookeeper

### Build

To build the image using packer
```
packer build packer/zookeeper.json
```


### Variable

* exhibitor_pom: is a link to the pom file allow use to install exhibitor
* Telegraf URL: is a link to the telegraf deb package that we wanted to be 
installed 
* Region: is the region where the AMI is created
* AWS AMI: is the source AMI your creation is based on
* key: is the AWS key that will be used
Also AWS credentials must be configured.

### Name

The AMI will be named base on the version and the time of the build following 
that pattern
simple-zk-exhibitor-<build_time>
Where version is the **version** specified in input and **build_time** the 
time, following that pattern *2006-01-02_15_04*, when the images is build


# Mesos Agent

### Build

To build the image using packer
```
packer build packer/mesos-agent-debian.json
```

### Variable

* Mesos URL: is a link to the mesos deb package that we wanted to be installed
* Docker URL: is a link to the docker deb package that we wanted to be 
installed
* Telegraf URL: is a link to the telegraf deb package that we wanted to be 
installed 
* Region: is the region where the AMI is created
* Version: is the version used in the nae of the AMI
* AWS AMI: is the source AMI your creation is based on
* key: is the AWS key that will be used
Also AWS credentials must be configured.

### Name

The AMI will be named base on the version and the time of the build following 
that pattern
simple-mesos-agent-<version>-<build_time>
Where version is the **version** specified in input and **build_time** the 
time, following that pattern *2006-01-02_15_04*, when the images is build

