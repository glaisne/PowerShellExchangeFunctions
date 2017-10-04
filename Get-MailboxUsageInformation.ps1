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
function Get-MailboxUsageInformation
{
    [CmdletBinding()]
    [OutputType([psobject])]
    Param
    (
        # Param1 help description
        [Parameter(Mandatory=$true,
                   ValueFromPipeline=$true,
                   Position=0)]
        $Identity
    )

    Begin
    {
    }
    Process
    {
        Foreach ($ID in $Identity)
        {
            # get-mailbox *wonski* | % {Get-MailboxFolderStatistics $_.identity -IncludeOldestAndNewestItems -IncludeAnalysis} | ? {$_.folderpath -eq '/Inbox' -or $_.Folderpath -eq '/Sent Items'} | fl *

            Try
            {
                $mbx = get-mailbox $ID -erroraction Stop
                If ($mbx -eq $null)
                {
                    Throw "Unable to find mailbox $ID"
                }
            }
            catch
            {
                Write-Warning "Unable to access mailbox $ID : $($_.Exception.Message)"
            }

            Try
            {
                $Stats = get-mailboxFolderStatistics -Identity $mbx.identity -IncludeOldestAndNewestItems
                if ($Stats -eq $null)
                {
                    Throw "Unable to gather folder statistics for $($mbx.identity)"
                }
            }
            Catch
            {
                Write-Warning "Unable to gather folder statistics for $($mbx.identity) : $($_.Exception.Message)"
            }

            $inboxStats     = $Stats |? {$_.FolderPath -eq '/Inbox'}
            $SentItemsStats = $Stats |? {$_.FolderPath -eq '/Sent Items'}

            $FolderStats = new-object System.Collections.ArrayList

            $FolderStats.Add($inboxStats)     | Out-Null
            $FolderStats.Add($SentItemsStats) | Out-Null

            Foreach ($folder in $FolderStats)
            {
                $Result = new-object psobject -Property @{
                    Mailbox                    = $mbx.identity
                    Folder                     = $folder.name
                    ItemsInFolder              = $folder.ItemsInFolder
                    ItemsInFolderAndSubfolders = $folder.ItemsInFolderAndSubfolders
                    FolderSize                 = $folder.FolderSize
                    FolderAndSubfolderSize     = $folder.FolderAndSubfolderSize
                    OldestItemReceivedDate     = $folder.OldestItemReceivedDate
                    NewestItemReceivedDate     = $folder.NewestItemReceivedDate
                    OldestItemLastModifiedDate = $folder.OldestItemLastModifiedDate
                    NewestItemLastModifiedDate = $folder.NewestItemLastModifiedDate
                }
                Write-Output $Result | select Mailbox, Folder, ItemsInFolder, ItemsInFolderAndSubfolders, FolderSize, FolderAndSubfolderSize, OldestItemReceivedDate, NewestItemReceivedDate, OldestItemLastModifiedDate, NewestItemLastModifiedDate
            }

        }
    }
    End
    {
    }
}

Get-MailboxUsageInformation -Identity 'Philip Wonski' | ft -AutoSize

