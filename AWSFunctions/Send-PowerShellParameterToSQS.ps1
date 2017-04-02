﻿function Send-PowerShellParameterToSQS
{
    [CmdletBinding()]
    [Alias()]
    [OutputType([int])]
    Param
    (
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        [String[]]$Parameters,
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=1)]
        [String]$SQSQueueUrl,
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=2)]
        [ValidateSet("Enable","Disable")]
        [String]$RequestType
    )

    Process
    {
        try
        {

            ForEach ($Parameter in $Parameters){
                $messageParameter = New-Object Amazon.SQS.Model.MessageAttributeValue
                $messageParameter.DataType = "String"
                $messageParameter.StringValue = $Parameter

                $messageAttributes = New-Object System.Collections.Hashtable
                $messageAttributes.Add($RequestType, $messageParameter)

                Send-SQSMessage -QueueUrl $SQSQueueUrl -MessageAttributes $messageAttributes -MessageBody "Request generated by $($env:Username) at $(Get-Date -Format u)"

            }
        }
        catch {
            Write-Error $_
        }

    }

}