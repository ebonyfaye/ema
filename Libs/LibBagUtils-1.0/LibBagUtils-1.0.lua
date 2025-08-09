-- LibBagUtils-1.0 - Updated for WoW 11.2 API
local MAJOR, MINOR = "LibBagUtils-1.0", tonumber(("$Revision: 36 $"):match("%d+"))
local lib = LibStub:NewLibrary(MAJOR, MINOR)
if not lib then return end -- no upgrade needed

-- Lua API
local strmatch, gsub, floor = string.match, string.gsub, math.floor
local tconcat, band = table.concat, bit.band
local pairs, select, type, next, tonumber, tostring = pairs, select, type, next, tonumber, tostring

-- WoW API (modernized for 11.2)
local GetTime = GetTime
local GetItemInfo, GetItemFamily = GetItemInfo, GetItemFamily
local C_Container = C_Container
local C_Cursor = C_Cursor
local C_Bank = C_Bank
local Enum_BagIndex = Enum.BagIndex
local Enum_BankType = Enum.BankType

local function escapePatterns(str)
	return (gsub(str, "([-+.?*%%%[%]%(%)])", "%%%1"))
end

-----------------------------------------------------------------------
-- Fuzzy link comparator for random suffix items
local function compareFuzzySuffix(link, pattern, uniq16)
	local uniq = strmatch(link, pattern)
	if not uniq then
		return false
	end
	return floor(tonumber(uniq) / 65536) == uniq16
end

local function makeLinkComparator(lookingfor)
	if type(lookingfor) == "number" then
		return strmatch, "|Hitem:" .. escapePatterns(lookingfor) .. "[:|]", nil
	elseif type(lookingfor) == "string" then
		if strmatch(lookingfor, "^item:") or strmatch(lookingfor, "|H") then
			local str = strmatch(lookingfor, "(item:.-:.-:.-:.-:.-:.-:.-:.-)[:|]")
			if not str then
				str = strmatch(lookingfor, "(item:[-0-9:]+)")
			else
				local firsteight, uniq = strmatch(str, "(item:.-:.-:.-:.-:.-:.-:%-.-:)([-0-9]+)")
				if uniq then
					return compareFuzzySuffix,
						"|H" .. escapePatterns(firsteight) .. "([-0-9]+)[:|]",
						floor(tonumber(uniq) / 65536)
				end
			end
			if not str then
				error(MAJOR .. ": MakeLinkComparator(): '" .. tostring(lookingfor) .. "' is invalid", 3)
			end
			return strmatch, "|H" .. escapePatterns(str) .. "[:|]", nil
		else
			return strmatch, "|h%[" .. escapePatterns(lookingfor) .. "%]|h", nil
		end
	end
	error(MAJOR .. ": MakeLinkComparator(): Expected number or string", 3)
end

-----------------------------------------------------------------------
-- Internal slot lock system
lib.slotLocks = {}
local function lockSlot(bag, slot)
	local slots = lib.slotLocks[bag] or {}
	lib.slotLocks[bag] = slots
	slots[slot] = GetTime()
end

local function isLocked(bag, slot)
	local slots = lib.slotLocks[bag]
	if not slots then return false end
	return GetTime() - (slots[slot] or 0) < 2
end

-----------------------------------------------------------------------
-- Container family and free slots wrappers
local function GetContainerFamily(bag)
	local free, fam = C_Container.GetContainerNumFreeSlots(bag)
	return fam
end

function lib:GetContainerFamily(bag)
	return GetContainerFamily(bag)
end

local function myGetContainerNumFreeSlots(bag)
	return C_Container.GetContainerNumFreeSlots(bag)
end

function lib:GetContainerNumFreeSlots(bag)
	return myGetContainerNumFreeSlots(bag)
end

-----------------------------------------------------------------------
-- MakeLinkComparator API
function lib:MakeLinkComparator(lookingfor)
	return makeLinkComparator(lookingfor)
end

-----------------------------------------------------------------------
-- Bag set definitions
local bags = {
	BAGS = {},
	BANK = {},
	BAGSBANK = {},
	REAGENTBANK = {},
}

-- Fill BAGS (backpack + equipped bags)
for i = Enum_BagIndex.Backpack, Enum_BagIndex.Bag_4 do
	bags.BAGS[i] = i
end

-- Fill BANK dynamically
for _, bagID in ipairs(C_Bank.FetchPurchasedBankTabIDs(Enum_BankType.Character) or {}) do
	bags.BANK[bagID] = bagID
end

-- Merge BAGS and BANK into BAGSBANK
for k, v in pairs(bags.BAGS) do
	bags.BAGSBANK[k] = v
end
for k, v in pairs(bags.BANK) do
	bags.BAGSBANK[k] = v
end

-- Reagent bank (if available)
bags.REAGENTBANK[Enum_BagIndex.ReagentBag] = Enum_BagIndex.ReagentBag

-----------------------------------------------------------------------
-- Iterators
local function iterbags(tab, cur)
	cur = next(tab, cur)
	while cur do
		if GetContainerFamily(cur) then
			return cur
		end
		cur = next(tab, cur)
	end
end

local function iterbagsfam0(tab, cur)
	cur = next(tab, cur)
	while cur do
		local free, fam = C_Container.GetContainerNumFreeSlots(cur)
		if fam == 0 then
			return cur
		end
		cur = next(tab, cur)
	end
end

function lib:IterateBags(which, itemFamily)
	local baglist = bags[which]
	if not baglist then
		error([[Usage: LibBagUtils:IterateBags("which"[, itemFamily])]], 2)
	end
	if not itemFamily then
		return iterbags, baglist
	elseif itemFamily == 0 then
		return iterbagsfam0, baglist
	else
		return function(tab, cur)
			cur = next(tab, cur)
			while cur do
				local fam = GetContainerFamily(cur)
				if fam and band(itemFamily, fam) ~= 0 then
					return cur
				end
				cur = next(tab, cur)
			end
		end, baglist
	end
end

-----------------------------------------------------------------------
-- CountSlots
function lib:CountSlots(which, itemFamily)
	local baglist = bags[which]
	if not baglist then
		error([[Usage: LibBagUtils:CountSlots("which"[, itemFamily])]], 2)
	end
	local free, tot = 0, 0
	if not itemFamily then
		for bag in pairs(baglist) do
			local f = C_Container.GetContainerNumFreeSlots(bag)
			free = free + f
			tot = tot + C_Container.GetContainerNumSlots(bag)
		end
	elseif itemFamily == 0 then
		for bag in pairs(baglist) do
			local f, fam = C_Container.GetContainerNumFreeSlots(bag)
			if fam == 0 then
				free = free + f
				tot = tot + C_Container.GetContainerNumSlots(bag)
			end
		end
	else
		for bag in pairs(baglist) do
			local f, fam = C_Container.GetContainerNumFreeSlots(bag)
			if fam and band(itemFamily, fam) ~= 0 then
				free = free + f
				tot = tot + C_Container.GetContainerNumSlots(bag)
			end
		end
	end
	return free, tot
end

-----------------------------------------------------------------------
-- IsBank & IsReagentBank
function lib:IsBank(bag)
	return bags.BANK[bag] ~= nil
end

function lib:IsReagentBank(bag)
	return bag == Enum_BagIndex.ReagentBag
end

-----------------------------------------------------------------------
-- Iterate
function lib:Iterate(which, lookingfor)
	local baglist = bags[which]
	if not baglist then
		error([[Usage: LibBagUtils:Iterate(which [, item])]], 2)
	end
	local bag, slot, curbagsize = nil, 0, 0
	local function iterator()
		while slot >= curbagsize do
			bag = iterbags(baglist, bag)
			if not bag then return nil end
			curbagsize = C_Container.GetContainerNumSlots(bag) or 0
			slot = 0
		end
		slot = slot + 1
		return bag, slot, C_Container.GetContainerItemLink(bag, slot)
	end
	if lookingfor == nil then
		return iterator
	else
		local comparator, arg1, arg2 = makeLinkComparator(lookingfor)
		return function()
			for bag, slot, link in iterator do
				if link and comparator(link, arg1, arg2) then
					return bag, slot, link
				end
			end
		end
	end
end

-----------------------------------------------------------------------
-- Find
function lib:Find(where, lookingfor, findLocked)
	for bag, slot, link in lib:Iterate(where, lookingfor) do
		local info = C_Container.GetContainerItemInfo(bag, slot)
		if findLocked or not (info and info.isLocked) then
			return bag, slot, link
		end
	end
end

-----------------------------------------------------------------------
-- FindSmallestStack
function lib:FindSmallestStack(where, lookingfor, findLocked)
	local smallest, smbag, smslot = math.huge
	for bag, slot in lib:Iterate(where, lookingfor) do
		local info = C_Container.GetContainerItemInfo(bag, slot)
		if info and info.stackCount < smallest and (findLocked or not info.isLocked) then
			smbag, smslot, smallest = bag, slot, info.stackCount
		end
	end
	if smbag then
		return smbag, smslot, smallest
	end
end

-----------------------------------------------------------------------
-- PutItem
local function putinbag(destbag)
	for slot = 1, C_Container.GetContainerNumSlots(destbag) do
		local info = C_Container.GetContainerItemInfo(destbag, slot)
		if not info and not isLocked(destbag, slot) then
			C_Container.PickupContainerItem(destbag, slot)
			if not C_Cursor.GetCursorItem() then
				lockSlot(destbag, slot)
				return slot
			end
		end
	end
end

function lib:PutItem(where, count, dontClearOnFail)
	local cursorItem = C_Cursor.GetCursorItem()
	if not cursorItem then
		geterrorhandler()(MAJOR .. ": PutItem(): No item on cursor.")
		return 0, 0
	end
	local baglist = bags[where]
	if not baglist then
		error("Usage: LibBagUtils:PutItem(where[, count[, dontClearOnFail]])", 2)
	end
	local itemLink = C_Item.GetItemLink(cursorItem)
	local itemID = C_Item.GetItemID(cursorItem)
	if count and count >= 1 then
		local _, _, _, _, _, _, _, itemStackCount = GetItemInfo(itemLink)
		if itemStackCount > 1 and count < itemStackCount then
			local bestsize, bestbag, bestslot = 0
			for bag, slot in lib:Iterate(where, itemID) do
				local info = C_Container.GetContainerItemInfo(bag, slot)
				if info and not info.isLocked and not isLocked(bag, slot) then
					if info.stackCount + count <= itemStackCount and info.stackCount > bestsize then
						bestsize, bestbag, bestslot = info.stackCount, bag, slot
					end
				end
			end
			if bestbag then
				C_Container.PickupContainerItem(bestbag, bestslot)
				if not C_Cursor.GetCursorItem() then
					lockSlot(bestbag, bestslot)
					return bestbag, bestslot
				end
			end
		end
	end
	local itemFam = GetItemFamily(itemLink)
	if itemFam ~= 0 and select(9, GetItemInfo(itemLink)) == "INVTYPE_BAG" then
		itemFam = 0
	end
	if itemFam ~= 0 then
		for bag in iterbags, baglist do
			local _, bagFam = C_Container.GetContainerNumFreeSlots(bag)
			if bagFam ~= 0 and band(itemFam, bagFam) ~= 0 then
				local slot = putinbag(bag)
				if slot then
					return bag, slot
				end
			end
		end
	end
	for bag in iterbagsfam0, baglist do
		if C_Container.GetContainerNumFreeSlots(bag) > 0 then
			local slot = putinbag(bag)
			if slot then
				return bag, slot
			end
		end
	end
	if not dontClearOnFail then
		C_Cursor.ClearCursor()
	end
	return false
end

-----------------------------------------------------------------------
-- LinkIsItem
function lib:LinkIsItem(fullLink, lookingfor)
	local comparator, arg1, arg2 = makeLinkComparator(lookingfor)
	return comparator(fullLink, arg1, arg2)
end
