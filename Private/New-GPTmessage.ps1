function New-GPTmessage {
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipeline)]
        [GPTMessage[]]$Messages,
        [Parameter(ValueFromPipelineByPropertyName)]
        [string]$Prompt,
        [string]$Role = 'user'
    )
    Begin {
    }
    Process {
        If ($Messages) {
            $Messages
        }
        [GPTMessage]::new($role, $prompt)
    }
    End{}
}