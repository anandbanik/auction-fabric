# Vagrant Development Environment
This directory contains the scripts necessary to bring up a simple development environment with Vagrant. This environment is focused on the requirements for building and testing the Fabric workshop code and can also be used for application development or chaincode.


### Prerequisite
1. VirtualBox<br>
    Download from [here](https://www.virtualbox.org/wiki/Downloads)<br>
    Installation Instructions are [here](https://www.virtualbox.org/manual/ch02.html)<br><br>

2. Vagrant<br>
    Download from [here](https://www.vagrantup.com/downloads)<br>
    Installation Instructions are [here](https://www.vagrantup.com/docs/installation)<br><br>


### Instructions
1. To create and start the VM 
``` 
    cd <to vagrant folder>
    vagrant up
```

2. To login to the VM 
``` 
    vagrant ssh
```

3. To shudown the VM 
```
    vagrant suspend
```

4. To delete the VM 
```
    vagrant destroy
```
