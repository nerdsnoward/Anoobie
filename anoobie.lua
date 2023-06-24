function print(arg)
    DEFAULT_CHAT_FRAME:AddMessage(arg);
end

G_childFrames = {
    marks = {
        [1] = MarkTexture1,
        [2] = MarkTexture2,
        [3] = MarkTexture3,
        [4] = MarkTexture4
    },
    buffs = {
        [1] = BuffTexture1,
        [2] = BuffTexture2,
        [3] = BuffTexture3,
        [4] = BuffTexture4
    },
    texts = {
        [1] = AnoobieLabel1,
        [2] = AnoobieLabel2,
        [3] = AnoobieLabel3,
        [4] = AnoobieLabel4
    }
}
G_DETECT_MAGIC_TEXTURE = 'Interface\\Icons\\Spell_Holy_Dizzy'
G_ABILITIES = {
    [G_DETECT_MAGIC_TEXTURE] = {
        name = "Arcane & Fire Reflect",
        order = 1,
        icon = nil
    },
    ["Interface\\Icons\\Spell_Arcane_Blink"] = {
        name = "Shadow & Frost Reflect",
        order = 1,
        icon = nil
    },
    ["Interface\\Icons\\Ability_ThunderClap"] = {
        name = "Thunderclap",
        order = 4,
        icon = nil
    },
    ["Interface\\Icons\\Spell_Nature_Thorns"] = {
        name = "Thorns",
        order = 4,
        icon = nil
    },
    ["Interface\\Icons\\Ability_UpgradeMoonGlaive"] = {
        name = "Knockaway & Taunt Immune",
        order = 3,
        icon = nil
    },
    ["Interface\\Icons\\Spell_Shadow_ManaBurn"] = {
        name = "Mana Burn",
        order = 4,
        icon = nil
    },
    ["Interface\\Icons\\Spell_Shadow_Haunting"] = {
        name = "Shadow Storm",
        order = 5,
        icon = nil
    },
    ["Interface\\Icons\\Ability_Warrior_SavageBlow"] = {
        name = "Mortal strike",
        order = 3,
        icon = nil
    },
    ["Interface\\Icons\\Spell_Nature_ResistNature"] = {
        name = "Mending",
        order = 2,
        icon = nil
    },
    ["Interface\\Icons\\Spell_Holy_MagicalSentry"] = {
        name = "Arcane intellect",
        order = 5,
        icon = nil
    },
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
G_discoveredAbilities = {}

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
            if (value.name == secondString) then
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
    if event == "CHAT_MSG_RAID_WARNING" or event == "CHAT_MSG_RAID" then
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
    local targetMarkIndex = discoveredMarkIndex or GetRaidTargetIndex("target")
    local targetBuff = discoveredTargetBuff or UnitBuff("target", 1)
    local targetId = removeWhitespaceAndAmpersand(G_ABILITIES[targetBuff].name) .. G_ICONS[targetMarkIndex].name

    if (targetMarkIndex and G_ABILITIES[targetBuff] and not G_registeredTargets[targetId] and G_counter <= 4) then
        Anoobie_SetTextures(targetBuff, targetMarkIndex, G_counter)
        Anoobie_SendRaidWarning(G_ICONS[targetMarkIndex].name .. ": " .. G_ABILITIES[targetBuff].name)
        G_counter = G_counter + 1
        G_registeredTargets[targetId] = true
        table.insert(G_discoveredAbilities, {
            name = G_ABILITIES[targetBuff].name,
            order = G_ABILITIES[targetBuff].order,
            icon = targetMarkIndex,
            buffTexture = targetBuff
        })
    end

    if (G_counter == 5) then
        local counter = 1

        table.sort(G_discoveredAbilities, function(a, b)
            return a.order < b.order
        end)

        for idx, ability in pairs(G_discoveredAbilities) do
            Anoobie_SetTextures(ability.buffTexture, ability.icon, idx)
        end
    end
end

function Anoobie_SetTextures(targetBuff, targetMarkIndex, counter)
    local icon = G_ICONS[targetMarkIndex]
    G_childFrames.marks[counter]:SetTexture("Interface\\TargetingFrame\\UI-RaidTargetingIcons")
    G_childFrames.marks[counter]:SetTexCoord(icon.textureCoords.left, icon.textureCoords.right,
        icon.textureCoords.top,
        icon.textureCoords.bottom)
    G_childFrames.buffs[counter]:SetTexture(targetBuff)
    G_childFrames.texts[counter]:SetText(G_ABILITIES[targetBuff].name)
    G_ABILITIES[targetBuff].icon = targetMarkIndex
end

function Anoobie_SendRaidWarning(message)
    if not G_announcedMessages[message] then
        SendChatMessage(message, "RAID_WARNING")
        G_announcedMessages[message] = true
    end
end

function Anoobie_OnLoad()
    Anoobie:RegisterEvent("UNIT_AURA")
    Anoobie:RegisterEvent("CHAT_MSG_RAID_WARNING")
    Anoobie:RegisterEvent("CHAT_MSG_RAID")
    print('---- ANOOBIE LOADED ----')
end

function Anoobie_Reset()
    --[[ SendChatMessage("Square: Arcane & Fire Reflect", "RAID_WARNING")
    SendChatMessage("Star: Mana Burn", "RAID_WARNING")
    SendChatMessage("Skull: Shadow Storm", "RAID_WARNING")
    SendChatMessage("Cross: Shadow & Frost Reflect", "RAID_WARNING")
    ]]
    for _, frame in pairs(G_childFrames.buffs) do
        frame:SetTexture("Interface\\Icons\\Inv_Misc_Questionmark")
    end
    for _, frame in pairs(G_childFrames.marks) do
        frame:SetTexture("Interface\\Icons\\Inv_Misc_Questionmark")
        frame:SetTexCoord(0, 1, 0, 1)
    end
    for _, frame in pairs(G_childFrames.texts) do
        frame:SetText("Unkown Ability")
    end
    G_registeredTargets = {}
    G_announcedMessages = {}
    G_discoveredAbilities = {}
    G_counter = 1
end
