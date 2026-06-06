; Magic-effect script for the "GS Pose Selector" lesser power. Attach to SNAnimGS_OpenSelectorMGEF.
; On cast it just asks the controller quest to open the PrismaUI pose grid.
Scriptname SkyrimNet_AnimGS_Power extends ActiveMagicEffect

; Fill in CK: point this at the SkyrimNet_AnimationsGS quest.
SkyrimNet_AnimationsGS Property Controller Auto

Event OnEffectStart(Actor akTarget, Actor akCaster)
    If Controller
        Controller.OpenSelector()
    Else
        Debug.Notification("GS Pose Selector: Controller property not set in CK.")
    EndIf
EndEvent
