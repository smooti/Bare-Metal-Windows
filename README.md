# Purpose

Create a perfect WIM everytime ;)

## Pre-Requisites

- [Packer](https://developer.hashicorp.com/packer/downloads)
- [VMware](https://www.vmware.com/products/workstation-pro/workstation-pro-evaluation.html)
- [OSFMount](https://www.osforensics.com/tools/mount-disk-images.html)

## Quick Start

- Change into the project directory and execute `packer init .` (This will download all missing plugins)
- Now as an administrator run the build script `Build-PackerImage.ps1`

## Customizing

### OEM Information

Custom OEM information can be configured in the respective answer file located [here](./Answers/)

## Building

In order to build the image you can run the `.\Build-PackerImage.ps1` located at the root of the repository.

## Testing

If you would like to run a specific step you can comment (`#`) out the `Start-Process @step<StepNumber>Args`, save and then run the powershell script.

---

**Note**

Due to how sysprep is implemented the built in 'Administrator' and 'Guest' account will always be renamed to their default 'values'. This is the reason we do not rename the built-in accounts.

---
