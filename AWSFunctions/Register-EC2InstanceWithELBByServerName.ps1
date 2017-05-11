function Register-EC2InstanceWithELBByServerName
{
    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        [String[]]$ServerNamesToRegister,
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=1)]
        [String]$ELBName,
        [int]$SecondsToPause = 1
    )

    Begin
    {
    Write-Verbose "Registering Servers with names: $($ServerNamesToRegister) to $($ELBName) and waiting $SecondsToPause seconds between registration" 
    }
    Process
    {
        try
        {
            ForEach($servername in $ServerNamesToRegister)
            {
            $instancetoregister = Get-EC2Instance -Filter @{name='tag:Name'; values= "$($servername.ToUpper())"}
            if(!$instancetoregister) { throw "Unable to map $servername to an EC2Instance" }
            $ELBInstance = New-Object Amazon.ElasticLoadBalancing.Model.Instance
            $ELBInstance = $instancetoregister.Instances[0].InstanceID

            Write-Verbose "Registering $ELBInstance to $ELBName"
            Register-ELBInstanceWithLoadBalancer -LoadBalancerName $ELBName -Instance $ELBInstance

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
    Write-Verbose "Done registering $($ServerNamesToStart) to $ELBName"
    }
}
