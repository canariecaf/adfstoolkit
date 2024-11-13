function Update-ADFSTk {

    #region Import ADFSTk Config
    Write-ADFSTkHost confProcessingADFSTkConfigs -AddLinesOverAndUnder -Style Info
    $continue = $true

    $mainConfiguration = Get-ADFSTkConfiguration -ForceCreation

    #Check version
    if ([string]::IsNullOrEmpty($mainConfiguration.Configuration.ConfigVersion)) {
        Write-ADFSTkLog (Get-ADFSTkLanguageText confCouldNotRetrieveVersion) -EntryType Error -MajorFault
        $continue = $false
    }
    elseif ($mainConfiguration.Configuration.ConfigVersion -eq $Global:ADFSTkCompatibleADFSTkConfigVersion) {
        Write-ADFSTkLog (Get-ADFSTkLanguageText confInstConfAlreadyCorrectVersion -f 'ADFS Toolkit Config file', $Global:ADFSTkCompatibleADFSTkConfigVersion) -EntryType Information
        $continue = $false
    }
    #endregion

    #region Import Main Federation Defaults
    $defaultMainFederationConfig = Get-ADFSTkConfigurationDefaults -FederationDefault
    if (![string]::IsNullOrEmpty($defaultMainFederationConfig) -and ![string]::IsNullOrEmpty($defaultMainFederationConfig.Configuration.ConfigVersion)) {
        if ($defaultMainFederationConfig.Configuration.ConfigVersion -ne $Global:ADFSTkCompatibleADFSTkConfigVersion) {
            #Try to locate the URL for the default config file
            if (![string]::IsNullOrEmpty($mainConfiguration.Configuration.FederationConfig.Federation.URL)) {
                if (Get-ADFSTkAnswer (Get-ADFSTkLanguageText confDownloadDefaultFederationConfig -f $mainConfiguration.Configuration.FederationConfig.Federation.URL) -DefaultYes) {
                    Get-ADFSTkFederationDefaults -URL $mainConfiguration.Configuration.FederationConfig.Federation.URL -InstallDefaults
                    $FederationDefaultsUpdated = $true
                }
                else {
                    $defaultMainFederationConfig = $null
                    if (Get-ADFSTkAnswer (Get-ADFSTkLanguageText confContinueWithoutDefaultFederationConfig) -DefaultYes) {
                        Write-ADFSTkLog (Get-ADFSTkLanguageText confContinueWithoutFederationConfig)
                    }
                    else {
                        Write-ADFSTkLog (Get-ADFSTkLanguageText confAbortDueToIncorrectFederationConfigVersion) -MajorFault
                    }
                }
            }
            else {
                if (Get-ADFSTkAnswer (Get-ADFSTkLanguageText confIncompatobleDefaultFederationConfig) -DefaultYes) {
                    Get-ADFSTkFederationDefaults -InstallDefaults
                    $FederationDefaultsUpdated = $true
                }
                else {
                    $defaultMainFederationConfig = $null
                    if (Get-ADFSTkAnswer (Get-ADFSTkLanguageText confContinueWithoutDefaultFederationConfig) -DefaultYes) {
                        Write-ADFSTkLog (Get-ADFSTkLanguageText confContinueWithoutFederationConfig)
                    }
                    else {
                        Write-ADFSTkLog (Get-ADFSTkLanguageText confAbortDueToIncorrectFederationConfigVersion) -MajorFault
                    }
                }
            }

            #Check the version again
            if ($FederationDefaultsUpdated) {
                $defaultMainFederationConfig = Get-ADFSTkConfigurationDefaults -FederationDefault
                if ($defaultMainFederationConfig.configuration.ConfigVersion -ne $Global:ADFSTkCompatibleInstitutionConfigVersion) {
                    if (Get-ADFSTkAnswer (Get-ADFSTkLanguageText confDownloadedDefaultFederationConfigIncompatible) -DefaultYes) {
                        $defaultMainFederationConfig = $null
                        Write-ADFSTkLog (Get-ADFSTkLanguageText confContinueWithoutFederationConfig)
                    }
                    else {
                        Write-ADFSTkLog (Get-ADFSTkLanguageText confNotAValidVersionError -f $defaultMainFederationConfig.configuration.ConfigVersion, $Global:ADFSTkCompatibleInstitutionConfigVersion) -MajorFault
                    }    
                }
            }
        }
    }
    else {
        $defaultMainFederationConfig = $null
        Write-ADFSTkLog (Get-ADFSTkLanguageText confContinueWithoutFederationConfig)
    }
    #endregion

    #region Update ADFSTk Config
    if ($continue) {
        $result = Update-ADFSTkConfiguration -defaultADFSTkFederationConfig $defaultMainFederationConfig
    }
    #endregion

    #region Import Institution Federation Defaults
    $defaultConfig = Get-ADFSTkInstitutionConfigDefaults
    $defaultFederationConfig = Get-ADFSTkInstitutionConfigDefaults -FederationDefault
    $FederationDefaultsUpdated = $false
    if (![string]::IsNullOrEmpty($defaultFederationConfig) -and ![string]::IsNullOrEmpty($defaultFederationConfig.configuration.ConfigVersion -and !$FederationDefaultsUpdated)) {
        if ($defaultFederationConfig.configuration.ConfigVersion -ne $Global:ADFSTkCompatibleInstitutionConfigVersion) {
            #Make this a function and call it from here and make new code to handle default main config file

            #Try to locate the URL for the default config file
            if (![string]::IsNullOrEmpty($mainConfiguration.Configuration.FederationConfig.Federation.URL)) {
                if (Get-ADFSTkAnswer (Get-ADFSTkLanguageText confDownloadDefaultFederationConfig -f $mainConfiguration.Configuration.FederationConfig.Federation.URL) -DefaultYes) {
                    Get-ADFSTkFederationDefaults -URL $mainConfiguration.Configuration.FederationConfig.Federation.URL -InstallDefaults
                    $FederationDefaultsUpdated = $true
                }
                else {
                    $defaultFederationConfig = $null
                    if (Get-ADFSTkAnswer (Get-ADFSTkLanguageText confContinueWithoutDefaultFederationConfig) -DefaultYes) {
                        Write-ADFSTkLog (Get-ADFSTkLanguageText confContinueWithoutFederationConfig) 
                    }
                    else {
                        Write-ADFSTkLog (Get-ADFSTkLanguageText confAbortDueToIncorrectFederationConfigVersion) -MajorFault
                    }
                }
            }
            else {
                if (Get-ADFSTkAnswer (Get-ADFSTkLanguageText confIncompatobleDefaultFederationConfig) -DefaultYes) {
                    Get-ADFSTkFederationDefaults -InstallDefaults
                    $FederationDefaultsUpdated = $true
                }
                else {
                    $defaultFederationConfig = $null
                    if (Get-ADFSTkAnswer (Get-ADFSTkLanguageText confContinueWithoutDefaultFederationConfig) -DefaultYes) {
                        Write-ADFSTkLog (Get-ADFSTkLanguageText confContinueWithoutFederationConfig) 
                    }
                    else {
                        Write-ADFSTkLog (Get-ADFSTkLanguageText confAbortDueToIncorrectFederationConfigVersion) -MajorFault
                    }
                }
            }

            #Check the version again
            if ($FederationDefaultsUpdated) {
                $defaultFederationConfig = Get-ADFSTkInstitutionConfigDefaults -FederationDefault
                if ($defaultFederationConfig.configuration.ConfigVersion -ne $Global:ADFSTkCompatibleInstitutionConfigVersion) {
                    if (Get-ADFSTkAnswer (Get-ADFSTkLanguageText confDownloadedDefaultFederationConfigIncompatible) -DefaultYes) {
                        $defaultFederationConfig = $null
                        Write-ADFSTkLog (Get-ADFSTkLanguageText confContinueWithoutFederationConfig) 
                    }
                    else {
                        Write-ADFSTkLog (Get-ADFSTkLanguageText confNotAValidVersionError -f $defaultFederationConfig.configuration.ConfigVersion, $Global:ADFSTkCompatibleInstitutionConfigVersion) -MajorFault
                    }    
                }
            }
        }
    }
    else {
        $defaultFederationConfig = $null
        Write-ADFSTkLog (Get-ADFSTkLanguageText confContinueWithoutFederationConfig) 
    }
    #endregion

    #region Import ADFSTk Institution Config
    Write-ADFSTkHost confProcessingInstitutionConfigs -AddLinesOverAndUnder -Style Info
    $allCurrentConfigs = Get-ADFSTkConfiguration -ConfigFilesOnly
    #region Old 0.9 code removed
    # if ([string]::IsNullOrEmpty($allCurrentConfigs)) {
    #     #This is for really old versions of ADFS Toolkit
    #     $currentConfigs = @()
    #     $currentConfigs += Get-ChildItem $Global:ADFSTkPaths.mainDir -Filter '*.xml' `
    #         -Recurse | ? { $_.Directory.Name -notcontains 'cache' -and `
    #             $_.Directory.Name -notcontains 'federation' -and `
    #             $_.Name -ne 'config.ADFSTk.xml' -and -not`
    #             $_.Name.EndsWith('_defaultConfigFile.xml') -and `
    #             $_.Directory.Name -notcontains 'backup' } | `
    #         Select Directory, Name, LastWriteTime | `
    #         Sort Directory, Name
        
    #     if ($currentConfigs.Count -eq 0) {
    #         Write-ADFSTkLog (Get-ADFSTkLanguageText confNoInstConfFiles) -MajorFault
    #     }

    #     #Add all selected federation config files to ADFSTk configuration
    #     $selectedConfigsTemp = $currentConfigs | Out-GridView -Title (Get-ADFSTkLanguageText confSelectInstConfFileToHandle) -PassThru

    #     foreach ($selectedConfig in $selectedConfigsTemp) {
    #         #Check if it's an old file that neds to be copied to the institution dir
    #         if ($selectedConfig.Directory -ne $Global:ADFSTkPaths.institutionDir) {
    #             #Copy the configuration file to new location
    #             $newFileName = Join-Path $Global:ADFSTkPaths.institutionDir $selectedConfig.Name
    #             if (Test-Path $newFileName) {
    #                 Write-ADFSTkLog (Get-ADFSTkLanguageText confInstConfFileAlreadyUpgraded -f (Join-Path $selectedConfig.Directory $selectedConfig.name), $newFileName) -MajorFault
    #             }
    #             else {
    #                 Copy-Item (Join-Path $selectedConfig.Directory $selectedConfig.name) $newFileName
    #             }

    #             #Copy the ManualSP file to new location
    #             [xml]$selectedConfigSettings = Get-Content (Join-Path $selectedConfig.Directory $selectedConfig.name)
    #             $selectedConfigManualSP = $selectedConfigSettings.configuration.LocalRelyingPartyFile
                
    #             $oldManualSPFile = Join-Path $selectedConfig.Directory $selectedConfigManualSP
    #             $newManualSPFile = Join-Path $Global:ADFSTkPaths.institutionDir $selectedConfigManualSP

    #             if (Test-Path $oldManualSPFile) {
    #                 if (Test-Path $newManualSPFile) {
    #                     Write-ADFSTkLog (Get-ADFSTkLanguageText confManualSPFileAlreadyExists -f $oldManualSPFile, $Global:ADFSTkPaths.institutionDir) -EntryType Warning
    #                 }
    #                 else {
    #                     Copy-Item $oldManualSPFile $newManualSPFile
    #                     Write-ADFSTkLog (Get-ADFSTkLanguageText confManualSPFileCopied -f $oldManualSPFile, $Global:ADFSTkPaths.institutionDir) -EntryType Information
    #                 }
    #             }
    #             $selectedConfig.Directory = $Global:ADFSTkPaths.institutionDir
    #         }

    #         $selectedConfigs += Add-ADFSTkConfigurationItem -ConfigurationItem (Join-Path $selectedConfig.Directory $selectedConfig.Name) -PassThru
    #     }
    # }
    # else {
    #endregion

    #Open all configs and check version. Choose from the ones with wrong verion
    $upgradableConfigs = foreach ($configFile in $allCurrentConfigs) {
        $continue = $true
        try {
            [xml]$config = Get-Content $configFile.ConfigFile -ErrorAction Stop
        }
        catch {
            Write-ADFSTkLog (Get-ADFSTkLanguageText confCouldNotOpenInstConfigFile -f $_) -EntryType Error
            $continue = $false
        }
    
        if ([string]::IsNullOrEmpty($config.configuration.ConfigVersion)) {
            Write-ADFSTkLog (Get-ADFSTkLanguageText confCouldNotRetrieveVersion) -EntryType Error
            $continue = $false
        }
        elseif ($config.configuration.ConfigVersion -eq $Global:ADFSTkCompatibleInstitutionConfigVersion) {
            Write-ADFSTkLog (Get-ADFSTkLanguageText confInstConfAlreadyCorrectVersion -f "Institution config file '$($configFile.ConfigFile.Replace($Global:ADFSTkPaths.institutionDir+'\',''))'", $Global:ADFSTkCompatibleInstitutionConfigVersion) -EntryType Information
            $continue = $false
        }

        if ($continue) {
            Write-ADFSTkLog (Get-ADFSTkLanguageText confInstConfNeedsUpgrade -f "Institution config file '$($configFile.ConfigFile.Replace($Global:ADFSTkPaths.institutionDir+'\',''))'", $config.configuration.ConfigVersion, $Global:ADFSTkCompatibleInstitutionConfigVersion) -EntryType Information
            $configFile
        }
    }

    $selectedConfigs = $upgradableConfigs | Out-GridView -Title (Get-ADFSTkLanguageText confSelectInstConfFileToHandle) -PassThru
    # }
    #endregion

    if (![string]::IsNullOrEmpty($selectedConfigs)) {
        #region Copy Local Transform Rule File
        if (!(Test-path $Global:ADFSTkPaths.institutionLocalTransformRulesFile)) {
            Write-ADFSTkHost confLocalTransformRulesMessage -Style Info -AddLinesOverAndUnder -f $Global:ADFSTkPaths.institutionLocalTransformRulesFile
            Copy-item -Path $Global:ADFSTkPaths.defaultInstitutionLocalTransformRulesFile -Destination $Global:ADFSTkPaths.institutionLocalTransformRulesFile
        }
        #endregion
    }

    #region Handle Institution Configs
    $anyFaults = $false
    $removeCache = $false

    foreach ($configFile in $selectedConfigs) {
        Write-ADFSTkHost confProcessingInstConfig -f $configFile.configFile -Style Info -AddSpaceAfter
        $continue = $true

        try {
            [xml]$config = Get-Content $configFile.ConfigFile -ErrorAction Stop
        }
        catch {
            Write-ADFSTkLog (Get-ADFSTkLanguageText confCouldNotOpenInstConfigFile -f $_) -EntryType Error
            $continue = $false
        }

        # if ([string]::IsNullOrEmpty($config.configuration.ConfigVersion)) {
        #     Write-ADFSTkLog (Get-ADFSTkLanguageText confCouldNotRetrieveVersion) -EntryType Error
        #     $continue = $false
        # }
        # elseif ($config.configuration.ConfigVersion -eq $Global:ADFSTkCompatibleInstitutionConfigVersion) {
        #     Write-ADFSTkVerboseLog (Get-ADFSTkLanguageText confInstConfAlreadyCorrectVersion -f 'Institution config file', $Global:ADFSTkCompatibleInstitutionConfigVersion) -EntryType Information
        #     $continue = $false
        # }

        if ($continue) {
            $resultObject = Update-ADFSTkInstitutionConfiguration -ConfigFile $configFile -config $config -defaultFederationConfig $defaultFederationConfig -defaultConfig $defaultConfig
            if ($resultObject.Result -eq $false) {
                $anyFaults = $true
            }
            if ($resultObject.RemoveCache -eq $true) {
                $removeCache = $true
            }
        }
    }

    if ($removeCache) {
        Write-ADFSTkHost confDeleteCacheWarning -Style Attention
        if (Get-ADFSTkAnswer (Get-ADFSTkLanguageText confDeleteCacheQuestion) -DefaultYes) {
            Get-ChildItem $Global:ADFSTkPaths.cacheDir | Remove-Item -Confirm:$false
        }
    }
    #endregion

    #region ADFSTkStore Version
    $ADFSTkStoreObject = Get-ADFSTkStore -ReturnAsObject
    if ($ADFSTkStoreObject.ADFSTkStoreIsInstalled -and $ADFSTkStoreObject.SourceDllVersion -ne $ADFSTkStoreObject.InstalledDllVersion) {
        Write-ADFSTkHost confADFSTkStoreNeedsUpgrade -Style Info -AddLinesOverAndUnder -f $ADFSTkStoreObject.InstalledDllVersion, $ADFSTkStoreObject.SourceDllVersion 

        Install-ADFSTkStore
    }
    #endregion

    #region RefedsMFA/SFA Version
    $ADFSTkMFAAdapters = Get-ADFSTkMFAAdapter -ReturnAsObject
    if (($ADFSTkMFAAdapters.RefedsMFA -or $ADFSTkMFAAdapters.RefedsSFA) -and $ADFSTkMFAAdapters.SourceDllVersion -ne $ADFSTkMFAAdapters.InstalledDllVersion) {
        Write-ADFSTkHost confADFSTkMFAAdaptersNeedsUpgrade -Style Info -AddLinesOverAndUnder -f $ADFSTkMFAAdapters.InstalledDllVersion, $ADFSTkMFAAdapters.SourceDllVersion

        if ($ADFSTkMFAAdapters.RefedsMFA) {
            Uninstall-ADFSTkMFAAdapter -RefedsMFA
        }
        if ($ADFSTkMFAAdapters.RefedsSFA ) {
            Uninstall-ADFSTkMFAAdapter -RefedsSFA
        }

        if ($ADFSTkMFAAdapters.RefedsMFA) {
            Install-ADFSTkMFAAdapter -RefedsMFA
        }
        if ($ADFSTkMFAAdapters.RefedsSFA) {
            Install-ADFSTkMFAAdapter -RefedsSFA
        }
    }
    #endregion
    
    ###Now lets upgrade in steps!###
    
    # break

    # $startVersion = '2.2.1'
    # $newVersion = $MyInvocation.MyCommand.Module.Version.ToString()            
    
    # $ADFSTkConfigResult = $null
    # $ADFSTkInstitutionConfigResult = $null

    # #2.3.0
    # if ($newVersion -eq '2.3.0') {
    #     #Get Federation Default
    #     #if (Get-ADFSTkAnswer -Message "T")

    #     # ADFSTkConfigVersion = 1.0 --> 1.1
    #     try {
    #         $ADFSTkConfigResult = Update-ADFSTkConfiguration 
    #     }
    #     catch {
    #         $_
    #         $ADFSTkConfigResult = $false
    #     }

    #     # ADFSTkInstitutionConfigVersion = ? --> 1.4
    #     try {
    #         $ADFSTkInstitutionConfigResult = Update-ADFSTkInstitutionConfiguration
    #     }
    #     catch {
    #         $_
    #         $ADFSTkInstitutionConfigResult = $false
    #     }
    # }

    # if ($ADFSTkConfigResult -eq $false -or $ADFSTkInstitutionConfigResult -eq $false) {
    #     Write-ADFSTkLog (Get-ADFSTkLanguageText confUpdateError) -EntryType Error
    # }
    # elseif ($ADFSTkConfigResult -eq $true -or $ADFSTkInstitutionConfigResult -eq $true) {
    #     Write-ADFSTkLog (Get-ADFSTkLanguageText confUpdatedInstConfigDone -f "ADFS Toolkit", $startVersion, $newVersion) -EntryType Information
        
    #     #Inform to run Get-ADFSTkHealth
    #     Write-ADFSTkHost confRunHealthCheckRecommended -ForegroundColor Yellow
    #     if (Get-ADFSTkAnswer (Get-ADFSTkLanguageText confDoRunHealthCheck) -DefaultYes) {
    #         Get-ADFSTkHealth -HealthCheckMode Full
    #     }
    # }
    # else {
    #     Write-ADFSTkLog (Get-ADFSTkLanguageText confNoUpdatesNeeded) -EntryType Information
    # }
}