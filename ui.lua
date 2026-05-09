-- UI Module for Alter Time Tracking
local addonName, addon = ...

-- Create namespace for UI
addon.UI = {}
local UI = addon.UI

-- Test mode flag
UI.testMode = false

-- Create the main frame
UI.healthFrame = CreateFrame("Frame", "TestAddonHealthFrame", UIParent)
UI.healthFrame:SetSize(300, 80)
UI.healthFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 200)
UI.healthFrame:SetMovable(true)
UI.healthFrame:EnableMouse(false)
UI.healthFrame:RegisterForDrag("LeftButton")
UI.healthFrame:SetScript("OnDragStart", UI.healthFrame.StartMoving)
UI.healthFrame:SetScript("OnDragStop", function(self)
    self:StopMovingOrSizing()
    -- Save position
    local point, _, relPoint, x, y = self:GetPoint()
    AlterTimeTrackingDB = AlterTimeTrackingDB or {}
    AlterTimeTrackingDB.point = point
    AlterTimeTrackingDB.relPoint = relPoint
    AlterTimeTrackingDB.x = x
    AlterTimeTrackingDB.y = y
end)

-- Create the health text
UI.healthText = UI.healthFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
UI.healthText:SetPoint("TOP", UI.healthFrame, "TOP", 0, 0)
UI.healthText:SetTextColor(1, 1, 1)

-- Get saved settings or defaults
function UI:GetSettings()
    AlterTimeTrackingDB = AlterTimeTrackingDB or {}
    AlterTimeTrackingDB.textFormat = AlterTimeTrackingDB.textFormat or "Saved: %saved | Current: %current"
    AlterTimeTrackingDB.colorR = AlterTimeTrackingDB.colorR or 1
    AlterTimeTrackingDB.colorG = AlterTimeTrackingDB.colorG or 1
    AlterTimeTrackingDB.colorB = AlterTimeTrackingDB.colorB or 0
    AlterTimeTrackingDB.fontSize = AlterTimeTrackingDB.fontSize or 16
    return AlterTimeTrackingDB
end

-- Apply font settings
function UI:ApplyFont()
    local db = self:GetSettings()
    local fontPath = self.healthText:GetFont()
    self.healthText:SetFont(fontPath, db.fontSize, "OUTLINE")
end

-- Function to update display
function UI:UpdateDisplay(savedHealth)
    local db = self:GetSettings()
    
    if self.testMode then
        local text = db.textFormat:gsub("%%saved", "250000"):gsub("%%current", "200000")
        self.healthText:SetText(text)
        self.healthText:SetTextColor(db.colorR, db.colorG, db.colorB)
    elseif savedHealth then
        -- Use SetFormattedText to handle secret numbers with %s
        local format = db.textFormat:gsub("%%saved", "%%s"):gsub("%%current", "%%s")
        self.healthText:SetFormattedText(format, savedHealth, UnitHealth("player"))
        self.healthText:SetTextColor(db.colorR, db.colorG, db.colorB)
    else
        self.healthText:SetText("")
    end
end

-- Load saved position
function UI:LoadPosition()
    if AlterTimeTrackingDB and AlterTimeTrackingDB.point then
        self.healthFrame:ClearAllPoints()
        self.healthFrame:SetPoint(AlterTimeTrackingDB.point, UIParent, AlterTimeTrackingDB.relPoint, AlterTimeTrackingDB.x, AlterTimeTrackingDB.y)
    end
    -- Apply saved font size
    self:ApplyFont()
end

-- Toggle test mode
function UI:ToggleTestMode()
    self.testMode = not self.testMode
    self.healthFrame:EnableMouse(self.testMode)
    if self.testMode then
        print("Test mode ON - Drag the frame to move it. Click again to lock.")
    else
        print("Test mode OFF - Position saved.")
    end
end

-- Create Options Panel
function UI:CreateOptionsPanel()
    local db = self:GetSettings()
    
    local panel = CreateFrame("Frame")
    panel.name = "Alter Time Tracking"

    local title = panel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", 16, -16)
    title:SetText("Alter Time Tracker v1.0.0")
    

    -- Test / Move button
    local testBtn = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
    testBtn:SetPoint("TOPLEFT", 16, -50)
    testBtn:SetSize(120, 25)
    testBtn:SetText("Test / Move")
    testBtn:SetScript("OnClick", function()
        self:ToggleTestMode()
        addon.Core:UpdateDisplay()
    end)

    -- Text Format Label
    local formatLabel = panel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    formatLabel:SetPoint("TOPLEFT", 16, -90)
    formatLabel:SetText("Text Format (use %saved and %current):")

    -- Text Format EditBox
    local formatBox = CreateFrame("EditBox", nil, panel, "InputBoxTemplate")
    formatBox:SetPoint("TOPLEFT", 16, -110)
    formatBox:SetSize(250, 25)
    formatBox:SetAutoFocus(false)
    formatBox:SetScript("OnEnterPressed", function(self)
        db.textFormat = self:GetText()
        self:ClearFocus()
        addon.Core:UpdateDisplay()
    end)
    formatBox:SetScript("OnEscapePressed", function(self)
        self:SetText(db.textFormat or "Saved: %saved | Current: %current")
        self:ClearFocus()
    end)
    
    -- Save Button
    local saveBtn = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
    saveBtn:SetPoint("LEFT", formatBox, "RIGHT", 10, 0)
    saveBtn:SetSize(60, 25)
    saveBtn:SetText("Save")
    saveBtn:SetScript("OnClick", function()
        db.textFormat = formatBox:GetText()
        formatBox:ClearFocus()
        addon.Core:UpdateDisplay()
        print("Text format saved!")
    end)

    -- Color Label
    local colorLabel = panel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    colorLabel:SetPoint("TOPLEFT", 16, -150)
    colorLabel:SetText("Text Color:")

    -- Color Swatch
    local colorSwatch = CreateFrame("Button", nil, panel)
    colorSwatch:SetPoint("TOPLEFT", 16, -170)
    colorSwatch:SetSize(30, 30)
    
    local swatchTexture = colorSwatch:CreateTexture(nil, "BACKGROUND")
    swatchTexture:SetAllPoints()
    swatchTexture:SetColorTexture(db.colorR, db.colorG, db.colorB)
    
    local swatchBorder = colorSwatch:CreateTexture(nil, "BORDER")
    swatchBorder:SetPoint("TOPLEFT", -1, 1)
    swatchBorder:SetPoint("BOTTOMRIGHT", 1, -1)
    swatchBorder:SetColorTexture(0.3, 0.3, 0.3)
    
    -- Font Size Label
    local fontLabel = panel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    fontLabel:SetPoint("TOPLEFT", 100, -150)
    fontLabel:SetText("Font Size:")

    -- Font Size Slider
    local fontSlider = CreateFrame("Slider", "AlterTimeTrackingFontSlider", panel, "OptionsSliderTemplate")
    fontSlider:SetPoint("TOPLEFT", 100, -175)
    fontSlider:SetWidth(150)
    fontSlider:SetMinMaxValues(10, 32)
    fontSlider:SetValueStep(1)
    fontSlider:SetObeyStepOnDrag(true)
    fontSlider:SetValue(db.fontSize or 16)
    fontSlider.Low:SetText("10")
    fontSlider.High:SetText("32")
    fontSlider.Text:SetText(db.fontSize or 16)
    fontSlider:SetScript("OnValueChanged", function(self, value)
        value = math.floor(value + 0.5)
        db.fontSize = value
        self.Text:SetText(value)
        UI:ApplyFont()
    end)

    -- Reset to Defaults Button
    local resetBtn = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
    resetBtn:SetPoint("TOPLEFT", 16, -220)
    resetBtn:SetSize(150, 25)
    resetBtn:SetText("Reset to Defaults")
    resetBtn:SetScript("OnClick", function()
        -- Reset position
        db.point = nil
        db.relPoint = nil
        db.x = nil
        db.y = nil
        UI.healthFrame:ClearAllPoints()
        UI.healthFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 200)
        
        -- Reset text format
        db.textFormat = "Saved: %saved | Current: %current"
        formatBox:SetText(db.textFormat)
        
        -- Reset color
        db.colorR = 1
        db.colorG = 1
        db.colorB = 0
        swatchTexture:SetColorTexture(db.colorR, db.colorG, db.colorB)
        
        -- Reset font size
        db.fontSize = 16
        fontSlider:SetValue(16)
        UI:ApplyFont()
        
        addon.Core:UpdateDisplay()
        print("Settings reset to defaults!")
    end)
    
    -- Refresh when panel is shown
    panel:SetScript("OnShow", function()
        local settings = UI:GetSettings()
        formatBox:SetText(settings.textFormat)
        swatchTexture:SetColorTexture(settings.colorR, settings.colorG, settings.colorB)
        fontSlider:SetValue(settings.fontSize)
    end)

    colorSwatch:SetScript("OnClick", function()
        local info = {}
        info.r = db.colorR
        info.g = db.colorG
        info.b = db.colorB
        info.swatchFunc = function()
            local r, g, b = ColorPickerFrame:GetColorRGB()
            db.colorR = r
            db.colorG = g
            db.colorB = b
            swatchTexture:SetColorTexture(r, g, b)
            addon.Core:UpdateDisplay()
        end
        info.cancelFunc = function(prev)
            db.colorR = prev.r
            db.colorG = prev.g
            db.colorB = prev.b
            swatchTexture:SetColorTexture(prev.r, prev.g, prev.b)
            addon.Core:UpdateDisplay()
        end
        ColorPickerFrame:SetupColorPickerAndShow(info)
    end)

    -- Author at bottom
    local author = panel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    author:SetPoint("BOTTOMLEFT", 16, 40)
    author:SetText("by Tramstarzz-Stormscale, Tramstarz-Stormscale, Tramstarzz-Twisting Nether")
    author:SetTextColor(0.8, 0.8, 0.8)
    
    -- GitHub link at bottom
    local github = panel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    github:SetPoint("BOTTOMLEFT", 16, 20)
    github:SetText("GitHub: github.com/KrunoslavKrainovic/AlterTimeTracking")
    github:SetTextColor(0.4, 0.7, 1)

    local category = Settings.RegisterCanvasLayoutCategory(panel, panel.name)
    Settings.RegisterAddOnCategory(category)
end
