Function Start-SQSQueuePolling{
    Param
    (
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        [String]$QueueUrl
    )

$numofmsg = Get-SQSQueueAttribute -QueueUrl $QueueUrl -AttributeName ApproximateNumberOfMessages

    if ($numofmsg.ApproximateNumberOfMessages -gt 0){

            Write-Output "Number of messages in the queue to process is approximately $($numofmsg.ApproximateNumberOfMessages)"

            While ($numofmsg.ApproximateNumberOfMessages -gt 0) {
            Start-SQSQueueProccessing -SQSQueueUrl $QueueUrl -Verbose
            Start-Sleep -Seconds 5
            $numofmsg = Get-SQSQueueAttribute -QueueUrl $QueueUrl -AttributeName ApproximateNumberOfMessages
            Write-Output "Number of messages is $($numofmsg.ApproximateNumberOfMessages)"
            }
        }else{
            Write-Output "No messages found in the queue to process"
        }
    Write-Output "Done processing SQS Messages in the Queue"
}