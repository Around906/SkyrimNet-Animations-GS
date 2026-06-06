; Papyrus stub for SNAnimGS_UI.dll (SKSE plugin — PrismaUI bridge for the pose grid).
; If the DLL is absent these are no-ops / return false.
Scriptname SNAnimGSUI

; True when PrismaUI is loaded and the pose-grid view is ready.
Bool Function IsAvailable() Global Native

; Show the pose-selector grid (pauses the game). The view reads poses.json itself.
; The player's pick comes back asynchronously via the SKSE mod event
; "SNAnimGS_PoseSelected" (strArg = the GS animation event, e.g. "GS123"; "" on cancel).
Function OpenPoseGrid() Global Native

; Force-close the pose grid (e.g. on cancel from script).
Function ClosePoseGrid() Global Native
