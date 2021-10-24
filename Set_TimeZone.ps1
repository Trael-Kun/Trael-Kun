#Set Timezone by IP for NAA Public Networks
#compiled by Bill


#set timezone variables
$AEST = "AUS Eastern Standard Time"
$TAS = "Tasmania Standard Time"
$DAR = "AUS Central Standard Time"
$ADE = "Cen. Australia Standard Time"
$PER = "W. Australia Standard Time"
$BRIS = "E. Australia Standard Time"
$UTC = "UTC"

##set IP variables
#WA (Northbridge) IP
$PerIP1 = "101.187.154.75"
#WA () IP
$PerIP2 = ""
#Hobart IP
$TasIP = ''
#Darwin IP
$DarIP = ''
#QLD (Cannon Hill) IP
$BrisIP = "120.151.22.78"
#SA (Adelaide) IP
$AdeIP = ''
#ACT (Mitchell) IP
$CbrIP1 = "149.135.98.246"
#ACT (Parkes) IP
$CbrIP2 = "139.130.186.214"
#NSW (Chester Hill) IP
$SydIP = "144.139.103.31"
#VIC (North Melbourne) IP
$VicIP1 = ''
#VIC (East Burwood) IP
$VicIP2 = ''

#find web IP
$IP = (Invoke-WebRequest -uri "http://ifconfig.me/ip").Content


    if ($IP.IPv4Address -eq $PerIP1) {
        Set-TimeZone -Name $PER
    }
    ifelse ($IP.IPv4Address -eq $PerIP2) {
        Set-TimeZone -Name $PER
    }
    ifelse ($IP.IPv4Address -eq $TasIP) {
        Set-TimeZone -Name $TAS
    }
    ifelse ($IP.IPv4Address -eq $DarIP) {
        Set-TimeZone -Name $DAR
    }
    ifelse ($IP.IPv4Address -eq $BrisIP) {
        Set-TimeZone -Name $Bris
    }
    ifelse ($IP.IPv4Address -eq $AdeIP) {
        Set-TimeZone -Name $ADE
    }
    ifelse ($IP.IPv4Address -eq $CbrIP1) {
        Set-TimeZone -Name $AEST
    }
    ifelse ($IP.IPv4Address -eq $CbrIP2) {
        Set-TimeZone -Name $AEST
    }
    ifelse ($IP.IPv4Address -eq $SydIP) {
        Set-TimeZone -Name $AEST
    }
    ifelse ($IP.IPv4Address -eq $VicIP1) {
        Set-TimeZone -Name $AEST
    }
    ifelse ($IP.IPv4Address -eq $VicIP2) {
        Set-TimeZone -Name $AEST
    }
    else {
        Set-TimeZone -Name "UTC"
    }

