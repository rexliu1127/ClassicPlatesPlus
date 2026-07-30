WOW_PROJECT_CLASSIC = 1
WOW_PROJECT_MAINLINE = 2
WOW_PROJECT_CATACLYSM_CLASSIC = 3
WOW_PROJECT_ID = WOW_PROJECT_CLASSIC

NamePlateDriverFrame = nil
PersonalFriendlyBuffFrame = nil

local hookCalls = 0
local installedHook

function hooksecurefunc(target, method, callback)
    assert(type(target) == "table", "hook target is unavailable")
    assert(type(target[method]) == "function", "hook method is unavailable")

    hookCalls = hookCalls + 1
    installedHook = callback
end

local core = {}
local chunk, loadError = loadfile("ClassicPlatesPlus/core.lua")
assert(chunk, loadError)

local loaded, runtimeError = pcall(chunk, "ClassicPlatesPlus", core)
assert(loaded, "core.lua must load without NamePlateDriverFrame: " .. tostring(runtimeError))
assert(type(core.func.Update_Health) == "function", "Update_Health must be defined")
assert(type(core.func.HookNamePlateDriver) == "function", "deferred hook function must be defined")
assert(hookCalls == 0, "hook must not be installed while the driver is unavailable")

local resizeNameplates = core.func.ResizeNameplates

NamePlateDriverFrame = {
    ApplyFrameOptions = function() end,
}

core.func:HookNamePlateDriver()
core.func:HookNamePlateDriver()

assert(hookCalls == 1, "nameplate driver hook must only be installed once")
assert(type(installedHook) == "function", "resize callback must be registered")

local resizeCalls = 0
core.func.ResizeNameplates = function()
    resizeCalls = resizeCalls + 1
end

installedHook(NamePlateDriverFrame, {})
assert(resizeCalls == 1, "the installed hook must resize nameplates")

CFG_ClassicPlatesPlus = {
    Profile = "test",
}
CFG_Account_ClassicPlatesPlus = {
    Profiles = {
        test = {
            Portrait = true,
            ShowLevel = true,
            Powerbar = true,
            NameplatesScale = 1,
            LargeName = true,
            ShowGuildName = true,
            LargeGuildName = false,
            ThreatPercentage = true,
        },
    },
}

function IsInInstance()
    return false, "none"
end

function InCombatLockdown()
    return false
end

local unifiedSizeCalls = 0
C_NamePlate = {
    SetNamePlateSize = function(width, height)
        unifiedSizeCalls = unifiedSizeCalls + 1
        assert(width == 164, "unified nameplate width must preserve the calculated value")
        assert(height == 48, "unified nameplate height must preserve the calculated value")
    end,
}

resizeNameplates()
assert(unifiedSizeCalls == 1, "the unified nameplate size API must be called once")

local friendlySizeCalls = 0
local enemySizeCalls = 0
C_NamePlate = {
    SetNamePlateFriendlySize = function(width, height)
        friendlySizeCalls = friendlySizeCalls + 1
        assert(width == 164 and height == 48, "legacy friendly size must preserve calculated values")
    end,
    SetNamePlateEnemySize = function(width, height)
        enemySizeCalls = enemySizeCalls + 1
        assert(width == 164 and height == 48, "legacy enemy size must preserve calculated values")
    end,
}

resizeNameplates()
assert(friendlySizeCalls == 1, "legacy friendly size API must remain supported")
assert(enemySizeCalls == 1, "legacy enemy size API must remain supported")

print("PASS: Classic Era nameplate API compatibility")
