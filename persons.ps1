##################################################
# HelloID-Conn-Prov-Source-SDB-Planning-API-Persons
#
# Version: 1.0.0
##################################################
# Initialize default value's
$config = $configuration | ConvertFrom-Json

#region functions
function Resolve-SDB-Planning-APIError {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [object]
        $ErrorObject
    )
    process {
        $httpErrorObj = [PSCustomObject]@{
            ScriptLineNumber = $ErrorObject.InvocationInfo.ScriptLineNumber
            Line             = $ErrorObject.InvocationInfo.Line
            ErrorDetails     = $ErrorObject.Exception.Message
            FriendlyMessage  = $ErrorObject.Exception.Message
        }
        if (-not [string]::IsNullOrEmpty($ErrorObject.ErrorDetails.Message)) {
            $httpErrorObj.ErrorDetails = $ErrorObject.ErrorDetails.Message
        }
        try {
            $errorDetailsObject = ($httpErrorObj.ErrorDetails | ConvertFrom-Json).Error.Message
            $httpErrorObj.FriendlyMessage = $errorDetailsObject
        }
        catch {
            $httpErrorObj.FriendlyMessage = "Error: [$($httpErrorObj.ErrorDetails)] [$($_.Exception.Message)]"
        }
        Write-Output $httpErrorObj
    }
}
#endregion

try {
    $historicalDays = (Get-Date).ToUniversalTime().AddDays( - $($config.HistoricalDays))
    $futureDays = (Get-Date).ToUniversalTime().AddDays($($config.FutureDays))
    $importStartDate = $historicalDays.ToString('yyyy-MM-dd')
    $importFinishDate = $futureDays.ToString('yyyy-MM-dd')

    # Set authentication header
    $headers = [System.Collections.Generic.Dictionary[[String], [String]]]::new()
    $headers.Add("api-key", "$($config.APIKey)")
    $headers.Add('Accept', 'application/json;charset=utf-8')

    # Retrieve duties
    $splatRetrieveDutiesParams = @{
        Uri     = "$($config.BaseUrl)/api/duties?startDate=$importStartDate&endDate=$importFinishDate&includePlannedDuties&rosterState=published"
        Method  = 'GET'
        Headers = $headers
    }
    $duties = Invoke-RestMethod @splatRetrieveDutiesParams
    $uniqueEmployees = $duties.employee | Sort-Object -Property number -Unique

    foreach ($employee in $uniqueEmployees) {
        # Adjust start and end to full datetime
        $importStartDateTime = [datetime]$historicalDays
        $importFinishDateTime = [datetime]$futureDays

        # Filter duties on employee and the provided historical and future date
        $allEmployeeDuties = $duties | Where-Object {
            $start = [datetime]$_.start
            $end = [datetime]$_.end

            $_.employee.number -eq $employee.number -and
            $start -le $importFinishDateTime -and
            $end -ge $importStartDateTime
        }

        # Loop through all duties and create the contract object
        $contracts = [System.Collections.Generic.List[object]]::new()
        foreach ($employeeDuty in $allEmployeeDuties) {
            $employeeDuty | Add-Member -MemberType NoteProperty -Name 'ExternalId' -Value $employeeDuty.id
            $contracts.Add($employeeDuty)
        }

        $nameParts = $employee.nameInformal -split '\s+'

        $givenName = $nameParts[0]

        $lastName = if ($nameParts.Count -gt 1) {
            ($nameParts[1..($nameParts.Count - 1)] -join ' ')
        }
        else {
            $null
        }

        # Person object
        $employee | Add-Member -MemberType NoteProperty 'ExternalId' -Value $employee.number
        $employee | Add-Member -MemberType NoteProperty 'DisplayName' -Value $employee.nameInformal
        $employee | Add-Member -MemberType NoteProperty 'Contracts' -Value $contracts
        $employee | Add-Member -MemberType NoteProperty 'GivenName' -Value $givenName
        $employee | Add-Member -MemberType NoteProperty 'LastName' -Value $lastName
        Write-Output $employee | ConvertTo-Json -Depth 20
    }
}
catch {
    $ex = $PSItem
    if ($($ex.Exception.GetType().FullName -eq 'Microsoft.PowerShell.Commands.HttpResponseException') -or
        $($ex.Exception.GetType().FullName -eq 'System.Net.WebException')) {
        $errorObj = Resolve-SDB-Planning-APIError -ErrorObject $ex
        Write-Verbose "Could not import $Name persons. Error at Line '$($errorObj.ScriptLineNumber)': $($errorObj.Line). Error: $($errorObj.ErrorDetails)"
        Write-Error "Could not import $Name persons. Error: $($errorObj.FriendlyMessage)"
    }
    else {
        Write-Verbose "Could not import $Name persons. Error at Line '$($ex.InvocationInfo.ScriptLineNumber)': $($ex.InvocationInfo.Line). Error: $($ex.Exception.Message)"
        Write-Error "Could not import $Name persons. Error: $($errorObj.FriendlyMessage)"
    }
}
