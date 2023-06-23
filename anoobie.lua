function print(arg)
    DEFAULT_CHAT_FRAME:AddMessage(arg);
end

G_childFrames = {
    marks = {},
    buffs = {},
    texts = {
        [1] = AnoobieLabel1,
        [2] = AnoobieLabel2,
        [3] = AnoobieLabel3,
        [4] = AnoobieLabel4
    }
}
G_DETECT_MAGIC_TEXTURE = 'Interface\\Icons\\Spell_Holy_Dizzy'
G_ABILITIES = {
    [G_DETECT_MAGIC_TEXTURE] = "Arcane & Fire Reflect",
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
G_ICONS = {
    [1] = {
        textureCoords = {
            left = "0", right = "0.25", top = "0", bottom = "0.25"
        },
        name = "Star"
    },
    [2] = {
        textureCoords = {
            left = "0.25", right = "0.5", top = "0", bottom = "0.25",
        },
        name = "Circle"
    },
    [3] = {
        textureCoords = {
            left = "0.5", right = "0.75", top = "0", bottom = "0.25"
        },
        name = "Diamond"
    },
    [4] = {
        textureCoords = {
            left = "0.75", right = "1", top = "0", bottom = "0.25"
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
            left = "0.25", right = "0.5", top = "0.25", bottom = "0.5"
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
            left = "0.75", right = "1", top = "0.25", bottom = "0.5"
        },
        name = "Skull"
    }
}
G_framesInitialized = false
G_counter = 1
G_registeredTargets = {}
G_announcedMessages = {}

-- Removes white spaces and & char from string.
-- Example: turnsShadow & Frost Reflect to ShadowFrostReflect
function removeWhitespaceAndAmpersand(str)
    str = string.gsub(str, "%s", "")
    str = string.gsub(str, "&", "")
    return str
end

-- Returns true if detect magic debuff is present on target
function checkForDetectMagicDebuff(target)
    local isDetectMagicOn = false
    local index = 1

    while not isDetectMagicOn do
        local debuff = UnitDebuff(target, index)
        if not debuff then
            break
        end

        if debuff == G_DETECT_MAGIC_TEXTURE then
            isDetectMagicOn = true
        end
        index = index + 1
    end

    return isDetectMagicOn
end

-- Splits messages "Mark: Ability" and returns coresponding mark, ability
function processRaidWarning(str)
    local mark = 0
    local ability = ""
    local delimiter = ":"
    local index = string.find(str, delimiter)

    if index then
        local firstString = string.sub(str, 1, index - 1)
        local secondString = string.sub(str, index + 2)

        for key, value in pairs(G_ABILITIES) do
            if (value == secondString) then
                ability = key
                break
            end
        end

        for key, value in pairs(G_ICONS) do
            if (value.name == firstString) then
                mark = key
                break
            end
        end
    end

    return mark, ability
end

function Anoobie_OnEvent()
    if event == "CHAT_MSG_RAID_WARNING" then
        local mark, ability = processRaidWarning(arg1)

        if mark > 0 and ability then
            if (not G_announcedMessages[arg1]) then
                G_announcedMessages[arg1] = true
            end
            Anoobie_Draw(ability, mark)
        end
    end

    if (event == "UNIT_AURA") then
        if checkForDetectMagicDebuff("player") then
            Anoobie_Draw(G_DETECT_MAGIC_TEXTURE)
        end

        local isAnoobieTarget = UnitExists("target") and UnitName("target") == "Anubisath Sentinel"

        if isAnoobieTarget then
            local isDetectMagicApplied = checkForDetectMagicDebuff("target")
            if (isDetectMagicApplied) then
                Anoobie_Draw()
            end
        end
    end
end

function Anoobie_Draw(discoveredTargetBuff, discoveredMarkIndex)
    if not G_framesInitialized then
        Anoobie_InitializeFrames()
        G_framesInitialized = true
    end

    local targetMarkIndex = discoveredMarkIndex or GetRaidTargetIndex("target")
    local targetBuff = discoveredTargetBuff or UnitBuff("target", 1)

    if (targetMarkIndex and G_ABILITIES[targetBuff]) then
        local buff = removeWhitespaceAndAmpersand(G_ABILITIES[targetBuff])
        local buffFrameId = "buff" .. buff .. "Row" .. G_counter
        local markFrameId = "mark" .. G_ICONS[targetMarkIndex].name .. "Row" .. G_counter
        local target = buff .. G_ICONS[targetMarkIndex].name

        -- Avoid drawing the same mark/buff combination multiple times
        if not G_registeredTargets[target] and G_counter <= 4 then
            G_registeredTargets[target] = true
            G_childFrames.marks[markFrameId]:Show()
            G_childFrames.buffs[buffFrameId]:Show()
            G_childFrames.texts[G_counter]:SetText(G_ABILITIES[targetBuff])
            local message = G_ICONS[targetMarkIndex].name .. ": " .. G_ABILITIES[targetBuff]
            Anoobie_SendRaidWarning(message)
            G_counter = G_counter + 1
        end
    end
end

function Anoobie_SendRaidWarning(message)
    if not G_announcedMessages[message] then
        SendChatMessage(message, "RAID_WARNING")
        G_announcedMessages[message] = true
    end
end

function Anoobie_InitializeFrames()
    local coords = { -36, -67, -98, -129 }

    for index, value in ipairs(coords) do
        for _, icon in ipairs(G_ICONS) do
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
            G_childFrames.marks[frameName] = childFrame
        end

        for key, name in pairs(G_ABILITIES) do
            local frameName = "buff" .. removeWhitespaceAndAmpersand(name) .. "Row" .. index
            local childFrame = CreateFrame("Frame", frameName, Anoobie)
            childFrame:SetWidth(25)
            childFrame:SetHeight(25)
            childFrame:SetPoint("TOPLEFT", 53, value)

            local texture = childFrame:CreateTexture("$parentTexture", "ARTWORK")
            texture:SetAllPoints(true)
            texture:SetTexture(key)
            childFrame:Hide()
            G_childFrames.buffs[frameName] = childFrame
        end
    end
end

function Anoobie_OnLoad()
    Anoobie:RegisterEvent("UNIT_AURA")
    Anoobie:RegisterEvent("CHAT_MSG_RAID_WARNING")
    print('---- ANOOBIE LOADED ----')
end

function Anoobie_Reset()
    for _, frame in pairs(G_childFrames.buffs) do
        frame:Hide()
    end
    for _, frame in pairs(G_childFrames.marks) do
        frame:Hide()
    end
    for _, frame in pairs(G_childFrames.texts) do
        frame:SetText("Unkown Ability")
    end
    G_registeredTargets = {}
    G_announcedMessages = {}
    G_counter = 1
end
