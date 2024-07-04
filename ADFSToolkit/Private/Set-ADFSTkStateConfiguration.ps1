function Set-ADFSTkStateConfiguration {
    [CmdletBinding(SupportsShouldProcess = $true)]
    param (
        [Parameter(ParameterSetName = "f-ticks")]
        $FticksLastRecordId
    )

    if (!(Test-Path $Global:ADFSTKPaths.stateConfigFile)) {
        Write-ADFSTkVerboseLog (Get-ADFSTkLanguageText stateconfNewConfFileMissing)
        New-ADFSTkStateConfiguration
    }
    
    try {
        [xml]$config = Get-Content $Global:ADFSTKPaths.stateConfigFile
    }
    catch {
        Write-ADFSTkLog (Get-ADFSTkLanguageText stateconfCouldNotParseConfigFile -f $_) -MajorFault
    }

    #FticksLastRecordId
    if ($PSBoundParameters.ContainsKey('FticksLastRecordId')) {
        if ($config.Configuration.Fticks.LastRecordId -eq $null) {
            Add-ADFSTkXML -NodeName "LastRecordId" -XPathParentNode "Configuration/Fticks" -Value $FticksLastRecordId
        }
        else {
            $OutpuLanguageNode = Select-Xml -Xml $config -XPath "Configuration/Fticks/LastRecordId"
            $OutpuLanguageNode.Node.innerText = $FticksLastRecordId
        }
    }

    #Save the configuration file
    #Don't save the configuration file if -WhatIf is present
    if ($PSCmdlet.ShouldProcess($Global:ADFSTkPaths.stateConfigFile, "Save")) {
        try {
            $config.Save($Global:ADFSTkPaths.stateConfigFile)
            Write-ADFSTkVerboseLog (Get-ADFSTkLanguageText mainconfConfigItemAdded)
            $Global:ADFSTkConfiguration = Get-ADFSTkConfiguration
        }
        catch {
            throw $_
        }
    }
}