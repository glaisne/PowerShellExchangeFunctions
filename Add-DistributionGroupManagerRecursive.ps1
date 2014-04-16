
function Add-DistributionGroupManagerRecursive
{

<#
.SYNOPSIS
	Adds a user to the ManagedBy list for a Distribution Group and all child groups recursively
.DESCRIPTION
	Adds a mailbox account to the existing list of a Distribution Group's ManagedBy field. In 
    addition, it will ensure that any user currently listed are viable entries in the list.
.EXAMPLE
	Add-DistributionGroupManagerRecursive -DistributionGroup DistGroup -Manager DDuck

    This example adds the mailbox DDuck to the list of managers in the distribution group
    DistGroup. Users will be prompted for confirmation of any changes which will occur.
.EXAMPLE
	Add-DistributionGroupManagerRecursive -DistributionGroup DistGroup -Manager DDuck -Force

    This example will add DDuck to the list of managers in the distribution group DistGroup
    and will not be prompted for any confirmations.
.EXAMPLE
   Add-DistributionGroupManagerRecursive -DistributionGroup DistGroup -Manager DDuck -WhatIf

   This example will add DDuck to the list of managers in the distribution group DistGroup
   but it will not make any changes and only note what changes would have occured.
.PARAMETER DistributionGroup
	This is the distribution group at the top of the hierarchy. Every Distribution Group 
    below this one will be modified to add the specified manager to the list of existing
    managers.
.PARAMETER Manager
    This is the manager who will be added to all the distribution groups' ManagedBy field. 
#>
	[CmdletBinding(SupportsShouldProcess=$true)]
	param(
		[Parameter(Mandatory=$true)]
		$DistributionGroup,
		[Parameter(Mandatory=$true)]
		$Manager,
        [Switch] $Force
	)

	begin{
		$Recursive = $True

        function Write-AsCSV
        {
            param([string[]] $List)

            [string] $Result = ([string]::Empty)

            foreach ($Entry in $List)
            {
                $Result += "$Entry,"
            }
            $Result = $Result.TrimEnd(", ")

            Return $Result
        }

	}

	Process{
        Write-Verbose "`$Force = $Force"
		$DL = $null
		$ManagerToAdd = $null

		write-verbose "Getting mailbox for manager $Manager"

		try
		{
			$ManagerToAdd = get-mailbox $Manager
		}
		catch [System.Management.Automation.RuntimeException]
		{
			write-host ("Exception: " + $Error[0].Exception.GetType().FullName)
			write-host $Error[0].Exception.Message
		}
		catch
		{
			throw $_
		}

		

		write-verbose "Getting Distribution Group $DistributionGroup"

		try
		{
			$DL = Get-DistributionGroup $DistributionGroup -ErrorAction "Stop"
		}
		catch [System.Management.Automation.RuntimeException]
		{
			write-host ("Exception: " + $Error[0].Exception.GetType().FullName)
			write-host $Error[0].Exception.Message
            $Error[0] |fl * -force | out-string -stream |% {write-host "Exception: $_" }
            write-host "Exception resulted from this call:"
            write-host "`$DL = Get-DistributionGroup $DistributionGroup -ErrorAction ""Stop"""
		}
		catch
		{
			throw $_
		}

		If ($DL)
		{
			write-verbose "Adding manager $($ManagerToAdd.Identity) to current list of managers ( $(Write-AsCSV $($dl.ManagedBy)) )"
			$Managers = $($dl.ManagedBy)
			if ($Managers -NotContains $($ManagerToAdd.identity) -And $Managers -ne $($ManagerToAdd.identity))
			{
				$TmpManagers = @()
				# Remove any invalid managers
				foreach ($M in $Managers)
				{
					write-verbose "Testing existing manager ($M) to determine if the user is an appropriate manger"

					if (get-mailbox $M -errorAction SilentlyContinue)
					{
						write-verbose "$M is an appropriate manager of a distribution list."
						$TmpManagers += $M
					}
					else
					{
                        write-verbose "$M is NOT an appropriate manager of a distribution list."
                        write-host -fore Red "$M is NOT a valid object to manage a distribution list and is being removed."						
					}
				}

				$Managers = $TmpManagers
				$TmpManagers = $null

				if ($($Managers.GetType().Name) -ne "Object[]" `
                    -And -Not [string]::isNullOrEmpty($Managers))
				{
					# Chances are we have one user listed.
					$Managers = @($Managers)
				}
				$Managers += $($ManagerToAdd.identity)
				write-verbose "NewManagers = $(write-AsCSV $Managers)"
                Write-verbose "Setting the distribution group managers to $(write-AsCSV $Managers)"

                
                if ( $PSCmdlet.ShouldProcess($($DL.Identity), "Setting ManageBy to $(write-AsCSV $Managers)") ) 
                {
                    Write-Verbose "`$Force = $Force"
                    if ( $Force -or $($PSCmdlet.ShouldContinue("Are you sure you want to make this change?","Setting ManagedBy to $(write-AsCSV $Managers) on target $($DL.Identity)"  )) )
                    {
				        try
				        {
					        Set-DistributionGroup $($DL.Identity) `
                                -ManagedBy $Managers `
                                -BypassSecurityGroupManagerCheck `
                                -ErrorAction "Stop"
				        }
				        catch [System.Management.Automation.RuntimeException]
				        {
					        write-host ("Exception: " + $Error[0].Exception.GetType().FullName)
					        write-host $Error[0].Exception.Message
                            $Error[0] |fl * -force | out-string -stream |% {write-host "Exception: $_" }
                            write-host "Exception resulted from this call:"
                            write-host "Set-DistributionGroup $($DL.Identity) `
                                -ManagedBy $Managers `
                                -BypassSecurityGroupManagerCheck `
                                -ErrorAction ""Stop"""
				        }
				        catch
				        {
					        throw $_
				        }
                    }
                }
			}
			else
			{
				Write-Verbose "$ManagerToAdd is already a manger of the Distribution List $($DL.Identity)"
			}
		}

		if ($Recursive)
		{
			foreach ( $group in $(Get-DistributionGroupMember $dl |?{$_.recipientType -like "*mail*Group*"}) )
			{
                if ($force)
                {
				    Add-distributionGroupManagerRecursive -DistributionGroup $($Group.identity) -Manager $Manager -Force
                }
                else
                {
				    Add-distributionGroupManagerRecursive -DistributionGroup $($Group.identity) -Manager $Manager
                }
			}
		}

	}

	end {

	}

}
