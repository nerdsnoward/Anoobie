SLASH_ANOOBIE1, SLASH_ANOOBIE2, SLASH_ANOOBIE3 = '/anoob', '/anoobie', '/anoobshow';

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