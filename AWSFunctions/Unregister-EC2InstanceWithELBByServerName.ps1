function Unregister-EC2InstanceFromELBByServerName
{
    [CmdletBinding()]
    [OutputType([int])]
    Param
    (
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        [String[]]$ServerNamesToUnregister,
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=1)]
        [String]$ELBName,
        [int]$SecondsToPause = 1
    )

    Begin
    {
    Write-Verbose "Unregistering Servers with names: $($ServerNamesToUnregister) from $($ELBName) and waiting $SecondsToPause seconds between unregistration" 
    }
    Process
    {
        try
        {
            ForEach($servername in $ServerNamesToUnregister)
            {
            $instancetounregister = Get-EC2Instance -Filter @{name='tag:Name'; values= "$($servername.ToUpper())"}
            if(!$instancetounregister) { throw "Unable to map $servername to an EC2Instance" }
            $ELBInstance = New-Object Amazon.ElasticLoadBalancing.Model.Instance
            $ELBInstance = $instancetounregister.Instances[0].InstanceID

            Write-Verbose "Unregistering $ELBInstance from $ELBName"
            Remove-ELBInstanceFromLoadBalancer -LoadBalancerName $ELBName -Instance $ELBInstance -Force

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
    Write-Verbose "Done unregistering $($ServerNamesToStart) from $ELBName"
    }
}