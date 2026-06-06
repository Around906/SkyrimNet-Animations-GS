#include <SKSE/SKSE.h>
#include "PrismaUIBridge.h"
#include "PrismaUI_API.h"
#include <atomic>
#include <string>

static PRISMA_UI_API::IVPrismaUI1* s_prisma = nullptr;
static PrismaView                  s_view   = 0;
static std::atomic<bool>           s_open{ false };
static std::atomic<bool>           s_watchMovement{ false };

// CreateView path is relative to PrismaUI/views/.
static constexpr const char* kViewHTMLPath = "GSAnim_Menu/index.html";
// Named SKSE mod events the controller listens for (no form lookup needed).
static constexpr const char* kPoseModEvent = "SNAnimGS_PoseSelected";
static constexpr const char* kStopModEvent = "SNAnimGS_StopPose";

void PrismaUIBridge::RequestAPI() noexcept {
    s_prisma = static_cast<PRISMA_UI_API::IVPrismaUI1*>(
        PRISMA_UI_API::RequestPluginAPI(PRISMA_UI_API::InterfaceVersion::V1));
    if (s_prisma)
        SKSE::log::info("[SNAnimGS] PrismaUI API acquired.");
    else
        SKSE::log::warn("[SNAnimGS] PrismaUI not found — pose grid unavailable.");
}

void PrismaUIBridge::CreatePoseView() noexcept {
    if (!s_prisma) return;
    if (s_view && s_prisma->IsValid(s_view)) return;  // already valid
    s_view = s_prisma->CreateView(kViewHTMLPath);
    if (!s_prisma->IsValid(s_view)) {
        SKSE::log::error("[SNAnimGS] Failed to create GSAnim_Menu view at '{}'.", kViewHTMLPath);
        return;
    }
    s_prisma->Hide(s_view);
    s_prisma->RegisterJSListener(s_view, "gsanim_chose", OnJSChoice);
    SKSE::log::info("[SNAnimGS] GSAnim_Menu view created + JS listener registered.");
}

bool PrismaUIBridge::IsAvailable() noexcept { return s_prisma && s_prisma->IsValid(s_view); }
bool PrismaUIBridge::IsMenuOpen() noexcept  { return s_open.load(); }

void PrismaUIBridge::OpenPoseGrid() noexcept {
    if (!IsAvailable()) {
        // View invalidated (e.g. PrismaUI reset after a save load) — try to recreate.
        CreatePoseView();
        if (!IsAvailable()) {
            SKSE::log::error("[SNAnimGS] OpenPoseGrid: view unavailable.");
            return;
        }
    }
    s_open = true;
    s_watchMovement = false;   // browsing the grid, not posing yet
    s_prisma->Show(s_view);
    s_prisma->Invoke(s_view, "window.gsanim_open()");
    // Pause while choosing; cursor still works with the focus menu (disableFocusMenu=false).
    s_prisma->Focus(s_view, /*pauseGame=*/true, /*disableFocusMenu=*/false);
    SKSE::log::info("[SNAnimGS] Pose grid opened.");
}

void PrismaUIBridge::ClosePoseGrid() noexcept {
    if (!s_prisma || !s_open.load()) return;
    s_open = false;
    s_prisma->Unfocus(s_view);
    s_prisma->Hide(s_view);
}

void PrismaUIBridge::CancelMenu() noexcept {
    if (!s_open.load()) return;
    OnJSChoice("");  // cancel -> empty selection
}

void PrismaUIBridge::OnJSChoice(const char* value) noexcept {
    if (!s_prisma) return;
    s_prisma->Unfocus(s_view);
    s_prisma->Hide(s_view);
    s_open = false;

    const std::string pose = value ? value : "";
    s_watchMovement = !pose.empty();   // a real pose was picked -> watch for movement to end it
    SKSE::log::info("[SNAnimGS] OnJSChoice: pose='{}'", pose);

    // Fire the named ModEvent on the main thread. The controller's
    // RegisterForModEvent("SNAnimGS_PoseSelected", "OnPoseSelected") receives it.
    SKSE::GetTaskInterface()->AddTask([pose]() {
        auto* source = SKSE::GetModCallbackEventSource();
        if (!source) return;
        SKSE::ModCallbackEvent ev{};
        ev.eventName = RE::BSFixedString(kPoseModEvent);
        ev.strArg    = RE::BSFixedString(pose.c_str());
        ev.numArg    = 0.0f;
        ev.sender    = nullptr;
        source->SendEvent(&ev);
    });
}

bool PrismaUIBridge::IsWatchingMovement() noexcept { return s_watchMovement.load(); }

void PrismaUIBridge::StopPoseFromMovement() noexcept {
    if (!s_watchMovement.exchange(false)) return;   // fire once
    SKSE::log::info("[SNAnimGS] player moved -> stopping pose");
    SKSE::GetTaskInterface()->AddTask([]() {
        auto* source = SKSE::GetModCallbackEventSource();
        if (!source) return;
        SKSE::ModCallbackEvent ev{};
        ev.eventName = RE::BSFixedString(kStopModEvent);
        ev.strArg    = RE::BSFixedString("");
        ev.numArg    = 0.0f;
        ev.sender    = nullptr;
        source->SendEvent(&ev);
    });
}
