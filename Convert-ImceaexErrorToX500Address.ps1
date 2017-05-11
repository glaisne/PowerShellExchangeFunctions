﻿function Convert-ImceaexErrorToX500Address
{
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

    [CmdletBinding()]
    Param
    (
        # Param1 help description
        [Parameter(Mandatory=$true,
                   Position=0)]
        [string] $IMCEAEX
    )

    Write-Verbose "Original IMCEAEX string: $IMCEAEX"
    $IMCEAEX = $IMCEAEX.replace("IMCEAEX-","X500:")
    $IMCEAEX = $IMCEAEX.replace("+20"," ")
    $IMCEAEX = $IMCEAEX.replace("+23",'.')
    $IMCEAEX = $IMCEAEX.replace("+28","(")
    $IMCEAEX = $IMCEAEX.replace("+29",")")
    $IMCEAEX = $IMCEAEX.replace('_','/')

    $IMCEAEX
}

