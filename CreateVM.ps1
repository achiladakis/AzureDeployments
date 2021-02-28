## Creating VM (CLI) 
az vm create `
--resource-group RG01 `
--name LinuxVM `
--image UbuntuLTS `
--admin-username demousr `
--admin-password LinuxTestingVM@123 `
--size Standard_B1s `
-- location westeurope ## Location in which to create VM and related resources. If default location is not configured, will default to the resource group's location.

## Powershell cmdlet 
## If we want to specifcy the VMSize, we cannot do that in NEW-AzVM
New-AzVm `
-Name LinuxVM2 `
-ResourceGroupName RG01 `
-Location CentralUS `
-Image UbuntuLTS `

####### Alternative Powershell cmdlet #######

## Creating a resource group
New-AzResourceGroup -Name "RG01" -Location "WestEurope"

###### Create a subnet ######
# Note that this is an "in-memory" representation and New-AzVirtualNetworkSubnetConfig does not create any subnets.
$subnetConfig = New-AzVirtualNetworkSubnetConfig `
  -Name "mySubnet" `
  -AddressPrefix 192.168.1.0/24 # ~254 hosts

##Creating a virtual network
$vnet = New-AzVirtualNetwork `
  -ResourceGroupName "RG01" `
  -Location "WestEurope" `
  -Name "VNET01" `
  -AddressPrefix 192.168.0.0/16 ` # ~65534 hosts
  -Subnet $subnetConfig

## Create a public IP address + specifing DNS name
$pip = New-AzPublicIpAddress `
  -ResourceGroupName "RG01" `
  -Location "WestEurope" `
  -AllocationMethod Static `  # If we want the IP to remain the same -> IP is assigned immediately and only released when deleting the resource/changing the allocation method to static
  -IdleTimeoutInMinutes 4 ` # Specifies the idle time-out, in minutes.
  -Name "publicdns$(Get-Random)" # e.g. publicdns1528789310 

## Create an inbound network security group rule for allowing access from the Internet to port 22
$nsgRuleSSH = New-AzNetworkSecurityRuleConfig `
  -Name "NetworkSecurityGroupRuleSSH"  `
  -Protocol "Tcp" `
  -Direction "Inbound" `
  -Priority 1000 `
  -SourceAddressPrefix * `
  -SourcePortRange * `
  -DestinationAddressPrefix * `
  -DestinationPortRange 22 ` # range of integers between 0 and 65535
  -Access "Allow"

# Create a security rule allowing access from the Internet to port 80 - inbound NSG (in case we want to install e.g. NGINX)
$nsgRuleWeb = New-AzNetworkSecurityRuleConfig `
  -Name "NetworkSecurityGroupRuleWWW"  `
  -Protocol "Tcp" `
  -Direction "Inbound" `
  -Priority 1001 `
  -SourceAddressPrefix * `
  -SourcePortRange * `
  -DestinationAddressPrefix * `
  -DestinationPortRange 80 `
  -Access "Allow"

# Create a network security group
$nsg = New-AzNetworkSecurityGroup `
  -ResourceGroupName "RG01" `
  -Location "WestEurope" `
  -Name "NetworkSecurityGroup" `
  -SecurityRules $nsgRuleSSH,$nsgRuleWeb  # Adding the rules (port 22, 80) to NSG "NetworkSecurityGroup"

# Create a NIC (network interface card) that connects the VM to a subnet, NSG and public IP address
$nic = New-AzNetworkInterface `
  -Name "Nic" `
  -ResourceGroupName "RG01" `
  -Location "WestEurope" `
  -SubnetId $vnet.Subnets[0].Id ` #Specifies the ID of the subnet for which to create a network interface.
  -PublicIpAddressId $pip.Id ` #Specifies the ID of a PublicIPAddress object to assign to a network interface.
  -NetworkSecurityGroupId $nsg.Id  #Specifies the ID of a network security group.

# Define a credential object
#Define a username with a blank password for our Azure VM.
# -Force confirms you understand the lack of security when using -AsPlainText
# -AsPlainText tells command to treat string as plain text
$securePassword = ConvertTo-SecureString ' ' -AsPlainText -Force 
# Create a PSCredential object with username (user1) and password
$credential = New-Object System.Management.Automation.PSCredential ("user1", $securePassword)

# Create a virtual machine configuration
$vmConfig = New-AzVMConfig `
  -VMName "LinuxVM" `
  -VMSize "Standard_B1s" | ` # Define VM size 
Set-AzVMOperatingSystem `
  -Linux `
  -ComputerName "LinuxVM" `
  -Credential $credential `
  -DisablePasswordAuthentication | `
Set-AzVMSourceImage `
  -PublisherName "Canonical" `
  -Offer "UbuntuServer" `
  -Skus "18.04-LTS" `
  -Version "latest" | `
Add-AzVMNetworkInterface `
  -Id $nic.Id 

## Generating SSH-Key 
ssh-keygen.exe

# Configure the SSH key (adds the public keys)
# Cannot be used
$sshPublicKey = cat ~/.ssh/id_rsa.pub
Add-AzVMSshPublicKey `
  -VM $vmConfig `  # VM stored in variable
  -KeyData $sshPublicKey ` #adding public key to path
  -Path "/home/azureuser/.ssh/authorized_keys" # path parameter

# Create the VM
  New-AzVM `
  -ResourceGroupName "RG01" `
  -Location westeurope -VM $vmConfig



## For information regarding SKU / list of VMs:
az vm list-sizes --location westeurope --output table
az vm list-skus --location westeurope --output table

