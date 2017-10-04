<#
.Synopsis
   Determines if an email address has received a message
   in the past
.DESCRIPTION
   Determines if an email address has received a message
   in the past number of days specified by the -Days 
   parameter. The default is to check for the past day.
.OUTPUTS
   Boolean. Test-O365RecipientReceivedMessages returns true if
   the specified email address(es) have received email in the 
   past number of days (specified by the -Days parameter).
.EXAMPLE
   Test-O365RecipientReceivedMessages -EmailAddress 'gene@contoso.com'

   This Example will determin if the email address 'gene@contoso.com' 
   has received any messages in the past 24 hours.
.EXAMPLE
   Test-O365RecipientReceivedMessages -EmailAddress 'gene@contoso.com' -Days 20

   This Example will determin if the email address 'gene@contoso.com' 
   has received any messages in the past 20 days.

#>
function Test-O365RecipientReceivedMessages
{
    [CmdletBinding()]
    Param
    (
        # Identity of the recipient.
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        [ValidatePattern('^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}$')]
        [string[]]
        $EmailAddress,

        # Number of days back to search
        [ValidateRange(0,30)]
        [int]
        $Days = 1
    )

    Begin
    {
    }
    Process
    {
        foreach ($id in $EmailAddress)
        {
            Write-Verbose $Email
            $sw = [System.Diagnostics.Stopwatch]::StartNew()
            $msgs = get-messagetrace -startdate ([datetime]::now.adddays((-1 * $Days))) -EndDate ([datetime]::now) -RecipientAddress $Email.trim() -pagesize 10 -page 1
            $sw.stop()
            Write-Verbose " - Finding messages took $($sw.Elapsed.TotalSeconds) seconds."
            if ($msgs -ne $null -and $msgs.count -gt 0)
            {
                Write-verbose "$Email has received message in the past $Days days."
                Write-output $Email
            }
            else
            {
                Write-verbose "$Email has not received message in the past $Days days."
            }

        }
    }
    End
    {
    }
}