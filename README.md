# Anoobie
Anubisath Sentinel magic detect helper

### Installation

Download the addon, remove "-main" sufix form the downloaded directory name and place it under Interface/AddOns/

### About

When detect magic is used on a marked Anubisath Sentinel in AQ40, their ability is announced and displayed. 

Once all abilities are discovered, they are sorted based on the following kill priority (first on list = first to kill):
- Arcane/Fire Reflect, Shadow/Frost Reflect
- Mending
- Mortal Strike
- Knockaway & Taunt Immune
- Mana Burn
- Thorns
- Thunderclap
- Shadow Storm

![Screenshot 2023-06-25 144028](https://github.com/nerdsnoward/Anoobie/assets/134713605/33fe4a74-36ba-4d84-9760-651b7b18acf6)

Icons will reset when re-entering combat or when refresh button is clicked (upper left corner).

Recommended for mages and raid leads.

### Known Issues

Hunter Feign Death then re-entering combat while Anubisath Sentinels are still alive with Detect Magic debuff may result in redundant raid announcement of their ability.

Mage with detect magic debuff on themselves when targeting a dead Anubisath Sentinel target may result in redundant raid announcement of their ability.
