Import-Module Posh-Git

Start-SSHAgent

New-PSDRive -Name F -PSProvider FileSystem -Root \\int-resources.ops.puppetlabs.net\Resources\ISO -ErrorAction SilentlyContinue
New-PSDRive -Name G -PSProvider FileSystem -Root "\\int-resources.ops.puppetlabs.net\Resources\Vagrant Images" -ErrorAction SilentlyContinue

function Test-Administrator {
    $user = [Security.Principal.WindowsIdentity]::GetCurrent();
    (New-Object Security.Principal.WindowsPrincipal $user).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)
}

function prompt {
    
    $realLASTEXITCODE = $LASTEXITCODE

    Write-Host

    # Reset color, which can be messed up by Enable-GitColors
    #$Host.UI.RawUI.ForegroundColor = $GitPromptSettings.DefaultForegroundColor

    if (Test-Administrator) {  # Use different username if elevated
        Write-Host "(Elevated): " -NoNewline -ForegroundColor White
    }

    # Write-Host "$ENV:USERNAME@" -NoNewline -ForegroundColor DarkYellow
    # Write-Host "$ENV:COMPUTERNAME" -NoNewline -ForegroundColor Magenta

    if ($s -ne $null) {  # color for PSSessions
        Write-Host " (`$s: " -NoNewline -ForegroundColor DarkGray
        Write-Host "$($s.Name)" -NoNewline -ForegroundColor Yellow
        Write-Host ") " -NoNewline -ForegroundColor DarkGray
    }

    Write-Host $($(Get-Location) -replace ($env:USERPROFILE).Replace('\','\\'), "~") -NoNewline -ForegroundColor Blue
    
    # Write-Host (Get-Date -Format G) -NoNewline -ForegroundColor DarkMagenta
    # Write-Host " : " -NoNewline -ForegroundColor DarkGray

    $global:LASTEXITCODE = $realLASTEXITCODE

    if(Get-GitStatus) {
        Write-Host " :" -NoNewline -ForegroundColor DarkGray
        Write-VcsStatus
    }

    Write-Host ""

    return "> "
    
}

Set-Alias -Name git -Value hub

if(!($env:Path.split(';') -eq 'C:\Program Files\Git\usr\bin')){
    [Environment]::SetEnvironmentVariable("Path", $env:Path + ";C:\Program Files\Git\usr\bin", "Machine")
}

function Copy-Profile {
    Copy-Item $profile.CurrentUserAllHosts C:\src\machine_config -Force
}

function Update-Win2012 {
    if(Test-Path G:\){
        Copy-Item -Path G:\win-2012r2-x86_64-virtualbox-vagrant.cygwin-0.0.2.box -Destination C:\vagrant\images
    }
}

function Update-Gitconfig {
    Copy-Item -Path $env:USERPROFILE\.gitconfig -Destination C:\src\machine_config
}