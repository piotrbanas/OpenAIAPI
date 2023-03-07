function Set-OpenAIKey {
    #
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipeline)]
        [string]$KeyFile = "$env:USERPROFILE\OpenAIkey.txt",
        [Parameter()]
        [string]$ApiKey
    )
    If ($ApiKey) {
        #Validate the key
        $null = Get-OpenAIModel -ApiKey $ApiKey -ea Stop
        $SecureApiKey = ConvertTo-SecureString -String $ApiKey -AsPlainText -Force
        $SecureApiKey | ConvertFrom-SecureString | Out-File $KeyFile
    }
    If (!(Test-Path -PathType Leaf $KeyFile)) {
        [System.Security.SecureString]$SecureApiKey = Read-Host "Enter the API key" -AsSecureString
        $ApiKey = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($SecureApiKey))
        #Validate Key
        $null = Get-OpenAIModel -ApiKey $ApiKey -ea Stop
        #Store key securely in user profile
        $SecureApiKey = ConvertTo-SecureString -String $ApiKey -AsPlainText -Force
        $SecureApiKey | ConvertFrom-SecureString | Out-File $KeyFile
    }
    $SecureApiKey = Get-Content $KeyFile | ConvertTo-SecureString
    [System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($SecureApiKey))
}