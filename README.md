# Alter Time Tracking

**Version:** 1.0.0  
**GitHub:** [https://github.com/KrunoslavKrainovic/AlterTimeTracking](https://github.com/KrunoslavKrainovic/AlterTimeTracking)

A World of Warcraft addon for Mages that tracks your health when using **Alter Time**, helping you decide whether to use the recall or cancel the buff.

## What It Does

When you cast **Alter Time**, the addon saves your current health. It then displays both your saved health and current health, so you can see at a glance whether recalling would heal you or cause you to lose HP.

## Features

- **Health Tracking** - Automatically saves your health when Alter Time Recall is cast
- **Live Display** - Shows saved health vs current health in real-time
- **Movable Frame** - Drag the display anywhere on your screen (position is saved)
- **Customizable Text** - Change the display format using `%saved` and `%current` placeholders
- **Custom Color** - Pick any color for the text using a color picker
- **Adjustable Font Size** - Slider to change text size (10-32)
- **Short Numbers** - Option to display health as 300k instead of 300000
- **Test Mode** - Preview the display and move it without needing to cast spells
- **Reset to Defaults** - One-click reset for all settings

## Slash Commands

| Command | Description |
|---------|-------------|
| `/att` | Open the options panel |
| `/atdebug` | Toggle debug mode (shows spell IDs when casting) |

## Options Panel

Access via `/att` or through Interface → AddOns → Alter Time Tracking

- **Test / Move** - Click to show test text and enable dragging to reposition
- **Text Format** - Customize the display text (use `%saved` and `%current` as placeholders)
- **Text Color** - Click the color swatch to open the color picker
- **Font Size** - Adjust the text size with the slider
- **Short Numbers** - Toggle to show 300k instead of 300000
- **Reset to Defaults** - Reset position, text, color, font size, and short numbers to defaults

## Default Settings

- **Text Format:** `Saved: %saved | Current: %current`
- **Color:** Yellow
- **Font Size:** 16
- **Short Numbers:** Off
- **Position:** Center of screen

## Installation

1. Download and extract to your `Interface/AddOns` folder
2. Ensure the folder is named `AlterTimeTracking`
3. Restart WoW or type `/reload`

## Requirements

- World of Warcraft Retail (Midnight)
- Mage class (uses Alter Time spell)
