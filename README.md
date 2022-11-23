# Summary

## Pre-Requisites

- [Packer](https://developer.hashicorp.com/packer/downloads)
- [Vagrant](https://developer.hashicorp.com/vagrant/downloads)
  - [Vagrant VMware Utility](https://developer.hashicorp.com/vagrant/downloads/vmware)
  - [Vagrant VMware plugin](https://developer.hashicorp.com/vagrant/docs/providers/vmware/installation)

## Testing

Initialize packer template `packer init .\win10.pkr.hcl`

Build image with `packer build .`

Deploy vagrant box

```cmd
# Add box to vagrant
vagrant box add --name <VMname> <myImage.box>

# Start vagrant box
vagrant up
```

---

**Note**

Due to how sysprep is implemented the built in 'Administrator' and 'Guest' account will always be renamed to their default 'values'.

---
