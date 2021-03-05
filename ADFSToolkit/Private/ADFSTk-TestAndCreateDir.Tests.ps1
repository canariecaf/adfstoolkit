Describe 'Test ADFSTk-TestAndCreateDir' {
    BeforeAll {
        $functionName = 'ADFSTk-TestAndCreateDir'
        
        $modulePath = (Get-Module ADFSToolkit -ListAvailable | Select -First 1).ModuleBase
        $privateScriptsPath = Join-Path $modulePath Private
        $functionPath = Join-Path $privateScriptsPath "$functionName.ps1"
        . $functionPath
    }
    
    BeforeEach {
        $dirName = [GUID]::NewGuid().GUID
        $dirPath = "TestDrive:\$dirname"
    }

    Context 'Test if function is loaded' { 
        It "Test that the function is loaded" {
            Test-Path function:$functionName | Should -Be $true -ErrorAction Stop
        }
    }
    Context 'Create a new directory' {
        It "Test that the directory don't exists" {
            $dirPath | Should -Not -Exist 
        }
        It 'Create a new directory and see that it exists' {
            ADFSTk-TestAndCreateDir -Path $dirPath
            $dirPath | Should -Exist 
        }
        It 'Test the same directory again and see that it exists' {
            ADFSTk-TestAndCreateDir -Path $dirPath
            $dirPath | Should -Exist 
        }
    }
}