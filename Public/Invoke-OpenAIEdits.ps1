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
        [string]$Instruction = 'Write 3 Pester tests.',
        [ValidateRange(0,1)]
        [int]$Temperature = 0.5,
        [int]$MaxTokens = 2048,
        [ValidateSet('code-davinci-edit-001', 'code-cushman-001', 'code-davinci-002' )]
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