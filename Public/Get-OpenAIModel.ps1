function Get-OpenAIModel {
    <#
    .SYNOPSIS
        Retrieves information about OpenAI models.
    .DESCRIPTION
        The Get-OpenAIModel function allows you to retrieve information about OpenAI models available through the OpenAI API. 
        You need to provide a valid API key to authenticate with the API. 
        You can either retrieve a list of all available models or specify models to retrieve information about.
    .PARAMETER ApiKey
        The API key used to authenticate with the OpenAI API. This parameter is mandatory.
    .PARAMETER Model
        The name of the models to retrieve information about. If not provided, the function will retrieve a list of all available models.
    .EXAMPLE
        PS C:\> Get-OpenAIModel -ApiKey "myapiKey"
        This will retrieve information about all available models.
    .EXAMPLE
        PS C:\> Get-OpenAIModel -ApiKey "myapiKey" -Model "text-davinci-002", "text-curie-001"
        This will retrieve information about the models "text-davinci-002" and "text-curie-001".
    .NOTES
        This function requires an internet connection to work.
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$false)]
        [string]$ApiKey = (Set-OpenAIKey),
        [Parameter(ValueFromPipeline)]
        [string[]]$Model
    )
    Begin {
        $uri = "https://api.openai.com/v1/models"
        $Headers = @{
            "Authorization" = "Bearer $ApiKey"
        }
    }
    Process {
        If (!$Model) {
            $modelsquery = Invoke-RestMethod -Uri $uri -Method GET -Headers $Headers -ContentType 'application/json'
            $modelsquery.data | Select-Object -ExpandProperty id | Sort-Object
        }
        Foreach ($Mod in $Model) {
            $query = Invoke-RestMethod -Uri $uri/$Mod -Method GET -Headers $Headers -ContentType 'application/json'
            $query
        }
    }
    End {
    }
}