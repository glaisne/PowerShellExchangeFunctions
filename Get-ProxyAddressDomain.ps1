function Get-ProxyAddressDomain
{
    Param
    (
        $proxyaddresses,
        $domain
    )
    $Found = $false
    foreach ($address in $proxyaddresses)
    {
        if ($address -like "*$domain")
        {
            $Found = $True
            break
        }
    }
    $address.toString()
}


