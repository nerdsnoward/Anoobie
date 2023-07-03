function print(arg)
    DEFAULT_CHAT_FRAME:AddMessage(arg);
end

G_VARIATIONS = {
    DEFAULT = {
        backdropColor = { 0, 0, 0 },
        backdropBorderColor = { 1, 1, 1 },
        VertexColor = { 1, 1, 1 },
        title = "Anoobie"

    },
    FLAMINGO = {
        backdropColor = { 1, 0.498, 0.631, 0.8 },
        backdropBorderColor = { 1, 0.498, 0.631 },
        VertexColor = { 1, 0.498, 0.631 },
        title = "Kill order"
    }
}
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
        name = "Mortal Strike",
        order = 3,
        icon = nil
    },
    ["Interface\\Icons\\Spell_Nature_ResistNature"] = {
        name = "Mending",
        order = 2,
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
G_counter = 1
G_announcedMessages = {}
G_discoveredAbilities = {}

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
    if event == "PLAYER_REGEN_DISABLED" then
        Anoobie_Reset()
    end

    if event == "CHAT_MSG_RAID_WARNING" or event == "CHAT_MSG_RAID" or event == "CHAT_MSG_RAID_LEADER" then
        local mark, ability = processRaidWarning(arg1)

        if mark > 0 and ability then
            if (not G_announcedMessages[arg1]) then
                G_announcedMessages[arg1] = true
            end
            Anoobie_Draw(ability, mark)
        end
    end

    if (event == "UNIT_AURA") then
        local isAnoobieTarget = UnitExists("target") and UnitName("target") == "Anubisath Sentinel"

        if isAnoobieTarget and UnitHealth("target") > 0 then
            if checkForDetectMagicDebuff("target") then
                Anoobie_Draw()
                return
            end
            
            if checkForDetectMagicDebuff("player") then
                Anoobie_Draw(G_DETECT_MAGIC_TEXTURE)
            end
        end
    end
end

function isAbilityDiscoverd(buff)
    isDiscovered = false
    for _, ability in pairs(G_discoveredAbilities) do
        if ability.buffTexture == buff then
            isDiscovered = true
        end
    end
    return isDiscovered
end

function Anoobie_Draw(discoveredTargetBuff, discoveredMarkIndex)
    local targetMarkIndex = discoveredMarkIndex or GetRaidTargetIndex("target")
    local targetBuff = discoveredTargetBuff or UnitBuff("target", 1)
    local isDiscovered = isAbilityDiscoverd(targetBuff)

    if (targetMarkIndex and G_ABILITIES[targetBuff] and G_counter <= 4 and not isDiscovered) then
        if not Anoobie:IsVisible() then
            Anoobie:Show()
        end
        Anoobie_SetTextures(targetBuff, targetMarkIndex, G_counter)
        Anoobie_SendRaidWarning(G_ICONS[targetMarkIndex].name .. ": " .. G_ABILITIES[targetBuff].name)
        table.insert(G_discoveredAbilities, {
            name = G_ABILITIES[targetBuff].name,
            order = G_ABILITIES[targetBuff].order,
            icon = targetMarkIndex,
            buffTexture = targetBuff
        })
        G_counter = G_counter + 1
    end

    if (G_counter == 5) then
        table.sort(G_discoveredAbilities, function(a, b)
            return a.order < b.order
        end)

        for idx, ability in pairs(G_discoveredAbilities) do
            Anoobie_SetTextures(ability.buffTexture, ability.icon, idx)
        end
        Anoobie:SetBackdrop({
            bgFile = "Interface/Tooltips/UI-Tooltip-Background",
            edgeFile = "Interface/DialogFrame/UI-DialogBox-Border",
            insets = { left = 11, right = 12, top = 12, bottom = 11 },
        })
        Anoobie_ChangeAppearance(G_VARIATIONS.FLAMINGO, "HumanExploration")
        G_counter = G_counter + 1
    end
end

function Anoobie_ChangeAppearance(variation, sound)
    Anoobie:SetBackdropColor(
        variation.backdropColor[1],
        variation.backdropColor[2],
        variation.backdropColor[3],
        variation.backdropColor[4]
    )
    Anoobie:SetBackdropBorderColor(
        variation.backdropBorderColor[1],
        variation.backdropBorderColor[2],
        variation.backdropBorderColor[3],
        variation.backdropBorderColor[4]
    )
    AnoobieTitleTexture:SetVertexColor(
        variation.VertexColor[1],
        variation.VertexColor[2],
        variation.VertexColor[3]
    )
    AnoobieTitle:SetText(variation.title)

    if (sound) then
        PlaySound(sound, "master");
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
        local channel = (isRaidLeader and "RAID_WARNING") or "RAID"
        SendChatMessage(message, channel)
        G_announcedMessages[message] = true
    end
end

function Anoobie_OnLoad()
    Anoobie:Hide()
    Anoobie:RegisterEvent("UNIT_AURA")
    Anoobie:RegisterEvent("CHAT_MSG_RAID_WARNING")
    Anoobie:RegisterEvent("CHAT_MSG_RAID")
    Anoobie:RegisterEvent("CHAT_MSG_RAID_LEADER")
    Anoobie:RegisterEvent("PLAYER_REGEN_DISABLED")
    print('---- ANOOBIE LOADED ----')
end

function Anoobie_Reset()
    for _, frame in pairs(G_childFrames.buffs) do
        frame:SetTexture("Interface\\Icons\\Inv_Misc_Questionmark")
    end
    for _, frame in pairs(G_childFrames.marks) do
        frame:SetTexture("Interface\\Icons\\Inv_Misc_Questionmark")
        frame:SetTexCoord(0, 1, 0, 1)
    end
    for _, frame in pairs(G_childFrames.texts) do
        frame:SetText("Unknown Ability")
    end
    Anoobie_ChangeAppearance(G_VARIATIONS.DEFAULT)
    G_announcedMessages = {}
    G_discoveredAbilities = {}
    G_counter = 1
end
