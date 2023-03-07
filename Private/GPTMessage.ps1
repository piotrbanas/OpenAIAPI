class GPTMessage {
    [ValidateSet("system", "assistant", "user")]
    [string]$role
    [string]$content
    
    GPTMessage([string]$role, [string]$content) {
        $this.role = $role
        $this.content = $content
    }
}