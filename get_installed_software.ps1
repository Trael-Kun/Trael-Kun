# Lists the software installed on the specified PC and outputs it as a CSV file

# Adapted from https://www.codetwo.com/admins-blog/how-to-check-installed-software-version/
# Adapted by Bill 09/09/2021

# Modified by Bill 10/09/2021; Added coloration to write-host
# Modified by Bill 13/09/2021; Added file check at end of script
#                            ; Added counter

###############################################################################

Write-Host ""

## Set Variables
###############
# Asset No. Input
$Asset = Read-Host -Prompt 'Input PC Name or Asset No.'
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
# Define where output file is stored
$logdir = "c:\temp\logs\"
# Name output file
$logfile  = "$PCname-Installed-Software_$(get-date -format yymmdd_hhmmtt).csv"
# Count installed
$installed = $wmipackages.count

# create log directory
if (Test-Path -Path $logdir){
    Write-Host "Logging to $logdir" -ForegroundColor Green
    }
else {
    New-Item -ItemType "directory" -Path $logdir -Force
    Write-Host "$logdir created"
    Write-Host "Logging to $logdir" -ForegroundColor Green
    }

## Get Data
###########
# Get Install Info
Write-Host "Getting Installed Software for $PCname"

$wmipackages = Get-WMIObject -Class win32_product -ComputerName $PCname | select Name,vendor,Version,Installdate

# Show Results
$wmipackages | Sort-Object -Property Name | Format-table Name, Vendor, Version, Installdate

# Write to log
$wmipackages | Export-Csv -Path "$logdir$logfile"

# Summary
Write-Host "Found $installed installed programs"

# Tell User where log is
if (Test-Path -Path $logdir){
    Write-Host "Logged to " -NoNewline
    Write-Host "$logdir$logfile" -ForegroundColor Green
    }
else {
    Write-Host "Failed to write .csv file" -ForegroundColor Red
    }
# copy this line as well