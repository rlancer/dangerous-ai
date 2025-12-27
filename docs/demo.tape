# VHS tape file for recording setup demo
# Install VHS: scoop install charm-vhs
# Run: vhs docs/demo.tape

Output docs/demo.gif

Set Shell "powershell"
Set FontSize 18
Set Width 1000
Set Height 600
Set Theme "Catppuccin Mocha"
Set Padding 20

# Title
Type "# AI Coding Assistants - One-Line Install"
Enter
Sleep 1s

# Show the command
Type "irm https://raw.githubusercontent.com/rlancer/ai-for-the-rest/main/scripts/setup.ps1 | iex"
Sleep 2s

# Execute
Enter
Sleep 5s
