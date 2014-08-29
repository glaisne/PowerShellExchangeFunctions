

$CASLogFolder = "C:\data\logs\cas\ExchangeClients"

function Clean-Username ([string] $Username)
{
    [CmdletBinding()]

    $OrigUsername = $Username
    if ($Username.contains('\'))
    {
        $Username = $Username.split('`\')[1]
    }

    #write-host -fore yellow "2 `$Username = $Username"

    if ($Username.contains('/'))
    {
        $Username = $Username.split('/')[1]
    }

    #write-host -fore yellow "3 `$Username = $Username"

    if ($Username.contains('@'))
    {
        $Username = $Username.split('@')[0]
    }

    write-Verbose "$($OrigUsername.padLeft(20)) becomes $Username"

    $Username
}


$Files = dir "$CASLogFolder\u_ex*.*"

$RegEx = "(?<date>.*) (?<time>.*) (?<s_ip>.*) (?<cs_method>.*) (?<cs_uri_stem>.*) (?<cs_uri_query>.*) (?<s_port>.*) (?<cs_username>.*) (?<c_ip>.*) (?<cs_User_Agent>.*) (?<sc_status>.*) (?<sc_substatus>.*) (?<sc_win32_status>.*) (?<time_taken>.*)"

$Lines = @()

foreach ($File in $Files )
{

    Select-String $regex $File |
    ForEach {
        ForEach($match in $_.Matches) {

            if ($($match.Groups["cs_username"].Value) -ne "-" `
                -AND $($match.Groups["cs_username"].Value) -ne "cs-username" )
            {
                $Username = Clean-Username -Username $($match.Groups["cs_username"].Value) -Verbose
                $Lines += New-Object PSObject -Property @{
                    "date"                = $match.Groups["date"].Value
                    "time"                = $match.Groups["time"].Value
                    "s_ip"                = $match.Groups["s_ip"].Value
                    "cs_method"           = $match.Groups["cs_method"].Value
                    "cs_uri_stem"         = $match.Groups["cs_uri_stem"].Value
                    "cs_uri_query"        = $match.Groups["cs_uri_query"].Value
                    "s_port"              = $match.Groups["s_port"].Value
                    "Username"            = $Username
                    "c_ip"                = $match.Groups["c_ip"].Value
                    "Client"              = $match.Groups["cs_User_Agent"].Value
                    "sc_status"           = $match.Groups["sc_status"].Value
                    "sc_substatus"        = $match.Groups["sc_substatus"].Value
                    "sc_win32-status"     = $match.Groups["sc_win32-status"].Value
                    "time_taken"          = $match.Groups["time_taken"].Value
                }
            }
        }
    }
}


$usersTmp = @()
$UsersTmp += $($Lines |? {$_.Username -like "*jmtay19*"} | select Username -Unique)

$usersTmp2 = @()

Foreach ($User in $UsersTmp)
{
    $User = $User.Username.ToString()
    
    write-host -fore yellow "a `$User = $User"

    if ($User.contains('\'))
    {
        $User = $user.split('`\')[1]
    }

    write-host -fore yellow "2 `$User = $User"

    if ($User.contains('/'))
    {
        $User = $user.split('/')[1]
    }

    write-host -fore yellow "3 `$User = $User"

    if ($User.contains('@'))
    {
        $User = $user.split('@')[0]
    }

<#
    $User = $User.Replace("AD`\", "")
    $User = $User.Replace("ad`\", "")
    write-host -fore yellow "b `$User = $User"
    $User = $User.Replace("AD2`\", "")
    $User = $User.Replace("ad2`\", "")
    write-host -fore yellow "c `$User = $User"
    $User = $User.Replace("AD.bu.edu`\", "")
    $User = $User.Replace("ad.bu.edu`\", "")
    write-host -fore yellow "d `$User = $User"
    $User = $User.Replace("AD2.bu.edu`\", "")
    $User = $User.Replace("ad2.bu.edu`\", "")
    write-host -fore yellow "e `$User = $User"
    $User = $User.Replace('@bu.edu', "")
#>

    $UsersTmp2 += $User
    
    write-host -fore yellow "h `$User = $User"
}

$Users = @()
$Users += $($UsersTmp2 | select -Unique)


$UserClients = @()
$AllClients  = @()

foreach ($User in $Users)
{
    $Clients =  @()
    write-Host -fore yellow  "`$User = '$User'"
    foreach ($Client in $($Lines |where {$_.Username -Like "*$User*"} | select Client -Unique) )
    {
        $Clients += $Client.Client
        $AllClients += $Client.Client
    }
    $UserClients += New-Object PSObject -Property @{
        Username = $User
        Clients  = $Clients
    }
}


$UserClients |ft Username, Clients -AutoSize

$AllClients | select -Unique | sort |ft -AutoSize

