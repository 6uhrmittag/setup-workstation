<#
.SYNOPSIS
    Powershell 7 Profile

.DESCRIPTION
    Place in: $HOME\Documents\PowerShell\Microsoft.PowerShell_profile.ps1
    or create a profile with: New-Item -Path $PROFILE -ItemType File

.NOTES
    Requires PowerShell version 5 and the MSOnline, AzureAD, and ImportExcel modules.
#>

# Enable Verbose Output
#$VerbosePreference = "Continue"
# Enable debug Output
# $DebugPreference = 'Continue'
# Disable Verbose/Debug:
# $DebugPreference = 'SilentlyContinue'


Write-Debug "PowerShell Profile start"



# Documentation
# https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_profiles?view=powershell-7.5
# Powershell Code Style:
# https://poshcode.gitbook.io/powershell-practice-and-style/style-guide/documentation-and-comments
# https://learn.microsoft.com/en-us/powershell/scripting/developer/cmdlet/strongly-encouraged-development-guidelines?view=powershell-7.5
#
# Sources
# https://github.com/stevencohn/WindowsPowerShell
# https://github.com/mikemaccana/powershell-profile/blob/master/Microsoft.PowerShell_profile.ps1
# https://github.com/Pscx/Pscx
# https://gist.github.com/cderv/883729f079e487d09b6b52f20e978963
# https://github.com/r3nanp/my-powershell-config
# https://github.com/janikvonrotz/awesome-powershell
# https://github.com/EvotecIT/PSSharedGoods
# https://megamorf.gitlab.io/cheat-sheets/powershell-psreadline/
# https://github.com/mikemaccana/powershell-profile/blob/master/Microsoft.PowerShell_profile.ps1
# https://github.com/Pscx/Pscx
#
# Guides etc.
# https://devblogs.microsoft.com/powershell/optimizing-your-profile/
#




# Deaktiviere automatisches laden aller Module
# https://learn.microsoft.com/de-de/powershell/module/microsoft.powershell.core/about/about_preference_variables?view=powershell-7.4
# $PSModuleAutoloadingPreference = 'ModuleQualified'

function Set-EnvironmentVariable {
    <#
        .SYNOPSIS
        Instantly sets an environment variable in the machine or user environment by updating the registry.
        .DESCRIPTION
        Instantly sets an environment variable in the machine or user environment by updating the registry.
        .PARAMETER Name
        The name of the environment variable to set.
        .PARAMETER Value
        The value of the environment variable to set.
        .PARAMETER Target
        The target environment to set the environment variable in. Valid values are 'Machine' and 'User'.
        .EXAMPLE
        Set-EnvironmentVariable -Name "MyVariable" -Value "MyValue" -Target "Machine"
        .LINK
        https://gist.github.com/asheroto/56d31c741792466b7fbfacc5d47e0e74
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$Name,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$Value,

        [Parameter(Mandatory = $true)]
        [ValidateSet("Machine", "User")]
        [string]$Target
    )

    $regKey = switch ( $Target.ToLower()) {
        "machine" {
            'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Environment'
        }
        "user" {
            'HKCU:\Environment'
        }
    }

    # Set-ItemProperty -Path $regKey -Name $Name -Value $Value
}
# Disable Update-Check + Telemetry (update comes via msstore automatically + delays the startup)
# This approach takes ages:
# [System.Environment]::SetEnvironmentVariable("POWERSHELL_TELEMETRY_OPTOUT", "1", "User")
# [System.Environment]::SetEnvironmentVariable("POWERSHELL_UPDATECHECK", "Off", "User")
# [System.Environment]::SetEnvironmentVariable("POWERSHELL_UPDATECHECK_OPTOUT", "1", "User")
Set-EnvironmentVariable -Name "POWERSHELL_UPDATECHECK" -Value "Off" -Target "User"
Set-EnvironmentVariable -Name "POWERSHELL_TELEMETRY_OPTOUT" -Value "1" -Target "User"



function hh {
    <#
        .SYNOPSIS
            An example function to display how help should be written.

        .EXAMPLE
            Get-Help -Name Test-Help

            This shows the help for the example function.
    #>

    Write-Host @"

# edit
edithistory
editprofile



# Usefull Commands
Get-Module -ListAvailable

## list environment variables
dir env:

"@


}
set-alias helpme hh



# https://blogs.technet.microsoft.com/heyscriptingguy/2012/12/30/powertip-change-the-powershell-console-title
function set-title([string]$newtitle) {
    $host.ui.RawUI.WindowTitle = $newtitle + ' – ' + $host.ui.RawUI.WindowTitle
}

# Scoop autocompletion
# https://github.com/Moeologist/scoop-completion
#Import-Module "$($(Get-Item $(Get-Command scoop).Path).Directory.Parent.FullName)\modules\scoop-completion"


function Load-Module($m) {
    Write-Debug "Loading module $m"
    # Source: https://stackoverflow.com/a/51692402
    # If module is imported say that and do nothing
    if (Get-Module | Where-Object { $_.Name -eq $m }) {
    }
    else {

        # If module is not imported, but available on disk then import
        if (Get-Module -ListAvailable | Where-Object { $_.Name -eq $m }) {
            Write-Debug "Module $m available on disk, importing."
            Import-Module $m
        }
        else {

            # If module is not imported, not available on disk, but is in online gallery then install and import
            if (Find-Module -Name $m | Where-Object { $_.Name -eq $m }) {
                write-host "Please install missing module:"
                write-host "Install-Module -Name $m -Scope CurrentUser -Repository PSGallery -AllowPrerelease"
                EXIT 1
                # Import-Module $m -Verbose
            }
            else {

                # If the module is not imported, not available and not in the online gallery then abort
                write-host "Module $m not imported, not available and not in an online gallery, exiting."
                EXIT 1
            }
        }
    }
    Write-Debug "Module $m loaded"
}

Load-Module 'Terminal-Icons' # braucht mehrere Sek. Ladezeit -.-



# Produce UTF-8 by default
# https://news.ycombinator.com/item?id=12991690
$PSDefaultParameterValues["Out-File:Encoding"] = "utf8"

$MaximumHistoryCount = 10000



$PathToFileEditor = "$env:LOCALAPPDATA" + "\Programs\PhpStorm\bin\phpstorm64.exe"


function find-file($name) {
    get-childitem -recurse -filter "*${name}*" -ErrorAction SilentlyContinue | foreach-object {
        write-output($PSItem.FullName)
    }
}

set-alias find find-file
set-alias unzip expand-archive
function tail($file, $lines = 10) {
    Get-Content $file | Select-Object -Last $lines
}
function head($file, $lines = 10) {
    Get-Content $file | Select-Object -First $lines
}




function set-title([string]$newtitle) {
    $host.ui.RawUI.WindowTitle = $newtitle + ' – ' + $host.ui.RawUI.WindowTitle
}



function grep($regex, $dir) {
    if ($dir) {
        get-childitem $dir | select-string $regex
        return
    }
    $input | select-string $regex
}
function export($name, $value) {
    set-item -force -path "env:$name" -value $value;
}
function head {
    param($Path, $n = 10)
    Get-Content $Path -Head $n
}

function tail {
    param($Path, $n = 10, [switch]$f = $false)
    Get-Content $Path -Tail $n -Wait:$f
}

function explorer {
    explorer.exe .
}

# Truncate homedir to ~
function limit-HomeDirectory($Path) {
    $Path.Replace("$home", "~")
    Return $Path
}
# Extract only the last directory name (leaf) from the full path
function Get-LastLeaf($Path) {
    # Split the path using "\" or "/" and get the last part
    $leaf = ($Path -split '[\\/]')[-1]
    # If the last part is empty (happens if path ends with "\"), get the second to last part
    if ($leaf -eq "") {
        $leaf = ($Path -split '[\\/]')[-2]
    }
    return $leaf
}

# Must be called 'prompt' to be used by pwsh
# https://github.com/gummesson/kapow/blob/master/themes/bashlet.ps1
function prompt {
    $realLASTEXITCODE = $LASTEXITCODE
    $currentDirPath = "$pwd"
    # if home in path, replace with ~
    if ($currentDirPath -like "$home*") {
        $currentDirPath = $currentDirPath.Replace("$home", "~")
    }
    $currentDirPath = Get-LastLeaf("$currentDirPath")
    # Write-Host $( limit-HomeDirectory("$pwd") ) -ForegroundColor Yellow -NoNewline
    # Write-Host ">" -NoNewline
    Write-Host "$currentDirPath" -ForegroundColor Yellow -NoNewline
    Write-Host ' #' -NoNewline

    $global:LASTEXITCODE = $realLASTEXITCODE
    Return " "
}

function which($name) {
    Get-Command $name | Select-Object -ExpandProperty Definition
}

function ide($location) {
    Start $PathToFileEditor "--temp-project $location"
}


function edit($location) {
    if (Test-Path -Path $location -PathType leaf) {
        Start notepad++ "${location}"
    }
    elseif (Test-Path -Path $location -PathType Container) {
        ide $location
    }
}

function showpath {
    $env:path -split ";"
}


function Edit-History {
    edit (Get-PSReadlineOption).HistorySavePath
}
Set-Alias -Name edithistory -Value Edit-History

function Edit-Profile {
    ide $PROFILE
}
Set-Alias -Name editprofile -Value Edit-Profile


function updatePowershell {
    iex "& { $( irm https://aka.ms/install-powershell.ps1 ) } -UseMSI"
}


# Az Tabcompletion
# https://learn.microsoft.com/en-us/cli/azure/install-azure-cli-windows?tabs=winget
#Register-ArgumentCompleter -Native -CommandName az -ScriptBlock {
#    param($commandName, $wordToComplete, $cursorPosition)
#    $completion_file = New-TemporaryFile
#    $env:ARGCOMPLETE_USE_TEMPFILES = 1
#    $env:_ARGCOMPLETE_STDOUT_FILENAME = $completion_file
#    $env:COMP_LINE = $wordToComplete
#    $env:COMP_POINT = $cursorPosition
#    $env:_ARGCOMPLETE = 1
#    $env:_ARGCOMPLETE_SUPPRESS_SPACE = 0
#    $env:_ARGCOMPLETE_IFS = "`n"
#    $env:_ARGCOMPLETE_SHELL = 'powershell'
#    az 2>&1 | Out-Null
#    Get-Content $completion_file | Sort-Object | ForEach-Object {
#        [System.Management.Automation.CompletionResult]::new($_, $_, "ParameterValue", $_)
#    }
#    Remove-Item $completion_file, Env:\_ARGCOMPLETE_STDOUT_FILENAME, Env:\ARGCOMPLETE_USE_TEMPFILES, Env:\COMP_LINE, Env:\COMP_POINT, Env:\_ARGCOMPLETE, Env:\_ARGCOMPLETE_SUPPRESS_SPACE, Env:\_ARGCOMPLETE_IFS, Env:\_ARGCOMPLETE_SHELL
#}
# linux like command completion



#oh-my-posh init pwsh --config 'C:\Users\MarvinHeimbrodt\AppData\Local\Programs\oh-my-posh\themes\clean-detailed.omp.json' | Invoke-Expression
#oh-my-posh init pwsh --config 'C:\Users\MarvinHeimbrodt\AppData\Local\Programs\oh-my-posh\themes\powerlevel10k_lean.omp.json' | Invoke-Expression


# Enhanced PowerShell Experience
# Enhanced PSReadLine Configuration
Load-Module 'PSReadLine'
Load-Module 'CompletionPredictor'
# https://learn.microsoft.com/de-de/powershell/scripting/learn/shell/using-keyhandlers?view=powershell-7.4
# https://learn.microsoft.com/de-de/powershell/scripting/learn/shell/using-predictors?view=powershell-7.4
Import-Module -Name CompletionPredictor
$PSReadLineOptions = @{
    EditMode = 'Windows'
    HistoryNoDuplicates = $true
    HistorySearchCursorMovesToEnd = $true
    Colors = @{
        Command = '#87CEEB'  # SkyBlue (pastel)
        Parameter = '#98FB98'  # PaleGreen (pastel)
        Operator = '#FFB6C1'  # LightPink (pastel)
        Variable = '#DDA0DD'  # Plum (pastel)
        String = '#FFDAB9'  # PeachPuff (pastel)
        Number = '#B0E0E6'  # PowderBlue (pastel)
        Type = '#F0E68C'  # Khaki (pastel)
        Comment = '#D3D3D3'  # LightGray (pastel)
        Keyword = '#8367c7'  # Violet (pastel)
        Error = '#FF6347'  # Tomato (keeping it close to red for visibility)
    }
    PredictionSource = 'HistoryAndPlugin'
    PredictionViewStyle = 'ListView'
    BellStyle = 'None'
}
Set-PSReadLineOption @PSReadLineOptions


# Custom key handlers
Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward
Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward
Set-PSReadLineKeyHandler -Key Tab -Function MenuComplete

# Linux Terminal Shortcuts go brrrrrr
Set-PSReadLineKeyHandler -Chord 'Ctrl+d' -Function DeleteChar
Set-PSReadLineKeyHandler -Chord 'Ctrl+w' -Function BackwardDeleteWord
Set-PSReadLineKeyHandler -Chord 'Alt+d' -Function DeleteWord
Set-PSReadLineKeyHandler -Chord 'Ctrl+LeftArrow' -Function BackwardWord
Set-PSReadLineKeyHandler -Chord 'Ctrl+RightArrow' -Function ForwardWord
Set-PSReadLineKeyHandler -Chord 'Ctrl+z' -Function Undo
Set-PSReadLineKeyHandler -Chord 'Ctrl+y' -Function Redo
Set-PSReadLineKeyHandler -Chord 'Ctrl+k' -Function DeleteToEnd
Set-PSReadLineKeyHandler -Chord 'Ctrl+u' -Function DeleteLine
Set-PSReadLineKeyHandler -Chord 'Ctrl+a' -Function BeginningOfLine
Set-PSReadLineKeyHandler -Chord 'Ctrl+e' -Function EndOfLine



# Custom completion for common commands
$scriptblock = {
    param($wordToComplete, $commandAst, $cursorPosition)
    $customCompletions = @{
        'git' = @('status', 'add', 'commit', 'push', 'pull', 'clone', 'checkout')
    }

    $command = $commandAst.CommandElements[0].Value
    if ( $customCompletions.ContainsKey($command)) {
        $customCompletions[$command] | Where-Object { $_ -like "$wordToComplete*" } | ForEach-Object {
            [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
        }
    }
}
Register-ArgumentCompleter -Native -CommandName git -ScriptBlock $scriptblock