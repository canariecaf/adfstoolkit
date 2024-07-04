function Set-ADFSTkFticksServer {
    param (
        #The DNS name of the F-Ticks server
        [Parameter(Mandatory = $true)]
        $Server
    )

    #Check if State config file exists and create it if needed
    if (!(Test-Path $Global:ADFSTKPaths.stateConfigFile)) {
        Write-ADFSTkVerboseLog (Get-ADFSTkLanguageText stateconfNewConfFileMissing)
        New-ADFSTkStateConfiguration
    }    

    Set-ADFSTkConfiguration -FticksServer $Server -FticksSalt (New-ADFSTkSalt)
    Write-ADFSTkLog -Message (Get-ADFSTkLanguageText fticksServerAndSaltUpdated -f $Server) -EventID 302
}