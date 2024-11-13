function Get-ADFSTkInstitutionConfigDefaults {
    param (
        [switch]$FederationDefault
    )
    
    if ($PSBoundParameters.ContainsKey('FederationDefault') -and $FederationDefault -ne $false) {
        $mainConfiguration = Get-ADFSTkConfiguration -ForceCreation
        $federationName = $mainConfiguration.Configuration.FederationConfig.Federation.FederationName
        $defaultFederationConfig = $null

        if (![string]::IsNullOrEmpty($federationName)) {
            $defaultFederationConfigDir = Join-Path $Global:ADFSTkPaths.federationDir $federationName
    
            #Check if the federation dir exists and if not, create it
            ADFSTk-TestAndCreateDir -Path $defaultFederationConfigDir -PathName "$federationName config directory"
    
            $allDefaultFederationConfigFiles = Get-ChildItem -Path $defaultFederationConfigDir -Filter "*_defaultConfigFile.xml"
            if ([string]::IsNullOrEmpty($allDefaultFederationConfigFiles)) {
                #No default config files found - Ask if we should download from GIT
                Write-ADFSTkHost -WriteLine -AddSpaceAfter
                Write-ADFSTkHost confCopyFederationDefaultFolderMessage -Style Info -AddSpaceAfter -f $defaultFederationConfigDir
    
                Read-Host (Get-ADFSTkLanguageText cPressEnterKey) | Out-Null
    
                $allDefaultFederationConfigFiles = Get-ChildItem -Path $defaultFederationConfigDir -Filter "*_defaultConfigFile.xml"
            }
    
            if ($allDefaultFederationConfigFiles -eq $null) {
                $defaultFederationConfigFile = $null
            }
            elseif ($allDefaultFederationConfigFiles -is [System.IO.FileSystemInfo]) {
                $defaultFederationConfigFile = $allDefaultFederationConfigFiles.FullName
            }
            elseif ($allDefaultFederationConfigFiles -is [System.Array]) {
                $defaultFederationConfigFile = $allDefaultFederationConfigFiles | Out-GridView -Title (Get-ADFSTkLanguageText confSelectDefaultFedConfigFile) -OutputMode Single | Select -ExpandProperty Fullname
            }
            else {
                #We should never be here...
            }
    
            if (Test-Path $defaultFederationConfigFile) {
                # if (!(Get-ADFSTkAnswer (Get-ADFSTkLanguageText confFederationDefaultConfigNotFoundQuestion -f $federationName) -DefaultYes)) { #Use the ADFSTk default Default Config?!
                #     Write-ADFSTkLog (Get-ADFSTkLanguageText confFederationDefaultConfigNotFound) -MajorFault
                # }
                # else {
                #     #What do we mean by this? = Yes, use the ADFSTk default Default Config - but do we have one?
                # }

                try {
                    [xml]$defaultFederationConfig = Get-Content $defaultFederationConfigFile -ErrorAction Stop
                }
                catch {
                    Write-ADFSTkLog (Get-ADFSTkLanguageText confCouldNotOpenFederationDefaultConfig -f $defaultFederationConfigFile, $_)
                    #Ask to download?
                }
            }
            else {
                Write-ADFSTkLog (Get-ADFSTkLanguageText confFederationDefaultConfigNotFound -f $defaultFederationConfigFile) #New text
                #Ask to download?
            }
        }

        return $defaultFederationConfig
    }
    else {
        $defaultConfigFile = $Global:ADFSTkPaths.defaultConfigFile

        if (Test-Path $defaultConfigFile) {
            #Try to open default config
            try {
                [xml]$defaultConfig = Get-Content $defaultConfigFile -ErrorAction Stop
                return $defaultConfig
            }
            catch {
                Write-ADFSTkLog (Get-ADFSTkLanguageText confCouldNotOpenDefaultConfig -f $defaultConfigFile, $_) -MajorFault
            }
        }
        else {
            Write-ADFSTkLog (Get-ADFSTkLanguageText confDefaultConfigNotFound) -MajorFault #CHeck text!
        }
    }
}