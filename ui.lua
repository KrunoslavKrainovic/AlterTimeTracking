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

-- Create the timer frame (separate and movable)
UI.timerFrame = CreateFrame("Frame", "AlterTimeTimerFrame", UIParent)
UI.timerFrame:SetSize(150, 30)
UI.timerFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 150)
UI.timerFrame:SetMovable(true)
UI.timerFrame:EnableMouse(false)
UI.timerFrame:RegisterForDrag("LeftButton")
UI.timerFrame:SetScript("OnDragStart", UI.timerFrame.StartMoving)
UI.timerFrame:SetScript("OnDragStop", function(self)
    self:StopMovingOrSizing()
    -- Save timer position
    local point, _, relPoint, x, y = self:GetPoint()
    AlterTimeTrackingDB = AlterTimeTrackingDB or {}
    AlterTimeTrackingDB.timerPoint = point
    AlterTimeTrackingDB.timerRelPoint = relPoint
    AlterTimeTrackingDB.timerX = x
    AlterTimeTrackingDB.timerY = y
end)

-- Create the timer text
UI.timerText = UI.timerFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
UI.timerText:SetPoint("CENTER", UI.timerFrame, "CENTER", 0, 0)
UI.timerText:SetTextColor(1, 1, 1)
UI.timerText:SetText("")

-- Create the icon frame (separate movable display)
UI.iconFrame = CreateFrame("Frame", "AlterTimeIconFrame", UIParent)
UI.iconFrame:SetSize(64, 64)
UI.iconFrame:SetPoint("CENTER", UIParent, "CENTER", -200, 0)
UI.iconFrame:SetMovable(true)
UI.iconFrame:EnableMouse(false)
UI.iconFrame:RegisterForDrag("LeftButton")
UI.iconFrame:SetScript("OnDragStart", UI.iconFrame.StartMoving)
UI.iconFrame:SetScript("OnDragStop", function(self)
    self:StopMovingOrSizing()
    -- Save icon position
    local point, _, relPoint, x, y = self:GetPoint()
    AlterTimeTrackingDB = AlterTimeTrackingDB or {}
    AlterTimeTrackingDB.iconPoint = point
    AlterTimeTrackingDB.iconRelPoint = relPoint
    AlterTimeTrackingDB.iconX = x
    AlterTimeTrackingDB.iconY = y
end)

-- Create the icon texture (Alter Time spell icon)
UI.iconTexture = UI.iconFrame:CreateTexture(nil, "ARTWORK")
UI.iconTexture:SetSize(64, 64)
UI.iconTexture:SetPoint("CENTER", UI.iconFrame, "CENTER", 0, 0)
UI.iconTexture:SetTexture(609811) -- Alter Time spell icon texture ID

-- Create current health text on icon (top)
UI.iconCurrentText = UI.iconFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
UI.iconCurrentText:SetPoint("TOP", UI.iconFrame, "TOP", 0, -2)
UI.iconCurrentText:SetTextColor(1, 1, 1)
UI.iconCurrentText:SetText("")

-- Create timer text on icon (middle)
UI.iconTimerText = UI.iconFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
UI.iconTimerText:SetPoint("CENTER", UI.iconFrame, "CENTER", 0, 0)
UI.iconTimerText:SetTextColor(1, 1, 1)
UI.iconTimerText:SetText("")

-- Create saved health text on icon (bottom)
UI.iconSavedText = UI.iconFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
UI.iconSavedText:SetPoint("BOTTOM", UI.iconFrame, "BOTTOM", 0, 2)
UI.iconSavedText:SetTextColor(1, 1, 0)
UI.iconSavedText:SetText("")

-- Get saved settings or defaults
function UI:GetSettings()
    AlterTimeTrackingDB = AlterTimeTrackingDB or {}
    AlterTimeTrackingDB.textFormat = AlterTimeTrackingDB.textFormat or "Alter HP: %saved | Current HP: %current"
    AlterTimeTrackingDB.colorR = AlterTimeTrackingDB.colorR or 1
    AlterTimeTrackingDB.colorG = AlterTimeTrackingDB.colorG or 1
    AlterTimeTrackingDB.colorB = AlterTimeTrackingDB.colorB or 0
    AlterTimeTrackingDB.fontSize = AlterTimeTrackingDB.fontSize or 16
    AlterTimeTrackingDB.iconSize = AlterTimeTrackingDB.iconSize or 64
    AlterTimeTrackingDB.shortNumbers = AlterTimeTrackingDB.shortNumbers or false
    if AlterTimeTrackingDB.usePercent == nil then AlterTimeTrackingDB.usePercent = true end
    if AlterTimeTrackingDB.showTimer == nil then AlterTimeTrackingDB.showTimer = false end
    if AlterTimeTrackingDB.showIcon == nil then AlterTimeTrackingDB.showIcon = true end
    if AlterTimeTrackingDB.showHealthText == nil then AlterTimeTrackingDB.showHealthText = false end
    return AlterTimeTrackingDB
end

-- Format number (300000 -> 300k)
function UI:FormatNumber(num)
    local db = self:GetSettings()
    if not db.shortNumbers then
        return tostring(num)
    end
    if num >= 1000000 then
        return string.format("%.1fm", num / 1000000)
    elseif num >= 1000 then
        return string.format("%.0fk", num / 1000)
    else
        return tostring(num)
    end
end

-- Apply font settings
function UI:ApplyFont()
    local db = self:GetSettings()
    local fontPath = self.healthText:GetFont()
    self.healthText:SetFont(fontPath, db.fontSize, "OUTLINE")
    self.timerText:SetFont(fontPath, db.fontSize, "OUTLINE")
    -- Apply font to icon text elements
    self.iconCurrentText:SetFont(fontPath, db.fontSize, "OUTLINE")
    self.iconTimerText:SetFont(fontPath, db.fontSize, "OUTLINE")
    self.iconSavedText:SetFont(fontPath, db.fontSize, "OUTLINE")
    -- Apply icon size
    self.iconFrame:SetSize(db.iconSize, db.iconSize)
    self.iconTexture:SetSize(db.iconSize, db.iconSize)
end

-- Function to update display
function UI:UpdateDisplay(savedHealth, savedHealthPercent, remainingTime)
    local db = self:GetSettings()
    
    -- Update timer text separately
    if db.showTimer then
        if self.testMode then
            self.timerText:SetText("5.0s")
            self.timerText:SetTextColor(db.colorR, db.colorG, db.colorB)
        elseif remainingTime then
            self.timerText:SetText(string.format("%.1f", remainingTime) .. "s")
            self.timerText:SetTextColor(db.colorR, db.colorG, db.colorB)
        else
            self.timerText:SetText("")
        end
    else
        self.timerText:SetText("")
    end
    
    -- Update icon display
    if db.showIcon and (savedHealth or self.testMode) then
        self.iconFrame:Show()
        if self.testMode then
            self.iconTimerText:SetText("5.0s")
            if db.usePercent then
                self.iconSavedText:SetText("83%")
                self.iconCurrentText:SetText("67%")
            elseif db.shortNumbers then
                self.iconSavedText:SetText("250k")
                self.iconCurrentText:SetText("200k")
            else
                self.iconSavedText:SetText("250000")
                self.iconCurrentText:SetText("200000")
            end
        else
            -- Update timer on icon
            if remainingTime then
                self.iconTimerText:SetText(string.format("%.1f", remainingTime) .. "s")
            else
                self.iconTimerText:SetText("")
            end
            
            -- Update saved health on icon
            if db.usePercent and savedHealthPercent then
                self.iconSavedText:SetText(string.format("%.0f", savedHealthPercent) .. "%")
            elseif db.shortNumbers then
                self.iconSavedText:SetText(AbbreviateNumbers(savedHealth))
            else
                self.iconSavedText:SetText(tostring(savedHealth))
            end
            
            -- Update current health on icon
            if db.usePercent then
                local currentPercent = UnitHealthPercent("player", true, CurveConstants.ScaleTo100) or 0
                self.iconCurrentText:SetText(string.format("%.0f", currentPercent) .. "%")
            elseif db.shortNumbers then
                self.iconCurrentText:SetText(AbbreviateNumbers(UnitHealth("player")))
            else
                self.iconCurrentText:SetText(tostring(UnitHealth("player")))
            end
        end
    else
        self.iconFrame:Hide()
        self.iconTimerText:SetText("")
        self.iconSavedText:SetText("")
        self.iconCurrentText:SetText("")
    end
    
    if self.testMode then
        if db.showHealthText then
            local savedDisplay, currentDisplay
            if db.usePercent then
                savedDisplay = "83%%"
                currentDisplay = "67%%"
            elseif db.shortNumbers then
                savedDisplay = "250k"
                currentDisplay = "200k"
            else
                savedDisplay = "250000"
                currentDisplay = "200000"
            end
            -- gsub replacement needs %% to produce a literal %
            local text = db.textFormat:gsub("%%saved", savedDisplay):gsub("%%current", currentDisplay)
            self.healthText:SetText(text)
            self.healthText:SetTextColor(db.colorR, db.colorG, db.colorB)
        else
            self.healthText:SetText("")
        end
    elseif savedHealth then
        if db.showHealthText then
            if db.usePercent and savedHealthPercent then
                -- Use percent display
                local currentPercent = UnitHealthPercent("player", true, CurveConstants.ScaleTo100) or 0
                local format = db.textFormat:gsub("%%saved", "%%s%%%%"):gsub("%%current", "%%s%%%%")
                self.healthText:SetFormattedText(format, string.format("%.0f", savedHealthPercent), string.format("%.0f", currentPercent))
            elseif db.shortNumbers then
                -- Use AbbreviateNumbers for short format (works with secret numbers)
                local format = db.textFormat:gsub("%%saved", "%%s"):gsub("%%current", "%%s")
                self.healthText:SetFormattedText(format, AbbreviateNumbers(savedHealth), AbbreviateNumbers(UnitHealth("player")))
            else
                -- Use SetFormattedText to handle secret numbers with %s
                local format = db.textFormat:gsub("%%saved", "%%s"):gsub("%%current", "%%s")
                self.healthText:SetFormattedText(format, savedHealth, UnitHealth("player"))
            end
            self.healthText:SetTextColor(db.colorR, db.colorG, db.colorB)
        else
            self.healthText:SetText("")
        end
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
    if AlterTimeTrackingDB and AlterTimeTrackingDB.timerPoint then
        self.timerFrame:ClearAllPoints()
        self.timerFrame:SetPoint(AlterTimeTrackingDB.timerPoint, UIParent, AlterTimeTrackingDB.timerRelPoint, AlterTimeTrackingDB.timerX, AlterTimeTrackingDB.timerY)
    end
    if AlterTimeTrackingDB and AlterTimeTrackingDB.iconPoint then
        self.iconFrame:ClearAllPoints()
        self.iconFrame:SetPoint(AlterTimeTrackingDB.iconPoint, UIParent, AlterTimeTrackingDB.iconRelPoint, AlterTimeTrackingDB.iconX, AlterTimeTrackingDB.iconY)
    end
    -- Apply saved font size
    self:ApplyFont()
end

-- Toggle test mode
function UI:ToggleTestMode()
    self.testMode = not self.testMode
    self.healthFrame:EnableMouse(self.testMode)
    self.timerFrame:EnableMouse(self.testMode)
    self.iconFrame:EnableMouse(self.testMode)
end

-- Create Options Panel
function UI:CreateOptionsPanel()
    local db = self:GetSettings()
    
    local panel = CreateFrame("Frame")
    panel.name = "Alter Time Tracking"

    -- Create scroll frame
    local scrollFrame = CreateFrame("ScrollFrame", nil, panel, "UIPanelScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT", 3, -4)
    scrollFrame:SetPoint("BOTTOMRIGHT", -27, 4)

    -- Create content frame
    local content = CreateFrame("Frame", nil, scrollFrame)
    content:SetSize(600, 850)
    scrollFrame:SetScrollChild(content)

    local title = content:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", 16, -16)
    title:SetText("Alter Time Tracking")

    -- Test / Move Button
    local testBtn = CreateFrame("Button", nil, content, "UIPanelButtonTemplate")
    testBtn:SetPoint("TOPLEFT", 16, -50)
    testBtn:SetSize(100, 25)
    testBtn:SetText("Test / Move")
    testBtn:SetScript("OnClick", function()
        UI:ToggleTestMode()
        if UI.testMode then
            testBtn:SetText("Stop Test")
        else
            testBtn:SetText("Test / Move")
        end
        addon.Core:UpdateDisplay()
    end)

    -- === DISPLAY OPTIONS SECTION ===
    local displayHeader = content:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    displayHeader:SetPoint("TOPLEFT", 16, -90)
    displayHeader:SetText("Display Options")

    -- Show Icon checkbox
    local iconCheck = CreateFrame("CheckButton", nil, content, "UICheckButtonTemplate")
    iconCheck:SetPoint("TOPLEFT", 16, -120)
    iconCheck:SetChecked(db.showIcon)
    
    local iconLabel = content:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    iconLabel:SetPoint("LEFT", iconCheck, "RIGHT", 5, 0)
    iconLabel:SetText("Show icon (movable with timer/health info)")
    
    iconCheck:SetScript("OnClick", function(self)
        db.showIcon = self:GetChecked()
        addon.Core:UpdateDisplay()
    end)

    -- Show Timer checkbox
    local timerCheck = CreateFrame("CheckButton", nil, content, "UICheckButtonTemplate")
    timerCheck:SetPoint("TOPLEFT", 16, -145)
    timerCheck:SetChecked(db.showTimer)
    
    local timerLabel = content:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    timerLabel:SetPoint("LEFT", timerCheck, "RIGHT", 5, 0)
    timerLabel:SetText("Show timer (separate movable display)")
    
    timerCheck:SetScript("OnClick", function(self)
        db.showTimer = self:GetChecked()
        addon.Core:UpdateDisplay()
    end)

    -- Show Health Text checkbox
    local healthTextCheck = CreateFrame("CheckButton", nil, content, "UICheckButtonTemplate")
    healthTextCheck:SetPoint("TOPLEFT", 16, -170)
    healthTextCheck:SetChecked(db.showHealthText)
    
    local healthTextLabel = content:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    healthTextLabel:SetPoint("LEFT", healthTextCheck, "RIGHT", 5, 0)
    healthTextLabel:SetText("Show health text (main display)")
    
    healthTextCheck:SetScript("OnClick", function(self)
        db.showHealthText = self:GetChecked()
        addon.Core:UpdateDisplay()
    end)

    -- === ICON SETTINGS SECTION ===
    local iconHeader = content:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    iconHeader:SetPoint("TOPLEFT", 16, -210)
    iconHeader:SetText("Icon Settings")

    -- Icon Size slider
    local iconSizeLabel = content:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    iconSizeLabel:SetPoint("TOPLEFT", 16, -240)
    iconSizeLabel:SetText("Icon Size")

    local iconSizeSlider = CreateFrame("Slider", nil, content, "OptionsSliderTemplate")
    iconSizeSlider:SetPoint("TOPLEFT", 16, -260)
    iconSizeSlider:SetSize(200, 16)
    iconSizeSlider:SetMinMaxValues(32, 128)
    iconSizeSlider:SetValueStep(4)
    iconSizeSlider:SetValue(db.iconSize)
    iconSizeSlider:Show()

    local iconSizeLow = iconSizeSlider:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
    iconSizeLow:SetPoint("BOTTOMLEFT", iconSizeSlider, "BOTTOMLEFT", 0, -17)
    iconSizeLow:SetText("32")

    local iconSizeHigh = iconSizeSlider:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
    iconSizeHigh:SetPoint("BOTTOMRIGHT", iconSizeSlider, "BOTTOMRIGHT", 0, -17)
    iconSizeHigh:SetText("128")

    local iconSizeValue = iconSizeSlider:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
    iconSizeValue:SetPoint("TOP", iconSizeSlider, "TOP", 0, 20)
    iconSizeValue:SetText(db.iconSize)

    iconSizeSlider:SetScript("OnValueChanged", function(self, value)
        db.iconSize = value
        iconSizeValue:SetText(math.floor(value))
        UI:ApplyFont()
    end)

    -- === TEXT SETTINGS SECTION ===
    local textHeader = content:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    textHeader:SetPoint("TOPLEFT", 16, -300)
    textHeader:SetText("Text Settings")

    -- Text Format Label
    local formatLabel = content:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    formatLabel:SetPoint("TOPLEFT", 16, -330)
    formatLabel:SetText("Text Format (use %saved and %current):")

    -- Text Format EditBox
    local formatBox = CreateFrame("EditBox", nil, content, "InputBoxTemplate")
    formatBox:SetPoint("TOPLEFT", 16, -350)
    formatBox:SetSize(250, 25)
    formatBox:SetAutoFocus(false)
    formatBox:SetScript("OnEnterPressed", function(self)
        db.textFormat = self:GetText()
        self:ClearFocus()
        addon.Core:UpdateDisplay()
    end)
    formatBox:SetScript("OnEscapePressed", function(self)
        self:SetText(db.textFormat or "Alter HP: %saved | Current HP: %current")
        self:ClearFocus()
    end)
    
    -- Save Button
    local saveBtn = CreateFrame("Button", nil, content, "UIPanelButtonTemplate")
    saveBtn:SetPoint("LEFT", formatBox, "RIGHT", 10, 0)
    saveBtn:SetSize(60, 25)
    saveBtn:SetText("Save")
    saveBtn:SetScript("OnClick", function()
        db.textFormat = formatBox:GetText()
        formatBox:ClearFocus()
        addon.Core:UpdateDisplay()
    end)

    -- Color Label
    local colorLabel = content:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    colorLabel:SetPoint("TOPLEFT", 16, -390)
    colorLabel:SetText("Text Color:")

    -- Color Swatch
    local colorSwatch = CreateFrame("Button", nil, content)
    colorSwatch:SetPoint("TOPLEFT", 16, -410)
    colorSwatch:SetSize(30, 30)
    
    local swatchTexture = colorSwatch:CreateTexture(nil, "BACKGROUND")
    swatchTexture:SetAllPoints()
    swatchTexture:SetColorTexture(db.colorR, db.colorG, db.colorB)
    
    local swatchBorder = colorSwatch:CreateTexture(nil, "BORDER")
    swatchBorder:SetPoint("TOPLEFT", -1, 1)
    swatchBorder:SetPoint("BOTTOMRIGHT", 1, -1)
    swatchBorder:SetColorTexture(0.3, 0.3, 0.3)

    -- === SHARED SETTINGS SECTION ===
    local sharedHeader = content:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    sharedHeader:SetPoint("TOPLEFT", 16, -460)
    sharedHeader:SetText("Shared Settings")

    -- Font Size Label
    local fontLabel = content:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    fontLabel:SetPoint("TOPLEFT", 16, -490)
    fontLabel:SetText("Font Size (affects both text and icon):")

    -- Font Size Slider
    local fontSlider = CreateFrame("Slider", "AlterTimeTrackingFontSlider", content, "OptionsSliderTemplate")
    fontSlider:SetPoint("TOPLEFT", 16, -515)
    fontSlider:SetWidth(200)
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

    -- Create both checkboxes first
    local shortNumCheck = CreateFrame("CheckButton", nil, content, "UICheckButtonTemplate")
    shortNumCheck:SetPoint("TOPLEFT", 16, -555)
    shortNumCheck:SetChecked(db.shortNumbers)
    
    local shortNumLabel = content:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    shortNumLabel:SetPoint("LEFT", shortNumCheck, "RIGHT", 5, 0)
    shortNumLabel:SetText("Short numbers (300k instead of 300000)")
    
    local percentCheck = CreateFrame("CheckButton", nil, content, "UICheckButtonTemplate")
    percentCheck:SetPoint("TOPLEFT", 16, -580)
    percentCheck:SetChecked(db.usePercent)
    
    local percentLabel = content:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    percentLabel:SetPoint("LEFT", percentCheck, "RIGHT", 5, 0)
    percentLabel:SetText("Use percent (83% instead of 250000)")
    
    -- Set click handlers after both exist
    shortNumCheck:SetScript("OnClick", function(self)
        db.shortNumbers = self:GetChecked()
        if self:GetChecked() then
            db.usePercent = false
            percentCheck:SetChecked(false)
        end
        addon.Core:UpdateDisplay()
    end)
    
    percentCheck:SetScript("OnClick", function(self)
        db.usePercent = self:GetChecked()
        if self:GetChecked() then
            db.shortNumbers = false
            shortNumCheck:SetChecked(false)
        end
        addon.Core:UpdateDisplay()
    end)


    -- Reset to Defaults Button
    local resetBtn = CreateFrame("Button", nil, content, "UIPanelButtonTemplate")
    resetBtn:SetPoint("TOPLEFT", 16, -620)
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
        
        -- Reset timer position
        db.timerPoint = nil
        db.timerRelPoint = nil
        db.timerX = nil
        db.timerY = nil
        UI.timerFrame:ClearAllPoints()
        UI.timerFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 150)
        
        -- Reset icon position
        db.iconPoint = nil
        db.iconRelPoint = nil
        db.iconX = nil
        db.iconY = nil
        UI.iconFrame:ClearAllPoints()
        UI.iconFrame:SetPoint("CENTER", UIParent, "CENTER", -200, 0)
        
        -- Reset text format
        db.textFormat = "Alter HP: %saved | Current HP: %current"
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
        
        -- Reset icon size
        db.iconSize = 64
        iconSizeSlider:SetValue(64)
        iconSizeValue:SetText(64)
        UI:ApplyFont()
        
        -- Reset short numbers and percent
        db.shortNumbers = false
        shortNumCheck:SetChecked(false)
        db.usePercent = true
        percentCheck:SetChecked(true)
        
        -- Reset show timer
        db.showTimer = false
        timerCheck:SetChecked(false)
        
        -- Reset show icon
        db.showIcon = true
        iconCheck:SetChecked(true)
        
        -- Reset show health text
        db.showHealthText = false
        healthTextCheck:SetChecked(false)
        
        addon.Core:UpdateDisplay()
    end)
    
    -- Refresh when panel is shown
    panel:SetScript("OnShow", function()
        local settings = UI:GetSettings()
        formatBox:SetText(settings.textFormat)
        swatchTexture:SetColorTexture(settings.colorR, settings.colorG, settings.colorB)
        fontSlider:SetValue(settings.fontSize)
        iconSizeSlider:SetValue(settings.iconSize)
        iconSizeValue:SetText(settings.iconSize)
        shortNumCheck:SetChecked(settings.shortNumbers)
        percentCheck:SetChecked(settings.usePercent)
        timerCheck:SetChecked(settings.showTimer)
        iconCheck:SetChecked(settings.showIcon)
        healthTextCheck:SetChecked(settings.showHealthText)
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
    local author = content:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    author:SetPoint("TOPLEFT", 16, -665)
    author:SetText("by Tramstarzz-Stormscale, Tramstarz-Stormscale, Tramstarzz-Twisting Nether")
    author:SetTextColor(0.8, 0.8, 0.8)
    
    -- Donation message
    local donation = content:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
    donation:SetPoint("TOPLEFT", 16, -685)
    donation:SetText("Donations not needed, but gold tips to my characters are always appreciated! <3")
    donation:SetTextColor(1, 0.84, 0)
    
    -- GitHub label
    local githubLabel = content:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    githubLabel:SetPoint("TOPLEFT", 16, -715)
    githubLabel:SetText("GitHub (click to select, Ctrl+C to copy):")
    githubLabel:SetTextColor(0.4, 0.7, 1)
    
    -- GitHub link at bottom (clickable to copy)
    local githubBox = CreateFrame("EditBox", nil, content, "InputBoxTemplate")
    githubBox:SetPoint("TOPLEFT", 16, -740)
    githubBox:SetSize(350, 25)
    githubBox:SetAutoFocus(false)
    githubBox:SetFontObject(GameFontHighlight)
    githubBox:SetText("https://github.com/KrunoslavKrainovic/AlterTimeTracking")
    githubBox:SetCursorPosition(0)
    githubBox:SetScript("OnEditFocusGained", function(self)
        self:HighlightText()
    end)
    githubBox:SetScript("OnEscapePressed", function(self)
        self:ClearFocus()
    end)
    githubBox:SetScript("OnTextChanged", function(self)
        self:SetText("https://github.com/KrunoslavKrainovic/AlterTimeTracking")
    end)

    local category = Settings.RegisterCanvasLayoutCategory(panel, panel.name)
    Settings.RegisterAddOnCategory(category)
end
