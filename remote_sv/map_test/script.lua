-- ===== OVERRIDE MECHANISM + RACE TEST (prompt_sandy_beaches dev only) =====
-- Pushed to remote_sv/map_test/ ; referenced ONLY by the local dev loader.
-- Safe to delete anytime. Does NOT include the real mapdata-match logic,
-- so the local server's mapdata report is intentionally disabled during the test.

print("^5[OVTEST] remote test script loaded, installing override...^7")

local _origMeta = GetResourceMetadata
GetResourceMetadata = function(res, key, idx)
    if key == "version" then
        return "1.0.2"   -- match the remote version file so the baked check stays silent
    end
    return _origMeta(res, key, idx)
end

-- Mechanism proof (independent of any race): can we shadow the native at all?
local realV = _origMeta(GetCurrentResourceName(), "version", 0)
local seenV = GetResourceMetadata(GetCurrentResourceName(), "version", 0)
print(("^5[OVTEST] real fxmanifest version = %s^7"):format(tostring(realV)))
print(("^5[OVTEST] shadowed value returned = %s^7"):format(tostring(seenV)))
if seenV == "1.0.2" and realV ~= "1.0.2" then
    print("^2[OVTEST] _G shadow WORKS — native IS overridable in this build^7")
else
    print("^1[OVTEST] _G shadow FAILED — environment is locked, override won't work^7")
end
print("^5[OVTEST] override installed^7")
