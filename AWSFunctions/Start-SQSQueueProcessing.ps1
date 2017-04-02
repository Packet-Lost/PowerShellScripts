function Start-SQSQueueProccessing
{
    [CmdletBinding()]
    [Alias()]
    [OutputType([int])]
    Param
    (
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        [String]$SQSQueueUrl
    )

    Process
    {
        try
        {
        Write-Verbose "$(Get-Date -Format u) Polling for $SQSQueueUrl messages"
        $recmsg = Receive-SQSMessage -QueueUrl $SQSQueueUrl -MessageCount 10 -MessageAttributeName All
        if ($recmsg) {
            Write-Verbose "$(Get-Date -Format u) ... Messages found in queue...starting to process them"
            $recmsg | ForEach-Object {
                Write-Verbose "$(Get-Date -Format u) ... Processing message $($_.MessageId) that was $($_.Body)" 
                $_.MessageAttributes | ForEach-Object {
                ###This is where you can take action depending on the Key value of the message attribute###
                    if ($_.Keys -eq "Enable") { Write-Output "We could do a Enable-Noun powershell cmdlet with the -parameter $($_.Enable.StringValue) here" }
                    elseif ($_.Keys -eq "Disable") { Write-Output "We could do a Disable-Noun powershell cmdlet with the -parameter $($_.Disable.StringValue) here" }
                    else { Write-Warning "Thats odd, the key of the message attribute was not what was expected so no action was taken" }
                    }
                Write-Verbose "$(Get-Date -Format u) Done processing $($_.MessageId) that was $($_.Body) attempting message deletion"  
                Remove-SQSMessage -QueueUrl $SQSQueueUrl -ReceiptHandle $_.ReceiptHandle -Force
                }

        }else{ Write-Verbose "$(Get-Date -Format u) ... No messages were pulled from the queue...nothing to do right now"}

        }
        catch {
            Write-Error $_
        }

    }

}