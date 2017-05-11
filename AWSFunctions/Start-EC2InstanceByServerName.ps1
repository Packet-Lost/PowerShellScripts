function Start-EC2InstanceByServerName
{
    [CmdletBinding()]
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
            if($instancetostart.Instances[0].State.Name.Value -eq "stopped"){
                Write-Verbose "Starting EC2 Instance $($instancetostart.Instances[0].InstanceId)"
                Start-EC2Instance -Instance $instancetostart.Instances[0].InstanceId
            }else{ 
                Write-Verbose "Not starting EC2 Instance $($instancetostart.Instances[0].InstanceId) because its instance state was not stopped it was detected as $($instancetostart.Instances[0].State.Name.Value)"
            }
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

