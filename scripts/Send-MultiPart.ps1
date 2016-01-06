<#
 .Synopsis
  Send multi-part files
 .Description
  Description here
 .Example
  Send-Results
 .Notes
    Credits: http://stackoverflow.com/questions/25075010/upload-multiple-files-from-powershell-script
#>
function Send-Results {
    param (
        [parameter(Mandatory=$True,Position=1)] [ValidateScript({ Test-Path -PathType Leaf $_ })] [String] $ResultFilePath,
        [parameter(Mandatory=$True,Position=2)] [System.URI] $ResultURL
    )
    $fileBin = [IO.File]::ReadAllBytes($ResultFilePath)
    $computer= $env:COMPUTERNAME

    # Convert byte-array to string (without changing anything)
    #
    $enc = [System.Text.Encoding]::GetEncoding("iso-8859-1")
    $fileEnc = $enc.GetString($fileBin)

    <#
    # PowerShell does not (heh) have built-in support for making 'multipart' (i.e. binary file upload compatible)
    # form uploads. So we have to craft one...
    #
    # This is doing similar to: 
    # $ curl -i -F "file=@file.any" -F "computer=MYPC" http://url
    #
    # Boundary is anything that is guaranteed not to exist in the sent data (i.e. string long enough)
    #    
    # Note: The protocol is very precise about getting the number of line feeds correct (both CRLF or LF work).
    #>
    $boundary = [System.Guid]::NewGuid().ToString()    # 

    $LF = "`n"
    $bodyLines = (
        "--$boundary",
        "Content-Disposition: form-data; name=`"file`"$LF",   # filename= is optional
        $fileEnc,
        "--$boundary",
        "Content-Disposition: form-data; name=`"computer`"$LF",
        $computer,
        "--$boundary--$LF"
        ) -join $LF

    try {
        # Returns the response gotten from the server (we pass it on).
        #
        Invoke-RestMethod -Uri $URL -Method Post -ContentType "multipart/form-data; boundary=`"$boundary`"" -TimeoutSec 20 -Body $bodyLines
    }
    catch [System.Net.WebException] {
        Write-Error( "FAILED to reach '$URL': $_" )
        throw $_
    }
}