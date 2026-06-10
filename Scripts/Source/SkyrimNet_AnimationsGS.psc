; SkyrimNet Animations — GS Poser : main controller (attach to the SkyrimNet_AnimationsGS quest).
; Animations are by Gunslicer (GSPoses) — https://www.patreon.com/Gunslicer — and are NOT bundled.
Scriptname SkyrimNet_AnimationsGS extends Quest

; Fill in CK: the lesser power that opens the selector (auto-granted to the player on init).
Spell Property OpenSelectorSpell Auto

Actor  PlayerRef
String _sCurrentPose     = ""
String _sCurrentPoseDesc = ""

Event OnInit()
    _Setup()
EndEvent

Function _Setup()
    PlayerRef = Game.GetPlayer()
    If OpenSelectorSpell && !PlayerRef.HasSpell(OpenSelectorSpell)
        PlayerRef.AddSpell(OpenSelectorSpell, False)
    EndIf
    ; Pose pick (from the DLL) + NPC Senses "an NPC saw something".
    RegisterForModEvent("SNAnimGS_PoseSelected", "OnPoseSelected")
    RegisterForModEvent("SNAnimGS_StopPose",     "OnStopPose")
    Debug.Trace("[SNAnimGS] Setup complete. power granted=" + (OpenSelectorSpell != None))
EndFunction

; Female-only is enforced in _PoseVibe (the exec no-ops on male NPCs) and stated in each action's
; description. We deliberately do NOT gate eligibility on a custom "gsanim_female" decorator: the
; LLM evaluates action eligibility for nearby NPCs before/independent of this quest registering
; the decorator, which floods the log with "Decorator not found" (same trap as baka_flirted).

; ── Called by the power's magic effect (SkyrimNet_AnimGS_Power) ──────────────
Function OpenSelector()
    If !SNAnimGSUI.IsAvailable()
        Debug.Notification("GS pose selector: UI not ready (PrismaUI / SNAnimGS_UI.dll missing?).")
        Return
    EndIf
    SNAnimGSUI.OpenPoseGrid()
EndFunction

; ── DLL fires this when the player clicks a pose. asPose = "GS123" ("" = cancel) ──
Event OnPoseSelected(String asEventName, String asPose, Float afNum, Form akSender)
    If asPose == ""
        Return
    EndIf
    ; The grid sends "GS123|short description" — split so we play the event but narrate the description.
    String[] parts = StringUtil.Split(asPose, "|")
    _sCurrentPose     = parts[0]
    _sCurrentPoseDesc = ""
    If parts.Length > 1
        _sCurrentPoseDesc = parts[1]
    EndIf
    Debug.SendAnimationEvent(PlayerRef, _sCurrentPose)
    String what = "a deliberate pose"
    If _sCurrentPoseDesc != ""
        what = "a pose — " + _sCurrentPoseDesc
    EndIf
    SkyrimNetApi.RegisterEvent("gsanim_player_pose", \
        PlayerRef.GetDisplayName() + " strikes " + what + ", holding it for show.", \
        PlayerRef, None)
EndEvent

; DLL fires this when the player presses a movement key (WASD / jump) while posing — drop the
; held idle (GS poses are designed to hold in place, so any movement should end them).
Event OnStopPose(String asEventName, String asArg, Float afNum, Form akSender)
    If _sCurrentPose != ""
        Debug.SendAnimationEvent(PlayerRef, "IdleForceDefaultState")
        ClearPose()
        Debug.Trace("[SNAnimGS] pose stopped (player moved).")
    EndIf
EndEvent

; Clears the "currently posing" flags.
Function ClearPose()
    _sCurrentPose     = ""
    _sCurrentPoseDesc = ""
EndFunction

; ════════════════════════════════════════════════════════════════════════════
;  NPC POSE VIBES — the LLM fires a vibe action; we play a random pose from it.
;  Female-only, held in place. Casual poses are freed if the NPC enters combat
;  (no one is "holding" them); the submission vibe stays locked through combat.
; ════════════════════════════════════════════════════════════════════════════
; Real-seconds hard stop — NPC poses auto-end after this (the LLM rarely picks StopPosing).
; Active vibes (workout / stretch / dance) hold longer; everything else ends sooner.
Float Property fPoseTimeoutActive  = 45.0 Auto   ; workout, stretch, dance, dance_sexy
Float Property fPoseTimeoutDefault = 25.0 Auto   ; all other vibes

; Per-vibe hard-stop duration. Exercise/stretch/dance read well held longer; the rest get 25s.
Float Function _VibeTimeout(String vibe)
    If vibe == "workout" || vibe == "stretch" || vibe == "dance" || vibe == "dance_sexy"
        Return fPoseTimeoutActive
    EndIf
    Return fPoseTimeoutDefault
EndFunction

; Comma-separated GS events per vibe (compact; edit to re-curate). Mirrors poses.js groups
; minus the player-only ones (explicit, situational).
String Function _VibeCSV(String vibe)
    If vibe == "seduce"
        Return "GS1,GS2,GS3,GS17,GS25,GS26,GS31,GS36,GS56,GS62,GS63,GS66,GS70,GS80,GS84,GS189,GS198"
    ElseIf vibe == "selftouch"
        Return "GS6,GS7,GS18,GS46,GS55,GS60,GS69,GS71,GS72,GS87"
    ElseIf vibe == "present"
        Return "GS4,GS5,GS11,GS37,GS38,GS43,GS86,GS88,GS99,GS118,GS130,GS162,GS190,GS193,GS202"
    ElseIf vibe == "dance"
        Return "GS21,GS27,GS34,GS42,GS47,GS48,GS58,GS59,GS79,GS95,GS125,GS132,GS133,GS154,GS209"
    ElseIf vibe == "dance_sexy"
        Return "GS9,GS10,GS12,GS13,GS14,GS15,GS23,GS29,GS44,GS52,GS61,GS83,GS102,GS107,GS144,GS187"
    ElseIf vibe == "ground_sexy"
        Return "GS253,GS257,GS261,GS267,GS271,GS275,GS282,GS285,GS305,GS306,GS311,GS316"
    ElseIf vibe == "ground_idle"
        Return "GS128,GS256,GS270,GS276,GS278,GS286,GS287,GS289,GS295,GS296,GS313,GS314,GS317,GS697,GS698,GS699,GS706,GS712"
    ElseIf vibe == "workout"
        Return "GS156,GS182,GS658,GS659,GS660,GS661,GS663,GS664,GS665,GS666,GS667,GS672,GS676,GS681,GS683,GS690"
    ElseIf vibe == "stretch"
        Return "GS662,GS668,GS669,GS670,GS671,GS673,GS674,GS678,GS679,GS680,GS684,GS686,GS689,GS691"
    ElseIf vibe == "submission"
        Return "GS51,GS700,GS705,GS707,GS708,GS709,GS710"
    ElseIf vibe == "plead"
        Return "GS701,GS702,GS703"
    ElseIf vibe == "idle"
        Return "GS131,GS135,GS147,GS177,GS196,GS624,GS628,GS629,GS632,GS639"
    EndIf
    Return ""
EndFunction

Function _PacifyGS(Actor ak, Bool on)
    If !ak
        Return
    EndIf
    If on
        If StorageUtil.GetIntValue(ak, "GSAnim.Pacified", 0) == 0
            StorageUtil.SetFloatValue(ak, "GSAnim.OrigAggr", ak.GetActorValue("Aggression"))
            StorageUtil.SetIntValue(ak, "GSAnim.Pacified", 1)
        EndIf
        ak.SetActorValue("Aggression", 0.0)
        ak.StopCombatAlarm()
        ak.StopCombat()
    ElseIf StorageUtil.GetIntValue(ak, "GSAnim.Pacified", 0) == 1
        ak.SetActorValue("Aggression", StorageUtil.GetFloatValue(ak, "GSAnim.OrigAggr", 1.0))
        StorageUtil.SetIntValue(ak, "GSAnim.Pacified", 0)
    EndIf
EndFunction

; Play a random pose from `vibe` on a FEMALE NPC, held in place; notify SkyrimNet.
; NOTE: "don't pose when busy" is enforced at the ELIGIBILITY layer (each pose_*.yaml gates on
; is_in_combat==false, is_busy==false, and not in the SexLab/OStim animating factions), so the LLM
; never picks a pose for an occupied NPC. The OnUpdate monitor also frees a casual poser who later
; enters combat. We deliberately keep no exec-side busy guard (it duplicated eligibility and forced
; a SexLab script dependency that won't compile against STOCK GAME source).
Function _PoseVibe(Actor ak, String vibe, String label)
    If !ak || ak == PlayerRef
        Return
    EndIf
    If ak.GetActorBase().GetSex() != 1     ; female only — males look wrong posing
        Return
    EndIf
    String csv = _VibeCSV(vibe)
    If csv == ""
        Return
    EndIf
    String[] list = StringUtil.Split(csv, ",")
    String ev = list[Utility.RandomInt(0, list.Length - 1)]
    Bool lockAI = (vibe == "submission")
    ak.SetRestrained(True)
    _PacifyGS(ak, True)
    If lockAI
        ak.SetDontMove(True)   ; bound/surrendered — a fight shouldn't break it
    EndIf
    Debug.SendAnimationEvent(ak, ev)
    StorageUtil.SetStringValue(ak, "GSAnim.Pose",    ev)
    StorageUtil.SetFloatValue(ak,  "GSAnim.Start",   Utility.GetCurrentRealTime())
    StorageUtil.SetFloatValue(ak,  "GSAnim.Timeout", _VibeTimeout(vibe))
    StorageUtil.SetIntValue(ak,    "GSAnim.LockAI",  lockAI as Int)
    StorageUtil.FormListAdd(None,  "GSAnim.Posing", ak, False)
    SkyrimNetApi.RegisterEvent("gsanim_npc_pose", \
        ak.GetDisplayName() + " strikes " + label + ", holding it in place.", ak, None)
    RegisterForSingleUpdate(3.0)
EndFunction

Function _StopActorPose(Actor ak)
    If !ak
        Return
    EndIf
    Debug.SendAnimationEvent(ak, "IdleForceDefaultState")
    ak.SetRestrained(False)
    ak.SetDontMove(False)
    _PacifyGS(ak, False)
    StorageUtil.SetStringValue(ak, "GSAnim.Pose", "")
EndFunction

; Monitor: free casual posers who entered combat / timed out; submission stays unless dead.
Event OnUpdate()
    Int i = StorageUtil.FormListCount(None, "GSAnim.Posing") - 1
    Bool anyLeft = False
    While i >= 0
        Actor ak = StorageUtil.FormListGet(None, "GSAnim.Posing", i) as Actor
        If !ak || StorageUtil.GetStringValue(ak, "GSAnim.Pose", "") == ""
            StorageUtil.FormListRemoveAt(None, "GSAnim.Posing", i)
        Else
            Bool  lockAI  = StorageUtil.GetIntValue(ak, "GSAnim.LockAI", 0) == 1
            Float elapsed = Utility.GetCurrentRealTime() - StorageUtil.GetFloatValue(ak, "GSAnim.Start", 0.0)
            Float timeout = StorageUtil.GetFloatValue(ak, "GSAnim.Timeout", fPoseTimeoutDefault)
            If (!lockAI && ak.IsInCombat()) || elapsed > timeout || ak.IsDead()
                _StopActorPose(ak)
                StorageUtil.FormListRemoveAt(None, "GSAnim.Posing", i)
            Else
                anyLeft = True
            EndIf
        EndIf
        i -= 1
    EndWhile
    If anyLeft
        RegisterForSingleUpdate(3.0)
    EndIf
EndEvent

; ── SkyrimNet vibe-action execs (speaker only — individual poses) ─────────────
Function PoseSeduce_Execute(Actor akInitiator)
    _PoseVibe(akInitiator, "seduce", "a seductive pose")
EndFunction
Function PoseSelftouch_Execute(Actor akInitiator)
    _PoseVibe(akInitiator, "selftouch", "an aroused, self-touching pose")
EndFunction
Function PosePresent_Execute(Actor akInitiator)
    _PoseVibe(akInitiator, "present", "a bent-over, presenting pose")
EndFunction
Function PoseDance_Execute(Actor akInitiator)
    _PoseVibe(akInitiator, "dance", "a dance")
EndFunction
Function PoseDanceSexy_Execute(Actor akInitiator)
    _PoseVibe(akInitiator, "dance_sexy", "a sexy dance")
EndFunction
Function PoseGroundSexy_Execute(Actor akInitiator)
    _PoseVibe(akInitiator, "ground_sexy", "a sultry pose on the ground")
EndFunction
Function PoseGroundIdle_Execute(Actor akInitiator)
    _PoseVibe(akInitiator, "ground_idle", "a spent / idle pose on the ground")
EndFunction
Function PoseWorkout_Execute(Actor akInitiator)
    _PoseVibe(akInitiator, "workout", "a workout")
EndFunction
Function PoseStretch_Execute(Actor akInitiator)
    _PoseVibe(akInitiator, "stretch", "a stretch / yoga pose")
EndFunction
Function PoseSubmission_Execute(Actor akInitiator)
    _PoseVibe(akInitiator, "submission", "a submissive / bound pose")
EndFunction
Function PosePlead_Execute(Actor akInitiator)
    _PoseVibe(akInitiator, "plead", "a pleading / praying pose")
EndFunction
Function PoseIdle_Execute(Actor akInitiator)
    _PoseVibe(akInitiator, "idle", "an idle pose")
EndFunction

; LLM ends the pose; no-ops if not currently posing.
Function StopPosing_Execute(Actor akInitiator)
    _StopActorPose(akInitiator)
EndFunction

; One character tells another to stop posing (roleplay: "stop that"). No-op if the target isn't posing.
Function CommandStopPose_Execute(Actor akInitiator, Actor akTarget)
    _StopActorPose(akTarget)
EndFunction
