# Global Agent Instructions

Machine-wide preferences and conventions that apply across all projects.

## Shell Environment

The user runs PowerShell (`pwsh`) as their primary shell on all platforms. When providing shell examples, commands, or scripts:

- Use PowerShell syntax, not bash/sh/zsh
- Use PowerShell cmdlets and operators (e.g. `Get-ChildItem` or `gci`, `Select-String`, `ForEach-Object`, `|` pipeline)
- Use PowerShell variable syntax `$variable`, not `$variable` in backticks or `${var}`
- String interpolation uses double quotes `"text $var"`, literal strings use single quotes `'text'`
- Use `-and`, `-or`, `-not` for logical operators, not `&&`, `||`, `!`
- Use PowerShell comparison operators: `-eq`, `-ne`, `-gt`, `-lt`, `-like`, `-match`
- For file paths, use forward slashes or `Join-Path` — both work in pwsh on all platforms
- If a task genuinely requires bash (e.g. a Dockerfile RUN command, a CI script), say so explicitly
