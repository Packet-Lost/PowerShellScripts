function Test-RunningEC2InstanceByServerName
{
    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        [String[]]$ServerNamesToCheck,       
        [int]$SecondsToPause = 5,
        [int]$MaximumNumberOfChecks = 50
    )

    Begin
    {
    Write-Verbose "Starting EC2 Instance running check on Servers: $($ServerNamesToCheck) and waiting $SecondsToPause seconds between checks for a maximum of $MaximumNumberOfChecks checks" 
    }
    Process
    {
        try
        {
            ForEach ($ServerNameToCheck in $ServerNamesToCheck)
            {

                $checkCount = 0
                $CheckInterval = $SecondsToPause

                $instancestate = (Get-EC2Instance -Filter @{name='tag:Name'; values= "$($ServerNameToCheck.ToUpper())"}).Instances[0].State.Name.Value

                While (($instancestate -ne "running") -and ($checkCount -le $MaximumNumberOfChecks))
                    {
                    $checkCount += 1
                    Write-Verbose "Waiting for $CheckInterval seconds for instance to enter the running state"
                    Start-Sleep -Seconds $CheckInterval
                    if ($checkCount -le $MaximumNumberOfChecks) { Write-Verbose "$checkCount / $MaximumNumberOfChecks Attempts..." }
                    $instancestate = (Get-EC2Instance -Filter @{name='tag:Name'; values= "$($ServerNameToCheck.ToUpper())"}).Instances[0].State.Name.Value
                    Write-Verbose "Current instance state: $instancestate "
                    }

                if ($instanceState -eq "running")
	                {
		                Write-Output "Instance is running..."
                    } #end if
                else
	                {
		                Write-Error -Message "Instance did not enter the running state. Last state: $instanceState "
	                } #end else
            }
        }
        catch 
        {
            Write-Error $_
        }


    }
}


