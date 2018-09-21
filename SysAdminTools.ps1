
Do
{
$PromptUser = Read-Host -Prompt '
--------------------------------------------------------------------------------------------------

Choose A/Another Selection :
1. Get Ram Info
2. Check HD/SSD 
3. Check Battery With Detailed Report On WebPage
4. Full Details On Network Adapters
5. Test Connection Remotely
6. Check Serial Number 
7. Exit

-------------------------------------------------------------------------------------------------
'
## For Checking Basic Ram Info
If($PromptUser -eq 1){

$colItems = get-wmiobject -class "Win32_PhysicalMemory" -namespace "root\CIMV2" ` 

foreach ($objItem in $colItems) { 
      write-host "`n"
      write-host "Bank Label: " $objItem.BankLabel 
      write-host "Capacity: " $objItem.Capacity 
      write-host "Caption: " $objItem.Caption 
      write-host "Creation Class Name: " $objItem.CreationClassName 
      write-host "Data Width: " $objItem.DataWidth 
      write-host "Description: " $objItem.Description 
      write-host "Device Locator: " $objItem.DeviceLocator 
      write-host "Form Factor: " $objItem.FormFactor 
      write-host "Hot-Swappable: " $objItem.HotSwappable 
      write-host "Installation Date: " $objItem.InstallDate 
      write-host "Interleave Data Depth: " $objItem.InterleaveDataDepth 
      write-host "Interleave Position: " $objItem.InterleavePosition 
      write-host "Manufacturer: " $objItem.Manufacturer 
      write-host "Memory Type: " $objItem.MemoryType 
      write-host "Model: " $objItem.Model 
      write-host "Name: " $objItem.Name 
      write-host "Other Identifying Information: " $objItem.OtherIdentifyingInfo 
      write-host "Part Number: " $objItem.PartNumber 
      write-host "Position In Row: " $objItem.PositionInRow 
      write-host "Powered-On: " $objItem.PoweredOn 
      write-host "Removable: " $objItem.Removable 
      write-host "Replaceable: " $objItem.Replaceable 
      write-host "Serial Number: " $objItem.SerialNumber 
      write-host "SKU: " $objItem.SKU 
      write-host "Speed: " $objItem.Speed 
      write-host "Status: " $objItem.Status 
      write-host "Tag: " $objItem.Tag 
      write-host "Total Width: " $objItem.TotalWidth 
      write-host "Type Detail: " $objItem.TypeDetail 
      write-host "Version: " $objItem.Version 
}

}


## For Checking The Status Of The SSD/HD
ElseIf($PromptUser -eq 2)
{

Get-PhysicalDisk | Sort Size | FT FriendlyName, Size, MediaType, 
SpindleSpeed, HealthStatus, OperationalStatus -AutoSize
}
## For Opening A HTML Page With Details About The Battery
ElseIf($PromptUser -eq 3){

powercfg /batteryreport
#ii C:\WINDOWS\system32\battery-report.html
Start-Process 'C:\WINDOWS\system32\battery-report.html'
write host " Report has been Generated , Please Check your Browser"

}
## For Network Troubleshooting 
ElseIf($PromptUser -eq 4){

$network=Get-NetIPConfiguration
$network
}

ElseIf($PromptUser -eq 5){
write-host "`n"

$UserInput = Read-Host -Prompt ' Please enter the IP Address/Website(without https) you want to ping  '

Test-NetConnection -ComputerName $UserInput
   
}


ElseIf($PromptUser -eq 6 ){
 systeminfo
 gwmi win32_bios
}

ElseIf($PromptUser -gt 7  -Or $PromptUser -ne [int]){
 Write-Host " Invalid input was made Was Made ......., Now Exiting "
 break
}


Else{
}

}while($PromptUser -ne 7)
