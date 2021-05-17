### Adding data disk to existing VM

$resourcegroup = 'RG01'
$machinename = 'LinuxVM '
$location = 'westeurope'
$storageType = 'Standard_LRS'
$dataDiskName = 'disk01'
$dataDiskSize = 10
 
#Create a new disk configuration
$datadiskConfig = New-AzDiskConfig -SkuName $storageType -Location $location -CreateOption Empty -DiskSizeGB $dataDiskSize
 
#Create a new disk
$dataDisk01 = New-AzDisk -DiskName $dataDiskName -Disk $datadiskConfig -ResourceGroupName $resourcegroup
 
#Get reference of VM 
$vm = Get-AzVM -Name $machinename -ResourceGroupName $resourcegroup
 
# Add data disk to VM 
$vm = Add-AzVMDataDisk -VM $vm -Name $dataDiskName -CreateOption Attach -ManagedDiskId $dataDisk01.Id -Lun 1
 
# Update the VM to complete the operation
Update-AzVM -VM $vm -ResourceGroupName $resourcegroup