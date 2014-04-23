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
        
        Get-DistributionGroup $OldName |fl * | out-string -stream | select-string $OldName
        $group = Get-DistributionGroup $OldName

        if ( $PSCmdlet.ShouldProcess($OldName, "Setting Name, Alias and DisplayName to $NewName") ) 
		{
			if ( -Not $Confirm -or $($PSCmdlet.ShouldContinue("Are you sure you want to make this change?","Setting Name, Alias and DisplayName to $NewName on target $OldName"  )) )
            {
                Set-DistributionGroup $OldName -alias $NewName -DisplayName $NewName -ForceUpgrade 
            }
        }

        $group.EmailAddresses

        foreach ($EmailAddress in $($group.EmailAddresses))
        {
            if ($EmailAddress -notmatch "^smtp:.*@.*$")
            { Continue }

            $domain = $EmailAddress.split('@')[1]

            $group.EmailAddresses += "smtp:$NewName@$Domain"
        }
        Get-DistributionGroup $NewName |fl * | out-string -stream | select-string $OldName
		if ( $PSCmdlet.ShouldProcess($OldName, "Adding new alias to the old address' smtp addresses.") ) 
		{

			if ( -Not $Confirm -or $($PSCmdlet.ShouldContinue("Are you sure you want to make this change?","Adding $NewName addresses on target $OldName"  )) )
            {

                Set-DistributionGroup $NewName -EmailAddressPolicyEnabled:$false
                Set-DistributionGroup $NewName -EmailAddresses $($group.EmailAddresses)
                Set-DistributionGroup $NewName -EmailAddressPolicyEnabled:$True
            }
        }

        get-distributiongroup $NewName |fl emailaddresses
        (get-distributiongroup $NewName).emailaddresses

}