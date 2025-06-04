
$offsets = (Invoke-WebRequest -Uri "https://raw.githubusercontent.com/a2x/cs2-dumper/refs/heads/main/output/offsets.rs").Content

$dwEntityList = $offsets -split "`n" | Where-Object { $_ -like "*pub const dwEntityList: usize =*" }
$dwLocalPlayerController = $offsets -split "`n" | Where-Object { $_ -like "*pub const dwLocalPlayerController: usize =*" }
$dwLocalPlayerPawn = $offsets -split "`n" | Where-Object { $_ -like "*pub const dwLocalPlayerPawn: usize =*" }
$dwPlantedC4 = $offsets -split "`n" | Where-Object { $_ -like "*pub const dwPlantedC4: usize =*" }
$dwViewAngles = $offsets -split "`n" | Where-Object { $_ -like "*pub const dwViewAngles: usize =*" }
$dwViewMatrix = $offsets -split "`n" | Where-Object { $_ -like "*pub const dwViewMatrix: usize =*" }

$client_dll = (Invoke-WebRequest -Uri "https://raw.githubusercontent.com/a2x/cs2-dumper/refs/heads/main/output/client_dll.rs").Content

$m_iHealth = $client_dll -split "`n" | Where-Object { $_ -like "*pub const m_iHealth: usize =*" }
$m_iTeamNum = $client_dll -split "`n" | Where-Object { $_ -like "*pub const m_iTeamNum: usize = *" }
$m_pGameSceneNode = $client_dll -split "`n" | Where-Object { $_ -like "*pub const m_pGameSceneNode: usize =*" }
$m_fFlags = $client_dll -split "`n" | Where-Object { $_ -like "*pub const m_fFlags: usize =* uint32*" }
$m_nSubclassID = $client_dll -split "`n" | Where-Object { $_ -like "*pub const m_nSubclassID: usize =*" }
$m_hPawn = $client_dll -split "`n" | Where-Object { $_ -like "*pub const m_hPawn: usize =*" }
$m_iszPlayerName = $client_dll -split "`n" | Where-Object { $_ -like "*pub const m_iszPlayerName: usize =*" }
$m_hPlayerPawn = $client_dll -split "`n" | Where-Object { $_ -like "*pub const m_hPlayerPawn: usize =*" }
$m_bPawnIsAlive = $client_dll -split "`n" | Where-Object { $_ -like "*pub const m_bPawnIsAlive: usize =*" }
$mm_pObserverServices = $client_dll -split "`n" | Where-Object { $_ -like "*pub const m_pObserverServices: usize =*" }
$m_pCameraServices = $client_dll -split "`n" | Where-Object { $_ -like "*pub const m_pCameraServices: usize =*" }
$m_vOldOrigin = $client_dll -split "`n" | Where-Object { $_ -like "*pub const m_vOldOrigin: usize =*" }
$m_vecLastClipCameraPos = $client_dll -split "`n" | Where-Object { $_ -like "*pub const m_vecLastClipCameraPos: usize =*" }
$m_angEyeAngles = $client_dll -split "`n" | Where-Object { $_ -like "*pub const m_angEyeAngles: usize =*" }
$m_pClippingWeapon = $client_dll -split "`n" | Where-Object { $_ -like "*pub const m_pClippingWeapon: usize =*" }
$m_iIDEntIndex = $client_dll -split "`n" | Where-Object { $_ -like "*pub const m_iIDEntIndex: usize =*" }
$m_entitySpottedState = $client_dll -split "`n" | Where-Object { $_ -like "*pub const m_entitySpottedState: usize =*" }
$m_ArmorValue = $client_dll -split "`n" | Where-Object { $_ -like "*pub const m_ArmorValue: usize =*" }
$m_iShotsFired = $client_dll -split "`n" | Where-Object { $_ -like "*pub const m_iShotsFired: usize =*" }
$m_aimPunchCache = $client_dll -split "`n" | Where-Object { $_ -like "*pub const m_aimPunchCache: usize =*" }
$m_vecAbsOrigin = $client_dll -split "`n" | Where-Object { $_ -like "*pub const m_vecAbsOrigin: usize =*" }
$m_iFOVStart = $client_dll -split "`n" | Where-Object { $_ -like "*pub const m_iFOVStart: usize =*" }
$m_bSpottedByMask = $client_dll -split "`n" | Where-Object { $_ -like "*pub const m_bSpottedByMask: usize =*" }
$m_modelState = $client_dll -split "`n" | Where-Object { $_ -like "*pub const m_modelState: usize =*" }
$m_hObserverTarget = $client_dll -split "`n" | Where-Object { $_ -like "*pub const m_hObserverTarget: usize =*" }
$m_nBombSite = $client_dll -split "`n" | Where-Object { $_ -like "*pub const m_nBombSite: usize =*" }
$m_iMaxClip1 = $client_dll -split "`n" | Where-Object { $_ -like "*pub const m_iMaxClip1: usize =*" }
$m_iClip1 = $client_dll -split "`n" | Where-Object { $_ -like "*pub const m_iClip1: usize =*" }

(Get-Content "./src/config.rs") | ForEach-Object {
    if ($_ -like "*pub const dwEntityList: usize =*") {
        $dwEntityList.Substring(4)
    } elseif ($_ -like "*pub const dwLocalPlayerController: usize =*") {
        $dwLocalPlayerController.Substring(4)
    } elseif ($_ -like "*pub const dwLocalPlayerPawn: usize =*") {
        $dwLocalPlayerPawn.Substring(4)
    } elseif ($_ -like "*pub const dwPlantedC4: usize =*") {
        $dwPlantedC4.Substring(4)
    } elseif ($_ -like "*pub const dwViewAngles: usize =*") {
        $dwViewAngles.Substring(4)
    } elseif ($_ -like "*pub const dwViewMatrix: usize =*") {
        $dwViewMatrix.Substring(4)
    } elseif ($_ -like "*pub const m_iHealth: usize =*") {
        $m_iHealth.Substring(4)
    } elseif ($_ -like "*pub const m_iTeamNum: usize =*") {
        $m_iTeamNum.Substring(4)
    } elseif ($_ -like "*pub const m_pGameSceneNode: usize =*") {
        $m_pGameSceneNode.Substring(4)
    } elseif ($_ -like "*pub const m_fFlags: usize =*") {
        $m_fFlags.Substring(4)
    } elseif ($_ -like "*pub const m_nSubclassID: usize =*") {
        $m_nSubclassID.Substring(4)
    } elseif ($_ -like "*pub const m_hPawn: usize =*") {
        $m_hPawn.Substring(4)
    } elseif ($_ -like "*pub const m_iszPlayerName: usize =*") {
        $m_iszPlayerName.Substring(4)
    } elseif ($_ -like "*pub const m_hPlayerPawn: usize =*") {
        $m_hPlayerPawn.Substring(4)
    } elseif ($_ -like "*pub const m_bPawnIsAlive: usize =*") {
        $m_bPawnIsAlive.Substring(4)
    } elseif ($_ -like "*pub const mm_pObserverServices: usize =*") {
        $mm_pObserverServices.Substring(4)
    } elseif ($_ -like "*pub const m_pCameraServices: usize =*") {
        $m_pCameraServices.Substring(4)
    } elseif ($_ -like "*pub const m_vOldOrigin: usize =*") {
        $m_vOldOrigin.Substring(4)
    } elseif ($_ -like "*pub const m_vecLastClipCameraPos: usize =*") {
        $m_vecLastClipCameraPos.Substring(4)
    } elseif ($_ -like "*pub const m_angEyeAngles: usize =*") {
        $m_angEyeAngles.Substring(4)
    } elseif ($_ -like "*pub const m_pClippingWeapon: usize =*") {
        $m_pClippingWeapon.Substring(4)
    } elseif ($_ -like "*pub const m_iIDEntIndex: usize =*") {
        $m_iIDEntIndex.Substring(4)
    } elseif ($_ -like "*pub const m_entitySpottedState: usize =*") {
        $m_entitySpottedState[0].Substring(4)
    } elseif ($_ -like "*pub const m_ArmorValue: usize =*") {
        $m_ArmorValue.Substring(4)
    } elseif ($_ -like "*pub const m_iShotsFired: usize =*") {
        $m_iShotsFired.Substring(4)
    } elseif ($_ -like "*pub const m_aimPunchCache: usize =*") {
        $m_aimPunchCache.Substring(4)
    } elseif ($_ -like "*pub const m_vecAbsOrigin: usize =*") {
        $m_vecAbsOrigin.Substring(4)
    } elseif ($_ -like "*pub const m_iFOVStart: usize =*") {
        $m_iFOVStart.Substring(4)
    } elseif ($_ -like "*pub const m_bSpottedByMask: usize =*") {
        $m_bSpottedByMask.Substring(4)
    } elseif ($_ -like "*pub const m_modelState: usize =*") {
        $m_modelState.Substring(4)
    } elseif ($_ -like "*pub const m_hObserverTarget: usize =*") {
        $m_hObserverTarget.Substring(4)
    } elseif ($_ -like "*pub const m_nBombSite: usize =*") {
        $m_nBombSite.Substring(4)
    } elseif ($_ -like "*pub const m_iMaxClip1: usize =*") {
        $m_iMaxClip1.Substring(4)
    } elseif ($_ -like "*pub const m_iClip1: usize =*") {
        $m_iClip1.Substring(4)
    } else {
         $_
    }

} | Set-Content "./src/config.rs"