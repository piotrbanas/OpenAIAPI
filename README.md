# OpenAIAPI
PowerShell client for OpenAI API (GPT-3)
This is a PowerShell module that allows you to interact with the OpenAI API, which provides various AI services such as language modeling and natural language processing.

To use the OpenAIAPI PowerShell module, please follow these steps:

1. Download or clone the OpenAIAPI repository from GitHub.
2. Open PowerShell and navigate to the directory where you saved the OpenAIAPI module (e.g. cd C:\OpenAIAPI).
3. Import the module by running the command: Import-Module .\OpenAIAPI.psd1
4. Alternatively, to install this module, copy the contents of the `OpenAIAPI` folder to a directory in your PowerShell module path, such as `$env:USERPROFILE\Documents\PowerShell\Modules`.
Once installed, you can import the module with the following command: Import-Module OpenAIAPI
5. You can now use any of the public functions in the module, such as Invoke-ChatGPT or Invoke-OpenAICompletion, to interact with the OpenAI API.

For more information on how to use the OpenAIAPI module, please refer to the comment-based help in the functions themselves, i.e. Get-Help Invoke-ChatGPT -Full

## Examples:
```
Invoke-ChatGPT -Prompt "Tell me a short one-sentence Azure tip" -Identity 'You are Piotr the CloudMaster, a helpful DevOps Guru'
Use Azure Resource Manager templates to automate deployment and configuration of your infrastructure.
```
You can continue the conversation and the context will be retained:
```
Invoke-ChatGPT -Prompt "Now a give me very obscure one." 
You can use the Azure Advisor REST API to programmatically access recommendations for optimizing your Azure resources.
```
To start a new conversation, define a new Identity:
```
Invoke-ChatGPT -Prompt "Now a give me very obscure one." -Identity 'You are a stand-up comedian' 
Sure, here's an obscure one: "Why did the tomato turn red? Because it saw the salad dressing!
```
Pass the script along with instructions through the pipeline to the chatbot:
```
(Get-Content .\Public\Invoke-ChatGPT.ps1 -raw)+ ' - Generate comment-based help for this function.' | Invoke-ChatGPT -Identity 'You are Piotr the Automator, a PowerShell and DevOps expert' -Verbose -Temperature 0.5 -MaxTokens 3500
```
Write a README based on the file names and structure:
```
((Get-Childitem -Recurse).FullName -join "`r`n") + ' Write a README for this project' | Invoke-ChatGPT -Identity 'You are Piotr the ScriptMaster, a helpful PowerShell and DevOps expert'
```

This will generate a completion for the prompt "Once upon a time" using a temperature of 0.5, a maximum number of tokens of 100, and the "text-curie-001" model:
```
Invoke-OpenAICompletion -ApiKey "myapiKey" -Prompt "Once upon a time" -Temperature 0.5 -MaxTokens 100 -Model "text-curie-001"
```

This will generate code edits for the file "test.txt" using an instruction of "Add error handling to the script", a temperature of 0.7, a maximum number of tokens of 100, and the "code-davinci-edit-001" model:
```
Invoke-OpenAIEdits -ApiKey "myapiKey" -Path C:\Test\test.txt -Instruction "Add error handling to the script" -Temperature 0.7 -MaxTokens 100 -Model "code-davinci-edit-001"
```

