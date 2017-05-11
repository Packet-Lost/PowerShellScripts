function Stop-EC2InstanceByServerName
{
    [CmdletBinding()]
    Param
    (
        # Array of servernames to stop
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        [String[]]$ServerNamesToStop,

        # seconds to pause between stop commands
        [int]$SecondsToPause = 1
    )

    Begin
    {
    Write-Verbose "Stopping EC2 Instances by Server Name, Servers: $($ServerNamesToStop) and waiting $SecondsToPause seconds between stops " 
    }
    Process
    {
        try
        {
            ForEach($servername in $ServerNamesToStop)
            {
            $instancetostop = Get-EC2Instance -Filter @{name='tag:Name'; values= "$($servername.ToUpper())"}
            if(!$instancetostop) { throw "Unable to map $servername to an EC2Instance" }
            Write-Verbose "Stopping EC2 Instance $($instancetostop.Instances[0].InstanceId) " 
            Stop-EC2Instance -Instance $instancetostop.Instances[0].InstanceId

            Write-Verbose "$(Get-Date) Waiting $SecondsToPause seconds"
            Start-Sleep -seconds $SecondsToPause
            } 
             
        }
        catch 
        {
            Write-Error $_  
        }

    }
    End
    {
    Write-Verbose "Successfully sent stop instance commands to Servers: $($ServerNamesToStop)"
    }
}