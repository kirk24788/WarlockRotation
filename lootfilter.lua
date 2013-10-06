local LOG = Logger(LogLevel.INFO)
local lootFilterFrame = CreateFrame("Frame", "lootFilter", UIParent)
local combinableLoot = {}
local lootBag = {}
local updateInterval = 2
local function toCombinableLoot(id,count) combinableLoot[id]=count end
combinableLoot[97619] = 10 -- Torn Green Tea Leaf
combinableLoot[97621] = 10 -- Silkweed Stem
combinableLoot[97623] = 10 -- Fool's Cap Spores
combinableLoot[89112] = 10 -- Mote of Harmony
combinableLoot[22572] = 10 -- Mote of Air
combinableLoot[22573] = 10 -- Mote of Earth
combinableLoot[22574] = 10 -- Mote of Fire
combinableLoot[22575] = 10 -- Mote of Life
combinableLoot[22576] = 10 -- Mote of Mana
combinableLoot[22577] = 10 -- Mote of Shadow
combinableLoot[22578] = 10 -- Mote of Water
combinableLoot[37700] = 10 -- Crystallized Air
combinableLoot[37701] = 10 -- Crystallized Earth
combinableLoot[37702] = 10 -- Crystallized Fire
combinableLoot[37704] = 10 -- Crystallized Life
combinableLoot[37703] = 10 -- Crystallized Shadow
combinableLoot[37705] = 10 -- Crystallized Water
combinableLoot[72162] = 5 -- Sha-Touched Leather
combinableLoot[33567] = 5 -- Borean Leather Scraps
lootBag[72201] = true -- Plump Intestines
lootBag[67495] = true -- Strange Bloated Stomach
lootBag[67539] = true -- Tiny Treasure Chest
lootBag[20768] = true -- Oozing Bag
lootBag[86623] = true -- Blingtron 4000 Gift Package


--local lfConfig = mConfig() -- mConfig:createConfig("LootFilter Config","LootFilter","Default",{"/lf","/lootfilter"})
lfConfig = mConfig:createConfig("LootFilter Config","LootFilter","Default",{"/lf","/lootfilter"})
lfConfig:addCheckBox("enabled", "Enabled?","Toggle to enable/disable LootFilter", false)
lfConfig:addTextBox("petSummon", "Pet to summon after Pet Battle","Choose the Pet which should be called after a Pet Battle. Leave empty if none.", "Withers")

function CallPetByName(petName)
   local _,myPets = C_PetJournal.GetNumPets(false)
   for i=1,myPets do
      local petID, speciesID, isOwned, customName, level, favorite, isRevoked, name, icon, petType, creatureID, sourceText, description, isWildPet, canBattle, tradable, unique = C_PetJournal.GetPetInfoByIndex(i, false)
      if name:lower() == petName:lower() then
         return C_PetJournal.SummonPetByGUID(petID)
      end
   end
   print('Pet "'..petName..'" not found')
end


local function combineItems()
    local combinableInventoryItems = {}
    for bag = 0,4,1 do
        for slot = 1, GetContainerNumSlots(bag), 1 do
            local name = GetContainerItemLink(bag, slot)
            if name then
                local itemId = GetContainerItemID(bag, slot) 
                local texture, itemCount, locked, quality, readable, lootable, itemLink = GetContainerItemInfo(bag, slot);
                local copper = select(11,GetItemInfo(itemId)) or 0;
                -- grey: string.find(name,"ff9d9d9d")
                
                if combinableLoot[itemId] then
                    if not combinableInventoryItems[itemId] then combinableInventoryItems[itemId] = 0 end
                    combinableInventoryItems[itemId] = combinableInventoryItems[itemId] + itemCount
                end
            end 
         end 
    end
    for itemId, itemCount in pairs(combinableInventoryItems) do
        if itemCount >= combinableLoot[itemId] then 
            LOG.info("Found %s of Item %s (%s) [Required: %s]", itemCount, GetItemInfo(itemId), itemId, combinableLoot[itemId] )
            RunMacroText("/use item:" .. itemId)
            return -- Exit after first hit
        end
    end
end

local function openLootBags()
    local lootBagsInInventory = {}
    for bag = 0,4,1 do
        for slot = 1, GetContainerNumSlots(bag), 1 do
            local name = GetContainerItemLink(bag, slot)
            if name then
                local itemId = GetContainerItemID(bag, slot) 
                local texture, itemCount, locked, quality, readable, lootable, itemLink = GetContainerItemInfo(bag, slot);
                local copper = select(11,GetItemInfo(itemId)) or 0;
                -- grey: string.find(name,"ff9d9d9d")
                
                if lootBag[itemId] then
                    if not lootBagsInInventory[itemId] then lootBagsInInventory[itemId] = 0 end
                    lootBagsInInventory[itemId] = lootBagsInInventory[itemId] + itemCount
                end
            end 
         end 
    end
    for itemId, itemCount in pairs(lootBagsInInventory) do
        LOG.info("Found %s (%s) [In inventory: %s]", GetItemInfo(itemId), itemId, itemCount )
        RunMacroText("/use item:" .. itemId)
        return -- Exit after first hit
    end
end

local function update(self, elapsed)
    if lfConfig:get("enabled") then
        if self.TimeSinceLastUpdate == nil then self.TimeSinceLastUpdate = 0 end
        self.TimeSinceLastUpdate = self.TimeSinceLastUpdate + elapsed
        if (self.TimeSinceLastUpdate > updateInterval) then
            self.TimeSinceLastUpdate = 0
            combineItems()
            openLootBags()
        end
    end
end

local function eventHandler(self, event, ...)
    if lfConfig:get("enabled") then
        if event == "LOOT_OPENED"  then
            LOG.debug("Loot opened!")
            -- Loot opened!
        elseif  event == "LOOT_CLOSED" then
            LOG.debug("Loot closed!")
        elseif  event == "BAG_UPDATE" then
            LOG.debug("Bag update!")
        elseif  event == "PET_BATTLE_CLOSE" then
            if lfConfig:get("petSummon") ~= "" then
                CallPetByName(lfConfig.get("petSummon"))
            end
        end
    end
end

lootFilterFrame:SetScript("OnEvent", eventHandler)
lootFilterFrame:SetScript("OnUpdate", update)
lootFilterFrame:RegisterEvent("LOOT_OPENED")
lootFilterFrame:RegisterEvent("LOOT_CLOSED")
lootFilterFrame:RegisterEvent("BAG_UPDATE")
lootFilterFrame:RegisterEvent("PET_BATTLE_CLOSE")


