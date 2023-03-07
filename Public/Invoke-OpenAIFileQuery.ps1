function Invoke-OpenAIFileQuery {
    <#
    .SYNOPSIS
        Invokes the OpenAI API to generate completions for a given file.
    .DESCRIPTION
        The Invoke-OpenAIFileQuery function allows you to generate completions for a given file by calling the OpenAI API. 
        You need to provide a valid API key to authenticate with the API. 
        You can also specify the temperature, maximum number of tokens, model, and prompt to use for the completion. 
    .PARAMETER ApiKey
        The API key used to authenticate with the OpenAI API. This parameter is mandatory.
    .PARAMETER Path
        The path of the file for which completions will be generated. This parameter is mandatory.
    .PARAMETER Temperature
        The temperature of the completion. The temperature controls the randomness of the generated text. This parameter is optional and defaults to 1.
    .PARAMETER MaxTokens
        The maximum number of tokens in the generated completion. This parameter is optional and defaults to 2048.
    .PARAMETER Model
        The name of the model to use for the completion. This parameter is optional and defaults to 'text-davinci-003'.
    .PARAMETER Prompt
        The prompt for which completions will be generated. This parameter is optional and defaults to 'Explain code:'
    .EXAMPLE
        PS C:\> Invoke-OpenAIFileQuery -ApiKey "myapiKey" -Path C:\Test\test.txt
        This will generate a completion for the file "test.txt" using the default parameters.
    .EXAMPLE
        PS C:\> Invoke-OpenAIFileQuery -ApiKey "myapiKey" -Path C:\Test\test.txt -Temperature 0.5 -MaxTokens 100 -Model "text-curie-001" -Prompt "Explain this script:"
        This will generate a completion for the file "test.txt" using a temperature of 0.5, a maximum number of tokens of 100, the "text-curie-001" model, and a prompt of "Explain this script:".
    .NOTES
        This function requires an internet connection to work.
        Only file path is accepted as input.
    .INPUTS
        System.IO.FileInfo[]
    .OUTPUTS
        System.String
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$false)]
        [string]$ApiKey = (Set-OpenAIKey),
        [Parameter(ValueFromPipeline, Mandatory)]
        [ValidateScript({
            if(-Not ($_ | Test-Path) ){
                throw "File or folder does not exist" 
            }
            if(-Not ($_ | Test-Path -PathType Leaf) ){
                throw "The Path argument must be a file. Folder paths are not allowed."
            }
            return $true
        })]
        [System.IO.FileInfo[]]$Path,
        [Parameter()]
        [string]$Prompt = 'Explain code:',
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
        Foreach ($File in $Path) {
            $raw = Get-Content $File -raw
            Write-Verbose "Prompt is $($Prompt + ' ' + $raw)"
            $Body = @{
                "model" = $Model;
                "prompt" = $Prompt + ' ' + $raw;
                "temperature" = $Temperature;
                "max_tokens" = $MaxTokens
            } | ConvertTo-Json
            $query = Invoke-RestMethod -Uri $uri -Method POST -Headers $Headers -Body $Body -ContentType 'application/json'
            $query.choices.text
            Write-Verbose "$($query.usage)"
        }
    }
}