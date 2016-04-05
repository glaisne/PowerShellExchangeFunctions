function Find-domain
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
    $found
}