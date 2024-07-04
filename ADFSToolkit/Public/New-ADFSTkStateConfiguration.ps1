function New-ADFSTkStateConfiguration {
    [CmdletBinding(SupportsShouldProcess = $true)]
    param(
        [switch]$Passthru
    )

    if (Test-Path $Global:ADFSTKPaths.stateConfigFile) {
        Write-ADFSTkLog -Message (Get-ADFSTkLanguageText stateconfConfigFileExists) -EntryType Warning
        
        if (Get-ADFSTkAnswer (Get-ADFSTkLanguageText stateconfDoCreateConfigFile) -Caption (Get-ADFSTkLanguageText cFileAlreadyExists)) {
            $file = Get-ChildItem $Global:ADFSTKPaths.stateConfigFile
            $backupFilename = "{0}_backup_{1}{2}" -f $file.BaseName, (Get-Date).tostring("yyyyMMdd_HHmmss"), $file.Extension

            $backupFile = Move-Item -Path $Global:ADFSTKPaths.stateConfigFile -Destination (Join-Path $Global:ADFSTKPaths.mainBackupDir $backupFilename) -PassThru
            
            Write-ADFSTkHost stateconfOldConfigBackedUp -f $backupFile.FullName -Style Value
        }
        else {
            Write-ADFSTkLog (Get-ADFSTkLanguageText stateconfAbortDueToExistingConfFile) -MajorFault
        }
    }

    #region Main config

    [xml]$config = New-Object System.Xml.XmlDocument
    $config.AppendChild($config.CreateXmlDeclaration("1.0", "UTF-8", $null)) | Out-Null
        
    $configurationNode = $config.CreateNode("element", "Configuration", $null)
        
    $configVersionNode = $config.CreateNode("element", "ConfigVersion", $null)
    $configVersionNode.InnerText = $Global:ADFSTkCompatibleStateConfigVersion

    $configurationNode.AppendChild($configVersionNode) | Out-Null

    $FticksNode = $config.CreateNode("element", "Fticks", $null)
    $LastRecordIdNode = $config.CreateNode("element", "LastRecordId", $null)
    $FticksNode.AppendChild($LastRecordIdNode) | Out-Null

    $configurationNode.AppendChild($FticksNode) | Out-Null

    $config.AppendChild($configurationNode) | Out-Null
    #endregion 

    #Don't save the configuration file if -WhatIf is present
    if ($PSCmdlet.ShouldProcess($Global:ADFSTKPaths.stateConfigFile, "Create")) {
        try {
            $config.Save($Global:ADFSTKPaths.stateConfigFile)
            Write-ADFSTkLog (Get-ADFSTkLanguageText stateconfNewConfFileCreated -f $Global:ADFSTKPaths.stateConfigFile) -ForegroundColor Green
        }
        catch {
            throw $_
        }
    }

    if ($PSBoundParameters.ContainsKey('Passthru')) {
        return $config.configuration
    }
}