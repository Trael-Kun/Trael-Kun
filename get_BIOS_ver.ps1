﻿#Checks the BIOS version of the specified PC and outputs it as a CSV file

# Adapted from https://www.reddit.com/r/PowerShell/comments/68vucx/trying_to_get_bios_version_and_model_for_all/dh207af?utm_source=share&utm_medium=web2x&context=3
# Adapted by Bill 05/08/2021
#
# Modified by Bill 13/09/2021; added log file check to end of script
#                            ; added WKS & LAP recognition to $PCname
#                            ; changed logfile name formatting 
#                            ; added opening descriptor
# Modified by Bill 22/10/2021; added Latitude 5410
#                            ; fixed looping issue (changed from until to while)
#                            ; formatting changes
# Modified by Bill 25/10/2021; removed individual model number/BIOS Ver checks to reduce  overall script size (by a lot)

#####################################################

Write-Host "`r`n Script to check BIOS version " -BackgroundColor DarkYellow

# Asset No. Input
$Asset = Read-Host -Prompt "`r`ninput PC Name or Asset No."

## Set Variables
 $IsCurrent = 0 
# Set where output file is stored (be sure to end with "\")
$logdir = "C:\Temp\Logs\"
# Enter current BIOS versions
 $HP = 'L01 v02.78'
 $Opti7040 = '1.20.2'
 $Opti7060 = '1.14.0'
 $Opti7070 = '1.9.1'
 $Opti7080 = '1.5.1'
 $Lat5400 = '1.12.0'
 $Lat5410 = '1.7.0'
 $LatE5470 = '1.27.3'
 $Prec5820T = '2.11.0'
 $PrecisionT5810 = 'A34'
 $PrecisionT7910 = 'A34'
 $PrecisionT7920 = '2.15.0'

## Set Computer Name
###################
# Add prefix to asset no.
if ($Asset -match '^WKS') {
    $PCname = "$Asset"
    }
elseif ($Asset -match '^LAP') {
    $PCname = "$Asset"
    }
elseif ($Asset -notmatch '^WKS') {
    $PCname = "WKS$Asset"
    }

# Set name of output file
$logfile  = "$PCname-BIOSver_$(get-date -format yymmdd_hhmmtt).csv"

## Create $logdir
New-Item -ItemType "directory" -Path $logdir -Force

Do {
# Find Data
$PCname | foreach {


    # Get workstation details
    $cs = Get-WmiObject -ClassName Win32_ComputerSystem -ComputerName $PCname
  
    # Get BIOS deatails
    $bios = Get-WmiObject -ClassName Win32_BIOS -ComputerName $PCname


    # Set model BIOS version
    if ($cs.Model -eq 'HP EliteDesk 800 G1 SFF') {
        $CurrentVer = $HP
    }
    elseif ($cs.Model -eq 'Latitude 5400') {
            $CurrentVer = $Lat5400
    }   
    elseif ($cs.Model -eq 'Latitude 5410') {
            $CurrentVer = $Lat5410    
    }
    elseif ($cs.Model -eq 'Latitude E5470') {
        $CurrentVer = $LatE5470       
    }
    elseif ($cs.Model -eq 'OptiPlex 7040') {
        $CurrentVer = $Opti7040
    }
    elseif ($cs.Model -eq 'OptiPlex 7060') {
        $CurrentVer = $Opti7060

    }
    elseif ($cs.Model -eq 'OptiPlex 7070') {
        $CurrentVer = $Opti7070
    }
    elseif ($cs.Model -eq 'OptiPlex 7080') {
            $CurrentVer = $Opti7080
    }
    elseif ($cs.Model -eq 'Precision 5820 Tower') {
        $CurrentVer = $Prec5820T
    }

    elseif ($cs.Model -eq 'Precision Tower 5810') {
            $CurrentVer = $PrecisionT5810
    }
    elseif ($cs.Model -eq 'Precision Tower 7910') {
        $CurrentVer = $PrecisionT7910
    } 
    elseif ($cs.Model -eq 'Precision Tower 7920') {
        $CurrentVer = $PrecisionT7920
    } 
    else {
        $CurrentVer = 'Unknown'
    }

# Check BIOS Version
  if ($bios.SMBIOSBIOSVersion -eq $CurrentVer) {
      $IsCurrent = 'Current'
      }
      else {
      $IsCurrent = 'Outdated'
      }

    # Put data in order
    $properties = [ordered]@{
        'Timestamp' = (get-date -format yyyy/mm/dd-hh:mm:tt)
        'Workstation' = $cs.Name;
        'Manufacturer' = $cs.Manufacturer;
        'Model' = $cs.Model;
        'InstalledVer' = $bios.SMBIOSBIOSVersion;
        'LatestVer' = $CurrentVer
        'Status' = $IsCurrent
    }

    # Put data in table
    $obj = New-Object -TypeName PSObject -Property $properties
    $obj
}

# Add data to $logdir
$obj | Export-CSV -Path $logdir$logfile -NoTypeInformation -Append

# Display Data in human-friendly format
$obj | Sort-Object -Property Workstation | Format-table Workstation, Manufacturer, Model, InstalledVer, Latestver, Status

}
# Close loop
while ($IsCurrent -eq '0')

# Tell User where log is, or tell them it's failed
if (Test-Path -Path $logdir){
    Write-Host "Logged to " -NoNewline
    Write-Host "$logdir$logfile" -ForegroundColor Green
    }
else {
    Write-Host "Failed to write .csv file" -ForegroundColor Red
    }
# End of script