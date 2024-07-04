function Update-ADFSTkConfiguration {
    [CmdletBinding(SupportsShouldProcess = $true)]
    param(
        [xml]$defaultADFSTkFederationConfig,
        [xml]$defaultConfig
    )

    $mainConfiguration = Get-ADFSTkConfiguration -ForceCreation
    
    $result = $null

    if ($mainConfiguration.configuration.ConfigVersion -eq $Global:ADFSTkCompatibleADFSTkConfigVersion) {
        Write-ADFSTkLog (Get-ADFSTkLanguageText confInstConfAlreadyCorrectVersion -f 'ADFS Toolkit Config file', $Global:ADFSTkCompatibleADFSTkConfigVersion) -EntryType Information
    }
    else {

        #First take a backup of the current file
        if (!(Test-Path $Global:ADFSTkPaths.mainBackupDir)) {
            Write-ADFSTkVerboseLog -Message (Get-ADFSTkLanguageText cFileDontExist -f $Global:ADFSTkPaths.mainBackupDir)
            New-Item -ItemType Directory -Path $Global:ADFSTkPaths.mainBackupDir | Out-Null
            Write-ADFSTkVerboseLog -Message (Get-ADFSTkLanguageText cCreated)
        }

        $mainConfigurationFile = $Global:ADFSTkPaths.mainConfigFile
        if (Test-Path $mainConfigurationFile) {
            $backupFilename = "{0}_backup_v{3}_{1}{2}" -f $mainConfigurationFile.BaseName, (Get-Date).tostring("yyyyMMdd_HHmmss"), $mainConfigurationFile.Extension, $mainConfiguration.Configuration.ConfigVersion
            $backupFile = Join-Path $Global:ADFSTkPaths.mainBackupDir $backupFilename
            Copy-Item -Path $mainConfigurationFile -Destination $backupFile | Out-Null
    
            Write-ADFSTkLog (Get-ADFSTkLanguageText confOldConfBackedUpTo -f $backupFile) -ForegroundColor Green
        }

        $startVersion = $mainConfiguration.Configuration.ConfigVersion
        ###Now lets upgrade in steps!###
                
        #v1.0 --> v1.1
        $currentVersion = '1.0'
        $newVersion = '1.1'
        if ($mainConfiguration.Configuration.ConfigVersion -eq $currentVersion) {
            Write-ADFSTkVerboseLog (Get-ADFSTkLanguageText confUpdatingADFSTkConfigFromTo -f $currentVersion, $newVersion)
                    
            Add-ADFSTkXML -XML $mainConfiguration -XPathParentNode "Configuration" -RefNodeName "ConfigVersion" -NodeName "ModuleVersion" 
            $mainConfiguration.Configuration.ModuleVersion = "2.3.0"
            $mainConfiguration.Configuration.ConfigVersion = $newVersion

            $fticksInstalled = $false
            if (![string]::IsNullOrEmpty($defaultADFSTkFederationConfig) -and ![string]::IsNullOrEmpty($defaultADFSTkFederationConfig.Configuration.Fticks)) {
                $xmlNode = $defaultADFSTkFederationConfig.Configuration.Fticks
                Add-ADFSTkXMLNode -Xml $mainConfiguration -XPathParentNode 'Configuration' -Node $xmlNode
            
                #Add-ADFSTkXML -XML $mainConfiguration -XPathParentNode "Configuration/Fticks" -NodeName "LastRecordId"
                $mainConfiguration.Save($mainConfigurationFile);

                if ([string]::IsNullOrEmpty($xmlNode.Server)) {
                    if (Get-ADFSTkAnswer -Message (Get-ADFSTkLanguageText confRegisterFticks)) {
                        #Register Fticks info
                        $FticksServer = Read-Host  (Get-ADFSTkLanguageText fticksServerNameNeeded)
                        Set-ADFSTkFticksServer -Server $FticksServer
                        $fticksInstalled = $true
                    }
                }
                else {
                    $FticksServer = $xmlNode.Server
                    Set-ADFSTkFticksServer -Server $FticksServer
                    $fticksInstalled = $true
                }
            }
            else {
                Add-ADFSTkXML -XML $mainConfiguration -XPathParentNode "Configuration" -RefNodeName "OutputLanguage" -NodeName "Fticks" 
                Add-ADFSTkXML -XML $mainConfiguration -XPathParentNode "Configuration/Fticks" -NodeName "Server"
                Add-ADFSTkXML -XML $mainConfiguration -XPathParentNode "Configuration/Fticks" -NodeName "Salt"
                $mainConfiguration.Save($mainConfigurationFile);

                if (Get-ADFSTkAnswer -Message (Get-ADFSTkLanguageText confRegisterFticks)) {
                    #Register Fticks info
                    $FticksServer = Read-Host  (Get-ADFSTkLanguageText fticksServerNameNeeded)
                    Set-ADFSTkFticksServer -Server $FticksServer
                    $fticksInstalled = $true
                }
            }
            
            #Register the Scheduled Task for F-Ticks
            if ($fticksInstalled) {
                if (Get-ADFSTkAnswer -Message (Get-ADFSTkLanguageText confRegisterFticksScheduledTask)) {
                    Register-ADFSTkFTicksScheduledTask
                }
                Write-ADFSTkHost confFticksRegisterOnAllServers -f $FticksServer -foregroundcolor Yellow -AddLinesOverAndUnder
            }
            
            $result = $true #We did an upgrade
        }

        Write-ADFSTkLog (Get-ADFSTkLanguageText confUpdatedInstConfigDone -f "ADFS Toolkit Config", $startVersion, $newVersion) -EntryType Information
    }
    return $result
}