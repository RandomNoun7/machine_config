$env:PSModulePath += ';C:\Users\bhurt\Documents\WindowsPowerShell\Modules;C:\Program Files (x86)\PowerShell Community Extensions\Pscx3\;C:\Program Files\WindowsPowerShell\Modules;C:\WINDOWS\system32\WindowsPowerShell\v1.0\Modules'
$env:GOPATH = 'C:\gopath'
$env:PATH += ";$env:GOPATH"

$masterPass = '~!@#$%^*-/ aZ'

# $env:BEAKER_setfile              = "hosts.yaml"
# $env:BEAKER_keyfile              = "$HOME/.ssh/id_rsa-acceptance"
# $env:BEAKER_destroy              = "yes"
# $env:BEAKER_debug                = "true"
# $env:BEAKER_PE_DIR               = "http://enterprise.delivery.puppetlabs.net/2017.3/ci-ready"
# $env:BEAKER_PE_VER               = "2017.3.3-rc0-148-gb5b47e0"
# $env:PUPPET_INSTALL_TYPE         = "agent"
# #$env:PUPPET_INSTALL_VERSION      = "2017.3"
# #$env:BEAKER_PUPPET_AGENT_VERSION = "5.3.2"
# $env:BEAKER_TESTMODE             = "apply"
# $env:BUNDLE_PATH                 = ".bundle/gems"
# $env:BUNDLE_BIN                  = ".bundle/bin"
# $env:TEST_FRAMEWORK              = "beaker-rspec"
# $env:SSL_CERT_FILE               = 'C:\Users\bhurt\AppData\Roaming\RubyCACert.pem'

$env:VAGRANT_PREFER_SYSTEM_BIN = 0

Import-Module Posh-Git, NetTCPIP, NetAdapter, Emojis #, oh-my-posh # -skipEditionCheck
# Set-Theme bill
$GitPromptSettings.DefaultPromptSuffix = "$('`n> ' * ($nestedPromptLevel + 1))"
$GitPromptSettings.DefaultForegroundColor = 'yellow'
$GitPromptSettings.BeforeForegroundColor = 'cyan'
$GitPromptSettings.AfterForegroundColor = 'cyan'
# uru 2.5 | Out-Null

Import-module C:\src\Terminal-Icons\Terminal-Icons

# Function Set-RubyDisplay {
#     If ($env:ShowRubyInfo -eq $true) {
#       $env:ShowRubyInfo = $false
#     } Else {
#       $env:ShowRubyInfo = $true
#     }
#   }


# function Test-Administrator {
#     $user = [Security.Principal.WindowsIdentity]::GetCurrent();
#     (New-Object Security.Principal.WindowsPrincipal $user).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)
# }

function Get-FloatyHostname {
    [cmdletbinding()]
    param(
        [parameter(valueFromPipeline)]
        [string]$floatyHostname
    )

    process {
        foreach($hostname in $floatyHostName) {

            $null = $hostname -match '\- ([\w]+\.delivery\.puppetlabs\.net)'

            Write-Output $matches[1]
        }
    }
}

function floatyrdp {
    param(
        [string]$template = 'win-2019-x86_64'
    )

    floaty get $template | Get-FloatyHostname | Foreach-Object -Process {$global:floatyhostname = $_; mstsc /v $_}
}

function branch {
    param (
        [string]$remote,
        [string]$branch
    )

    git checkout -b $branch
    git push --set-upstream $remote $branch
}

# function prompt {

#     $realLASTEXITCODE = $LASTEXITCODE

#     $helo = Get-Emoji HELICOPTER

#     Write-Host

#     # Reset color, which can be messed up by Enable-GitColors
#     #$Host.UI.RawUI.ForegroundColor = $GitPromptSettings.DefaultForegroundColor

#     if (Test-Administrator) {  # Use different username if elevated
#         Write-Host "*" -NoNewline -ForegroundColor Blue
#     }

#     # Write-Host "$ENV:USERNAME@" -NoNewline -ForegroundColor DarkYellow
#     # Write-Host "$ENV:COMPUTERNAME" -NoNewline -ForegroundColor Magenta

#     if ($s -ne $null) {  # color for PSSessions
#         Write-Host " (`$s: " -NoNewline -ForegroundColor DarkGray
#         Write-Host "$($s.Name)" -NoNewline -ForegroundColor Yellow
#         Write-Host ") " -NoNewline -ForegroundColor DarkGray
#     }

#     Write-Host $($(Get-Location) -replace ($env:USERPROFILE).Replace('\','\\'), "~") -NoNewline -ForegroundColor Blue

#     # Write-Host (Get-Date -Format G) -NoNewline -ForegroundColor DarkMagenta
#     # Write-Host " : " -NoNewline -ForegroundColor DarkGray

#     $global:LASTEXITCODE = $realLASTEXITCODE

#     if(Get-GitStatus) {
#         Write-Host " :" -NoNewline -ForegroundColor DarkGray
#         Write-VcsStatus
#     }

#     Write-Host " $helo" -ForegroundColor Yellow

#     $ESC = [char]27

#     "$ESC[33m>$ESC[0m"

# }

# Set-Theme Paradox

Set-Alias -Name git -Value hub
Set-Alias -name shit -value hub
Set-Alias -name code -value code-insiders

if(!($env:Path.split(';') -eq 'C:\Program Files\Git\usr\bin')){
    [Environment]::SetEnvironmentVariable("Path", $env:Path + ";C:\Program Files\Git\usr\bin", "Machine")
}

function Copy-Profile {
    Copy-Item $profile.CurrentUserAllHosts C:\src\machine_config -Force
}

function Update-Image {
    param(
        # name of image to update
        [ValidateSet('Win2012','Win2016', 'win2008r2','win2008r2WMF5','win10pro')]
        [string]
        $name
    )

    $boxName = switch ($name) {
        'Win2012' { 'win-2012r2-x86_64-virtualbox-vagrant.cygwin-0.0.2.box' }
        'Win2016' { 'win-2016-x86_64-virtualbox-vagrant.cygwin-0.0.2.box' }
        'win2008r2' { 'win-2008r2-x86_64-virtualbox-vagrant.cygwin-0.0.2.box' }
        'win2008r2WMF5' { 'win-2008r2-wmf5-x86_64-virtualbox-vagrant.cygwin-0.0.2.box' }
        'win10pro' { 'win-10-pro-x86_64-virtualbox-vagrant.cygwin-0.0.2.box' }
        Default {}
    }

    $basePath = "\\int-resources.ops.puppetlabs.net\Resources\Vagrant Images\"

    $sourcePath = "$basePath$boxName"

    $destination = 'C:\vagrant\images'

    $FOF_CREATEPROGRESSDLG = "&H0&"

    $objShell = New-Object -ComObject "Shell.Application"
    $objFolder = $objShell.NameSpace($destination)

    $objFolder.CopyHere($sourcePath, $FOF_CREATEPROGRESSDLG)
}

function Update-Gitconfig {
    Copy-Item -Path $env:USERPROFILE\.gitconfig -Destination C:\src\machine_config
}

# if((Get-NetIPConfiguration).dnsserver.ServerAddresses -eq '10.240.0.10'){
#     $peVer = (invoke-WebRequest -uri 'http://getpe.delivery.puppetlabs.net/latest/2017.3').content
# }

function git-PullRequestStartChrome {
    git pull-request | %{start chrome $_}
}

function vagrantstatus {
    ls c:\vagrant\boxes -Directory | %{Write-Host $_; Push-Location $_; vagrant status; pop-location}
}

function gr {
    set-location (git rev-parse --show-toplevel)
}

function gitgraph {
    git graph $args
}

function Get-TopLevel {(Get-Item -path (git rev-parse --show-toplevel)).fullname}
function tl {Set-Location (Get-TopLevel)}
function set-clipboard{
    param(
       [parameter(position=0,mandatory=$true,ValueFromPipeline=$true)]$Text
    )
    begin{
        $data = [system.text.stringbuilder]::new()
    }

    process{
        if ($text){
            [void]$data.appendline($text)
        }
    }

    end{
        if ($data){
            $data.tostring().trimend([environment]::newline) + [convert]::tochar(0) | clip.exe
        }
    }
}
function masterpass {$masterPass | Set-Clipboard}

function dps {docker ps --no-trunc -a --format '{{ json . }}' | ConvertFrom-JSON}
function dil {docker image list --format '{{json .}}' | ConvertFrom-JSON}

New-Alias -name pr -value git-pullrequestStartChrome  -description 'Start a Pull Request, edit in VSCode, and launch chrome when done. Only works if the PR is against Origin/master'

New-Alias -name vstatus -value vagrantstatus -description 'Get status of all Vagrant machines.'

New-Alias -name gg -value gitgraph -Description 'Shortcut to git graph'

New-Alias -name d -value docker -Description 'Shortcut to get to the docker command'

function yeahNah { $false }

function nahYeah { $true }

function light {
    Get-MSTerminalProfile -Name "PowerShell Core" | Set-MSTerminalProfile -ColorScheme Novel
    $GitPromptSettings.DefaultForegroundColor = 'blue'
}

function dark {
    Get-MSTerminalProfile -Name "PowerShell Core" | Set-MSTerminalProfile -ColorScheme OceanicMaterial
    $GitPromptSettings.DefaultForegroundColor = 'yellow'
}

function b {
    Invoke-Expression "bundle exec $args"
}

function gf { git f }

function bi { bundle install --path .bundle/gems }
