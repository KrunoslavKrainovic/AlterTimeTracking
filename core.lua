-- Core Module for Alter Time Tracking
local addonName, addon = ...

-- Create namespace for Core
addon.Core = {}
local Core = addon.Core

-- Tracking
Core.savedHealth = nil
Core.savedHealthPercent = nil

-- Alter Time spell IDs
local ALTER_TIME_SPELL_ID = 342247
local ALTER_TIME_RECALL_ID = 371817
local debugMode = false

-- Slash command to toggle debug mode
SLASH_ATDEBUG1 = "/atdebug"
SlashCmdList["ATDEBUG"] = function()
    debugMode = not debugMode
end

-- Function to update display
function Core:UpdateDisplay()
    addon.UI:UpdateDisplay(self.savedHealth, self.savedHealthPercent)
end

-- Initialize core functionality
function Core:Init()
    local frame = CreateFrame("Frame")
    frame:RegisterUnitEvent("UNIT_HEALTH", "player")
    frame:RegisterEvent("PLAYER_ENTERING_WORLD")
    frame:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
    frame:RegisterEvent("ADDON_LOADED")
    
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
                if spellID == ALTER_TIME_RECALL_ID then
                    if Core.savedHealth == nil then
                        Core.savedHealth = UnitHealth("player")
                        Core.savedHealthPercent = UnitHealthPercent("player", true, CurveConstants.ScaleTo100) or 100
                    end
                elseif spellID == ALTER_TIME_SPELL_ID then
                    Core.savedHealth = nil
                    Core.savedHealthPercent = nil
                end
            end
        end
        Core:UpdateDisplay()
    end)
end

-- Slash command to open options
SLASH_ALTERTIMETRACKING1 = "/att"
SlashCmdList["ALTERTIMETRACKING"] = function()
    Settings.OpenToCategory("Alter Time Tracking")
end

-- Initialize
Core:Init()
