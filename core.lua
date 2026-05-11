-- Core Module for Alter Time Tracking
local addonName, addon = ...

-- Create namespace for Core
addon.Core = {}
local Core = addon.Core

-- Tracking
Core.savedHealth = nil
Core.savedHealthPercent = nil
Core.alterTimeStartTime = nil
Core.alterTimeDuration = 10

-- Alter Time spell IDs
local ALTER_TIME_SPELL_ID = 342247  -- Cast spell
local ALTER_TIME_BUFF_ID = 342246   -- Actual buff
local ALTER_TIME_RECALL_ID = 371817 -- Recall spell
local debugMode = false

-- Slash command to toggle debug mode
SLASH_ATDEBUG1 = "/atdebug"
SlashCmdList["ATDEBUG"] = function()
    debugMode = not debugMode
end

-- Function to update display
function Core:UpdateDisplay()
    local remainingTime = nil
    if self.alterTimeStartTime then
        local elapsed = GetTime() - self.alterTimeStartTime
        remainingTime = self.alterTimeDuration - elapsed
        if remainingTime <= 0 then
            self.alterTimeStartTime = nil
            remainingTime = nil
            -- Clear saved health when timer expires
            self.savedHealth = nil
            self.savedHealthPercent = nil
        end
    end
    addon.UI:UpdateDisplay(self.savedHealth, self.savedHealthPercent, remainingTime)
end

-- Initialize core functionality
function Core:Init()
    local frame = CreateFrame("Frame")
    frame:RegisterUnitEvent("UNIT_HEALTH", "player")
    frame:RegisterEvent("PLAYER_ENTERING_WORLD")
    frame:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
    frame:RegisterEvent("ADDON_LOADED")
    frame:RegisterUnitEvent("UNIT_AURA", "player")
    
    frame:SetScript("OnEvent", function(self, event, ...)
        if event == "ADDON_LOADED" then
            local loadedAddon = ...
            if loadedAddon == addonName then
                addon.UI:LoadPosition()
                addon.UI:CreateOptionsPanel()
            end
        elseif event == "UNIT_SPELLCAST_SUCCEEDED" then
            local unit, castGUID, spellID = ...
            if unit == "player" then
                if spellID == ALTER_TIME_SPELL_ID then
                    -- Alter Time was cast (to cancel) - clear everything
                    Core.savedHealth = nil
                    Core.savedHealthPercent = nil
                    Core.alterTimeStartTime = nil
                end
            end
        elseif event == "UNIT_AURA" then
            -- Check if Alter Time buff exists (342246)
            local hasAlterTimeBuff = C_UnitAuras.GetPlayerAuraBySpellID(ALTER_TIME_BUFF_ID)
            
            if hasAlterTimeBuff and not Core.savedHealth then
                -- Buff just appeared - save health and start timer
                Core.savedHealth = UnitHealth("player")
                Core.savedHealthPercent = UnitHealthPercent("player", true, CurveConstants.ScaleTo100) or 100
                Core.alterTimeStartTime = GetTime()
            elseif not hasAlterTimeBuff and Core.savedHealth then
                -- Buff disappeared (dispelled, spell stolen, canceled, or expired) - clear everything
                Core.savedHealth = nil
                Core.savedHealthPercent = nil
                Core.alterTimeStartTime = nil
            end
        end
        Core:UpdateDisplay()
    end)
    
    -- OnUpdate handler for timer
    frame:SetScript("OnUpdate", function(self, elapsed)
        if Core.alterTimeStartTime then
            Core:UpdateDisplay()
        end
    end)
end

-- Slash command to open options
SLASH_ALTERTIMETRACKING1 = "/att"
SlashCmdList["ALTERTIMETRACKING"] = function()
    Settings.OpenToCategory("Alter Time Tracking")
end

-- Initialize
Core:Init()
