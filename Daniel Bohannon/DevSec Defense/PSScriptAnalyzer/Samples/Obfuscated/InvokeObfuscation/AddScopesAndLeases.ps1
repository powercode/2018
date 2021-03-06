param(
    [parameter(maNdAtORY=$false,POSiTIoN=0)]
    [ValidateRange(1,256)] 
    [Int] 
    $TotalScopeCount = 10,
    
    [parameter(mANdAtorY=$false,PoSiTIon=1)]
    [ValidateRange(0,254)] 
    [Int] 
    $LeasesUnderEachScope = 10,
    
    [parameter(mandATORY=$false,PosITIon=2)]
    [String] 
    $ComputerName = "localhost"
)

# Function for adding a V4 Scope
Function AddV4Scope($ScopeParam)
{
    <#
    # Adding the Scope
    #>
    $OutObj = $null
    $myEV = $null
    try {
        $OutObj = Add-DhcpServerv4Scope @ScopeParam -EV myEV -PassThru
    } catch [Exception] {
        Write-Warning "Unexpected TE encountered while calling Add-DhcpServerv4Scope Cmdlet"
        return $false
    }
    if(($null -ne $myEV) -and ($myEV."coU`NT" -gt 0))
    {
        Write-Warning "Unexpected NTE encountered while calling Add-DhcpServerv4Scope Cmdlet"
    }
    
    $ScopeId = $OutObj."s`copeId"
    Write-Verbose "Scope $ScopeId added successfully"

    return $true
}


# Function for adding a V4 Lease
Function AddV4Lease($LeaseParam)
{
    <#
    # Adding the Lease
    #>
    
    $OutObj = $null
    $myEV = $null
    try {
        $OutObj = Add-DhcpServerv4Lease @LeaseParam -EV myEV
    } catch [Exception] {
        Write-Warning "Unexpected TE encountered while calling Add-DhcpServerv4Lease Cmdlet"
        return $false
    }
    if(($null -ne $myEV) -and ($myEV."COu`NT" -gt 0))
    {
        Write-Warning "Unexpected NTE encountered while calling Add-DhcpServerv4Lease Cmdlet"
    }
    
    $LeaseIp = $LeaseParam."i`PaDdRe`ss"
    Write-Verbose "IP address lease $LeaseIp added successfully"
    
    return $true
}

Function AddV4ScopesWithLeases($TotalScopeCount, $LeasesUnderEachScope, $ComputerName)
{
    # Add all the Scopes
    $ScopeCount = 0
    $Row = 2
    for ($i = 0; $i -le 255 -and $ScopeCount -lt $TotalScopeCount; ++$i)
    {
        $v4ScopeParam = @{}
        $v4ScopeParam."nA`mE" = $("Scope$i")
        $v4ScopeParam."s`Tar`T`RangE" = $("10.$i.0.1")
        $v4ScopeParam."EN`DRAN`gE" = $("10.$i.0.254")
        $v4ScopeParam."s`UBnEtMA`sk" = "255.255.255.0"
        $v4ScopeParam."Co`MP`utERnaME" = $ComputerName
        $v4ScopeParam."L`E`AsedUR`AtIOn" = "15.0:0"
        
        $Result = $false
        $Result = AddV4Scope $v4ScopeParam
        if ($false -eq $Result)
        {
            Write-Warning "Addition of Scope failed"
            return
        }
        ++$ScopeCount

        # Now add leases under this scope
        $LeaseCount = 0
            
        for ($j = 1; $j -le 254 -and $LeaseCount -lt $LeasesUnderEachScope; ++$j)
        {          
            $v4LeaseParam = @{}
            $v4LeaseParam."IpADd`RE`sS" = $("10.$i.0.$j")
            $v4LeaseParam."sc`opeID" = $("10.$i.0.0")
            $temp1 = [Convert]::("{2}{0}{1}" -f'oS','tring','T').Invoke($i, 16)
            if (1 -eq $temp1."LE`NG`TH")
            {
                $temp1 = "0" + $temp1
            }
            $temp2 = [Convert]::("{2}{0}{1}" -f 'tri','ng','ToS').Invoke($j, 16)
            if (1 -eq $temp2."l`e`NGTh")
            {
                $temp2 = "0" + $temp2
            }
            $v4LeaseParam."c`lI`eNTiD" = $("A1-A2-A3-A4-$temp1-$temp2")
            $v4LeaseParam."h`OStn`AmE" = $("Host-$temp1-$temp2.contoso.com")
            $v4LeaseParam."C`O`mPUtErNA`me" = $ComputerName
            $Result = $false
            $Result = AddV4Lease $v4LeaseParam
            
            if ($false -eq $Result)
            {
                Write-Warning "Addition of Lease for following IPAddress failed:"
                Write-Warning $v4LeaseParam."I`paDdRESs"
                return
            }
                           
            ++$LeaseCount
        }
    }
    Write-Host "DHCP scopes added successfully"
}

AddV4ScopesWithLeases -TotalScopeCount $TotalScopeCount -LeasesUnderEachScope $LeasesUnderEachScope -ComputerName $ComputerName
