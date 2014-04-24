function Rename-DistributionGroup
{

<#
.SYNOPSIS
	Renames distribution groups
.DESCRIPTION
	Changes the old name of the distribution group
    to the new name. Specifically, the fields that
    are changed are 'Name', 'Alias', 'DisplayName'.
    Also, for each smtp domain the added new alias
    address will be added. For example, if the old 
    distribution list had an EmailAddresses field 
    containing smtp:OldName@contoso.com and 
    smtp:OldName@microsoft.com, this cmdlet would 
    add 'smtp:NewName@contoso.com and 
    'smtp:NewName@Microsoft.com.    
.EXAMPLE
	Rename-DistributionGroup -OldName "OldDistributionGroup" -NewName "NewDistribtuionGroup"

    This would rename the distribution group named "OldDistributionGroup" to "NewDistributionGroup"
.PARAMETER OldName
	The old (or current) name of the distribution group
.PARAMETER NewName
    The new name of the distribution group. This is the name
    this script will change the distribution group to.
.Parameter Confirm
    Use this to force or remove confirmation.
#>
	[CmdletBinding(SupportsShouldProcess=$true)]
	param(
		[Parameter(Mandatory=$true)]
		[string]  $OldName,
		[Parameter(Mandatory=$true)]
        [string]  $NewName,
		[Boolean] $Confirm = $True
	)
        
    write-verbose "Fields that contain ""$OldName"""
    try
    {
        Get-DistributionGroup $OldName -ErrorAction "Stop" |fl * | out-string -stream | select-string $OldName | 
        Where {$_ -ne "" } | ForEach { write-verbose $_ }
    }
    catch [System.Management.Automation.RuntimeException]
    {
        Write-Verbose "There was an error accessing Distribution Group $OldName"
	    write-host ("Exception: " + $Error[0].Exception.GetType().FullName)
	    write-host $Error[0].Exception.Message
        return
    }
    catch
    {
        Write-Verbose "There was an error accessing Distribution Group $OldName"
        throw $_
    }
            

    Write-Verbose "Getting the Distribution Group $OldName"
    $group = Get-DistributionGroup $OldName

    if ( $PSCmdlet.ShouldProcess($OldName, "Setting Name, Alias and DisplayName to $NewName") ) 
	{
		if ( -Not $Confirm -or $($PSCmdlet.ShouldContinue("Are you sure you want to make this change?","Setting Name, Alias and DisplayName to $NewName on target $OldName"  )) )
        {
            Set-DistributionGroup $OldName -alias $NewName -DisplayName $NewName -ForceUpgrade 
        }
    }

    Write-Verbose "EmailAddresses listed on the original group:"
    $group.EmailAddresses |ft -auto | out-string -stream | Where {$_ -ne "" } | ForEach { write-verbose $_ }

    foreach ($EmailAddress in $($group.EmailAddresses))
    {
        if ($EmailAddress -notmatch "^smtp:.*@.*$")
        {
            Write-Verbose "Skipping processing of EmailAddress $EmailAddress"
            Continue
        }

        $domain = $EmailAddress.split('@')[1]

        Write-Verbose "Current Emailaddress ($EmailAddress) domain = $Domain"

        Write-Verbose "Adding new smtp address (smtp:$NewName@$Domain) to the EmailAddresses field"
        $group.EmailAddresses += "smtp:$NewName@$Domain"
    }
        
    Get-DistributionGroup $OldName -ErrorAction "Stop" |fl * | out-string -stream | select-string $OldName | 
    Where {$_ -ne "" } | ForEach { write-verbose $_ }

	if ( $PSCmdlet.ShouldProcess($OldName, "Adding new alias to the old address' smtp addresses.") ) 
	{

		if ( -Not $Confirm -or $($PSCmdlet.ShouldContinue("Are you sure you want to make this change?","Adding $NewName addresses on target $OldName"  )) )
        {
            if ($($group.EmailAddressPolicyEnabled))
            {
                Write-Verbose "Turning off the Email Address Policy for this distribution group."
                Set-DistributionGroup $NewName -EmailAddressPolicyEnabled:$false
            }
            Write-Verbose "Setting the distribution groups new EmailAddresses setting."
            Set-DistributionGroup $NewName -EmailAddresses $($group.EmailAddresses)
                
            if ($($group.EmailAddressPolicyEnabled))
            {
                Write-Verbose "Turning Back on the Email Address Policy for this distribution group."
                Set-DistributionGroup $NewName -EmailAddressPolicyEnabled:$True
            }
        }
    }

    Write-Verbose "New EmailAddresses listed on the original group:"
    (get-distributiongroup $NewName).EmailAddresses | out-string -stream | Where {$_ -ne "" } | ForEach { write-verbose $_ }

}