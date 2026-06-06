#include "PCH.h"
#include "PrismaUIBridge.h"
#include "PapyrusFunctions.h"
#include <spdlog/sinks/basic_file_sink.h>
#include <RE/B/BSInputDeviceManager.h>
#include <RE/I/InputEvent.h>
#include <RE/B/ButtonEvent.h>

// Closes the pose grid on ESC or Tab so the player can't get stuck with it focused.
class MenuInputHandler : public RE::BSTEventSink<RE::InputEvent*> {
public:
    static MenuInputHandler* GetSingleton() {
        static MenuInputHandler instance;
        return &instance;
    }

    RE::BSEventNotifyControl ProcessEvent(RE::InputEvent* const* a_event,
                                          RE::BSTEventSource<RE::InputEvent*>*) override {
        if (!a_event) return RE::BSEventNotifyControl::kContinue;
        const bool menuOpen = PrismaUIBridge::IsMenuOpen();
        const bool watching = PrismaUIBridge::IsWatchingMovement();
        if (!menuOpen && !watching) return RE::BSEventNotifyControl::kContinue;

        for (auto* ev = *a_event; ev; ev = ev->next) {
            if (ev->GetEventType() != RE::INPUT_EVENT_TYPE::kButton) continue;
            if (ev->GetDevice()    != RE::INPUT_DEVICE::kKeyboard)   continue;
            auto* btn = ev->AsButtonEvent();
            if (!btn) continue;

            constexpr std::uint32_t kEscape = 1;
            constexpr std::uint32_t kTab    = 15;
            // Grid open: Esc/Tab cancels (consume the key).
            if (menuOpen && btn->IsDown() && (btn->idCode == kEscape || btn->idCode == kTab)) {
                PrismaUIBridge::CancelMenu();
                return RE::BSEventNotifyControl::kStop;
            }
            // Posing: WASD / jump / sprint / sneak ends the held pose. Use IsPressed (held OR
            // tapped) since a held movement key only reports "down" on its first frame. Don't
            // consume the key — let the player actually move; we just drop the idle.
            if (watching && btn->IsPressed()) {
                constexpr std::uint32_t kW = 17, kA = 30, kS = 31, kD = 32, kSpace = 57, kLShift = 42, kC = 46;
                const std::uint32_t c = btn->idCode;
                if (c == kW || c == kA || c == kS || c == kD || c == kSpace || c == kLShift || c == kC)
                    PrismaUIBridge::StopPoseFromMovement();
            }
        }
        return RE::BSEventNotifyControl::kContinue;
    }
};

static void SetupLog() {
    auto logsFolder = SKSE::log::log_directory();
    if (!logsFolder) return;
    auto logPath = *logsFolder / "SNAnimGS_UI.log";
    auto sink = std::make_shared<spdlog::sinks::basic_file_sink_mt>(logPath.string(), true);
    auto logger = std::make_shared<spdlog::logger>("SNAnimGS_UI", std::move(sink));
    logger->set_level(spdlog::level::trace);
    logger->flush_on(spdlog::level::trace);
    spdlog::set_default_logger(std::move(logger));
}

SKSEPluginLoad(const SKSE::LoadInterface* skse) {
    SKSE::Init(skse);
    SetupLog();
    SKSE::log::info("[SNAnimGS] Plugin loaded.");

    SKSE::GetMessagingInterface()->RegisterListener([](SKSE::MessagingInterface::Message* msg) {
        switch (msg->type) {
        case SKSE::MessagingInterface::kPostLoad:
            PrismaUIBridge::RequestAPI();
            break;
        case SKSE::MessagingInterface::kDataLoaded:
            PrismaUIBridge::CreatePoseView();
            RE::BSInputDeviceManager::GetSingleton()->AddEventSink(MenuInputHandler::GetSingleton());
            SKSE::log::info("[SNAnimGS] Input handler registered.");
            break;
        }
    });

    SKSE::GetPapyrusInterface()->Register(PapyrusFunctions::Register);
    return true;
}
