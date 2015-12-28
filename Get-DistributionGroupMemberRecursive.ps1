function Get-DistributionGroupMemberRecursive
{
<#
.Synopsis
   Gets all members of a distribution group including sub groups
.DESCRIPTION
   Long description
.EXAMPLE
   Get-DistributionGroupMemberRecursive -Group "AllStaff"

   Gets all members of the distribution group (dynamic or static)
.EXAMPLE
   Get-DistributionGroupMemberRecursive -Group "AllStaff" -IncludeGroups

   Gets all members of the distribution group (dynamic or static) and
   includes the groups in the list. By default

#>
    [CmdletBinding()]
    Param
    (
        # Param1 help description
        [Parameter(Mandatory=$true,
                   Position=0)]
        [string[]]$Group,
        [switch] $IncludeGroups
    )

    Begin
    {
    }
    Process
    {
        foreach ($g in $Group)
        {
            write-verbose "Working on group $g"
            Try
            {
                $StartType = (get-recipient $g).RecipientType
                Write-Verbose "Group $g is RecipientType: $StartType"
            }
            Catch [System.Management.Automation.RuntimeException]
            {
                $Err = $_
                Write-Error "$($Err.Exception.Message)`nException: $($Err.Exception.GetType().FullName)"
            }
            Catch
            {
                $Err = $_
                write-Error $Err.Exception.Message
            }

            switch ($StartType)
            {
                'MailUniversalDistributionGroup'
                {
                    write-verbose "Getting members of group $g"
                    $members = get-DistributionGroupMember $g -resultsize unlimited
                }
                'MailUniversalSecurityGroup'
                {
                    write-verbose "Getting members of group $g"
                    $members = get-DistributionGroupMember $g -resultsize unlimited
                }
                'MailNonUniversalGroup'
                {
                    write-verbose "Getting members of group $g"
                    $members = get-DistributionGroupMember $g -resultsize unlimited
                }
                'DynamicDistributionGroup'
                {
                    Write-Verbose "Getting Dynamic Group $g"
                    $DynGroup = Get-DynamicDistributionGroup $g
                    write-verbose "Getting members of dynamic group $g"
                    $members = Get-Recipient -RecipientPreviewFilter $($DynGroup.RecipientFilter) -OrganizationalUnit $($DynGroup.RecipientContainer) -resultsize unlimited
                }
                Default 
                {
                    write-error "RecipientType '$StartType' is not accounted for in this function."
                }
            }

            ForEach ($member in $Members |? {$_.RecipientType -like "*Group"})
            {
                if ($IncludeGroups)
                {
                    
                }
                Write-Verbose "Calling Get-DistributionGroupMemberRecursive on sub-group $Member"
                Write-Output $(Get-DistributionGroupMemberRecursive -Group $Member)
            }

            Write-Output $members |?  {$_.RecipientType -notlike "*Group"}
        }
    }
    End
    {
    }
}

