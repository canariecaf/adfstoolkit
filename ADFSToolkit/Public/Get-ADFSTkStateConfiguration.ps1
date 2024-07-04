function Get-ADFSTkStateConfiguration {
    param(
    )

    if ((Test-Path $Global:ADFSTKPaths.stateConfigFile)) {
        try {
            [xml]$stateConfig = Get-Content $Global:ADFSTKPaths.stateConfigFile
        }
        catch {
            Write-ADFSTkLog (Get-ADFSTkLanguageText stateconfCouldNotParseConfigFile -f $_) -MajorFault
        }

        $stateConfig.Configuration
    }
    else {
        Write-ADFSTkVerboseLog (Get-ADFSTkLanguageText stateconfNewConfFileMissing)
        New-ADFSTkStateConfiguration -PassThru
    }
}