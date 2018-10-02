
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
7. System-Health Report ( Cred. Gregory Van Den Hem)
8. Change Computer Name (Step 1 for AD Join)
9. AD Join(Computer name is assigned , if not change computer name first)
10. Exit

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

$UserInput = Read-Host -Prompt ' Please enter the ip address/website you want to ping '

Test-NetConnection -ComputerName $UserInput
   
}


ElseIf($PromptUser -eq 6 ){
 systeminfo
 gwmi win32_bios
}

ElseIf($PromptUser -eq 7){

$sysname = Read-Host 'What is the hostname or IP are you diagnosing? (Default is localhost)'
$howmanylogs = Read-Host 'How many log entries do you want to see from Event, System and Security? (Default is 50)'
#Set Default on howmanylogs if empty
if (!$howmanylogs) { 
$howmanylogs = '50'
}
if (!$sysname) { 
$sysname = 'localhost'
}

#Disk freespace function from http://binarynature.blogspot.com/2010/04/powershell-version-of-df-command.html
function Get-DiskFree
{
    [CmdletBinding()]
    param 
    (
        [Parameter(Position=0,
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true)]
        [Alias('hostname')]
        [Alias('cn')]
        [string[]]$ComputerName = $env:COMPUTERNAME,
        
        [Parameter(Position=1,
                   Mandatory=$false)]
        [Alias('runas')]
        [System.Management.Automation.Credential()]$Credential =
        [System.Management.Automation.PSCredential]::Empty,
        
        [Parameter(Position=2)]
        [switch]$Format
    )
    
    BEGIN
    {
        function Format-HumanReadable 
        {
            param ($size)
            switch ($size) 
            {
                {$_ -ge 1PB}{"{0:#.#'P'}" -f ($size / 1PB); break}
                {$_ -ge 1TB}{"{0:#.#'T'}" -f ($size / 1TB); break}
                {$_ -ge 1GB}{"{0:#.#'G'}" -f ($size / 1GB); break}
                {$_ -ge 1MB}{"{0:#.#'M'}" -f ($size / 1MB); break}
                {$_ -ge 1KB}{"{0:#'K'}" -f ($size / 1KB); break}
                default {"{0}" -f ($size) + "B"}
            }
        }
        
        $wmiq = 'SELECT * FROM Win32_LogicalDisk WHERE Size != Null AND DriveType >= 2'
    }
    
    PROCESS
    {
        foreach ($computer in $ComputerName)
        {
            try
            {
                if ($computer -eq $env:COMPUTERNAME)
                {
                    $disks = Get-WmiObject -Query $wmiq `
                             -ComputerName $computer -ErrorAction Stop
                }
                else
                {
                    $disks = Get-WmiObject -Query $wmiq `
                             -ComputerName $computer -Credential $Credential `
                             -ErrorAction Stop
                }
                
                if ($Format)
                {
                    # Create array for $disk objects and then populate
                    $diskarray = @()
                    $disks | ForEach-Object { $diskarray += $_ }
                    
                    $diskarray | Select-Object @{n='Name';e={$_.SystemName}}, 
                        @{n='Vol';e={$_.DeviceID}},
                        @{n='Size';e={Format-HumanReadable $_.Size}},
                        @{n='Used';e={Format-HumanReadable `
                        (($_.Size)-($_.FreeSpace))}},
                        @{n='Avail';e={Format-HumanReadable $_.FreeSpace}},
                        @{n='Use%';e={[int](((($_.Size)-($_.FreeSpace))`
                        /($_.Size) * 100))}},
                        @{n='FS';e={$_.FileSystem}},
                        @{n='Type';e={$_.Description}}
                }
                else 
                {
                    foreach ($disk in $disks)
                    {
                        $diskprops = @{'Volume'=$disk.DeviceID;
                                   'Size'=$disk.Size;
                                   'Used'=($disk.Size - $disk.FreeSpace);
                                   'Available'=$disk.FreeSpace;
                                   'FileSystem'=$disk.FileSystem;
                                   'Type'=$disk.Description
                                   'Computer'=$disk.SystemName;}
                    
                        # Create custom PS object and apply type
                        $diskobj = New-Object -TypeName PSObject `
                                   -Property $diskprops
                        $diskobj.PSObject.TypeNames.Insert(0,'BinaryNature.DiskFree')
                    
                        Write-Output $diskobj
                    }
                }
            }
            catch 
            {
                # Check for common DCOM errors and display "friendly" output
                switch ($_)
                {
                    { $_.Exception.ErrorCode -eq 0x800706ba } `
                        { $err = 'Unavailable (Host Offline or Firewall)'; 
                            break; }
                    { $_.CategoryInfo.Reason -eq 'UnauthorizedAccessException' } `
                        { $err = 'Access denied (Check User Permissions)'; 
                            break; }
                    default { $err = $_.Exception.Message }
                }
                Write-Warning "$computer - $err"
            } 
        }
    }
    
    END {}
}
Write-Host "`n`n"
Write-Host "$sysname report"
Write-Host "`n`n"
Write-Host "The Report is generated On  $(get-date) by $((Get-Item env:\username).Value) on computer $((Get-Item env:\Computername).Value)" 
Write-Host "`n`n"
# CPU RAM Host Information
Write-Host "###########################################################################"
Write-Host "###   System Information                                                ###"
Write-Host "###                                                                     ###"
Write-Host "###                                                                     ###"
Write-Host "###########################################################################"
Write-Host "`n`n"

Get-WmiObject win32_bios -ComputerName $sysname | select Status,Version,PrimaryBIOS,Manufacturer,ReleaseDate,SerialNumber

Write-Host "`n`n"
get-WmiObject win32_operatingsystem -ComputerName $sysname | select Caption,Organization,InstallDate,OSArchitecture,Version,ServicePackMajorVersion,ServicePackMinorVersion,SerialNumber,BootDevice,LastBootUpTime,WindowsDirectory,CountryCode,TotalVisibleMemorySize,FreePhysicalMemory,TotalSwapSpaceSize,FreeSpaceInPagingFiles,FreeVirtualMemory 

Write-Host "`n`n"
#Get-WmiObject win32_startupCommand -ComputerName $sysname | select Name,Location,Command,User,caption

Write-Host "`n`n"
$loadvalue = Get-WmiObject -class win32_processor -ComputerName $sysname  | select LoadPercentage
$loadpercentage = $loadvalue.LoadPercentage
Write-Host "CPU Load Percent is: $loadpercentage`n"
$reg = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey('LocalMachine', $sysname)
$regKey = $reg.OpenSubKey("SOFTWARE\\Microsoft\\Internet Explorer")
$regKeyResult = $regKey.GetValue("SvcVersion")
write-host "Current Internet Explorer Version is: $regKeyResult"

Write-Host "`n`n" 
# List Services
Write-Host "###########################################################################"
Write-Host "###   Services Health                                                   ###"
Write-Host "###                                                                     ###"
Write-Host "###                                                                     ###"
Write-Host "###########################################################################"
Write-Host "`n`n"

get-service -ComputerName $sysname | Sort-Object status, displayname | Format-Table status, name, displayname
Write-Host "`n###### `nServices with Start State Auto that are NOT running `n###### `n"
Get-WmiObject -ComputerName $sysname win32_Service  | where {$_.StartMode -eq "Auto" -and $_.State -eq "stopped"} |  Sort-Object Name | Format-Table Name,StartMode,State

Write-Host "`n`n"
# List Last x Error Events from Event Log
Write-Host "###########################################################################"
Write-Host "###   Event Log - Checking last $howmanylogs  for Errors                ###"
Write-Host "###   If No Result, no matches in last $howmanylogs                     ###"
Write-Host "###                                                                     ###"
Write-Host "###########################################################################"
Write-Host "`n`n"

try{
$SysEventErr = Get-Eventlog -ComputerName $sysname -Logname system -Newest $howmanylogs
$SysErrorErr = $SysEventErr | Where {$_.entryType -Match "Error"}
$SysErrorErr | Sort-Object EventID |
Format-Table EventID, Source, TimeWritten, Message -auto
# Write-Host "$SysErrorErr"
# Write-Host "$SysEventErr"
}
catch
{
Write-Host "Unable to access Event Log... Check your access level."
}

Write-Host "`n`n"
# List Last x Warning Events from EventLog
Write-Host "###########################################################################"
Write-Host "###   Event Log - Checking last $howmanylogs  for Warnings              ###"
Write-Host "###   If No Result, no matches in last $howmanylogs                     ###"
Write-Host "###                                                                     ###"
Write-Host "###########################################################################"
Write-Host "`n`n"

try{
$SysEventWar = Get-Eventlog -ComputerName $sysname -Logname system -Newest $howmanylogs
$SysErrorWar = $SysEventWar | Where {$_.entryType -Match "Warning"}
$SysErrorWar | Sort-Object EventID |
Format-Table EventID, Source, TimeWritten, Message -auto
}
catch
{
Write-Host "Unable to access Event Log... Check your access level."
}

Write-Host "`n`n"
# List Last x Error Events from Application Log
Write-Host "###########################################################################"
Write-Host "###   Application Log - Checking last $howmanylogs  for Errors          ###"
Write-Host "###   If No Result, no matches in last $howmanylogs                     ###"
Write-Host "###                                                                     ###"
Write-Host "###########################################################################"
Write-Host "`n`n"

try{
$SysEventApp = Get-Eventlog -ComputerName $sysname -Logname Application -Newest $howmanylogs
$SysErrorApp = $SysEventApp | Where {$_.entryType -Match "Error"}
$SysErrorApp | Sort-Object EventID |
Format-Table EventID, Source, TimeWritten, Message -auto
}
catch
{
Write-Host "Unable to access Application Log... Check your access level."
}

Write-Host "`n`n"
# List Last x Warning Events from Application Log
Write-Host "###########################################################################"
Write-Host "###   Application Log - Checking last $howmanylogs  for Warnings        ###"
Write-Host "###   If No Result, no matches in last $howmanylogs                     ###"
Write-Host "###                                                                     ###"
Write-Host "###########################################################################"
Write-Host "`n`n"

try{
$SysEventAppWar = Get-Eventlog -ComputerName $sysname -Logname Application -Newest $howmanylogs
$SysErrorAppWar = $SysEventAppWar | Where {$_.entryType -Match "Warning"}
$SysErrorAppWar | Sort-Object EventID |
Format-Table EventID, Source, TimeWritten, Message -auto
}
catch
{
Write-Host "Unable to access Application Log... Check your access level."
}

Write-Host "`n`n"
# List Last x Error Events from Security Log
Write-Host "###########################################################################"
Write-Host "###   Security Log - Checking last $howmanylogs  for Errors             ###"
Write-Host "###   If No Result, no matches in last $howmanylogs                     ###"
Write-Host "###                                                                     ###"
Write-Host "###########################################################################"
Write-Host "`n`n"

try{
$SysEventSec = Get-Eventlog -ComputerName $sysname -Logname Security -Newest $howmanylogs
$SysErrorSec = $SysEventSec | Where {$_.entryType -Match "Error"}
$SysErrorSec | Sort-Object EventID |
Format-Table EventID, Source, TimeWritten, Message -auto
}
catch
{
Write-Host "Unable to access Security Log... Check your access level."
}

Write-Host "`n`n"
# List Last x Warning Events from Security Log
Write-Host "###########################################################################"
Write-Host "###   Security Log - Checking last $howmanylogs  for Warnings           ###"
Write-Host "###   If No Result, no matches in last $howmanylogs                     ###"
Write-Host "###                                                                     ###"
Write-Host "###########################################################################"
Write-Host "`n`n"

try{
$SysEventSecWar = Get-Eventlog -ComputerName $sysname -Logname Security -Newest $howmanylogs
$SysErrorSecWar = $SysEventSecWar | Where {$_.entryType -Match "Warning"}
$SysErrorSecWar | Sort-Object EventID |
Format-Table EventID, Source, TimeWritten, Message -auto
}
catch
{
Write-Host "Unable to access Security Log... Check your access level."
}

Write-Host "`n`n"
# Disk Information
Write-Host "###########################################################################"
Write-Host "###   Disk Information                                                  ###"
Write-Host "###                                                                     ###"
Write-Host "###                                                                     ###"
Write-Host "###########################################################################" 
Write-Host "`n`n"

# Drive Info
Get-WmiObject win32_DiskDrive -ComputerName $sysname | Select Model,SerialNumber,Description,MediaType,FirmwareRevision

# Call function and list drives
Get-DiskFree -ComputerName $sysname -Format | ft -GroupBy Name -AutoSize

Write-Host "`n`n"
# Network Information
Write-Host "###########################################################################"
Write-Host "###   Network Information                                               ###"
Write-Host "###                                                                     ###"
Write-Host "###                                                                     ###"
Write-Host "###########################################################################"
Write-Host "`n`n"

#Network Adapter Info
Get-WmiObject -Class Win32_NetworkAdapterConfiguration -Filter IPEnabled=TRUE -ComputerName $sysname | Select-Object -Property DHCPEnabled,IPAddress,MACAddress,DefaultIPGateway,DNSDomain,DNSServerSearchOrder,ServiceName,Description,Index

}
ElseIf($PromptUser -eq 8){

$GetName=Read-Host -Prompt ' Enter the computer name you want to add to Active Directory, then after restart run Step 9 '
Rename-Computer -NewName $GetName
$OSWMI=Get-WmiObject -class Win32_OperatingSystem
$OSWMI.Description=$GetName
$OSWMI.put()
-RestartComputer
}

ElseIf($PromptUser -eq 9){
$domain="intra.rakuten.co.jp"
Write-Host ' Now Joining'......... $domain
$password= Read-Host -Prompt 'Enter the password for the domain' | ConvertTo-SecureString -asPlainText -Force
$username="$domain\ls-chris"
$creds=New-Object System.Management.Automation.PSCredential($username,$password)
Add-Computer -DomainName $domain -Credential $creds -restart -force -verbose
}


ElseIf($PromptUser -ge 10  -Or $PromptUser -ne [int]){
 Write-Host " Exiting or Invalid input was made Was Made ......., Now Exiting "
 break
}




}while($PromptUser)

