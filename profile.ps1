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

function Update-Image {
    param(
        # name of image to update
        [ValidateSet('Win2012','Win2016', 'win2008r2')]
        [string]
        $name
    )

    $boxName = switch ($name) {
        'Win2012' { 'win-2012r2-x86_64-virtualbox-vagrant.cygwin-0.0.2.box' }
        'Win2016' { 'win-2016-x86_64-virtualbox-vagrant.cygwin-0.0.2.box' }
        'win2008r2' { 'win-2008r2-x86_64-virtualbox-vagrant.cygwin-0.0.2.box' }
        'win2008r2WMF5' { ' win-2008r2-wmf5-x86_64-virtualbox-vagrant.cygwin-0.0.2.box' }
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