## VMSS (Virtual Machine Scale Set) - AZURE CLI

## Create RG
az group create --name ScaleSetRG --location westeurope

# Create VNET
az network vnet create
--name VN01 `
--resource-group ScaleSetRG `
--subnet-name default `

## Scale Set
az vmss create -n appvmset -g ScaleSetRG # Set a name for the scale set + RG
--instance-count 1  # Inital number of instances
--image Win2016Datacenter ` # Underlying image
--data-disk-sizes-gb 10  # Underlying data disk size
--vnet-name VN01  # VNET
--subnet default 
--public-ip-per-vm # Public IP
--admin-username achiladakis  # Admin user name 


## Custom Script Extension
## Installation of Internet Information Systems

az vmss extension set
--publisher "Microsoft.Compute" 
--version 1.10 
--resource-group ScaleSetRG 
--vmss-name appvmset 
--settings "customscriptwin.json"  # Download Powershell Script from Github + use Powershell to execute the script
--name CustomScriptExtension 



