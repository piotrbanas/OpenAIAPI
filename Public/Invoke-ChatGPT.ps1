function Invoke-ChatGPT {
<#
.SYNOPSIS
    Sends a prompt to the OpenAI GPT-3 API and returns the generated response.
.DESCRIPTION
    The Invoke-ChatGPT function sends a prompt to the OpenAI GPT-3 API and returns the generated response. This function can be used for chatbot applications, language modeling, and more.
.PARAMETER ApiKey
    The API key to use for authentication with the OpenAI API. If not provided, the function will attempt to retrieve the key from the Set-OpenAIKey function.
.PARAMETER Messages
    An array of messages to include in the prompt. Each message should be an object with a 'content' property and an optional 'role' property. If not provided, the function will attempt to retrieve the messages from the $global:Messages variable.
.PARAMETER Prompt
    The prompt to send to the OpenAI API.
.PARAMETER Identity
    An optional parameter that sets the identity of the bot or user sending the prompt. If provided, the function will clear the $global:Messages variable and create a new "conversation" with the provided identity.
.PARAMETER Temperature
    A value between 0 and 1 that controls the creativity of the generated response. Higher values result in more creative responses.
.PARAMETER MaxTokens
    The maximum number of tokens to generate in the response. The default value is 2048.
.PARAMETER Model
    The name of the GPT-3 model to use. The default value is 'gpt-3.5-turbo'.
.EXAMPLE
    PS C:\> Invoke-ChatGPT -Prompt "Hello, how are you today?"
    Returns a generated response based on the provided prompt.
.EXAMPLE
    (Get-Content .\Public\Invoke-ChatGPT.ps1 -raw)+ ' - Generate comment-based help for this function.' | Invoke-ChatGPT -Identity 'You are Piotr the Automator, a PowerShell and DevOps expert' -Verbose -Temperature 0.5 -MaxTokens 3500
    Pass the script along with instructions through the pipeline to the chatbot.
.EXAMPLE
    Get-Child
.NOTES
    Author: Piotr the Automator
#>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$false)]
        [string]$ApiKey = (Set-OpenAIKey),
        [Parameter(ValueFromPipelineByPropertyName, Mandatory=$false)]
        [Object[]]$Messages = $global:Messages,
        [Parameter(ValueFromPipeline, ValueFromPipelineByPropertyName, Mandatory=$true)]
        [string]$Prompt,
        [string]$Identity,
        [ValidateRange(0,1)]
        [float]$Temperature = 0.8,
        [int]$MaxTokens = 2048,
        [ValidateSet('gpt-3.5-turbo', 'gpt-3.5-turbo-0301')]
        [string]$Model = 'gpt-3.5-turbo'
    )
    Begin {
        $query = $null
        $uri = "https://api.openai.com/v1/chat/completions"
        $Headers = @{
            "Authorization" = "Bearer $ApiKey"
        }
    }
    Process {
        If ($Identity) {
            Remove-Variable -Scope global -Name Messages
            $Messages = New-GPTmessage -Role 'system' -Prompt $Identity
        }
        $Messages = New-GPTmessage -Messages $Messages -Prompt "$Prompt"
        $Body = @{
            messages = $Messages
            temperature = $Temperature
            model = $Model
            max_tokens = $MaxTokens
            top_p = 1
            frequency_penalty = 0
            presence_penalty = 0.6
            stream = $false
        } | ConvertTo-Json -Depth 10 -Compress
    Write-Verbose "$body"
    $bodyUTF = [System.Text.Encoding]::UTF8.GetBytes($body)
    }
    End {
        $query = Invoke-RestMethod -Uri $uri -Method POST -Headers $Headers -Body $BodyUTF -ContentType 'application/json' 
        Write-Verbose "$($query.usage)"
        $global:Messages = New-GPTmessage -Messages $Messages -Prompt $query.choices.message[0].content -Role $query.choices.message[0].role
        $query.choices.message[0].content
    }
}