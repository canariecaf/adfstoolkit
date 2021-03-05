Describe 'Test Split-Collection' {
   BeforeAll {
      $functionName = 'Split-Collection'
       
      $modulePath = (Get-Module ADFSToolkit -ListAvailable | Select -First 1).ModuleBase
      $privateScriptsPath = Join-Path $modulePath Private
      $functionPath = Join-Path $privateScriptsPath "$functionName.ps1"
      . $functionPath

      $letters = @('a','b','c','d','e','f','g','h','i','j')
   }
   
   Context 'Test if function is loaded' { 
      It "Test that the function is loaded" {
         Test-Path function:$functionName | Should -Be $true -ErrorAction Stop
      }
   }
   Context 'Split 1..10' { 
      It "Test split 1..10 in half" {
         Split-Collection -Collection (1..10) -Count 5 | Should -Be @(@(1, 2, 3, 4, 5), @(6, 7, 8, 9, 10))
      }
      It "Test split 1..10 in two's" {
         Split-Collection -Collection (1..10) -Count 2 | Should -Be @(@(1, 2), @(3, 4), @(5, 6), @(7, 8), @(9, 10))
      }
      It "Test split 1..10 in 9 and 1" {
         Split-Collection -Collection (1..10) -Count 9 | Should -Be @(@(1, 2, 3, 4, 5, 6, 7, 8, 9), 10)
      }
   }
   Context 'Split a..j' { 
      It "Test split a..j in half" {
         Split-Collection -Collection $letters -Count 5 | Should -Be @(@('a','b','c','d','e'), @('f','g','h','i','j'))
      }
      It "Test split a..j in two's" {
         Split-Collection -Collection $letters -Count 2 | Should -Be @(@('a','b'), @('c','d'), @('e','f'), @('g','h'), @('i','j'))
      }
      It "Test split a..j in 9 and 1" {
         Split-Collection -Collection $letters -Count 9 | Should -Be @(@('a','b','c','d','e','f','g','h','i'), 'j')
      }
   }
}