# Lists the MSI install & update codes (GUIDs) of software installed on the specified PC and outputs it as a CSV file

# Adapted from https://stackoverflow.com/questions/46637094/how-can-i-find-the-upgrade-code-for-an-installed-msi-file/46637095#46637095
# Adapted by Bill 15/07/2021

# Modified by Bill 05/08/2021; Adjusted $PCname input
# Modified by Bill 30/08/2021; Tidied formatting
# Modified by Bill 01/09/2021; added Version & Vendor to report
#                            ; added WKS & LAP recognition to $PCname
# Modified by Bill 13/09/2021; added colouring to log file output notification
#                            ; Added file check at end of script
#                            ; Added counter
# Modified by Bill 14/09/2021; Added opening descriptive
# Modified by Bill 21/10/2021; Added VM & CAF recognition to $PCname (just in case)
#                            ; Added $VERSION

$VERSION="0.4.1"
##########################################################################

Write-Host "`r`n Script to fetch GUIDs of MSI installed programs `r`n" -BackgroundColor DarkYellow
Write-Host "`r`n Version $VERSION `r`n" -BackgroundColor DarkYellow

## Set Variables
###############
# Asset No. Input
$Asset = Read-Host -Prompt 'input target PC Name or WKS Asset No.'
## Set Computer Name
###################
# Add prefix to asset no.
if ($Asset -match '^WKS') {
    $PCname = "$Asset"
    }
elseif ($Asset -match '^LAP') {
    $PCname = "$Asset"
    }
elseif ($Asset -match '^VM') {
    $PCname = "$Asset"
    }
elseif ($Asset -match '^CAF') {
    $PCname = "$Asset"
    }
elseif ($Asset -notmatch '^WKS') {
    $PCname = "WKS$Asset"
    }
# Define where output file is stored
$logdir = "c:\temp\logs\"
# Name output file
$logfile  = "$PCname-MSI-codes_$(get-date -format yymmdd_hhmmtt).csv"


## Get data
##########
# Get Install Info
Write-Host "Getting MSI GUIDs for " -NoNewline
Write-Host "$PCname...`r`n" -ForegroundColor Green
$wmipackages = Get-WmiObject -Class win32_product -ComputerName $PCname

# Select relevant values
$wmiproperties = Get-WMIObject -Query "SELECT ProductCode,Value FROM Win32_Property WHERE Property='UpgradeCode'"

# create log directory
if (Test-Path -Path $logdir){
    Write-Host "Logging to $logdir"
    }
else {
    New-Item -ItemType "directory" -Path $logdir -Force
    Write-Host "$logdir created"
    Write-Host "Logging to $logdir"
    }

# Set Data Table
$packageinfo = New-Object System.Data.Datatable
[void]$packageinfo.Columns.Add("Name")
[void]$packageinfo.Columns.Add("ProductCode")
[void]$packageinfo.Columns.Add("UpgradeCode")
[void]$packageinfo.Columns.Add("Version")
[void]$packageinfo.Columns.Add("Vendor")

# add blanks for no upgrade code
foreach ($package in $wmipackages)    
{
    $foundupgradecode = $false #Assume no upgrade code is found

    foreach ($property in $wmiproperties) {
        
        if ($package.IdentifyingNumber -eq $property.ProductCode) {
           [void]$packageinfo.Rows.Add($package.Name,$package.IdentifyingNumber, $property.Value, $package.Version, $package.Vendor)
           $foundupgradecode = $true
           break
        }
    }
    
    if(-Not ($foundupgradecode)) { 
         # No upgrade code found, add product code to list
         [void]$packageinfo.Rows.Add($package.Name,$package.IdentifyingNumber, "") 
    }
}

# Format Output
$packageinfo | Sort-Object -Property Name | Format-table ProductCode, Name, Vendor, Version, UpgradeCode

# Export to log
$packageinfo | Export-Csv $logdir\$logfile

## Summary
#count
$installed = $wmipackages.Count
Write-Host "Found $installed GUIDs"

# Tell User where log is
if (Test-Path -Path $logdir){
    Write-Host "Logged to " -NoNewline
    Write-Host "$logdir$logfile`r`n" -ForegroundColor Green
    }
else {
    Write-Host "Failed to write .csv file`r`n" -ForegroundColor Red
    }
# copy this line as well