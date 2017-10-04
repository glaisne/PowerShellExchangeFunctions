[CmdletBinding()]
Param
(
    # Param1 help description
    [Parameter(Mandatory=$true,
                Position=0)]
    [String] $DisplayName,
    [Parameter(Mandatory=$true,
                Position=1)]
    [String] $Alias,

    # Param2 help description
    [Parameter(Mandatory=$true,
                ValueFromPipeline=$true,
                Position=2)]
    [String] $MembersPath
)

#$WIP = $WhatIfPreference
#$WhatIfPreference = $True


if (-Not $(test-path $MembersPath -ErrorAction SilentlyContinue))
{
    throw "Unable to access file $MembersPath`."
}


#
#    Confirm access to module and commands
#


# confirm access to Connect-ExchangeOnLine
TRY
{
	IF (-not (Get-command -Name Connect-ExchangeOnLine))
	{
		throw "No access to Connect-ExchangeOnLine."
	}
}
CATCH
{
    $err = $_
	Write-Warning -Message "Error while accessing command Connect-ExchangeOnLine : $($err.exception.message)"
    return
}


#
#    Connect to msol Exchange Online
#

try
{
    Connect-ExchangeOnLine | Out-Null
}
catch
{
    $err = $_
	Write-Warning -Message "Exception connecting to Exchange OnLine : $($err.exception.message)"
    return
}


#
#    Create Distribution Group
#


$NewDistributionGroup = $null
Try
{
    $NewDistributionGroup = New-DistributionGroup -DisplayName $DisplayName -Name $DisplayName.replace(' ','') -Alias $Alias -MemberDepartRestriction Closed
}
catch
{
    $err = $_
	Write-Warning -Message "Exception Creating the new distribution group ($DisplayName) : $($err.exception.message)"
    return
}

if ($NewDistributionGroup -eq $Null)
{
    throw "Unable to create distribution group ($DisplayName)"
}

try
{
    $NewDistributionGroup | Set-DistributionGroup -PrimarySmtpAddress "$Alias@cushwake.com"
}
catch
{
    $err = $_
	Write-Warning -Message "Error setting PrimarySMTPAddress ($Alias@cushwake.com) : $($err.exception.message)"
}



$Results = new-object System.Collections.ArrayList



gc $MembersPath | select -Unique | foreach {

    $EmailAddress = $_.trim()

    $Object = New-Object PSObject -Property @{
        EmailAddress     = $EmailAddress
        Found            = [string]::Empty
        AddedToDG        = [string]::Empty
        Error            = [string]::Empty
    }

    if ($EmailAddress -notmatch "^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}$")
    {
        Write-Warning "Entry ($EmailAddress) does not match email syntax. Skipping user."
        $Object.Error = "Entry ($EmailAddress) does not match email syntax. Skipping user."
        $Object.Found = $False
    }

    $Error.Clear()
    Add-DistributionGroupMember -Identity $NewDistributionGroup.distinguishedName -Member $EmailAddress 2>2

    if ($Error.Count -ne 0 )
    {
        $err = $error[0]
        if ($err.exception.message -like "*Couldn't find object*")
        {
            $Object.AddedToDG = $Object.Found = $False
            $Object.Error = $err.exception.message
        }
        else
        {
            $Object.AddedToDG = $False
            $Object.Error = $err.exception.message
        }
    }
    else
    {
        $Object.AddedToDG = $Object.Found = $True
    }

    $Results.Add($Object) | Out-Null
}

try
{
    $NewDistributionGroup | Set-DistributionGroup -DisplayName $DisplayName
}
catch
{
    $err = $_
	Write-Warning -Message "Error setting DisplayName ($DisplayName) : $($err.exception.message)"
}


$Results
