#pragma once

namespace RE { namespace BSScript { class IVirtualMachine; } }

// Registers the native functions backing the Papyrus "SNAnimGSUI" script.
namespace PapyrusFunctions {
    bool Register(RE::BSScript::IVirtualMachine* vm);
}
