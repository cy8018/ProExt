
<#
.SYNOPSIS
    Updates CS2 offsets from cs2-dumper repository and shows comparison of changes.

.DESCRIPTION
    This script fetches the latest offsets from the cs2-dumper repository,
    compares them with the current offsets in config.rs, and optionally updates them.
    
.PARAMETER CheckOnly
    Only check for changes without applying them.
    
.PARAMETER Force
    Apply changes automatically without prompting for confirmation.
    
.PARAMETER NoDeploy
    Skip automatic deployment after applying changes.
    
.EXAMPLE
    .\update_offsets.ps1
    Normal mode - fetch, compare, prompt to apply changes, and deploy if changes applied
    
.EXAMPLE
    .\update_offsets.ps1 -CheckOnly
    Check for changes without applying them
    
.EXAMPLE  
    .\update_offsets.ps1 -Force
    Apply changes automatically without confirmation and deploy
    
.EXAMPLE  
    .\update_offsets.ps1 -NoDeploy
    Apply changes but skip automatic deployment
#>

param(
    [switch]$CheckOnly,
    [switch]$Force,
    [switch]$NoDeploy
)

# Function to extract generation date from offsets content
function Get-GenerationDate {
    param([string]$Content)
    
    # Look for the date pattern in the content
    if ($Content -match "// (\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}\.\d+) UTC") {
        return $matches[1]
    }
    return "Unknown"
}

# Extract offset values with null checking
function Get-SafeOffsetValue {
    param([string]$Content, [string]$Pattern)
    $result = $Content -split "`n" | Where-Object { $_ -like "*pub const $Pattern*" }
    if ($result) {
        # Return first match if multiple found
        if ($result -is [array]) {
            return $result[0]
        } else {
            return $result
        }
    } else {
        return ""
    }
}

# Function to compare and display changes
function Compare-OffsetChanges {
    param(
        [string]$OldFile,
        [string]$NewFile,
        [string]$GenerationDate = "Unknown"
    )
    
    Write-Host "=== OFFSET COMPARISON ===" -ForegroundColor Cyan
    Write-Host ""
    
    $oldContent = Get-Content $OldFile
    $newContent = Get-Content $NewFile
    
    $changes = @()
    
    # Extract offset values from both files
    $offsetPatterns = @(
        "dwEntityList", "dwLocalPlayerController", "dwLocalPlayerPawn", "dwPlantedC4", "dwViewAngles", "dwViewMatrix",
        "m_iHealth", "m_iTeamNum", "m_pGameSceneNode", "m_fFlags", "m_nSubclassID", "m_hPawn", "m_iszPlayerName",
        "m_hPlayerPawn", "m_bPawnIsAlive", "m_pObserverServices", "m_pCameraServices", "m_vOldOrigin",
        "m_vecLastClipCameraPos", "m_angEyeAngles", "m_pClippingWeapon", "m_iIDEntIndex", "m_entitySpottedState",
        "m_ArmorValue", "m_iShotsFired", "m_aimPunchCache", "m_vecAbsOrigin", "m_iFOVStart", "m_bSpottedByMask",
        "m_modelState", "m_hObserverTarget", "m_nBombSite", "m_iMaxClip1", "m_iClip1"
    )
    
    foreach ($pattern in $offsetPatterns) {
        $oldLine = $oldContent | Where-Object { $_ -like "*pub const $pattern*" }
        $newLine = $newContent | Where-Object { $_ -like "*pub const $pattern*" }
        
        if ($oldLine -and $newLine) {
            # Extract hex values
            $oldValue = if ($oldLine -match "0x[0-9A-Fa-f]+") { $matches[0] } else { "Not found" }
            $newValue = if ($newLine -match "0x[0-9A-Fa-f]+") { $matches[0] } else { "Not found" }
            
            if ($oldValue -ne $newValue) {
                $changes += [PSCustomObject]@{
                    Offset = $pattern
                    OldValue = $oldValue
                    NewValue = $newValue
                    Status = "Changed"
                }
                Write-Host "CHANGED: $pattern" -ForegroundColor Yellow
                Write-Host "  Old: $oldValue" -ForegroundColor Red
                Write-Host "  New: $newValue" -ForegroundColor Green
                Write-Host ""
            }
            # Skip outputting unchanged items for cleaner display
        }
    }
    
    if ($changes.Count -eq 0) {
        Write-Host "No changes detected in offsets!" -ForegroundColor Green
        Write-Host "Updated: $GenerationDate UTC" -ForegroundColor Cyan
    } else {
        Write-Host "=== SUMMARY ===" -ForegroundColor Cyan
        Write-Host "Total changes: $($changes.Count)" -ForegroundColor Yellow
        Write-Host "Updated: $GenerationDate UTC" -ForegroundColor Cyan
        Write-Host ""
    }
    
    return $changes
}

# Create backup of current config
if (-not $CheckOnly) {
    $backupFile = "./src/config.rs.backup"
    Copy-Item "./src/config.rs" $backupFile
    Write-Host "Backup created: $backupFile" -ForegroundColor Green
}

# Fetch new offsets
Write-Host "Fetching latest offsets..." -ForegroundColor Cyan

try {
    $offsets = (Invoke-WebRequest -Uri "https://raw.githubusercontent.com/a2x/cs2-dumper/refs/heads/main/output/offsets.rs").Content
    $client_dll = (Invoke-WebRequest -Uri "https://raw.githubusercontent.com/a2x/cs2-dumper/refs/heads/main/output/client_dll.rs").Content
    Write-Host "Offsets fetched successfully!" -ForegroundColor Green
} catch {
    Write-Host "Error fetching offsets: $_" -ForegroundColor Red
    Write-Host "Please check your internet connection and try again." -ForegroundColor Yellow
    exit 1
}

# Extract generation date from offsets
$generationDate = Get-GenerationDate -Content $offsets
Write-Host "Offsets updated: $generationDate UTC" -ForegroundColor Cyan

$dwEntityList = Get-SafeOffsetValue -Content $offsets -Pattern "dwEntityList: usize =*"
$dwLocalPlayerController = Get-SafeOffsetValue -Content $offsets -Pattern "dwLocalPlayerController: usize =*"
$dwLocalPlayerPawn = Get-SafeOffsetValue -Content $offsets -Pattern "dwLocalPlayerPawn: usize =*"
$dwPlantedC4 = Get-SafeOffsetValue -Content $offsets -Pattern "dwPlantedC4: usize =*"
$dwViewAngles = Get-SafeOffsetValue -Content $offsets -Pattern "dwViewAngles: usize =*"
$dwViewMatrix = Get-SafeOffsetValue -Content $offsets -Pattern "dwViewMatrix: usize =*"

$m_iHealth = Get-SafeOffsetValue -Content $client_dll -Pattern "m_iHealth: usize =*"
$m_iTeamNum = Get-SafeOffsetValue -Content $client_dll -Pattern "m_iTeamNum: usize = *"
$m_pGameSceneNode = Get-SafeOffsetValue -Content $client_dll -Pattern "m_pGameSceneNode: usize =*"
$m_fFlags = Get-SafeOffsetValue -Content $client_dll -Pattern "m_fFlags: usize =* uint32*"
$m_nSubclassID = Get-SafeOffsetValue -Content $client_dll -Pattern "m_nSubclassID: usize =*"
$m_hPawn = Get-SafeOffsetValue -Content $client_dll -Pattern "m_hPawn: usize =*"
$m_iszPlayerName = Get-SafeOffsetValue -Content $client_dll -Pattern "m_iszPlayerName: usize =*"
$m_hPlayerPawn = Get-SafeOffsetValue -Content $client_dll -Pattern "m_hPlayerPawn: usize =*"
$m_bPawnIsAlive = Get-SafeOffsetValue -Content $client_dll -Pattern "m_bPawnIsAlive: usize =*"
$m_pObserverServices = Get-SafeOffsetValue -Content $client_dll -Pattern "m_pObserverServices: usize =*"
$m_pCameraServices = Get-SafeOffsetValue -Content $client_dll -Pattern "m_pCameraServices: usize =*"
$m_vOldOrigin = Get-SafeOffsetValue -Content $client_dll -Pattern "m_vOldOrigin: usize =*"
$m_vecLastClipCameraPos = Get-SafeOffsetValue -Content $client_dll -Pattern "m_vecLastClipCameraPos: usize =*"
$m_angEyeAngles = Get-SafeOffsetValue -Content $client_dll -Pattern "m_angEyeAngles: usize =*"
$m_pClippingWeapon = Get-SafeOffsetValue -Content $client_dll -Pattern "m_pClippingWeapon: usize =*"
$m_iIDEntIndex = Get-SafeOffsetValue -Content $client_dll -Pattern "m_iIDEntIndex: usize =*"
$m_entitySpottedState = Get-SafeOffsetValue -Content $client_dll -Pattern "m_entitySpottedState: usize =*"
$m_ArmorValue = Get-SafeOffsetValue -Content $client_dll -Pattern "m_ArmorValue: usize =*"
$m_iShotsFired = Get-SafeOffsetValue -Content $client_dll -Pattern "m_iShotsFired: usize =*"
$m_aimPunchCache = Get-SafeOffsetValue -Content $client_dll -Pattern "m_aimPunchCache: usize =*"
$m_vecAbsOrigin = Get-SafeOffsetValue -Content $client_dll -Pattern "m_vecAbsOrigin: usize =*"
$m_iFOVStart = Get-SafeOffsetValue -Content $client_dll -Pattern "m_iFOVStart: usize =*"
$m_bSpottedByMask = Get-SafeOffsetValue -Content $client_dll -Pattern "m_bSpottedByMask: usize =*"
$m_modelState = Get-SafeOffsetValue -Content $client_dll -Pattern "m_modelState: usize =*"
$m_hObserverTarget = Get-SafeOffsetValue -Content $client_dll -Pattern "m_hObserverTarget: usize =*"
$m_nBombSite = Get-SafeOffsetValue -Content $client_dll -Pattern "m_nBombSite: usize =*"
$m_iMaxClip1 = Get-SafeOffsetValue -Content $client_dll -Pattern "m_iMaxClip1: usize =*"
$m_iClip1 = Get-SafeOffsetValue -Content $client_dll -Pattern "m_iClip1: usize =*"

# If check-only mode, just compare without updating
if ($CheckOnly) {
    Write-Host "=== CHECK-ONLY MODE ===" -ForegroundColor Magenta
    Write-Host "Comparing current offsets with latest from repository..." -ForegroundColor Cyan
    
    # Create temporary file with new offsets
    $tempFile = "./src/config.rs.temp"
    (Get-Content "./src/config.rs") | ForEach-Object {
        if ($_ -like "*pub const dwEntityList: usize =*" -and $dwEntityList) {
            $dwEntityList.Substring(4)
        } elseif ($_ -like "*pub const dwLocalPlayerController: usize =*" -and $dwLocalPlayerController) {
            $dwLocalPlayerController.Substring(4)
        } elseif ($_ -like "*pub const dwLocalPlayerPawn: usize =*" -and $dwLocalPlayerPawn) {
            $dwLocalPlayerPawn.Substring(4)
        } elseif ($_ -like "*pub const dwPlantedC4: usize =*" -and $dwPlantedC4) {
            $dwPlantedC4.Substring(4)
        } elseif ($_ -like "*pub const dwViewAngles: usize =*" -and $dwViewAngles) {
            $dwViewAngles.Substring(4)
        } elseif ($_ -like "*pub const dwViewMatrix: usize =*" -and $dwViewMatrix) {
            $dwViewMatrix.Substring(4)
        } elseif ($_ -like "*pub const m_iHealth: usize =*" -and $m_iHealth) {
            $m_iHealth.Substring(8)
        } elseif ($_ -like "*pub const m_iTeamNum: usize =*" -and $m_iTeamNum) {
            $m_iTeamNum.Substring(8)
        } elseif ($_ -like "*pub const m_pGameSceneNode: usize =*" -and $m_pGameSceneNode) {
            $m_pGameSceneNode.Substring(8)
        } elseif ($_ -like "*pub const m_fFlags: usize =*" -and $m_fFlags) {
            $m_fFlags.Substring(8)
        } elseif ($_ -like "*pub const m_nSubclassID: usize =*" -and $m_nSubclassID) {
            $m_nSubclassID.Substring(8)
        } elseif ($_ -like "*pub const m_hPawn: usize =*" -and $m_hPawn) {
            $m_hPawn.Substring(8)
        } elseif ($_ -like "*pub const m_iszPlayerName: usize =*" -and $m_iszPlayerName) {
            $m_iszPlayerName.Substring(8)
        } elseif ($_ -like "*pub const m_hPlayerPawn: usize =*" -and $m_hPlayerPawn) {
            $m_hPlayerPawn.Substring(8)
        } elseif ($_ -like "*pub const m_bPawnIsAlive: usize =*" -and $m_bPawnIsAlive) {
            $m_bPawnIsAlive.Substring(8)
        } elseif ($_ -like "*pub const m_pObserverServices: usize =*" -and $m_pObserverServices) {
            $m_pObserverServices.Substring(8)
        } elseif ($_ -like "*pub const m_pCameraServices: usize =*" -and $m_pCameraServices) {
            $m_pCameraServices.Substring(8)
        } elseif ($_ -like "*pub const m_vOldOrigin: usize =*" -and $m_vOldOrigin) {
            $m_vOldOrigin.Substring(8)
        } elseif ($_ -like "*pub const m_vecLastClipCameraPos: usize =*" -and $m_vecLastClipCameraPos) {
            $m_vecLastClipCameraPos.Substring(8)
        } elseif ($_ -like "*pub const m_angEyeAngles: usize =*" -and $m_angEyeAngles) {
            $m_angEyeAngles.Substring(8)
        } elseif ($_ -like "*pub const m_pClippingWeapon: usize =*" -and $m_pClippingWeapon) {
            $m_pClippingWeapon.Substring(8)
        } elseif ($_ -like "*pub const m_iIDEntIndex: usize =*" -and $m_iIDEntIndex) {
            $m_iIDEntIndex.Substring(8)
        } elseif ($_ -like "*pub const m_entitySpottedState: usize =*" -and $m_entitySpottedState) {
            $m_entitySpottedState.Substring(8)
        } elseif ($_ -like "*pub const m_ArmorValue: usize =*" -and $m_ArmorValue) {
            $m_ArmorValue.Substring(8)
        } elseif ($_ -like "*pub const m_iShotsFired: usize =*" -and $m_iShotsFired) {
            $m_iShotsFired.Substring(8)
        } elseif ($_ -like "*pub const m_aimPunchCache: usize =*" -and $m_aimPunchCache) {
            $m_aimPunchCache.Substring(8)
        } elseif ($_ -like "*pub const m_vecAbsOrigin: usize =*" -and $m_vecAbsOrigin) {
            $m_vecAbsOrigin.Substring(8)
        } elseif ($_ -like "*pub const m_iFOVStart: usize =*" -and $m_iFOVStart) {
            $m_iFOVStart.Substring(8)
        } elseif ($_ -like "*pub const m_bSpottedByMask: usize =*" -and $m_bSpottedByMask) {
            $m_bSpottedByMask.Substring(8)
        } elseif ($_ -like "*pub const m_modelState: usize =*" -and $m_modelState) {
            $m_modelState.Substring(8)
        } elseif ($_ -like "*pub const m_hObserverTarget: usize =*" -and $m_hObserverTarget) {
            $m_hObserverTarget.Substring(8)
        } elseif ($_ -like "*pub const m_nBombSite: usize =*" -and $m_nBombSite) {
            $m_nBombSite.Substring(8)
        } elseif ($_ -like "*pub const m_iMaxClip1: usize =*" -and $m_iMaxClip1) {
            $m_iMaxClip1.Substring(8)
        } elseif ($_ -like "*pub const m_iClip1: usize =*" -and $m_iClip1) {
            $m_iClip1.Substring(8)
        } else {
             $_
        }
    } | Set-Content $tempFile
    
    $changes = Compare-OffsetChanges -OldFile "./src/config.rs" -NewFile $tempFile -GenerationDate $generationDate
    Remove-Item $tempFile -ErrorAction SilentlyContinue
    
    if ($changes.Count -gt 0) {
        Write-Host ""
        Write-Host "Run without -CheckOnly to apply these changes." -ForegroundColor Yellow
    }
    return
}

(Get-Content "./src/config.rs") | ForEach-Object {
    if ($_ -like "*pub const dwEntityList: usize =*" -and $dwEntityList) {
        $dwEntityList.Substring(4)
    } elseif ($_ -like "*pub const dwLocalPlayerController: usize =*" -and $dwLocalPlayerController) {
        $dwLocalPlayerController.Substring(4)
    } elseif ($_ -like "*pub const dwLocalPlayerPawn: usize =*" -and $dwLocalPlayerPawn) {
        $dwLocalPlayerPawn.Substring(4)
    } elseif ($_ -like "*pub const dwPlantedC4: usize =*" -and $dwPlantedC4) {
        $dwPlantedC4.Substring(4)
    } elseif ($_ -like "*pub const dwViewAngles: usize =*" -and $dwViewAngles) {
        $dwViewAngles.Substring(4)
    } elseif ($_ -like "*pub const dwViewMatrix: usize =*" -and $dwViewMatrix) {
        $dwViewMatrix.Substring(4)
    } elseif ($_ -like "*pub const m_iHealth: usize =*" -and $m_iHealth) {
        $m_iHealth.Substring(8)
    } elseif ($_ -like "*pub const m_iTeamNum: usize =*" -and $m_iTeamNum) {
        $m_iTeamNum.Substring(8)
    } elseif ($_ -like "*pub const m_pGameSceneNode: usize =*" -and $m_pGameSceneNode) {
        $m_pGameSceneNode.Substring(8)
    } elseif ($_ -like "*pub const m_fFlags: usize =*" -and $m_fFlags) {
        $m_fFlags.Substring(8)
    } elseif ($_ -like "*pub const m_nSubclassID: usize =*" -and $m_nSubclassID) {
        $m_nSubclassID.Substring(8)
    } elseif ($_ -like "*pub const m_hPawn: usize =*" -and $m_hPawn) {
        $m_hPawn.Substring(8)
    } elseif ($_ -like "*pub const m_iszPlayerName: usize =*" -and $m_iszPlayerName) {
        $m_iszPlayerName.Substring(8)
    } elseif ($_ -like "*pub const m_hPlayerPawn: usize =*" -and $m_hPlayerPawn) {
        $m_hPlayerPawn.Substring(8)
    } elseif ($_ -like "*pub const m_bPawnIsAlive: usize =*" -and $m_bPawnIsAlive) {
        $m_bPawnIsAlive.Substring(8)
    } elseif ($_ -like "*pub const m_pObserverServices: usize =*" -and $m_pObserverServices) {
        $m_pObserverServices.Substring(8)
    } elseif ($_ -like "*pub const m_pCameraServices: usize =*" -and $m_pCameraServices) {
        $m_pCameraServices.Substring(8)
    } elseif ($_ -like "*pub const m_vOldOrigin: usize =*" -and $m_vOldOrigin) {
        $m_vOldOrigin.Substring(8)
    } elseif ($_ -like "*pub const m_vecLastClipCameraPos: usize =*" -and $m_vecLastClipCameraPos) {
        $m_vecLastClipCameraPos.Substring(8)
    } elseif ($_ -like "*pub const m_angEyeAngles: usize =*" -and $m_angEyeAngles) {
        $m_angEyeAngles.Substring(8)
    } elseif ($_ -like "*pub const m_pClippingWeapon: usize =*" -and $m_pClippingWeapon) {
        $m_pClippingWeapon.Substring(8)
    } elseif ($_ -like "*pub const m_iIDEntIndex: usize =*" -and $m_iIDEntIndex) {
        $m_iIDEntIndex.Substring(8)
    } elseif ($_ -like "*pub const m_entitySpottedState: usize =*" -and $m_entitySpottedState) {
        $m_entitySpottedState.Substring(8)
    } elseif ($_ -like "*pub const m_ArmorValue: usize =*" -and $m_ArmorValue) {
        $m_ArmorValue.Substring(8)
    } elseif ($_ -like "*pub const m_iShotsFired: usize =*" -and $m_iShotsFired) {
        $m_iShotsFired.Substring(8)
    } elseif ($_ -like "*pub const m_aimPunchCache: usize =*" -and $m_aimPunchCache) {
        $m_aimPunchCache.Substring(8)
    } elseif ($_ -like "*pub const m_vecAbsOrigin: usize =*" -and $m_vecAbsOrigin) {
        $m_vecAbsOrigin.Substring(8)
    } elseif ($_ -like "*pub const m_iFOVStart: usize =*" -and $m_iFOVStart) {
        $m_iFOVStart.Substring(8)
    } elseif ($_ -like "*pub const m_bSpottedByMask: usize =*" -and $m_bSpottedByMask) {
        $m_bSpottedByMask.Substring(8)
    } elseif ($_ -like "*pub const m_modelState: usize =*" -and $m_modelState) {
        $m_modelState.Substring(8)
    } elseif ($_ -like "*pub const m_hObserverTarget: usize =*" -and $m_hObserverTarget) {
        $m_hObserverTarget.Substring(8)
    } elseif ($_ -like "*pub const m_nBombSite: usize =*" -and $m_nBombSite) {
        $m_nBombSite.Substring(8)
    } elseif ($_ -like "*pub const m_iMaxClip1: usize =*" -and $m_iMaxClip1) {
        $m_iMaxClip1.Substring(8)
    } elseif ($_ -like "*pub const m_iClip1: usize =*" -and $m_iClip1) {
        $m_iClip1.Substring(8)
    } else {
         $_
    }

} | Set-Content "./src/config.rs"

# Compare changes
Write-Host ""
Write-Host "Comparing changes..." -ForegroundColor Cyan
$changes = Compare-OffsetChanges -OldFile $backupFile -NewFile "./src/config.rs" -GenerationDate $generationDate

# Ask user if they want to keep changes or restore backup
if ($changes.Count -gt 0) {
    Write-Host ""
    if ($Force) {
        Write-Host "Force mode enabled - applying changes automatically." -ForegroundColor Green
        $response = "y"
    } else {
        $response = Read-Host "Do you want to keep these changes? (y/n) [default: y]"
    }
    
    if ($response -eq "n" -or $response -eq "N") {
        Copy-Item $backupFile "./src/config.rs"
        Write-Host "Changes reverted. Original file restored." -ForegroundColor Yellow
    } else {
        Write-Host "Changes applied successfully!" -ForegroundColor Green
        
        # Call deploy script if changes were applied and NoDeploy is not set
        if (-not $NoDeploy) {
            Write-Host ""
            Write-Host "Deploying updated build..." -ForegroundColor Cyan
            try {
                & ".\scripts\deploy.ps1"
                Write-Host "Deployment completed successfully!" -ForegroundColor Green
            } catch {
                Write-Host "Deployment failed: $_" -ForegroundColor Red
                Write-Host "You may need to run deploy manually: .\scripts\deploy.ps1" -ForegroundColor Yellow
            }
        } else {
            Write-Host "Skipping deployment (NoDeploy flag set)" -ForegroundColor Yellow
            Write-Host "Run .\scripts\deploy.ps1 manually when ready to deploy" -ForegroundColor Gray
        }
    }
} else {
    Write-Host "No changes to apply." -ForegroundColor Green
}

# Clean up backup file
if (-not $CheckOnly) {
    Remove-Item $backupFile -ErrorAction SilentlyContinue
    Write-Host "Backup file cleaned up." -ForegroundColor Gray
}