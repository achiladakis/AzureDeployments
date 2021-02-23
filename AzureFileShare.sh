# This bash scripts creates a simple Windows VM that we then
# can mount to our system.

## Windows - via RDP (remote desktop protocol)
### Bash:

group=RG02
name=windows-vm
az group create -g $group -l westeurope
password=Adm1nPasSword$RANDOM

az vm create \
  -n $name \
  -g $group \
  -l westeurope \
  --image Win2019Datacenter \
  --admin-username demoadmin \
  --admin-password $password \
  --nsg-rule rdp

az vm show \
  -g $group \
  -n $name \
  -d \
  --query "{name:name,publicIps:publicIps,user:osProfile.adminUsername,password:'$password'}" \
  -o jsonc > clouddrive/$name.json

cat clouddrive/$name.json

#### Under Windows Powershell:

$group='RG02'  # $ defines a variable
$name='windows-vm'
az group create -g $group -l westeurope
$RANDOM = Get-Random
$password='Adm1nPasSword'+$RANDOM  # concat via "+"

az vm create `
  -n $name `
  -g $group `
  -l westeurope `
  --image Win2019Datacenter `
  --admin-username demoadmin `
  --admin-password $password `
  --nsg-rule rdp `

az vm show `
  -g $group `
  -n $name `
  -d `
  --query "{name:name,publicIps:publicIps,user:osProfile.adminUsername,password:'$password'}" ` 
  -o jsonc > clouddrive/$name.json `

cat clouddrive/$name.json

### Linux VM - optimized for Powershell

$group='RG02'
$name='linux-vm'
az group create -g $group -l westeurope

az vm create `
--name $name `
--resource-group $group `
--image UbuntuLTS `
--size Standard_B1s `
--generate-ssh-keys `
--admin-username demoadmin `

az vm show `
  -g $group `
  -n $name `
  -d `
  --query "{name:name,publicIps:publicIps,user:osProfile.adminUsername}" `

### To connect through SSH --> ssh demoadmin@20.67.103.199

