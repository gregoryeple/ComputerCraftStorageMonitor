--[[

PeripheralDetector program
By Out-Feu

version 1.0.0

Free to distribute/alter
so long as proper credit to original
author is maintained.

This program will display on a monitor the storage of all connected RF storage cells or equivalent.
Multiple monitors can be connected.

--]]

table.find = function(self, search)
 for index, value in pairs(self) do
  if value == search then
   return index
  end
 end
 return nil
end

table.findAll = function(self, searchTable)
 for i, search in pairs(searchTable) do
  local found = false
  for index, value in pairs(self) do
   if value == search then
    found = true
    break
   end
  end
  if not found then
   return false
  end
 end
 return true
end

math.floorDecimal = function(num, precision)
 local power = 10 ^ math.abs(precision)
 if precision < 0 then
  return math.floor(num / power) * power
 else
  return math.floor(num * power) / power
 end
end

function formatNumber(num)
 local abreviation = ""
 if useAbreviation then
  local n = 1
  while num >= 1000 and n <= #abreviationList do
   num = num / 1000
   abreviation = abreviationList[n]
   n = n + 1
  end
 end
 return math.floorDecimal(num, decimalPrecision) .. abreviation .. " " .. storageType
end

function getCurrentStorage()
 local currentStorage = 0 
 for i, storage in pairs(storageRF) do
  currentStorage = currentStorage + storage.getEnergy()
 end
 for i, storage in pairs(storageMeka) do
  currentStorage = currentStorage + math.floor(storage.getEnergy() * 0.4)
 end
 for i, storage in pairs(storageEU) do
  currentStorage = currentStorage + storage.getEUStored()
 end
 for i, storage in pairs(storageQIO) do
  if storage.hasFrequency() then
   currentStorage = currentStorage + storage.getFrequencyItemCount()
  end
 end
 for i, storage in pairs(storageItem) do
  for n, item in pairs(storage.list()) do
   currentStorage = currentStorage + item.count
  end
 end
 return currentStorage
end

function getMaxStorage()
 local maxStorage = 0
 for i, storage in pairs(storageRF) do
  maxStorage = maxStorage + storage.getEnergyCapacity()
 end
 for i, storage in pairs(storageMeka) do
  maxStorage = maxStorage + math.floor(storage.getMaxEnergy() * 0.4)
 end
 for i, storage in pairs(storageEU) do
  maxStorage = maxStorage + storage.getEUCapacity()
 end
 for i, storage in pairs(storageItem) do
  for n = 1, storage.size() do
   local item = storage.getItemDetail(n)
   if item ~= nil then
    maxStorage = maxStorage + item.maxCount
   else
    maxStorage = maxStorage + storage.getItemLimit(n)
   end
  end
 end
 for i, storage in pairs(storageQIO) do
  if storage.hasFrequency() then
   maxStorage = maxStorage + storage.getFrequencyItemCapacity()
  end
 end
 return maxStorage
end

function findStorageType()
 if forceStorageType ~= nil and forceStorageType ~= "" then
  return forceStorageType
 end
 types = { (#storageRF + #storageMeka), #storageEU, (#storageItem + #storageQIO) }
 nType = 0
 for i, type in pairs(types) do
  if type > 0 then
   nType = nType + 1
  end
 end
 if nType == 1 then
  if #storageRF > 0 or #storageMeka > 0 then
   return "RF"
  elseif #storageEU > 0 then
   return "EU"
  elseif #storageItem > 0  or #storageQIO > 0 then
   return "Item"
  end
 end
 return ""
end

function findConnectedPeripherals(resetAll)
 if resetAll then
  monitors = {}
  storageRF = {}
  storageMeka = {}
  storageEU = {}
  storageItem = {}
  storageQIO = {}
 end
 local peripherals = peripheral.getNames()
 for i, per in pairs(peripherals) do
  if peripheral.getType(per) == "monitor" then
   table.insert(monitors, peripheral.wrap(per))
  elseif table.findAll(peripheral.getMethods(per), {"getEnergy", "getEnergyCapacity"}) and table.find({nil, "", "RF", "FE"}, forceStorageType) ~= nil then
   table.insert(storageRF, peripheral.wrap(per))
  elseif table.findAll(peripheral.getMethods(per), {"getEnergy", "getMaxEnergy"}) and table.find({nil, "", "RF", "FE"}, forceStorageType) ~= nil then
   table.insert(storageMeka, peripheral.wrap(per))
  elseif table.findAll(peripheral.getMethods(per), {"getEUStored", "getEUCapacity"}) and table.find({nil, "", "EU"}, forceStorageType) ~= nil then
   table.insert(storageEU, peripheral.wrap(per))
  elseif table.findAll(peripheral.getMethods(per), {"hasFrequency", "getFrequencyItemCount", "getFrequencyItemCapacity"}) and table.find({nil, "", "Item"}, forceStorageType) ~= nil then
   table.insert(storageQIO, peripheral.wrap(per))
  elseif table.findAll(peripheral.getMethods(per), {"size", "list", "getItemLimit", "getItemDetail"}) and table.find({nil, "", "Item"}, forceStorageType) ~= nil then
   table.insert(storageItem, peripheral.wrap(per))
  elseif peripheral.getType(per) ~= "modem" then
   printError("Found unsupported peripheral: " .. peripheral.getType(per))
  end
 end
 print("Found " .. #monitors .. " monitors and " .. (#storageRF + #storageMeka + #storageEU + #storageItem + #storageQIO) .. " storage peripherals")
end 

function initStorageColor()
 if storageFillColor ~= nil then
  return
 elseif storageType == "RF" or storageType == "FE" then
  if #storageMeka > 0 and #storageRF == 0 then
   storageFillColor = colors.green
   storageFillColorAlt = colors.lime
  else
   storageFillColor = colors.red
   storageFillColorAlt = colors.pink
  end
 elseif storageType == "EU" or storageType == "Mana" or storageType == "mB" then
  storageFillColor = colors.blue
  storageFillColorAlt = colors.lightBlue
 elseif storageType == "Item" then
  storageFillColor = colors.brown
  storageFillColorAlt = colors.orange
 else
  storageFillColor = colors.white
  storageFillColorAlt = colors.lightGray
 end
end

--------------------------------------------------------------------------------

textColor = colors.white --color of the text
backgroundColor = colors.black --background color of the program
transfertPlusColor = colors.green --color of the text for positive transfert
transfertMinusColor = colors.red --color of the text for negative transfert
storageBackgroundColor = colors.gray --color for empty storage space
storageFillColor = nil --color for full storage, set to nil to automatically set the color depending on storage type
storageFillColorAlt = nil --transition color for half full storage, set to nil to automatically set the color depending on storage type
displayTotalStorage = true --display the total storage
displayCurrentStorage = true --display the current storage
displayStorageTransfert = true --display the difference of the current storage per tick
displayStoragePercent = true --display the fill percentage of the storage
paddingAll = 1 --padding on all the sides of the monitor
paddingSide = 0 --extra padding on the left and on the right of the storage space display
decimalPrecision = 2 --maximum number of decimal to display on storage capacity
useAbreviation = false --use abreviations on storage capacity
forceStorageType = "" --if set, all other conneczzted storage type will be ignored
updateFrequency = 1 --how often should the display be updated (in seconds)

abreviationList = { "K", "M", "B", "T" } --each subsequent symbol must be equal to it's predecessor x1000
storageRF = {}
storageMeka = {}
storageEU = {}
storageItem = {}
storageQIO = {}
monitors = {}
storageType = ""

--------------------------------------------------------------------------------

findConnectedPeripherals(false)
storageType = findStorageType()
initStorageColor()

currentMaxStorage = getMaxStorage()
currentStorage = getCurrentStorage()
currentTransfert = 0
if currentMaxStorage == 0 then
 currentPercent = 0
else
 currentPercent = currentStorage / currentMaxStorage
end
os.startTimer(updateFrequency)
repeat --main loop

 --display storage on the monitors
 for index, monitor in pairs(monitors) do
  local w, h = monitor.getSize()
  monitor.setTextColour(textColor)
  monitor.setBackgroundColor(backgroundColor)
  monitor.clear()
  paddingTop = 1 + paddingAll
  if displayTotalStorage then
   monitor.setCursorPos(1 + paddingAll, paddingTop)
   monitor.write("Capacity:  " .. formatNumber(currentMaxStorage))
   paddingTop = paddingTop + 1
  end
  if displayCurrentStorage then
   monitor.setCursorPos(1 + paddingAll, paddingTop)
   monitor.write("Stored:    " .. formatNumber(currentStorage))
   paddingTop = paddingTop + 1
  end
  if displayStorageTransfert then
   monitor.setCursorPos(1 + paddingAll, paddingTop)
    monitor.write("Transfer: ")
   if currentTransfert == 0 then
    monitor.write(" " .. formatNumber(currentTransfert) .. "/t")
   elseif currentTransfert > 0 then
    monitor.setTextColour(transfertPlusColor)
    monitor.write("+" .. formatNumber(currentTransfert) .. "/t")
   else
    monitor.setTextColour(transfertMinusColor)
    monitor.write(formatNumber(currentTransfert) .. "/t")
   end
   paddingTop = paddingTop + 1
  end
  if displayTotalStorage or displayCurrentStorage or displayStorageTransfert then
   paddingTop = paddingTop + 1
  end
  local height = h - paddingTop - paddingAll
  local width = w - (paddingAll * 2) - (paddingSide * 2)
  local lenPercent = height - (height * currentPercent)
  for n = 0, height do
   if n < lenPercent or (n == height and currentPercent <= 0) then
    monitor.setBackgroundColor(storageBackgroundColor)
   elseif storageFillColorAlt ~= nil and n == math.ceil(lenPercent) and currentPercent < 1 and n - lenPercent < 0.5 then
    monitor.setBackgroundColor(storageFillColorAlt)
   else
    monitor.setBackgroundColor(storageFillColor)
   end
   monitor.setCursorPos(1 + paddingAll + paddingSide, paddingTop + n)
   monitor.write(string.rep(" ", width))
   if displayStoragePercent and n == math.floor(height / 2) then
    local padingPercent = width / 2
    if currentPercent < 10 then
     padingPercent = padingPercent - 1
    elseif currentPercent < 100 then
     padingPercent = padingPercent - 1.5
    else
     padingPercent = padingPercent - 2
    end
    monitor.setTextColour(textColor)
    monitor.setCursorPos(1 + paddingAll + paddingSide + padingPercent, paddingTop + n)
    monitor.write(math.floor(currentPercent * 100) .. "%")
   end
  end
 end

 --wait for event
 local eve,id,cx,cy
 repeat
  event = os.pullEvent()
 until event == "timer" or event == "peripheral" or event == "peripheral_detach" or event == "monitor_resize"
 
 if event == "timer" then
  local oldStorage = currentStorage
  currentStorage = getCurrentStorage()
  currentTransfert = (currentStorage - oldStorage) / (updateFrequency * 20)
  if currentMaxStorage == 0 then
   currentPercent = 0
  else
   currentPercent = currentStorage / currentMaxStorage
  end
  os.startTimer(updateFrequency)
 elseif event == "peripheral" or event == "peripheral_detach" then
   findConnectedPeripherals(true)
   storageType = findStorageType()
   currentMaxStorage = getMaxStorage()
 end

until false