function doOption {
    param ([string] $option) 
    switch($option) {
        "H" { 
            $sys = Get-CimInstance -ClassName Win32_ComputerSystem #Basic system info 
            $cpu = Get-CimInstance -ClassName Win32_Processor #CPU info 
            $mem = Get-CimInstance -ClassName Win32_PhysicalMemory #Memory info
            $disk = Get-CimInstance -ClassName Win32_DiskDrive #Disk info
            return "$sys`n$cpu`n$mem`n$disk" }  
        "S" { return Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* | Select-Object DisplayName, DisplayVersion, Publisher, InstallDate }  #software
        "A" { return Get-MpComputerStatus} #antivirus status
        "F" { return Get-NetFirewallProfile } #firewall status 
        "C" {
            $cpu = Get-WmiObject Win32_Processor | Measure-Object -Property LoadPercentage -Average | Select-Object Average  
            $cpuCap = Get-CimInstance -ClassName Win32_Processor | Select-Object Name, NumberOfCores, MaxClockSpeed
            #$cpu = Get-Counter "\Processor(_Total)\% Processor Time" #cpu usage 
            $ram = Get-CimInstance -ClassName Win32_OperatingSystem | Select-Object TotalVisibleMemorySize, FreePhysicalMemory #ram usage 
            $disk = Get-CimInstance -ClassName Win32_LogicalDisk -Filter "DriveType=3" | Select-Object DeviceID, Size, FreeSpace #disk usage 
            return "$cpu; $cpuCap`n$ram`n$disk" }  
        "E" { return Get-WinEvent -LogName System -MaxEvents 20 | Where-Object {$_.LevelDisplayName -in "Error", "Warning"} } 
        "U" { 
            $user = Get-LocalUser 
            $group = Get-LocalGroup 
            $mem = Get-LocalGroupMember -Group "Administrators" 
            return "$user`n$group`n$mem" } 
        "S" { return Get-SmbShare }  
        "P" { return Get-Printer } 
        "N" { return Get-NetAdapter } 


} 
}
Write-Output("Welcome to the System Information Center. Choose an option by pressing a letter or choose multiple options by putting a comma between each option (Ex: A,B).`n")
$userInput = Read-Host "Menu:`nH: Basic System/Hardware Info`nS: Software Info`nA: AV Status`nF: Firewall Status`nC: Current Memory Info`nE: Last 20 Event Logs`nU: User/Group Info`nS: Shared Folders`nP: Printer Info`nN: Network Info`nInsert Option(s)"
# Split the input into an array
$options = $userInput.Split(",")

# Trim any whitespace from each option
$options = $options.Trim() 
foreach($choice in $options) {
    Write-Output (doOption -option $choice) 
    Write-Output ("`n")
}