-- ================================================================================ --
--				EMA - ( Ebony's MultiBoxing Assistant )    							--
--				Current Author: Jennifer Calladine (Ebony)								--
--																					--
--				License: All Rights Reserved 2018-2023 Jennifer Calladine							--
--																					--
--				Some Code Used from "Jamba" that is 								--
--				Released under the MIT License 									--
--				"Jamba" Copyright 2008-2015  Michael "Jafula" Miller				--
--																					--
-- ================================================================================ --

-- Localization debugging.
--GAME_LOCALE = "frFR"

local MAJOR, MINOR = "EbonyUtilities-1.0", 1
local EbonyUtilities, oldMinor = LibStub:NewLibrary( MAJOR, MINOR )

if not EbonyUtilities then 
	return 
end

-- Code modified from http://lua-users.org/wiki/CopyTable
function EbonyUtilities:CopyTable(object)
    local lookup_table = {}
    local function _copy(object)
        if type(object) ~= "table" then
            return object
        elseif lookup_table[object] then
            return lookup_table[object]
        end
        local new_table = {}
        lookup_table[object] = new_table
        for index, value in pairs(object) do
            new_table[_copy(index)] = _copy(value)
        end
        return setmetatable(new_table, getmetatable(object))
    end
    return _copy(object)
end

function EbonyUtilities:ClearTable( object )
	for key in next, object do
		if type( object[key] ) == "table" then
			EbonyUtilities:ClearTable( object[key] )
		end
		object[key] = nil
	end
end

function EbonyUtilities:GetStatusPercent(val, max)
	if (max > 0) then
		return (val / max)
	end
	return 1.0
end

function EbonyUtilities:Lowercase( name )
	if name ~= nil then
		return string.utf8lower( name )
	end	
end

function EbonyUtilities:AddRealmToNameIfMissing( name )
	if name == nil then
		return
	end
	Name = name:gsub("^%l", string.upper )
	fullName = Name:gsub( "%s+", "")
	local matchDash = fullName:find( "-" )
	if not matchDash then
		local k = GetRealmName()
		local realm = k:gsub( "%s+", "")
		fullName = fullName.."-"..realm
		end
	return fullName
end

-- Capitalise the name.	
function EbonyUtilities:Capitalise( name )
    if name ~= nil then
		return string.utf8upper( string.utf8sub( name, 1, 1 ) )..string.utf8lower( string.utf8sub( name, 2 ) )
	end
end	

function EbonyUtilities:AddRealmToNameIfNotNil( name, realm )
	local fullName = name
	if realm ~= nil and realm:trim() ~= "" then
		fullName = name.."-"..realm
	end
	return fullName
end

-- Money constants.
EbonyUtilities.COLOUR_COPPER = "eda55f"
EbonyUtilities.COLOUR_SILVER = "c7c7cf"
EbonyUtilities.COLOUR_GOLD = "ffd700"
EbonyUtilities.COPPER_PER_SILVER = 100;
EbonyUtilities.SILVER_PER_GOLD = 100;
EbonyUtilities.COPPER_PER_GOLD = EbonyUtilities.COPPER_PER_SILVER * EbonyUtilities.SILVER_PER_GOLD;

-- value - the amount of money to display formatted.
-- Creates a money string from the value passed; don't pass negative values!
function EbonyUtilities:FormatMoneyString( value )
	local gold = floor( value / ( EbonyUtilities.COPPER_PER_SILVER * EbonyUtilities.SILVER_PER_GOLD ) );
	local silver = floor( ( value - ( gold * EbonyUtilities.COPPER_PER_SILVER * EbonyUtilities.SILVER_PER_GOLD ) ) / EbonyUtilities.COPPER_PER_SILVER );
	local copper = mod( value, EbonyUtilities.COPPER_PER_SILVER );
	local goldFormat = format( "|cff%s%d|r", EbonyUtilities.COLOUR_GOLD, gold )	
	local silverFormat = format( "|cff%s%02d|r", EbonyUtilities.COLOUR_SILVER, silver )
	local copperFormat = format( "|cff%s%02d|r", EbonyUtilities.COLOUR_COPPER, copper )
	if gold <=0 then
		goldFormat = ""
		if silver <= 0 then
			silverFormat = ""
		end
	end
	return strtrim(goldFormat.." "..silverFormat.." "..copperFormat)	
end

-- A little toy to retun Gold,  silver and copper for mail use
function EbonyUtilities:MoneyString( value )
	local gold = floor( value / ( EbonyUtilities.COPPER_PER_SILVER * EbonyUtilities.SILVER_PER_GOLD ) );
	local silver = floor( ( value - ( gold * EbonyUtilities.COPPER_PER_SILVER * EbonyUtilities.SILVER_PER_GOLD ) ) / EbonyUtilities.COPPER_PER_SILVER );
	local copper = mod( value, EbonyUtilities.COPPER_PER_SILVER );
	if gold <=0 then
		goldFormat = ""
		if silver <= 0 then
			silverFormat = ""
		end
	end
	return gold, silver, copper	
end


-- A little toy to retun Gold,  silver and copper for formatted use.
function EbonyUtilities:MoneyStringFormatted( value )
	local gold = floor( value / ( EbonyUtilities.COPPER_PER_SILVER * EbonyUtilities.SILVER_PER_GOLD ) );
	local silver = floor( ( value - ( gold * EbonyUtilities.COPPER_PER_SILVER * EbonyUtilities.SILVER_PER_GOLD ) ) / EbonyUtilities.COPPER_PER_SILVER );
	local copper = mod( value, EbonyUtilities.COPPER_PER_SILVER );
	if gold <=0 then
		goldFormat = ""
		if silver <= 0 then
			silverFormat = ""
		end
	end
	return BreakUpLargeNumbers(gold), silver, copper	
end


-- itemLink - the item link to extract an item id from.
-- Gets an item id from an item link.  Returns nil, if an item id could not be found.
function EbonyUtilities:GetItemIdFromItemLink( itemLink )
	if itemLink == nil then
		return
	end
	local itemIdFound = nil 
	local itemStringStart, itemStringEnd, itemString = itemLink:find( "^|c%x+|H(.+)|h%[.*%]" )
	if itemStringStart then
		local matchStart, matchEnd, itemId = itemString:find( "(item:%d+)" )
		if matchStart then
			itemIdFound = itemId	
		end
	end
	return itemIdFound	
end

-- itemLink1 - the first item link to compare.
-- itemLink2 - the second item link to compare.
-- Compares two itemlinks to see if they both refer to the same item.  Return true if they do, false if they don't.
function EbonyUtilities:DoItemLinksContainTheSameItem( itemLink1, itemLink2 )
	local theSame = false
	local itemId1 = EbonyUtilities:GetItemIdFromItemLink( itemLink1 )
	local itemId2 = EbonyUtilities:GetItemIdFromItemLink( itemLink2 )
	if itemId1 ~= nil and itemId2 ~= nil then
		if itemId1 == itemId2 then
			theSame = true
		end
	end
	return theSame	
end

-- state - string value containing "on" or "off".
-- onCommand - string that is equivalent to true, like "on".
-- offCommand - string that is equivalent to false, like "off".
-- Returns true for "on"; false for "off"; nil for invalid.
function EbonyUtilities:GetOnOrOffFromCommand( state, onCommand, offCommand )
	local setToOn = nil
	state = state:lower():trim()
	if state == onCommand then
		setToOn = true
	end
	if state == offCommand then
		setToOn = false
	end
	return setToOn
end

-- Check for a buff.
function EbonyUtilities:DoesThisCharacterHaveBuff( buffName )
	local hasBuff = false
	local iterateBuffs = 1
	local buff = UnitBuff( "player", iterateBuffs )
	while buff ~= nil do
		if buff == buffName then
			hasBuff = true
			break
		end
		iterateBuffs = iterateBuffs + 1
		buff = UnitBuff( "player", iterateBuffs )
	end
	return hasBuff
end

function EbonyUtilities:FixValueToRange( value, minValue, maxValue )
	if value < minValue then
		value = minValue
	end		
	if value > maxValue then
		value = maxValue
	end	
	return value
end

function EbonyUtilities:MerchantFrameIsShown()
	local Show = false
	if MerchantFrame:IsVisible() == true then
		Show = true
	else
		if IsAddOnLoaded("TradeSkillMaster" ) == true then
			if TSM_API.IsUIVisible("VENDORING") == true then
				Show = true
			end
		end
	end	
	return Show
end	

function EbonyUtilities:CheckIsFromMyRealm( name )
	--print("test", name)
	local sameRealm = false
	if name ~= nil then
		local player, realm = strsplit( "-", name, 2 )
		local myRealm = string.gsub(GetRealmName(), "%s+", "")
		if realm == myRealm then
			--print("Real SameRealm")
			sameRealm = true
		else
			local connectedServers = GetAutoCompleteRealms()
			if connectedServers then --Check if realm matches any realm in our connection		
				for i = 1, #connectedServers do
	 				if realm == connectedServers[i] then
						--print("connectedRealm")
						sameRealm = true
					end
				end		
			else
				--print("NotFromARealm")
				sameRealm = false
			end
		end	
	end
	return sameRealm
end	
	
function EbonyUtilities:InTagList( tag )
	local isInTagList = false
	if JambaApi.DoesGroupExist(  tag ) then
		isInTagList = true 
	end	
	return isInTagList	
end	

function EbonyUtilities:TooltipScaner(item)
	local text = nil
	local text2 = nil	
		if item ~= nil then
			local tooltipName = "EMAScanner"
			local tooltipScanner = CreateFrame("GameTooltip", tooltipName, nil, "GameTooltipTemplate")
			tooltipScanner:SetOwner( WorldFrame, "ANCHOR_NONE")
			tooltipScanner:SetHyperlink(item)
			local tooltipText = _G[tooltipName.."TextLeft2"]:GetText()
			local tooltipTextTwo = _G[tooltipName.."TextLeft3"]:GetText()
				--print("test",  tooltipTextTwo)
				text = tooltipText 
				text2 = tooltipTextTwo	
			--print("test9", text, text2)
			--tooltipScanner:Hide()
			tooltipScanner:Hide()
			tooltipScanner:ClearLines()
		end		
	
	return text, text2
end

-- We should Not need this anymore but its always here incase! using ItemMixIn
function EbonyUtilities:ToolTipBagScaner(item, bag, slot)
	--print("test", item, bag, slot )
	if item ~= nil or bag ~= nil or slot ~= nil then
		local boe = nil
		local ilvl = nil
		local tooltipName = "EMABagScanner"
		local tooltipbagScanner = CreateFrame("GameTooltip", tooltipName , nil, "GameTooltipTemplate")
			tooltipbagScanner:SetOwner(UIParent, "ANCHOR_NONE")
			tooltipbagScanner:SetBagItem(bag, slot)
			tooltipbagScanner:Show()		
		for i = 1,6 do
			local t = _G[tooltipName.."TextLeft"..i]:GetText()
			--print("test", t)
			if (t == ITEM_SOULBOUND) then
				boe = ITEM_SOULBOUND
			end
		end
	    tooltipbagScanner:Hide()
		return boe
	end
end

-- GetPetOwner
function EbonyUtilities:getPetOwner( petName )
	--print(petName)
	if petName ~= nil then
		local tooltipName = "EMAPetScanner"
		local tooltipPetScanner = CreateFrame("GameTooltip", tooltipName, nil, "GameTooltipTemplate")
		tooltipPetScanner:ClearLines()
		tooltipPetScanner:SetOwner(WorldFrame, "ANCHOR_NONE")
		tooltipPetScanner:SetUnit( petName )
		local ownerName = _G[tooltipName.."TextLeft2"]:GetText() -- This is the line with <[Player]'s Pet>
		if not ownerName then 
			 return nil 
		end
		local owner, _ = string.split("'",ownerName)
		tooltipPetScanner:Hide()
		return owner -- This is the pet's owner
	--	print(owner)
	end
end

function EbonyUtilities:endsWith(str, ending)
	if str ~= nil then
		return str:match(ending .. '$')
	else
		return false
	end
end
