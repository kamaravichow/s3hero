# S3Hero Windows Installation Script
#
# This script installs S3Hero on Windows systems.
# Run this in PowerShell with Administrator privileges.
#
# Usage:
#   Set-ExecutionPolicy Bypass -Scope Process -Force
#   .\install.ps1
#

$ErrorActionPreference = "Stop"

# Configuration
$REPO = "kamaravichow/s3hero"
$InstallDir = "$env:LOCALAPPDATA\s3hero"
$VenvDir = "$InstallDir\venv"
$BinDir = "$InstallDir\bin"
$MinPythonVersion = [Version]"3.8"

# Color output functions
function Write-Info { Write-Host "ℹ " -ForegroundColor Blue -NoNewline; Write-Host $args }
function Write-Success { Write-Host "✓ " -ForegroundColor Green -NoNewline; Write-Host $args }
function Write-Warning { Write-Host "⚠ " -ForegroundColor Yellow -NoNewline; Write-Host $args }
function Write-Err { Write-Host "✗ " -ForegroundColor Red -NoNewline; Write-Host $args }

function Write-Header {
    Write-Host ""
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Blue
    Write-Host "   S3Hero Installer for Windows" -ForegroundColor Blue
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Blue
    Write-Host ""
}

# Check Python installation
function Get-PythonCommand {
    $pythonCommands = @("python", "python3", "py")
    
    foreach ($cmd in $pythonCommands) {
        try {
            $version = & $cmd -c "import sys; print(f'{sys.version_info.major}.{sys.version_info.minor}.{sys.version_info.micro}')" 2>$null
            if ($version) {
                $ver = [Version]$version
                if ($ver -ge $MinPythonVersion) {
                    return $cmd
                }
            }
        } catch {
            continue
        }
    }
    
    return $null
}

# Create virtual environment
function New-Venv {
    param([string]$PythonCmd, [string]$VenvPath)
    
    Write-Info "Creating virtual environment at $VenvPath..."
    
    # Create parent directory
    $parentDir = Split-Path -Parent $VenvPath
    if (-not (Test-Path $parentDir)) {
        New-Item -ItemType Directory -Path $parentDir -Force | Out-Null
    }
    
    # Remove existing venv
    if (Test-Path $VenvPath) {
        Remove-Item -Recurse -Force $VenvPath
    }
    
    # Create venv
    & $PythonCmd -m venv $VenvPath
    
    if (-not (Test-Path "$VenvPath\Scripts\python.exe")) {
        throw "Failed to create virtual environment"
    }
    
    Write-Success "Virtual environment created"
}

# Install s3hero
function Install-S3Hero {
    param([string]$VenvPath)
    
    Write-Info "Installing s3hero..."
    
    $pythonVenv = "$VenvPath\Scripts\python.exe"
    $pipVenv = "$VenvPath\Scripts\pip.exe"
    
    # Upgrade pip
    & $pythonVenv -m pip install --upgrade pip --quiet
    
    # Try to install from PyPI, fallback to GitHub
    try {
        & $pipVenv install s3hero --quiet 2>$null
    } catch {
        Write-Info "Installing from GitHub..."
        & $pipVenv install "git+https://github.com/$REPO.git" --quiet
    }
    
    # If that fails, try local installation
    if (-not (Test-Path "$VenvPath\Scripts\s3hero.exe")) {
        if (Test-Path "pyproject.toml") {
            Write-Info "Installing from local source..."
            & $pipVenv install . --quiet
        }
    }
    
    Write-Success "s3hero installed"
}

# Create batch wrapper
function New-Wrapper {
    param([string]$BinPath, [string]$VenvPath)
    
    Write-Info "Creating s3hero command wrapper..."
    
    if (-not (Test-Path $BinPath)) {
        New-Item -ItemType Directory -Path $BinPath -Force | Out-Null
    }
    
    $wrapperContent = @"
@echo off
REM S3Hero wrapper script
setlocal
set PATH=$VenvPath\Scripts;%PATH%
"$VenvPath\Scripts\python.exe" -m s3hero.cli %*
endlocal
"@
    
    Set-Content -Path "$BinPath\s3hero.cmd" -Value $wrapperContent
    
    Write-Success "Wrapper script created at $BinPath\s3hero.cmd"
}

# Update PATH environment variable
function Update-Path {
    param([string]$BinPath)
    
    $currentPath = [Environment]::GetEnvironmentVariable("Path", "User")
    
    if ($currentPath -notlike "*$BinPath*") {
        Write-Info "Adding $BinPath to PATH..."
        
        $newPath = "$currentPath;$BinPath"
        [Environment]::SetEnvironmentVariable("Path", $newPath, "User")
        
        # Also update current session
        $env:Path = "$env:Path;$BinPath"
        
        Write-Success "Added to PATH"
    }
}

# Main installation
function Main {
    Write-Header
    
    # Check Python
    Write-Info "Checking Python installation..."
    $pythonCmd = Get-PythonCommand
    
    if (-not $pythonCmd) {
        Write-Err "Python $MinPythonVersion or higher is required but not found."
        Write-Info "Please install Python from https://www.python.org/downloads/"
        Write-Info "Make sure to check 'Add Python to PATH' during installation."
        exit 1
    }
    
    $pythonVersion = & $pythonCmd -c "import sys; print(f'{sys.version_info.major}.{sys.version_info.minor}.{sys.version_info.micro}')"
    Write-Success "Found Python $pythonVersion ($pythonCmd)"
    
    # Create virtual environment
    New-Venv -PythonCmd $pythonCmd -VenvPath $VenvDir
    
    # Install s3hero
    Install-S3Hero -VenvPath $VenvDir
    
    # Create wrapper
    New-Wrapper -BinPath $BinDir -VenvPath $VenvDir
    
    # Update PATH
    Update-Path -BinPath $BinDir
    
    Write-Host ""
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Green
    Write-Host "   Installation Complete!" -ForegroundColor Green
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Green
    Write-Host ""
    Write-Info "To get started, open a new PowerShell or Command Prompt and run:"
    Write-Host ""
    Write-Host "    s3hero configure add" -ForegroundColor Cyan
    Write-Host ""
    Write-Info "Or run:"
    Write-Host ""
    Write-Host "    s3hero --help" -ForegroundColor Cyan
    Write-Host ""
}

# Run main
Main
