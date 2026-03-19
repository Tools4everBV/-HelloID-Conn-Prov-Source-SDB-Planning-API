######################################################
# HelloID-Conn-Prov-Source-SDB-Planning-API-Departments
#
# Version: 1.0.0
######################################################
# Initialize default value's
$config = $Configuration | ConvertFrom-Json

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
            $errorDetailsObject = ($httpErrorObj.ErrorDetails| ConvertFrom-Json).Error.Message
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
    $uniqueDepartments = $duties.organizationalUnit | Sort-Object -Property code -Unique

    foreach ($department in $uniqueDepartments) {
        $department | Add-Member -MemberType NoteProperty 'ExternalId' -Value $department.code
        $department | Add-Member -MemberType NoteProperty 'DisplayName' -Value $department.name

        Write-Output $department | ConvertTo-Json -Depth 10
    }
}
catch {
    $ex = $PSItem
    if ($($ex.Exception.GetType().FullName -eq 'Microsoft.PowerShell.Commands.HttpResponseException') -or
        $($ex.Exception.GetType().FullName -eq 'System.Net.WebException')) {
        $errorObj = Resolve-SDB-Planning-APIError -ErrorObject $ex
        Write-Verbose "Could not import $Name departments. Error at Line '$($errorObj.ScriptLineNumber)': $($errorObj.Line). Error: $($errorObj.ErrorDetails)"
        Throw "Could not import $Name departments. Error: $($errorObj.FriendlyMessage)"
    }
    else {
        Write-Verbose "Could not import $Name departments. Error at Line '$($ex.InvocationInfo.ScriptLineNumber)': $($ex.InvocationInfo.Line). Error: $($ex.Exception.Message)"
        Throw "Could not import $Name departments. Error: $($errorObj.FriendlyMessage)"
    }
}
