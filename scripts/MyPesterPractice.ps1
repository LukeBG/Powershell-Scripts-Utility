#This is a common variable
$sbtypes = @{
 Uri1= "{ param (`$param1, `$expectedresult); ( Invoke-Webrequest -uri `$param1).statuscode | should be `$expectedresult } "
 Uri2= "{ param (`$param1, `$expectedresult); ( Invoke-Webrequest -uri `$param1).rawcontentlength | should begreaterthan `$expectedresult }  "
 FileExist = "{ param(`$param1, `$expectedresult); ( Test-path -path `$param1 -pathtype 'leaf' ) | should be `$expectedresult }"
 DirExist = "{ param(`$param1, `$expectedresult); ( Test-path -path `$param1 -pathtype 'container' ) | should be `$expectedresult }"
}

$myone1 = @{
Pending=$true
DescribeName='#01: Sends a request object to uri'
Tags="'uri','google'"
TestCase=@"
@(
@{Param1='http://google.com';ExpectedResult='200'}
@{Param1='http://www.data.gov';ExpectedResult='200'}
)
"@
ScriptBlockType='URI1'
It = "Connect by uri <param1> should be <expectedresult>"
}

$myone2 = @{
Pending=$false
DescribeName='#02: Sends a request object to uri and measures size of rawcontentlength'
Tags="'uri','google','data.gov'"
TestCase=@"
@(
@{Param1='http://google.com';ExpectedResult='2000'}
@{Param1='http://www.data.gov';ExpectedResult='2000'}
)
"@
ScriptBlockType='URI2'
It = "Raw content length by uri <param1> should be greater than <expectedresult>"
}

$myone3 = @{
Pending=$false
DescribeName='#03: Tests file path for existence'
Tags="'alldata'"
TestCase=@"
@(
@{Param1='c:\alldata\mybadfile.txt';ExpectedResult=`$false}
)
"@
ScriptBlockType='FileExist'
It = "Testing path <param1> should be <expectedresult>"
}


$myone4 = @{
Pending=$false
DescribeName='#04: Tests directory path for existence'
Tags="'alldata'"
TestCase=@"
@(
@{Param1='c:\alldata';ExpectedResult=`$true}
)
"@
ScriptBlockType='DirExist'
It = "Testing directory path <param1> should be <expectedresult>"
}


Function Create-Test {
param(
[string]$describename,
[string]$tags,
[ValidateSet('URI1','URI2','FileExist','DirExist')]
[string]$scriptblocktype,
[string]$testcase,
[string]$it,
[validateset($true,$false)]
[bool]$pending
)
begin {
    if ($pending) {$pendingval = "-pending"} else { $pendingval = ""}
}
process {

$test = @"
[string[]]`$tags = $($tags)
Describe -Name '$($describename)' -Tags `$tags -fixture {
    
    `$testcases = $($testcase)

    $($sbtypes[$($scriptblocktype)])

    `$sb = $($sbtypes[$($scriptblocktype)])

    it -name '$($it)' -testcases `$testcases $($pendingval) -test `$sb

}
"@

}
end { $test}
}

# Construct myone2
create-test @myone1 | Set-content -path .\mynewtest1.ps1 
create-test @myone2 | Set-content -path .\mynewtest2.ps1 
create-test @myone3 | Set-content -path .\mynewtest3.ps1 
create-test @myone4 | Set-content -path .\mynewtest4.ps1 

invoke-pester .\mynewtest1.ps1
invoke-pester .\mynewtest2.ps1
invoke-pester .\mynewtest3.ps1
invoke-pester .\mynewtest4.ps1