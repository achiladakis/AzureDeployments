#General: Credentials in Powershell

###VM credentials in Powershell
$vmAdminUsername = 'achiladakis'
#Create a secure string from an encrypted string in a file -> See StoringCredentials.ps1
$secureStringFile = Get-Content '.\encrypted.txt'
$vmAdminPassword = $secureStringFile | ConvertTo-SecureString 
$vmCredential = New-Object System.Management.Automation.PSCredential ($vmAdminUsername, $vmAdminPassword)

#General: Retrieve VNET
#Retrieve Virtual Network
$retrieveVnet = Get-AzVirtualNetwork -Name $vnetName `
  -ResourceGroupName $ResourceGroupName `


#General: Loops in Powershell
$names = @("Max","Simon","Luke")

for ($i = 0; $i -lt 1; $i++) {
$names[$i]  

  for ($i = 0; $i -le $names.Count -1; $i++) {
  $names[$i]
  }
}


##### Create 3 VMs + 3 Subnets 

for ($i = 0; $i -lt 1; $i++) {

#Resource Group
$resourceGroupName = "RG01"
$azureLocation= "westeurope"
 
#Virtual Network 
$vnetName = "VNET01"
$nicName = "NIC-"
$addressPrefix = @("10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24")
$subnetName = @("subnetA", "subnetB", "subnetC")

#Virtual Machines
$vmNames = @("LinuxVM01","LinuxVM02", "LinuxVM03")
$vmSize = "Standard_B2s"
$publisherName = "Canonical"
$vmOffer = "UbuntuServer"
$vmSKU = "18.04-LTS" 
 
#Create a RG
New-AzResourceGroup -Name $resourceGroupName -Location $azureLocation

#Creating a virtual network
$vnet = New-AzVirtualNetwork `
  -ResourceGroupName $resourceGroupName `
  -Location $azureLocation `
  -Name $vnetName `
  -AddressPrefix 10.0.0.0/16 ` # ~65534 hosts

# range of integers between 0 and 65535
$nsgRuleSSH = New-AzNetworkSecurityRuleConfig `
  -Name "NetworkSecurityGroupRuleSSH"  `
  -Protocol "Tcp" `
  -Direction "Inbound" `
  -Priority 1000 `
  -SourceAddressPrefix * `
  -SourcePortRange * `
  -DestinationAddressPrefix * `
  -DestinationPortRange 22 `
  -Access "Allow" `

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
  -Access "Allow" `

$vmAdminUsername = 'achiladakis'
$secureStringFile = Get-Content '.\encrypted.txt'
$vmAdminPassword = $secureStringFile | ConvertTo-SecureString 
$vmCredential = New-Object System.Management.Automation.PSCredential ($vmAdminUsername, $vmAdminPassword)

# Loop condition -> If we want to create 3 VMs, we need to loop 3 times
# Therefore the following condition applies:  i = 0 <= 2 -> 0,1,2
for ($i = 0; $i -le $vmNames.Count -1; $i++) {

#10.1.0.0/24, 10.1.1.0/24, 10.1.2.0/24
Add-AzVirtualNetworkSubnetConfig `
  -Name $subnetName[$i] `
  -VirtualNetwork $vnet `
  -AddressPrefix $addressPrefix[$i]`

#Write the modified virtual network state on the service side  
$vnet | Set-AzVirtualNetwork

## Create a public IP address + specifing DNS name
# If we want the IP to remain the same -> IP is assigned immediately and only released when deleting the resource/changing the allocation method to static
# Specifies the idle time-out, in minutes.
# e.g. publicdns1528789310 
$pip = New-AzPublicIpAddress `
  -ResourceGroupName $ResourceGroupName `
  -Location $azureLocation `
  -AllocationMethod Static `
  -IdleTimeoutInMinutes 4 `
  -Name "publicdns$(Get-Random)" `

# Create a network security group
# Adding the rules (port 22, 80) to NSG "NetworkSecurityGroup"
$nsg = New-AzNetworkSecurityGroup `
  -ResourceGroupName $resourceGroupName `
  -Location $azureLocation `
  -Name ("NetworkSecurityGroup" + $i) `
  -SecurityRules $nsgRuleSSH,$nsgRuleWeb `

#vnet has no ID -> we need to retrieve the vnet object to get the ID
$vnet = Get-AzVirtualNetwork -Name $vnetName `
  -ResourceGroupName $ResourceGroupName `

  # Create a NIC (network interface card) that connects the VM to a subnet, NSG and public IP address
#Specifies the ID of the subnet for which to create a network interface.
#Specifies the ID of a PublicIPAddress object to assign to a network interface.
#Specifies the ID of a network security group.
$nic = New-AzNetworkInterface `
  -Name ("Nic"+$i) `
  -ResourceGroupName $ResourceGroupName `
  -Location $azureLocation `
  -SubnetId $vnet.Subnets[$i].Id `
  -PublicIpAddressId $pip.Id `
  -NetworkSecurityGroupId $nsg.Id `

#Linux - Create the virtual machine configuration
$VmConfig = New-AzVMConfig `
  -VMName $vmNames[$i] `
  -VMSize $vmSize `

$VMConfig = Set-AzVMOperatingSystem `
  -VM $VmConfig `
  -ComputerName $vmNames[$i] `
  -Linux `
  -Credential $vmCredential `

$VMConfig = Add-AzVMNetworkInterface `
  -VM $VmConfig `
  -Id $nic.Id `

$VMConfig = Set-AzVMSourceImage `
  -VM $VmConfig `
  -PublisherName $publisherName `
  -Offer $vmOffer `
  -Skus $vmSKU `
  -Version "latest" `

New-AzVM `
  -ResourceGroupName $resourceGroupName `
  -Location $azureLocation `
  -VM $vmConfig `
  -Verbose `
}    
    
}