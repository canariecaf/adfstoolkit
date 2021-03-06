﻿function Enable-ADFSTkInstitutionConfiguration {
    [CmdletBinding(SupportsShouldProcess = $true)]
    param(
        [switch]$All
    )

    #Get all config items and set the enabled to false    
    $configItems = Get-ADFSTkConfiguration -ConfigFilesOnly 

    if ($PSBoundParameters.ContainsKey('All') -and $All -ne $false) {
        $selectedConfigFiles = $configItems | ? Enabled -eq 'false'
    }
    else {
        $selectedConfigFiles = $configItems | Out-GridView -Title (Get-ADFSTkLanguageText confSelectInstitutionConfigToEnable) -OutputMode Multiple | ? Enabled -eq 'false'
    }
    
    if ([string]::IsNullOrEmpty($selectedConfigFiles)) {
        Write-ADFSTkHost confNoInstitutionConfigFileSelected
    }
    else {
        foreach ($configItem in $selectedConfigFiles) {
            #Don't update the configuration file if -WhatIf is present
            if ($PSCmdlet.ShouldProcess("ADFSToolkit configuration file", "Save")) {
                try {
                    Set-ADFSTkInstitutionConfiguration -ConfigurationItem $configItem.ConfigFile -Status 'Enabled'
                }
                catch {
                    throw $_
                }
            }
        }
    }
}