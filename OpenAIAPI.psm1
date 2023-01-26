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
        [Parameter(Mandatory=$true)]
        [string]$ApiKey,
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
        [Parameter(Mandatory=$true)]
        [string]$ApiKey,
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
        [Parameter(Mandatory=$true)]
        [string]$ApiKey,
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


function Invoke-OpenAIEdits {
    <#
    .SYNOPSIS
        Invokes the OpenAI API to generate code edits for a given file.
    .DESCRIPTION
        The Invoke-OpenAIEdits function allows you to generate code edits for a given file by calling the OpenAI API. 
        You need to provide a valid API key to authenticate with the API. 
        You can also specify the instruction, temperature, maximum number of tokens, and model to use for the completion.
    .PARAMETER ApiKey
        The API key used to authenticate with the OpenAI API. This parameter is mandatory.
    .PARAMETER Path
        The path of the file for which code edits will be generated. This parameter is mandatory.
    .PARAMETER Instruction
        The instruction for which code edits will be generated. This parameter is optional and defaults to 'Write 3 Pester tests.'
    .PARAMETER Temperature
        The temperature of the code edits. The temperature controls the randomness of the generated text. This parameter is optional and defaults to 0.5
    .PARAMETER MaxTokens
        The maximum number of tokens in the generated code edits. This parameter is optional and defaults to 2048.
    .PARAMETER Model
        The name of the model to use for the code edits. This parameter is optional and defaults to 'code-davinci-edit-001'.
    .INPUTS
        System.IO.FileInfo[]
    .OUTPUTS
        System.String
    .EXAMPLE
        PS C:\> Invoke-OpenAIEdits -ApiKey "myapiKey" -Path C:\Test\test.txt
        This will generate code edits for the file "test.txt" using the default parameters.
    .EXAMPLE
        PS C:\> Invoke-OpenAIEdits -ApiKey "myapiKey" -Path C:\Test\test.txt -Instruction "Add error handling to the script" -Temperature 0.7 -MaxTokens 100 -Model "code-davinci-edit-001"
        This will generate code edits for the file "test.txt" using an instruction of "Add error handling to the script", a temperature of 0.7, a maximum number of tokens of 100, and the "code-davinci-edit-001" model.
    .NOTES
        This function requires an internet connection to work.
        Only file path is accepted as input.
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]$ApiKey,
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
        [string]$Instruction = 'Write 3 Pester tests.',
        [ValidateRange(0,1)]
        [int]$Temperature = 0.5,
        [int]$MaxTokens = 2048,
        [string]$Model = 'code-davinci-edit-001'
    )
    Begin {
        $uri = "https://api.openai.com/v1/edits"
        $Headers = @{
            "Authorization"= "Bearer $ApiKey"
        }
    }
    Process {
        Foreach ($File in $Path) {
            $Body = @{
                model = $Model;
                input = (Get-Content -Raw $File).psobject.baseobject;
                instruction = $Instruction;
                temperature = $Temperature;
            } | ConvertTo-Json
            $query = Invoke-RestMethod -Uri $uri -Method POST -Headers $Headers -Body $Body -ContentType 'application/json'
            $query.choices.text
            Write-Verbose "$($query.usage)"
        }
    }
}