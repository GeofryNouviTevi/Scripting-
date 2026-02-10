if (-not $PSScriptRoot) {
    Write-Error "Impossible de déterminer l'emplacement du script"
    exit 1
}

$ResultPath = Join-Path $PSScriptRoot "RESULTS"

if (-not (Test-Path $ResultPath)) {
    New-Item -ItemType Directory -Path $ResultPath -Force | Out-Null
}

# ================== PATHS ==================
$OutFile = Join-Path $ResultPath "Etat_Info.txt"
$LogFile = Join-Path $ResultPath "forensic.log"

Start-Transcript -Path $LogFile -Append | Out-Null
function Write-Section($title) {
    Add-Content $OutFile "`n==== $title ===="
}
# ================== HEADER ==================
@"
===============================
FORENSIC NETWORK SNAPSHOT
Date        : $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")
Computer    : $env:COMPUTERNAME
User        : $env:USERNAME
Domain      : $env:USERDOMAIN
===============================
"@ | Out-File $OutFile -Encoding utf8


# ================== SYSTEM ==================
Write-Section "System Information"
# Marque et mod le
Get-CimInstance Win32_ComputerSystem | Select-Object Manufacturer, Model| Format-List |
Out-File -Append $OutFile -Encoding utf8
# version
Get-CimInstance Win32_OperatingSystem |
Select Caption, Version, OSArchitecture, LastBootUpTime | Format-List |
Out-File -Append $OutFile -Encoding utf8

# RAM totale (simplifi )
Get-CimInstance Win32_ComputerSystem | Select-Object TotalPhysicalMemory| Format-List |
Out-File -Append $OutFile -Encoding utf8
#CPU
Get-CimInstance Win32_Processor | Select-Object Name, NumberOfCores, NumberOfLogicalProcessors, MaxClockSpeed | Format-List |
Out-File -Append $OutFile -Encoding utf8

# ================  =================
Write-Section "Memoire / Processeurs "


# ===================== DISQUE ================
Write-Section "Disque "
# Disques physiques
Get-CimInstance Win32_DiskDrive | Select-Object Model, Size, MediaType | Format-List |
Out-File -Append $OutFile -Encoding utf8

# Partitions logiques
Get-CimInstance Win32_LogicalDisk | Select-Object DeviceID, FileSystem, Size, FreeSpace | Format-List |
Out-File -Append $OutFile -Encoding utf8

# Pour Windows 10/11 modernes, on peut aussi utiliser Storage module :
Get-PhysicalDisk | Select FriendlyName, MediaType, Size | Format-List |
Out-File -Append $OutFile -Encoding utf8


# ================== USERS ==================
Write-Section "Local Users"
Get-LocalUser |
Select Name, Enabled, LastLogon |
Out-File -Append $OutFile -Encoding utf8

# ================== DEFENDER ==================
Write-Section "Windows Defender"
Get-MpComputerStatus |
Select AMServiceEnabled, RealTimeProtectionEnabled |
Out-File -Append $OutFile -Encoding utf8

 # ==== Profil rÃ©seau =====

Write-Section "NETWORK PROFILE" 
Get-NetConnectionProfile | Select Name, NetworkCategory, IPv4Connectivity | 
Format-Table -AutoSize | 
Out-File -Append $OutFile -Encoding utf8

# ================== NETWORK ==================

Write-Section "NETWORK Interfaces" 
$ForensicData = [ordered]@{}
 $ForensicData.Interfaces = Get-NetIPConfiguration | ForEach-Object {
    [PSCustomObject]@{
        Interface  = $_.InterfaceAlias
        IPv4       = $_.IPv4Address.IPAddress
        IPv6       = $_.IPv6Address.IPAddress
        Gateway    = $_.IPv4DefaultGateway.NextHop
        DNS        =  ($_.DNSServer.ServerAddresses -join ", ")
        MAC        = $_.NetAdapter.MacAddress
        Status     = $_.NetAdapter.Status
    }
} | Format-Table -AutoSize | Out-File -Append $OutFile -Encoding utf8

#  ---- DHCP ----- 
 Write-Section "DHCP CONFIGURATION" 
Get-NetIPInterface | select InterfaceAlias , Dhcp | Format-Table | Out-File -Append $OutFile -Encoding utf8

# route comment crÃ©Ã© un tunel de connexion entre deux machine  (via powerShell )
 Write-Section "Routing Table" 
Get-NetRoute -DestinationPrefix "0.0.0.0/0" | Format-Table | Out-File -Append $OutFile -Encoding utf8

# A quoi peut servir l'information des connections active sur une machine
Write-Section  "Active Network Connections" 
Get-NetTCPConnection -State Established | Select LocalAddress, LocalPort, RemoteAddress, 
    RemotePort,  OwningProcess | Format-Table | Out-File -Append $OutFile -Encoding utf8

Write-Section "Dection de tunel" 
Get-NetRoute |  Where-Object {
        $_.DestinationPrefix -notmatch "0.0.0.0|127.0.0.0"
    } |  Out-File -Append $OutFile -Encoding utf8

# ================== VPN ==================
Write-Section "VPN / Tunnel Detection"
Get-NetAdapter |
Where-Object { $_.InterfaceDescription -match "VPN|TUN|TAP|WireGuard|Virtual" } |
Select Name, InterfaceDescription, Status |
Out-File -Append $OutFile -Encoding utf8

Stop-Transcript
