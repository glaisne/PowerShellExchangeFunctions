<#
    This function is based on data taken from Joe Palarchio's Get-MailboxLoctaion
    https://gallery.technet.microsoft.com/PowerShell-Script-to-a6bbfc2e
#>


<#
.Synopsis
   Short description
.DESCRIPTION
   Long description
.EXAMPLE
   Example of how to use this cmdlet
.EXAMPLE
   Another example of how to use this cmdlet
#>
function Get-MailboxDatacenterLocation
{
    [CmdletBinding()]
    Param
    (
        # Param1 help description
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        [string[]]$ServerName
    )

    Begin
    {
        $Datacenter = @{}
        $Datacenter["CP"]=@("LAM","Brazil")
        $Datacenter["GR"]=@("LAM","Brazil")
        $Datacenter["HK"]=@("APC","Hong Kong")
        $Datacenter["SI"]=@("APC","Singapore")
        $Datacenter["SG"]=@("APC","Singapore")
        $Datacenter["KA"]=@("JPN","Japan")
        $Datacenter["OS"]=@("JPN","Japan")
        $Datacenter["TY"]=@("JPN","Japan")
        $Datacenter["AM"]=@("EUR","Amsterdam, Netherlands")
        $Datacenter["DB"]=@("EUR","Dublin, Ireland")
        $Datacenter["HE"]=@("EUR","Finland")
        $Datacenter["VI"]=@("EUR","Austria")
        $Datacenter["BL"]=@("NAM","Virginia, USA")
        $Datacenter["SN"]=@("NAM","San Antonio, Texas, USA")
        $Datacenter["BN"]=@("NAM","Virginia, USA")
        $Datacenter["DM"]=@("NAM","Des Moines, Iowa, USA")
        $Datacenter["BY"]=@("NAM","San Francisco, California, USA")
        $Datacenter["CY"]=@("NAM","Cheyenne, Wyoming, USA")
        $Datacenter["CO"]=@("NAM","Quincy, Washington, USA")
        $Datacenter["MW"]=@("NAM","Quincy, Washington, USA")
        $Datacenter["CH"]=@("NAM","Chicago, Illinois, USA")
        $Datacenter["ME"]=@("APC","Melbourne, Victoria, Australia")
        $Datacenter["SY"]=@("APC","Sydney, New South Wales, Australia")
        $Datacenter["KL"]=@("APC","Kuala Lumpur, Malaysia")
        $Datacenter["PS"]=@("APC","Busan, South Korea")
        $Datacenter["YQ"]=@("CAN","Quebec City, Canada")
        $Datacenter["YT"]=@("CAN","Toronto, Canada")
        $Datacenter["MM"]=@("GBR","Durham, England")
        $Datacenter["LO"]=@("GBR","London, England")
    }
    Process
    {
        Foreach ($SN in $ServerName)
        {
            $Object = New-Object PSObject -Property @{
                ServerName = $SN
                Datacenter = [string]::Empty
            }

            $Datacenter[$($ServerName.SubString(0,2))][1]
        }
    }
    End
    {
    }
}