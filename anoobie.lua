function print(arg)
    DEFAULT_CHAT_FRAME:AddMessage(arg);
end

local childFrames = {
    marks = {},
    buffs = {}
}

local abilities = {
    ["Interface\\Icons\\Spell_Arcane_Blink"] = "Shadow & Frost Reflect",
    ["Interface\\Icons\\Ability_ThunderClap"] = "Thunderclap",
    ["Interface\\Icons\\Spell_Nature_Thorns"] = "Thorns",
    ["Interface\\Icons\\Ability_UpgradeMoonGlaive"] = "Knockaway & Taunt Immune",
    ["Interface\\Icons\\Spell_Shadow_ManaBurn"] = "Mana Burn",
    ["Interface\\Icons\\Spell_Shadow_Haunting"] = "Shadow Storm",
    ["Interface\\Icons\\Ability_Warrior_SavageBlow"] = "Mortal strike",
    ["Interface\\Icons\\Spell_Nature_ResistNature"] = "Mending",
    ["Interface\\Icons\\Spell_Holy_MagicalSentry"] = "Arcane intellect",
}


local icons = {
    [1] = {
        textureCoords = {
            left = "0", right = "0.25", top = "0", bottom = "0.25"
        },
        name = "Star"
    },
    [2] = {
        textureCoords = {
            left="0.25", right="0.5", top="0", bottom="0.25",
        },
        name = "Circle"
    },
    [3] = {
        textureCoords = {
            left="0.5", right="0.75", top="0", bottom="0.25"
        },
        name = "Diamond"
    },
    [4] = {
        textureCoords = {
            left="0.75", right="1", top="0", bottom="0.25"
        },
        name = "Triangle"
    },
    [5] = {
        textureCoords = {
            left = "0", right = "0.25", top = "0.25", bottom = "0.5"
        },
        name = "Moon"
    },
    [6] = {
        textureCoords = {
            left = "0.25", right = "0.25", top = "0.5", bottom = "0.5"
        },
        name = "Square"
    },
    [7] = {
        textureCoords = {
            left = "0.5", right = "0.75", top = "0.25", bottom = "0.5"
        },
        name = "Cross"
    },
    [8] = {
        textureCoords = {
            left="0.75", right="1", top="0.25", bottom="0.5"
        },
        name = "Skull"
    }
}
framesInitialized = false
counter = 1
local registeredTargets = {}

function removeWhitespaceAndAmpersand(str)
    str = string.gsub(str, "%s", "")
    str = string.gsub(str, "&", "")
    return str
end

function Anoobie_OnEvent()
    if (event == "UNIT_AURA") then
        print('fired')
        local isAnoobieTarget = UnitExists("target") and UnitName("target") == "Eralin"

        if isAnoobieTarget then
            local isDetectMagicApplied = true
            if (isDetectMagicApplied) then
                if not framesInitialized then
                    Anoobie_Draw()
                    framesInitialized = true
                end

                local targetMarkIndex = GetRaidTargetIndex("target")
                local targetBuff = UnitBuff("target", 1)
                
                if (targetMarkIndex and abilities[targetBuff]) then
                    local buff = removeWhitespaceAndAmpersand(abilities[targetBuff])
                    local buffFrameId = "buff" .. buff .. "Row" .. counter
                    local markFrameId = "mark" .. icons[targetMarkIndex].name .. "Row" .. counter
                    local target = buff .. icons[targetMarkIndex].name

                    if not registeredTargets[target] and counter <= 4 then
                        registeredTargets[target] = true
                        showMark(markFrameId)
                        showAbility(buffFrameId)
                        counter = counter + 1
                    end
                end
            end
        end
    end
end

function Anoobie_Draw()
    local coords = { -36, -67, -98, -129 }

    for index, value in ipairs(coords) do
        for _, icon in ipairs(icons) do
            local frameName = "mark" .. icon.name .. "Row" .. index
            local childFrame = CreateFrame("Frame", frameName, Anoobie)
            childFrame:SetWidth(25)
            childFrame:SetHeight(25)
            childFrame:SetPoint("TOPLEFT", 22, value)

            local texture = childFrame:CreateTexture("$parentTexture", "ARTWORK")
            texture:SetAllPoints(true)
            texture:SetTexture("Interface\\TargetingFrame\\UI-RaidTargetingIcons")
            texture:SetTexCoord(icon.textureCoords.left, icon.textureCoords.right, icon.textureCoords.top,
                icon.textureCoords.bottom)
            childFrame:Hide()
            childFrames.marks[frameName] = childFrame
        end

        for key, name in pairs(abilities) do
            local frameName = "buff" .. removeWhitespaceAndAmpersand(name) .. "Row" .. index
            local childFrame = CreateFrame("Frame", frameName, Anoobie)
            childFrame:SetWidth(25)
            childFrame:SetHeight(25)
            childFrame:SetPoint("TOPLEFT", 53, value)

            local texture = childFrame:CreateTexture("$parentTexture", "ARTWORK")
            texture:SetAllPoints(true)
            texture:SetTexture(key)
            childFrame:Hide()
            childFrames.buffs[frameName] = childFrame
        end
    end
end

function Anoobie_OnLoad()
    Anoobie:RegisterEvent("UNIT_AURA", "player")
    print('anoobie loaded')
end

function showMark(mark)
    if not childFrames.marks[mark]:IsVisible() then
        childFrames.marks[mark]:Show()
    end
end

function showAbility(ability)
    if not childFrames.buffs[ability]:IsVisible() then
        childFrames.buffs[ability]:Show()
    end
end

function Hide()
    Anoobie:Hide()
end
