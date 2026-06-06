#pragma once

// Bridge between Papyrus / the game and the GSAnim_Menu PrismaUI pose-grid view.
namespace PrismaUIBridge {
    // kPostLoad: resolve the PrismaUI plugin API.
    void RequestAPI() noexcept;
    // kDataLoaded: create the (hidden) pose-grid view + register the JS listener.
    void CreatePoseView() noexcept;

    // True when PrismaUI is loaded and the view is valid.
    bool IsAvailable() noexcept;
    // True while the grid is on screen (used by the Esc/Tab input sink).
    bool IsMenuOpen() noexcept;

    // Show the grid + pause the game (called from the SNAnimGSUI.OpenPoseGrid native).
    void OpenPoseGrid() noexcept;
    // Hide the grid without a selection (script-initiated).
    void ClosePoseGrid() noexcept;
    // Esc / Tab -> cancel: closes and reports an empty pick.
    void CancelMenu() noexcept;

    // JS listener callback (window.gsanim_chose). value = "GS123" or "" on cancel.
    void OnJSChoice(const char* value) noexcept;

    // After the PLAYER picks a pose we watch for movement keys (WASD / jump). The input sink
    // calls these: while IsWatchingMovement() is true, any movement key fires the
    // "SNAnimGS_StopPose" mod event (-> controller forces IdleForceDefaultState) since GS poses
    // are designed to hold in place. Cleared once stopped or when the grid reopens.
    bool IsWatchingMovement() noexcept;
    void StopPoseFromMovement() noexcept;
}
