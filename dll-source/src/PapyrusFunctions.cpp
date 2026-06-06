#include "PapyrusFunctions.h"
#include <SKSE/SKSE.h>
#include "PrismaUIBridge.h"

// Must match Scriptname in SNAnimGSUI.psc.
static constexpr const char* kScriptName = "SNAnimGSUI";

static bool SNAnimGSUI_IsAvailable(RE::StaticFunctionTag*) {
    return PrismaUIBridge::IsAvailable();
}

static void SNAnimGSUI_OpenPoseGrid(RE::StaticFunctionTag*) {
    PrismaUIBridge::OpenPoseGrid();
}

static void SNAnimGSUI_ClosePoseGrid(RE::StaticFunctionTag*) {
    PrismaUIBridge::ClosePoseGrid();
}

bool PapyrusFunctions::Register(RE::BSScript::IVirtualMachine* vm) {
    vm->RegisterFunction("IsAvailable",   kScriptName, SNAnimGSUI_IsAvailable);
    vm->RegisterFunction("OpenPoseGrid",  kScriptName, SNAnimGSUI_OpenPoseGrid);
    vm->RegisterFunction("ClosePoseGrid", kScriptName, SNAnimGSUI_ClosePoseGrid);
    SKSE::log::info("[SNAnimGS] Papyrus functions registered.");
    return true;
}
