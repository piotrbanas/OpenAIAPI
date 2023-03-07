function Invoke-OpenAICompletion {
    <#
    .SYNOPSIS
        Invokes the OpenAI API to generate completions for a given prompt.
    .DESCRIPTION
        The Invoke-OpenAICompletion function allows you to generate completions for a given prompt by calling the OpenAI API. 
        You need to provide a valid API key to authenticate with the API. 
        You can also specify the temperature, maximum number of tokens, and model to use for the completion.
    .PARAMETER ApiKey
        The API key used to authenticate with the OpenAI API. This parameter is mandatory.
    .PARAMETER Prompt
        The prompt for which completions will be generated. This parameter is mandatory.
    .PARAMETER Temperature
        The temperature of the completion. The temperature controls the randomness of the generated text. This parameter is optional and defaults to 1.
    .PARAMETER MaxTokens
        The maximum number of tokens in the generated completion. This parameter is optional and defaults to 2048.
    .PARAMETER Model
        The name of the model to use for the completion. This parameter is optional and defaults to 'text-davinci-003'.
    .EXAMPLE
        PS C:\> Invoke-OpenAICompletion -ApiKey "myapiKey" -Prompt "Once upon a time"
        This will generate a completion for the prompt "Once upon a time" using the default parameters.
    .EXAMPLE
        PS C:\> Invoke-OpenAICompletion -ApiKey "myapiKey" -Prompt "Once upon a time" -Temperature 0.5 -MaxTokens 100 -Model "text-curie-001"
        This will generate a completion for the prompt "Once upon a time" using a temperature of 0.5, a maximum number of tokens of 100, and the "text-curie-001" model.
    .NOTES
        This function requires an internet connection to work.
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$false)]
        [string]$ApiKey = (Set-OpenAIKey),
        [Parameter(ValueFromPipeline, Mandatory=$true)]
        [string[]]$Prompt,
        [ValidateRange(0,1)]
        [int]$Temperature = 1,
        [int]$MaxTokens = 2048,
        [string]$Model = 'text-davinci-003'
    )
    Begin {
        $uri = "https://api.openai.com/v1/completions"
        $Headers = @{
            "Authorization" = "Bearer $ApiKey"
        }
    }
    Process {
        Foreach ($Pro in $Prompt) {
            $Body = @{
                "model" = $Model;
                "prompt" = $Pro;
                "temperature" = $Temperature;
                "max_tokens" = $MaxTokens
            } | ConvertTo-Json
            $query = Invoke-RestMethod -Uri $uri -Method POST -Headers $Headers -Body $Body -ContentType 'application/json'
            $query.choices.text
            Write-Verbose "$($query.usage)"
        }
    }
}