-- ================================================================================ --
--				EMA - ( Ebony's MultiBoxing Assistant )    							--
--				Current Author: Jennifer Cally (Ebony)								--
--																					--
--				License: All Rights Reserved 2018-2021 Jennifer Calladine					--
--																					--
--				Some Code Used from "Jamba" that is 								--
--				Released under the MIT License 										--
--				"Jamba" Copyright 2008-2015  Michael "Jafula" Miller				--
--																					--
-- ================================================================================ --

-- Create the addon using AceAddon-3.0 and embed some libraries.
local EMA = LibStub( "AceAddon-3.0" ):NewAddon( 
	"Purchase", 
	"Module-1.0", 
	"AceConsole-3.0", 
	"AceEvent-3.0",
	"AceHook-3.0"
)

-- Load libraries.
local EMAUtilities = LibStub:GetLibrary( "EbonyUtilities-1.0" )
local EMAHelperSettings = LibStub:GetLibrary( "EMAHelperSettings-1.0" )
local LibBagUtils = LibStub:GetLibrary( "LibBagUtils-1.0" )
local AceGUI = LibStub:GetLibrary( "AceGUI-3.0" )

--  Constants and Locale for this module.
EMA.moduleName = "Purchase"
EMA.settingsDatabaseName = "PurchaseProfileDB"
EMA.chatCommand = "ema-purchase"
local L = LibStub( "AceLocale-3.0" ):GetLocale( "Core" )
EMA.parentDisplayName = L["VENDER"]
EMA.moduleDisplayName = L["PURCHASE"]
-- Icon 
EMA.moduleIcon = "Interface\\Addons\\EMA\\Media\\SellIcon.tga"
-- order
EMA.moduleOrder = 60

-- Settings - the values to store and their defaults for the settings database.
EMA.settings = {
	global = {
		['**'] = {
			autoBuyItemsListGlobal = {},
		},
	 },
	profile = {
		autoBuy = false,
		autoBuyOverflow = true,
		globalBuyList = false,
		messageArea = EMAApi.DefaultMessageArea(),
		autoBuyItems = {}
	},
}

-- Configuration.
function EMA:GetConfiguration()
	local configuration = {
		name = EMA.moduleDisplayName,
		handler = EMA,
		type = 'group',
		childGroups  = "tab",
		get = "EMAConfigurationGetSetting",
		set = "EMAConfigurationSetSetting",
		args = {
			config = {
				type = "input",
				name = L["OPEN_CONFIG"],
				desc = L["OPEN_CONFIG_HELP"],
				usage = "/ema-purchase config",
				get = false,
				set = "",				
			},
			push = {
				type = "input",
				name = L["PUSH_SETTINGS"],
				desc = L["PUSH_ALL_SETTINGS"],
				usage = "/ema-purchase push",
				get = false,
				set = "EMASendSettings",
			},
			copy = {
				type = "input",
				name = L["COPY"],
				desc = L["COPY_HELP"],
				usage = "/ema-purchase copy",
				get = false,
				set = "CopyListCommmand",
			},
		},
	}
	return configuration
end

-------------------------------------------------------------------------------------------------------------
-- Command this module sends.
-------------------------------------------------------------------------------------------------------------

-------------------------------------------------------------------------------------------------------------
-- Messages module sends.
-------------------------------------------------------------------------------------------------------------

-------------------------------------------------------------------------------------------------------------
-- Purchase Management.
-------------------------------------------------------------------------------------------------------------

function EMA:BeforeEMAProfileChanged()	
end

function EMA:OnEMAProfileChanged()	
	EMA:SettingsRefresh()
end

function EMA:SettingsRefresh()
	EMA.settingsControl.checkBoxAutoBuy:SetValue( EMA.db.autoBuy )
	-- global CheckBox
	EMA.settingsControl.checkBoxGlobalBuyList:SetValue( EMA.db.globalBuyList )
	EMA.settingsControl.checkBoxGlobalBuyList:SetDisabled( not EMA.db.autoBuy )	
	EMA.settingsControl.checkBoxAutoBuyOverflow:SetValue( EMA.db.autoBuyOverflow )
	EMA.settingsControl.editBoxTag:SetText( EMA.autoBuyItemTag )
	EMA.settingsControl.editBoxAmount:SetText( EMA.autoBuyAmount )
	EMA.settingsControl.dropdownMessageArea:SetValue( EMA.db.messageArea )	
	EMA.settingsControl.checkBoxAutoBuyOverflow:SetDisabled( not EMA.db.autoBuy )
	EMA.settingsControl.editBoxItem:SetDisabled( not EMA.db.autoBuy )
	EMA.settingsControl.editBoxTag:SetDisabled( not EMA.db.autoBuy )
	EMA.settingsControl.editBoxAmount:SetDisabled( not EMA.db.autoBuy )
	EMA.settingsControl.buttonRemove:SetDisabled( not EMA.db.autoBuy )
	EMA.settingsControl.buttonAdd:SetDisabled( not EMA.db.autoBuy )
	EMA:SettingsScrollRefresh()
end

-- Settings received.
function EMA:EMAOnSettingsReceived( characterName, settings )	
	if characterName ~= EMA.characterName then
		-- Update the settings.
		EMA.db.autoBuy = settings.autoBuy
		EMA.db.globalBuyList = settings.globalBuyList	
		EMA.db.autoBuyOverflow = settings.autoBuyOverflow
		EMA.db.messageArea = settings.messageArea
		EMA.db.autoBuyItems = EMAUtilities:CopyTable( settings.autoBuyItems )
		EMA.db.global.autoBuyItemsListGlobal = EMAUtilities:CopyTable( settings.global.autoBuyItemsListGlobal )		
		-- Refresh the settings.
		EMA:SettingsRefresh()
		-- Tell the player.
		EMA:Print( L["SETTINGS_RECEIVED_FROM_A"]( characterName ) )
	end
end

-------------------------------------------------------------------------------------------------------------
-- Settings Dialogs.
-------------------------------------------------------------------------------------------------------------

local function SettingsCreateOptions( top )
	-- Position and size constants.
	local buttonControlWidth = 105
	local checkBoxHeight = EMAHelperSettings:GetCheckBoxHeight()
	local buttonHeight = EMAHelperSettings:GetButtonHeight()
	local editBoxHeight = EMAHelperSettings:GetEditBoxHeight()
	local dropdownHeight = EMAHelperSettings:GetDropdownHeight()
	local left = EMAHelperSettings:LeftOfSettings()
	local headingHeight = EMAHelperSettings:HeadingHeight()
	local headingWidth = EMAHelperSettings:HeadingWidth( false )
	local horizontalSpacing = EMAHelperSettings:GetHorizontalSpacing()
	local indentContinueLabel = horizontalSpacing * 18
	local verticalSpacing = EMAHelperSettings:GetVerticalSpacing()
	local halfWidth = (headingWidth - horizontalSpacing) / 2
	local thirdWidth = (headingWidth - indentContinueLabel) / 3	
	local left2 = left + thirdWidth +  horizontalSpacing
	local left3 = left2 + thirdWidth +  horizontalSpacing
	local dropBoxWidth = (headingWidth - horizontalSpacing) / 4	
	
	local movingTop = top
	-- A blank to get layout to show right?
	EMAHelperSettings:CreateHeading( EMA.settingsControl, L[""], movingTop, false )
	movingTop = movingTop - headingHeight
	EMAHelperSettings:CreateHeading( EMA.settingsControl, L["PURCHASE_ITEMS"], movingTop, false )
	movingTop = movingTop - headingHeight
	EMA.settingsControl.checkBoxAutoBuy = EMAHelperSettings:CreateCheckBox( 
		EMA.settingsControl, 
		thirdWidth, 
		left, 
		movingTop, 
		L["AUTO_BUY_ITEMS"],
		EMA.SettingsToggleAutoBuyItems
	)	
	EMA.settingsControl.checkBoxAutoBuyOverflow = EMAHelperSettings:CreateCheckBox( 
		EMA.settingsControl, 
		thirdWidth, 
		left2, 
		movingTop, 
		L["OVERFLOW"],
		EMA.SettingsToggleAutoBuyItemsOverflow
	)	
	EMA.settingsControl.checkBoxGlobalBuyList = EMAHelperSettings:CreateCheckBox( 
		EMA.settingsControl, 
		thirdWidth, 
		left3, 
		movingTop, 
		L["GLOBAL_LIST"],
		EMA.SettingsToggleGlobalBuyList,
		L["GLOBAL_SETTINGS_LIST_HELP"]
	)
	movingTop = movingTop - checkBoxHeight	
	EMA.settingsControl.highlightRow = 1
	EMA.settingsControl.offset = 1
	local list = {}
	list.listFrameName = "EMAPurchaseSettingsFrame"
	list.parentFrame = EMA.settingsControl.widgetSettings.content
	list.listTop = movingTop
	list.listLeft = left
	list.listWidth = headingWidth
	list.rowHeight = 20
	list.rowsToDisplay = 8
	list.columnsToDisplay = 3
	list.columnInformation = {}
	list.columnInformation[1] = {}
	list.columnInformation[1].width = 60
	list.columnInformation[1].alignment = "LEFT"
	list.columnInformation[2] = {}
	list.columnInformation[2].width = 10
	list.columnInformation[2].alignment = "RIGHT"	
	list.columnInformation[3] = {}
	list.columnInformation[3].width = 30
	list.columnInformation[3].alignment = "LEFT"		
	list.scrollRefreshCallback = EMA.SettingsScrollRefresh
	list.rowClickCallback = EMA.SettingsRowClick
	EMA.settingsControl.list = list
	EMAHelperSettings:CreateScrollList( EMA.settingsControl.list )
	movingTop = movingTop - list.listHeight - verticalSpacing
	EMA.settingsControl.buttonRemove = EMAHelperSettings:CreateButton(
		EMA.settingsControl, 
		buttonControlWidth, 
		left2 + 50, 
		movingTop,
		L["REMOVE"],
		EMA.SettingsRemoveClick,
		L["REMOVE_VENDER_LIST"]
	)
	movingTop = movingTop -	buttonHeight - verticalSpacing
	EMAHelperSettings:CreateHeading( EMA.settingsControl, L["ADD_ITEM"], movingTop, false )
	movingTop = movingTop - headingHeight
	EMA.settingsControl.editBoxItem = EMAHelperSettings:CreateEditBox( 
		EMA.settingsControl,
		thirdWidth,
		left2,
		movingTop,
		L["ITEM_DROP"]
	)
	EMA.settingsControl.editBoxItem:SetCallback( "OnEnterPressed", EMA.SettingsEditBoxChangedItem )
	movingTop = movingTop - editBoxHeight		
	EMA.settingsControl.editBoxTag = EMAHelperSettings:CreateDropdown(
		EMA.settingsControl, 
		thirdWidth,	
		left,
		movingTop, 
		L["GROUP_LIST"]
	)
	EMA.settingsControl.editBoxTag:SetList( EMAApi.GroupList() )
	EMA.settingsControl.editBoxTag:SetCallback( "OnValueChanged",  EMA.GroupDropDownList )	
	EMA.settingsControl.editBoxAmount = EMAHelperSettings:CreateEditBox( 
		EMA.settingsControl,
		dropBoxWidth,
		left3,
		movingTop,
		L["AMOUNT"]
	)
	EMA.settingsControl.editBoxAmount:SetCallback( "OnEnterPressed", EMA.SettingsEditBoxChangedAmount )
	movingTop = movingTop - editBoxHeight		
	EMA.settingsControl.buttonAdd = EMAHelperSettings:CreateButton(	
		EMA.settingsControl, 
		buttonControlWidth, 
		left2 + 50, 
		movingTop, 
		L["ADD"],
		EMA.SettingsAddClick
	)
	movingTop = movingTop -	buttonHeight	
	EMAHelperSettings:CreateHeading( EMA.settingsControl, L["PURCHASE_MSG"], movingTop, false )
	movingTop = movingTop - headingHeight	
	EMA.settingsControl.dropdownMessageArea = EMAHelperSettings:CreateDropdown( 
		EMA.settingsControl, 
		headingWidth, 
		left, 
		movingTop, 
		L["MESSAGE_AREA"] 
	)
	EMA.settingsControl.dropdownMessageArea:SetList( EMAApi.MessageAreaList() )
	EMA.settingsControl.dropdownMessageArea:SetCallback( "OnValueChanged", EMA.SettingsSetMessageArea )
	movingTop = movingTop - dropdownHeight - verticalSpacing								
	return movingTop
end

function EMA:OnMessageAreasChanged( message )
	EMA.settingsControl.dropdownMessageArea:SetList( EMAApi.MessageAreaList() )
end

function EMA:OnGroupAreasChanged( message )
	EMA.settingsControl.editBoxTag:SetList( EMAApi.GroupList() )
end

local function SettingsCreate()
	EMA.settingsControl = {}
	EMAHelperSettings:CreateSettings( 
		EMA.settingsControl, 
		EMA.moduleDisplayName, 
		EMA.parentDisplayName, 
		EMA.SettingsPushSettingsClick,
		EMA.moduleIcon,
		EMA.moduleOrder			
	)
	local bottomOfSettings = SettingsCreateOptions( EMAHelperSettings:TopOfSettings() )
	EMA.settingsControl.widgetSettings.content:SetHeight( -bottomOfSettings )
	-- Help
	local helpTable = {}
	EMAHelperSettings:CreateHelp( EMA.settingsControl, helpTable, EMA:GetConfiguration() )		
end

-------------------------------------------------------------------------------------------------------------
-- Settings Callbacks.
-------------------------------------------------------------------------------------------------------------

function EMA:SettingsScrollRefresh()
	FauxScrollFrame_Update(
		EMA.settingsControl.list.listScrollFrame, 
		EMA:GetItemsMaxPosition(),
		EMA.settingsControl.list.rowsToDisplay, 
		EMA.settingsControl.list.rowHeight
	)
	EMA.settingsControl.offset = FauxScrollFrame_GetOffset( EMA.settingsControl.list.listScrollFrame )
	for iterateDisplayRows = 1, EMA.settingsControl.list.rowsToDisplay do
		-- Reset.
		EMA.settingsControl.list.rows[iterateDisplayRows].columns[1].textString:SetText( "" )
		EMA.settingsControl.list.rows[iterateDisplayRows].columns[1].textString:SetTextColor( 1.0, 1.0, 1.0, 1.0 )
		EMA.settingsControl.list.rows[iterateDisplayRows].columns[2].textString:SetText( "" )
		EMA.settingsControl.list.rows[iterateDisplayRows].columns[2].textString:SetTextColor( 1.0, 1.0, 1.0, 1.0 )		
		EMA.settingsControl.list.rows[iterateDisplayRows].columns[3].textString:SetText( "" )
		EMA.settingsControl.list.rows[iterateDisplayRows].columns[3].textString:SetTextColor( 1.0, 1.0, 1.0, 1.0 )			
		EMA.settingsControl.list.rows[iterateDisplayRows].highlight:SetColorTexture( 0.0, 0.0, 0.0, 0.0 )
		-- Get data.
		local dataRowNumber = iterateDisplayRows + EMA.settingsControl.offset
		if dataRowNumber <= EMA:GetItemsMaxPosition() then
			-- Put data information into columns.
			local itemInformation = EMA:GetItemAtPosition( dataRowNumber )
			EMA.settingsControl.list.rows[iterateDisplayRows].columns[1].textString:SetText( itemInformation.name )
			EMA.settingsControl.list.rows[iterateDisplayRows].columns[2].textString:SetText( itemInformation.amount )
			EMA.settingsControl.list.rows[iterateDisplayRows].columns[3].textString:SetText( itemInformation.tag )
			-- Highlight the selected row.
			if dataRowNumber == EMA.settingsControl.highlightRow then
				EMA.settingsControl.list.rows[iterateDisplayRows].highlight:SetColorTexture( 1.0, 1.0, 0.0, 0.5 )
			end
		end
	end
end

function EMA:SettingsRowClick( rowNumber, columnNumber )		
	if EMA.settingsControl.offset + rowNumber <= EMA:GetItemsMaxPosition() then
		EMA.settingsControl.highlightRow = EMA.settingsControl.offset + rowNumber
		EMA:SettingsScrollRefresh()
	end
end

function EMA:SettingsPushSettingsClick( event )
	EMA:EMASendSettings()
end

function EMA:SettingsSetMessageArea( event, value )
	EMA.db.messageArea = value
	EMA:SettingsRefresh()
end

function EMA:SettingsToggleAutoBuyItems( event, checked )
	EMA.db.autoBuy = checked
	EMA:SettingsRefresh()
end

function EMA:SettingsToggleAutoBuyItemsOverflow( event, checked )
	EMA.db.autoBuyOverflow = checked
	EMA:SettingsRefresh()
end

function EMA:SettingsToggleGlobalBuyList( event, checked )
	EMA.db.globalBuyList = checked
	EMA:SettingsRefresh()
end

function EMA:SettingsRemoveClick( event )
	StaticPopup_Show( "EMAPURCHASE_CONFIRM_REMOVE_AUTO_BUY_ITEM" )
end

function EMA:SettingsEditBoxChangedItem( event, text )
	EMA.autoBuyItemLink = text
	EMA:SettingsRefresh()
end

function EMA:GroupDropDownList (event, value )
	-- if nil or the blank group then don't get Name.
	if value == " " or value == nil then 
		return 
	end
	for index, groupName in ipairs( EMAApi.GroupList() ) do
		if index == value then
			EMA.autoBuyItemTag = groupName
			break
		end
	end
	EMA:SettingsRefresh()
end

function EMA:SettingsEditBoxChangedAmount( event, text )
	if not text or text:trim() == "" or text:find( "^(%d+)$" ) == nil then
		EMA:Print( L["NUM_ERROR"] )
		return
	end
	EMA.autoBuyAmount = text
	EMA:SettingsRefresh()
end

function EMA:SettingsAddClick( event )
	if EMA.autoBuyItemLink ~= nil and EMA.autoBuyItemTag ~= nil then
		EMA:AddItem( EMA.autoBuyItemLink, EMA.autoBuyItemTag, EMA.autoBuyAmount )
		EMA.autoBuyItemLink = nil
		EMA.settingsControl.editBoxItem:SetText( "" )
		EMA:SettingsRefresh()
	end
end

function EMA:CopyListCommmand()
	EMA:Print("Copying Local List To Global List")
	EMA.db.global.autoBuyItemsListGlobal = EMAUtilities:CopyTable( EMA.db.autoBuyItems )
	EMA:SettingsRefresh()
end

-------------------------------------------------------------------------------------------------------------
-- Popup Dialogs.
-------------------------------------------------------------------------------------------------------------

-- Initialize Popup Dialogs.
local function InitializePopupDialogs()
	StaticPopupDialogs["EMAPURCHASE_CONFIRM_REMOVE_AUTO_BUY_ITEM"] = {
        text = L["BUY_POPUP_ACCEPT"],
        button1 = YES,
        button2 = NO,
        timeout = 0,
		whileDead = 1,
		hideOnEscape = 1,
        OnAccept = function()
			EMA:RemoveItem()
		end,
    }
end

-------------------------------------------------------------------------------------------------------------
-- Addon initialization, enabling and disabling.
-------------------------------------------------------------------------------------------------------------

-- Initialise the module.
function EMA:OnInitialize()
	EMA.autoBuyItemTag = EMAApi.AllTag()
	EMA.autoBuyItemLink = nil
	EMA.autoBuyAmount = 20
	-- Create the settings control.
	SettingsCreate()
	-- Initialise the EMAModule part of this module.
	EMA:EMAModuleInitialize( EMA.settingsControl.widgetSettings.frame )
	-- Initialise the popup dialogs.
	InitializePopupDialogs()		
	-- Populate the settings.
	EMA:SettingsRefresh()
end

-- Called when the addon is enabled.
function EMA:OnEnable()
	EMA:RegisterEvent( "MERCHANT_SHOW" )
	EMA:RawHook( "ContainerFrameItemButton_OnModifiedClick", true)
	EMA:RegisterMessage( EMAApi.MESSAGE_MESSAGE_AREAS_CHANGED, "OnMessageAreasChanged" )
	EMA:RegisterMessage( EMAApi.GROUP_LIST_CHANGED , "OnGroupAreasChanged" )
end

-- Called when the addon is disabled.
function EMA:OnDisable()
end

-------------------------------------------------------------------------------------------------------------
-- Purchase functionality.
-------------------------------------------------------------------------------------------------------------

function EMA:ContainerFrameItemButton_OnModifiedClick( self, event, ... )
	local isConfigOpen = EMAPrivate.SettingsFrame.Widget:IsVisible()
	if isConfigOpen == true and IsShiftKeyDown() == true then
		local GUIPanel = EMAPrivate.SettingsFrame.TreeGroupStatus.selected
		local currentModule = string.find(GUIPanel, EMA.moduleDisplayName) 
		--EMA:Print("test2", GUIPanel, "vs", currentModule )
		if currentModule ~= nil then
			local itemID, itemLink = GameTooltip:GetItem()
			--EMA:Print("test1", itemID, itemLink )
			if itemLink ~= nil then
				EMA.settingsControl.editBoxItem:SetText( "" )
				EMA.settingsControl.editBoxItem:SetText( itemLink )
				EMA.autoBuyItemLink = itemLink		
				return
			end
		end	
	end	
	return EMA.hooks["ContainerFrameItemButton_OnModifiedClick"]( self, event, ... )
end

function EMA:GetItemsMaxPosition()
	if EMA.db.globalBuyList == true then
		return #EMA.db.global.autoBuyItemsListGlobal
	else	
		return #EMA.db.autoBuyItems
	end	
end

function EMA:GetItemAtPosition( position )
	if EMA.db.globalBuyList == true then
		return EMA.db.global.autoBuyItemsListGlobal[position]
	else
		return EMA.db.autoBuyItems[position]
	end	
end

function EMA:AddItem( itemLink, itemTag, amountToBuy )
	-- Get some more information about the item.
	local name, link, quality, iLevel, reqLevel, class, subclass, maxStack, equipSlot, texture, vendorPrice = GetItemInfo( itemLink )
	-- If the item could be found.
	if name ~= nil then
		local itemInformation = {}
		itemInformation.link = itemLink
		itemInformation.name = name
		itemInformation.tag = itemTag
		itemInformation.amount = amountToBuy
		if EMA.db.globalBuyList == true then
			table.insert( EMA.db.global.autoBuyItemsListGlobal, itemInformation )
		else	
			table.insert( EMA.db.autoBuyItems, itemInformation )
		end
		EMA:SettingsRefresh()			
		EMA:SettingsRowClick( 1, 1 )
	end	
end

function EMA:RemoveItem()
	if EMA.db.globalBuyList == true then
		table.remove( EMA.db.global.autoBuyItemsListGlobal, EMA.settingsControl.highlightRow )
	else	
		table.remove( EMA.db.autoBuyItems, EMA.settingsControl.highlightRow )
	end
	EMA:SettingsRefresh()
	EMA:SettingsRowClick( 1, 1 )		
end

function EMA:MERCHANT_SHOW()
	if EMA.db.autoBuy == true then
		EMA:DoMerchantAutoBuy()
	end
end

-- A EMA command has been recieved.
function EMA:EMAOnCommandReceived( characterName, commandName, ... )
end

function EMA:DoMerchantAutoBuy()
	-- Flags will be set if the character does not have enough bag space or money.
	local outOfBagSpace = false
	local outOfMoney = false
	local outOfOtherCurrency = false
	-- Iterate all the wanted items...
	if EMA.db.globalBuyList == true then
		itemTable = EMA.db.global.autoBuyItemsListGlobal
	else
		itemTable = EMA.db.autoBuyItems
	end
	for position, itemInfoTable in pairs( itemTable ) do	
		
		local maxItemAmount = tonumber( itemInfoTable.amount )
		local itemTag = itemInfoTable.tag
		local itemLink = itemInfoTable.link
		-- Does this character have the item tag?  No, don't buy.
		if EMAApi.IsCharacterInGroup( EMA.characterName, itemTag ) then
			-- Does the merchant have the item in stock?
			local itemIndexMerchant = EMA:DoesMerchantHaveItemInStock( itemLink )
			if itemIndexMerchant ~= nil then
				-- Yes, item is in stock, how many does the character need?
				local amountNeeded = EMA:GetAmountNeededForItemTopUp( itemLink, maxItemAmount )
				-- Need more than 0 items, buy them.
				if amountNeeded > 0 then
					-- Attempt to buy the items.
					local noFreeBagSpace, notEnoughMoney, notEnoughOtherCurrency = EMA:BuyItemFromMerchant( itemIndexMerchant, amountNeeded )
					-- Set flags if problems occurred.
					if noFreeBagSpace then
						outOfBagSpace = true		
					end
					if notEnoughMoney then
						outOfMoney = true
					end
					if notEnoughOtherCurrency then 
						outOfOtherCurrency = true
					end
				end
			end
		end
	end
	-- If there was a problem, tell the master.
	if outOfBagSpace then
		EMA:EMASendMessageToTeam( EMA.db.messageArea, L["ERROR_BAGS_FULL"], false )			
	end
	if outOfMoney then
		EMA:EMASendMessageToTeam( EMA.db.messageArea, L["ERROR_GOLD"], false )
	end
	if outOfOtherCurrency then
		EMA:EMASendMessageToTeam( EMA.db.messageArea, L["ERROR_CURR"], false )
	end	
end

function EMA:DoesMerchantHaveItemInStock( itemLink )
	-- The index of the item to be found in the merchants inventory; initially nil, not found.
	local indexOfItemToFind = nil 
	-- Get the name of the item to find from the item link.
	local itemNameToFind = GetItemInfo( itemLink )
	-- How many items does the merchant have?
	local numberMerchantItems = GetMerchantNumItems()
	-- Iterate all the merchants items...
	for merchantIndex = 1, numberMerchantItems do
		-- Is there an item link for this item.
		local merchantItemLink = GetMerchantItemLink( merchantIndex )
		if merchantItemLink then
			-- Yes, get the item name.
			local itemNameMerchant = GetItemInfo( merchantItemLink )
			if itemNameMerchant == itemNameToFind then
				indexOfItemToFind = merchantIndex
				break
			end
		end
	end
	-- Return the index into the merchants inventory of the item.
	return indexOfItemToFind
end

function EMA:GetAmountNeededForItemTopUp( itemLink, maxItemAmount )
	-- The amount of the item needed to top up the item.
	local amountNeeded = 0
	-- How much of this item does the character have in it's bags?
	local amountInBags = GetItemCount( itemLink )
	-- Does the character need more?
	if amountInBags < maxItemAmount then
		-- Yes, how much more?
		amountNeeded = maxItemAmount - amountInBags
	end
	-- Return the amount needed.
	return amountNeeded	
end

function EMA:BuyItemFromMerchant( itemIndexMerchant, amountToBuy )
	-- Flags will be set if the character does not have enough bag space or money.
	local noFreeBagSpace = false
	local notEnoughMoney = false
	local notEnoughOtherCurrency = false
	-- Processing variables.
	local buyThisAmount = 0
	local amountLeftToBuy = amountToBuy
	local actualAmountToBuy = 0
	local costToBuy = 0
	local moneyAvailable = 0
	-- Get information about the item from the merchant.
	local name, texture, price, itemsPerStack, numberAvailable, isUsable, extendedCost = GetMerchantItemInfo( itemIndexMerchant )	
	local maximumCanBuyAtATime = GetMerchantItemMaxStack( itemIndexMerchant )
	-- Loop buying stacks from the merchant until the required number has been purchased.
	repeat
		-- Still need to buy more than the maximum?
		if amountLeftToBuy >= maximumCanBuyAtATime then
			-- Yes, buy the maximum amount.
			buyThisAmount = maximumCanBuyAtATime
		else
			-- No, just buy the amount left.
			buyThisAmount = amountLeftToBuy
		end
		-- Attempt to buy this amount from the merchant; although actual amount bought may differ,
		-- depending on merchant stock and over buy flag.
		-- How many does the merchant have left?
		numberAvailable = select( 5, GetMerchantItemInfo( itemIndexMerchant ) )
		-- Calculate how many to buy depending on the stacksize and whether over buying is allowed.
		actualAmountToBuy = buyThisAmount
		if EMA.db.autoBuyOverflow == true then
			actualAmountToBuy = ceil(actualAmountToBuy)
		else
			actualAmountToBuy = floor(actualAmountToBuy)
		end
		-- If requesting more than the number available, then just buy as much as possible.
		-- If numberAvailable is -1 then there is unlimited stock available.
		if numberAvailable ~= -1 then
			if actualAmountToBuy > numberAvailable then
				actualAmountToBuy = numberAvailable 
			end
		end
		-- Does the character have enough money?
		costToBuy = actualAmountToBuy * price
		moneyAvailable = GetMoney()
		if moneyAvailable < costToBuy then			
			notEnoughMoney = true
		end
		-- Is there enough free space for this item in the characters bags?				
		--TODO - need to find items family type and compare to each container.
		local numFreeSlots, numTotalSlots = LibBagUtils:CountSlots("BAGS", 0)
        if numFreeSlots == 0 then
            noFreeBagSpace = true
        end
		-- Buy from the merchant, if there is a valid amount to buy and the character has enough money.
		if (actualAmountToBuy > 0) and (not notEnoughMoney) then
			BuyMerchantItem( itemIndexMerchant, actualAmountToBuy )
		end
		-- How much left to buy?
		amountLeftToBuy = amountLeftToBuy - buyThisAmount
	until (amountLeftToBuy == 0 or noFreeBagSpace == true)
	-- TODO
	-- Return the success flags.
	return noFreeBagSpace, notEnoughMoney, notEnoughOtherCurrency
end
