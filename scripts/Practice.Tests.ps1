[STRING[]]$MYTAG = @('MYTAG1','MYTAG2','MYTAG3')
Describe -Name 'MyName' -Tag $MYTAG -Fixture {
    $testc = @{Computer='one'}

    It -name 'Mytest' -TestCases $testc -test {
       $computer | should be $computer

    }
}

# Example:
# PS C:\codelukebg\scripts> Invoke-Pester -Script .\Practice.Tests.ps1 -Tag 'MYTAG3'
# Describing MyName
#  [+] Mytest 86ms
# Tests completed in 86ms
# Passed: 1 Failed: 0 Skipped: 0 Pending: 0
