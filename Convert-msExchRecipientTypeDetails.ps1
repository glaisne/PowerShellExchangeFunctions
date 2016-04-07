<#
.Synopsis
   Short description
.DESCRIPTION
   Long description
.EXAMPLE
   Example of how to use this cmdlet
.EXAMPLE
   Another example of how to use this cmdlet
.Note
 see:
 https://blogs.technet.microsoft.com/dkegg/2014/05/09/msexchrecipienttypedetails/
 http://www.msexchange.org/kbase/ExchangeServerTips/MicrosoftOffice365/ExchangeOnline/msexchangerecipienttypedetails-active-directory-values.html
#>
function Convert-msExchRecipientTypeDetails
{
    [CmdletBinding()]
    [OutputType([string])]
    Param
    (
        # Param1 help description
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        [int[]] $msExchRecipientTypeDetails
    )

    Begin
    {
    }
    Process
    {
        foreach ($Value in $msExchRecipientTypeDetails)
        {
            switch ($Value.ToString())
            {
                '1'            {'UserMailbox'}
                '2'            {'LinkedMailbox'}
                '4'            {'SharedMailbox'}
                '8'            {'LegacyMailbox'}
                '16'           {'RoomMailbox'}
                '32'           {'EquipmentMailbox'}
                '64'           {'MailContact'}
                '128'          {'MailEnabledUser'}
                '256'          {'MailEnabledUniversalDistributionGroup'}
                '512'          {'MailEnabledNonUniversalDistributionGroup'}
                '1024'         {'MailEnabledUniversalSecurityGroup'}
                '2048'         {'DynamicDistributionGroup'}
                '4096'         {'MailEnabledPublicFolder'}
                '8192'         {'SystemAttendantMailbox'}
                '16384'        {'MailboxDatabaseMailbox'}
                '32768'        {'AcrossForestMailContact'}
                '65536'        {'User'}
                '131072'       {'Contact'}
                '262144'       {'UniversalDistributionGroup'}
                '524288'       {'UniversalSecurityGroup'}
                '1048576'      {'Non-UniversalGroup'}
                '2097152'      {'DisabledUser'}
                '4194304'      {'MicrosoftExchange'}
                '8388608'      {'ArbitrationMailbox'}
                '16777216'     {'MailboxPlan'}
                '33554432'     {'LinkedUser'}
                '268435456'    {'RoomList'}
                '536870912'    {'DiscoverMailbox'}
                '1073741824'   {'RoleGroup'}
                '2147483648'   {'RemoteUserMailbox'}
                '8589934592'   {'RemoteRoomMailbox'}
                '17173869184'  {'RemoteEquipmentMailbox'}
                '34359738368'  {'RemoteSharedMailbox'}
                '137438953472' {'TeamMailbox'}
                
                Default {'Unknown'}
            }
        }
    }
    End
    {
    }
}