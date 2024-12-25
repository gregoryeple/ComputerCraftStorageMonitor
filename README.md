# ComputerCraft Storage Monitor

A monitor program that displays the current storage for multiple types of storage _(see below)_.

Can be connected to multiple monitors or multiple storage containers.

Pastebin: [mdKK9nYg](https://pastebin.com/mdKK9nYg)

# Supported storage types

 - **Energy** (Generic energy storage and [Mekanism](https://www.curseforge.com/minecraft/mc-mods/mekanism)'s energy storage)
 - **Item** (Generic item storage and [Mekanism](https://www.curseforge.com/minecraft/mc-mods/mekanism)'s QIO)
 - **Fluid** (Generic fluid storage and [Mekanism](https://www.curseforge.com/minecraft/mc-mods/mekanism)'s fluid storage)
 - **Mana** from [Botania](https://www.curseforge.com/minecraft/mc-mods/botania) _(Requires [Advanced Peripherals](https://www.curseforge.com/minecraft/mc-mods/advanced-peripherals))_
 - **Pressure** from [PneumaticCraft: Repressurized](https://www.curseforge.com/minecraft/mc-mods/pneumaticcraft-repressurized)

# Example

![Energy monitor](https://github.com/gregoryeple/ComputerCraftStorageMonitor/blob/main/examples/energy.png?raw=true)

[See more examples](https://github.com/gregoryeple/ComputerCraftStorageMonitor/tree/main/examples)

# Notes
 
 - This program was only tested with Minecraft 1.20.1.
 - When monitoring fluids with generic containers, I recommend activating the `updateCapacity` variable because the total capacity of a generic fluid storage isn't yet accessible.
 - When monitoring items with generic containers, I also recommend activating the `updateCapacity` variable because storing items with a different stack size _(other than 64)_ will change the total capacity of the storage container.
 - If the computer is connected to a container with multiple types of storage _(like item and fluid)_, it will only show the storage for 1 type, you can force which of theses type to display by using the `forceStorageType` variable.
 
 This program was inspired by [Toyguna/EnergyMonitor](https://github.com/Toyguna/EnergyMonitor).
