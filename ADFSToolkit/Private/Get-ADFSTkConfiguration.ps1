function Get-ADFSTkConfiguration {
    param(
        [switch]$ConfigFilesOnly,
        [switch]$ForceCreation
    )

    if (!(Test-Path $Global:ADFSTKPaths.mainConfigFile)) {
        if ($PSBoundParameters.ContainsKey("ForceCreation") -and $ForceCreation -ne $false) {
            #Inform that we need a main config and that we will call that now
            Write-ADFSTkHost confNeedMainConfigurationMessage -Style Info

            $config = New-ADFSTkConfiguration -Passthru
        }
        else {
            Write-ADFSTkLog (Get-ADFSTkLanguageText mainconfNoConfigFileFound) -MajorFault
        }
    }
    else {
        try {
            [xml]$config = Get-Content $Global:ADFSTKPaths.mainConfigFile
            
        }
        catch {
            Write-ADFSTkLog (Get-ADFSTkLanguageText mainconfCouldNotParseConfigFile -f $_) -MajorFault
        }
    }

    if ($PSBoundParameters.ContainsKey('ConfigFilesOnly')) {
        if ([string]::IsNullOrEmpty($config.Configuration.ConfigFiles)) {
            @()
        }
        else {
            $config.Configuration.ConfigFiles.ConfigFile | % {
                $ConfigItems = @()
            } {
                $ConfigItems += New-Object -TypeName PSCustomObject -Property @{
                    ConfigFile = $_.'#text'
                    Enabled    = $_.enabled
                }
            } {
                $ConfigItems
            }
        }
    }
    else {
        return $config
    }
}