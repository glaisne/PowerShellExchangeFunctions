$ExSrv = Get-ExchangeServer |?{$_.AdminDisplayVersion -like "*14.*"}

$ChangeName = "CHG021892"
$DateStamp = get-date -format "MMddyyyy"

$ExSrv |
%{
    if ($($_.Name) -like "*CAS*")
    {
        write-host -fore cyan "$($_.Name)"
        write-host -fore cyan "--------------------------------------------------`r`n"
        
        if (!$(test-path "\\$($_.fqdn)\c`$\Backup")) {
            mkdir "\\$($_.fqdn)\c`$\Backup\" -confirm:$false
        }
             if (!$(test-path "\\$($_.name)\c`$\Backup\$ChangeName-EWS\")) {
            mkdir "\\$($_.fqdn)\c`$\Backup\$ChangeName-EWS\" -confirm:$false
        }


        if (!$(test-path "\\$($_.fqdn)\c`$\Backup\$ChangeName-EWS\OWA\")) {
            mkdir "\\$($_.fqdn)\c`$\Backup\$ChangeName-EWS\OWA\" -confirm:$false
        }

        copy-item "\\$($_.fqdn)\c`$\Program Files\Microsoft\Exchange Server\V14\ClientAccess\Owa\Web.Config" "\\$($_.name)\c`$\Backup\$ChangeName-EWS\OWA\"
        
        copy-item "\\$($_.fqdn)\c`$\Program Files\Microsoft\Exchange Server\V14\ClientAccess\Owa\Web.Config" "\\$($_.fqdn)\c`$\Program Files\Microsoft\Exchange Server\V14\ClientAccess\Owa\Web.Config.$DateStamp"
#        copy-item "\\$($_.fqdn)\c`$\Program Files\Microsoft\Exchange Server\V14\ClientAccess\Owa\Web.Config.owa.jeff" "\\$($_.fqdn)\c`$\Program Files\Microsoft\Exchange Server\V14\ClientAccess\Owa\Web.Config"


        if (!$(test-path "\\$($_.fqdn)\c`$\Backup\$ChangeName-EWS\EWS\")) {
            mkdir "\\$($_.fqdn)\c`$\Backup\$ChangeName-EWS\EWS\" -confirm:$false
        }

        copy-item "\\$($_.fqdn)\c`$\Program Files\Microsoft\Exchange Server\V14\ClientAccess\exchweb\ews\Web.Config" "\\$($_.name)\c`$\Backup\$ChangeName-EWS\EWS\"
        
        copy-item "\\$($_.fqdn)\c`$\Program Files\Microsoft\Exchange Server\V14\ClientAccess\Owa\Web.Config" "\\$($_.fqdn)\c`$\Program Files\Microsoft\Exchange Server\V14\ClientAccess\Owa\Web.Config.$DateStamp"
#        copy-item "\\$($_.fqdn)\c`$\Program Files\Microsoft\Exchange Server\V14\ClientAccess\Owa\Web.Config.ews.jeff" "\\$($_.fqdn)\c`$\Program Files\Microsoft\Exchange Server\V14\ClientAccess\Owa\Web.Config"


#        if (!$(test-path "\\$($_.fqdn)\c`$\Backup\$ChangeName-EWS\ECP\")) {
#            mkdir "\\$($_.fqdn)\c`$\Backup\$ChangeName-EWS\ECP\" -confirm:$false
#        }
#
#        copy-item "\\$($_.fqdn)\c`$\Program Files\Microsoft\Exchange Server\V14\ClientAccess\exchweb\ecp\Web.Config" "\\$($_.name)\c`$\Backup\$ChangeName-EWS\ECP\"

    }
}

