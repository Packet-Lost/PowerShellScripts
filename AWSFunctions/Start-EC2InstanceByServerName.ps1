function Start-EC2InstanceByServerName
{
    [CmdletBinding()]
    [OutputType([int])]
    Param
    (
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        [String[]]$ServerNamesToStart,
        [int]$SecondsToPause = 1
    )

    Begin
    {
    Write-Verbose "Starting EC2 Instances by Server Name, Servers: $($ServerNamesToStart) and waiting $SecondsToPause seconds between starts" 
    }
    Process
    {
        try
        {
            ForEach($servername in $ServerNamesToStart)
            {
            $instancetostart = Get-EC2Instance -Filter @{name='tag:Name'; values= "$($servername.ToUpper())"}
            if(!$instancetostart) { throw "Unable to map $servername to an EC2Instance" }
            Write-Verbose "Starting EC2 Instance $($instancetostart.Instances[0].InstanceId) " 
            Start-EC2Instance -Instance $instancetostart.Instances[0].InstanceId

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
    Write-Verbose "Successfully sent start instance commands to Servers: $($ServerNamesToStart)"
    }
}

