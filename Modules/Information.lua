-- ================================================================================ --
--				EMA - ( Ebony's MultiBoxing Assistant )    							--
--				Current Author: Jennifer Cally (Ebony)								--
--																					--
--				License: All Rights Reserved 2018-2019 Jennifer Cally					--
--																					--
--				Some Code Used from "Jamba" that is 								--
--				Released under the MIT License 										--
--				"Jamba" Copyright 2008-2015  Michael "Jafula" Miller				--
--																					--
-- ================================================================================ --

-- Only Load for Live
if _G.WOW_PROJECT_ID ~= _G.WOW_PROJECT_MAINLINE then
	return
end	

-- Create the addon using AceAddon-3.0 and embed some libraries.
local EMA = LibStub( "AceAddon-3.0" ):NewAddon( 
	"Information", 
	"Module-1.0", 
	"AceConsole-3.0", 
	"AceEvent-3.0",
	"AceTimer-3.0"
)

-- Get the EMA Utilities Library.
local AceGUI = LibStub( "AceGUI-3.0" )
local EMAUtilities = LibStub:GetLibrary( "EbonyUtilities-1.0" )
local EMAHelperSettings = LibStub:GetLibrary( "EMAHelperSettings-1.0" )
local LibBagUtils = LibStub:GetLibrary( "LibBagUtils-1.0" )
EMA.SharedMedia = LibStub( "LibSharedMedia-3.0" )

--  Constants and Locale for this module.
EMA.moduleName = "Information"
EMA.settingsDatabaseName = "InformationProfileDB"
EMA.chatCommand = "ema-info"
local L = LibStub( "AceLocale-3.0" ):GetLocale( "Core" )
EMA.parentDisplayName = L["DISPLAY"]
EMA.moduleDisplayName = L["INFORMATION"]
-- Icon 
EMA.moduleIcon = "Interface\\Addons\\EMA\\Media\\SellIcon.tga"
-- order
EMA.moduleOrder = 3

EMA.globalCurrencyFramePrefix = "EMAToonCurrencyListFrame"
--EMA.currTypes = {}
EMA.simpleCurrList = {}

-- Currency Identifiers. To add you own just add a new line at the bottom of this part
-- http://www.wowhead.com/currencies

local function allAlwaysCurrencys()
	local allAlwaysCurrencys = {}
		allAlwaysCurrencys.Honor = 1792
		allAlwaysCurrencys.TimeWalker = 1166
		allAlwaysCurrencys.Darkmoon = 515
	return allAlwaysCurrencys
end	

-- Before WOD
local function classicCurrencys()
	local classicCurrencys = {}
		classicCurrencys.ChampionsSeal = 241
		classicCurrencys.TolBaradCommendation = 391
		classicCurrencys.LesserCharmOfGoodFortune = 738
		classicCurrencys.ElderCharmOfGoodFortune = 697
		classicCurrencys.MoguRuneOfFate = 752
		classicCurrencys.WarforgedSeal = 776
		classicCurrencys.BloodyCoin = 789
		classicCurrencys.TimelessCoin = 777
	return classicCurrencys
end		

-- Wod Currency
local function wodCurrencys()
	local wodCurrencys = {}
		wodCurrencys.GarrisonResources = 824
		wodCurrencys.TemperedFate = 994
		wodCurrencys.ApexisCrystal = 823
		wodCurrencys.Oil = 1101
		wodCurrencys.InevitableFate = 1129
		wodCurrencys.Valor = 1191
	return wodCurrencys
end		

--Legion Currency
local function legionCurrencys()
	local legionCurrencys = {}
		legionCurrencys.OrderResources = 1220
		legionCurrencys.AncientMana = 1155
		legionCurrencys.NetherShard = 1226
		legionCurrencys.SealofBrokenFate = 1273
		legionCurrencys.ShadowyCoins = 1154
		legionCurrencys.SightlessEye = 1149
		legionCurrencys.TimeWornArtifact = 1268
		legionCurrencys.CuriousCoin = 1275
		legionCurrencys.LegionfallWarSupplies = 1342
		legionCurrencys.CoinsOfAir = 1416
		legionCurrencys.WakeningEssence = 1533
		legionCurrencys.VeiledArgunite = 1508
	return legionCurrencys	

end

-- BattleforAzeroth Currency
local function battleforAzerothnCurrencys()
	local bfa = {}
		bfa.WarResources = 1560
		bfa.RichAzeriteFragment = 1565
		bfa.SeafarersDubloon = 1710
		bfa.SealofWartornFate = 1580
		bfa.WarSupplies = 1587
		bfa.SeventhLegionService = 1717
		bfa.HonorboundService = 1716
		bfa.TitanResiduum = 1718
		bfa.PrismaticManapearl = 1721
		bfa.CoalescingVisions = 1755
		bfa.CorruptedMementos = 1719
		bfa.EchoesOfNyalotha = 1803
	return bfa
end	

local function shadowlandsCurrencys()
	local shadowlandsCurrencys = {}
		shadowlandsCurrencys.ArgentCommendation = 1754
		shadowlandsCurrencys.SoulAsh = 1828
		shadowlandsCurrencys.Stygia = 1767
		shadowlandsCurrencys.ReservoirAnima = 1813
		shadowlandsCurrencys.SinstoneFragments = 1816
		shadowlandsCurrencys.InfusedRuby = 1820
		shadowlandsCurrencys.FreedSoul = 1751
	return shadowlandsCurrencys
end	
		


local function testcode()
	return EMA.currTypes
end
-------------------------------------- End of edit --------------------------------------------------------------

function EMA:CurrencyIconAndName( id )
	local info = C_CurrencyInfo.GetCurrencyInfo(id)
	if info ~= nil and info.iconFileID ~= nil then
		--EMA:Print("test", info.name, info.iconFileID )
		local currName = strconcat(" |T"..info.iconFileID..":20|t", L[" "]..info.name)	
		return currName
	end	
end	

function EMA:AddCurrencyToTable()
	table.wipe( EMA.currTypes )
	for name, id in pairs( allAlwaysCurrencys() ) do
		EMA.currTypes[name] = id
	end
	
	if EMA.db.currClassicCurrencys == true then
		for name, id in pairs( classicCurrencys() ) do
			EMA.currTypes[name] = id
		end
	end
	if 	EMA.db.currWodCurrencys == true then
		for name, id in pairs( wodCurrencys() ) do
			EMA.currTypes[name] = id
		end
	end
	if EMA.db.currLegionCurrencys == true then
		for name, id in pairs( legionCurrencys() ) do
			EMA.currTypes[name] = id
		end
	end
	if EMA.db.currBattleforAzerothCurrencys == true then
		for name, id in pairs( battleforAzerothnCurrencys() ) do
			EMA.currTypes[name] = id
		end
	end
	if EMA.db.currShadowlands == true then 
		for name, id in pairs( shadowlandsCurrencys() ) do
			EMA.currTypes[name] = id
		end
	end
end	
	
-- Settings - the values to store and their defaults for the settings database.
EMA.settings = {
	profile = {
		currChatTrigger = false, 
		currGold = true,
		currGoldInGuildBank = false,
		currBagSpace = false,
		currClassicCurrencys = false,
		currWodCurrencys = false, 
		currLegionCurrencys = false,
		currBattleforAzerothCurrencys = false,
		currShadowlands = true,
		-- Currency default's ALL NONE! (saves updating every xpac....)
		CcurrTypeOne = 1,
		CcurrTypeOneName = "",
		CcurrTypeTwo = 1,
		CcurrTypeTwoName = "",
		CcurrTypeThree = 1,
		CcurrTypeThreeName = "",
		CcurrTypeFour = 1,
		CcurrTypeFourName = "",
		CcurrTypeFive = 1,
		CcurrTypeFiveName = "",
		CcurrTypeSix = 1,
		CcurrTypeSixName = "",
		currencyFrameAlpha = 1.0,
		currencyFramePoint = "CENTER",
		currencyFrameRelativePoint = "CENTER",
		currencyFrameXOffset = 0,
		currencyFrameYOffset = 0,
		currencyFrameBackgroundColourR = 1.0,
		currencyFrameBackgroundColourG = 1.0,
		currencyFrameBackgroundColourB = 1.0,
		currencyFrameBackgroundColourA = 1.0,
		currencyFrameBorderColourR = 1.0,
		currencyFrameBorderColourG = 1.0,
		currencyFrameBorerColourB = 1.0,
		currencyFrameBorderColourA = 1.0,		
		currencyBorderStyle = L["BLIZZARD_TOOLTIP"],
		currencyBackgroundStyle = L["BLIZZARD_DIALOG_BACKGROUND"],
		currencyFontStyle = L["ARIAL_NARROW"],
		currencyFontSize = 12,		
		currencyScale = 1,
		currencyNameWidth = 60,
		currencyPointsWidth = 50,
		currencyGoldWidth = 140,
		currencyOtherWidth = 50,
		currencySpacingWidth = 3,
		currencyLockWindow = false,
		currOpenStartUpMaster = false,
		currOpenStartUpAll = false
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
				usage = "/ema-information config",
				get = false,
				set = "",				
			},
			show = {
				type = "input",
				name = L["SHOW_CURRENCY"],
				desc = L["SHOW_CURRENCY_HELP"],
				usage = "ema-info show",
				get = false,
				set = "ShowInformationPanel",
			},
			hide = {
				type = "input",
				name = L["HIDE_CURRENCY"],
				desc = L["HIDE_CURRENCY_HELP"],
				usage = "ema-info hide",
				get = false,
				set = "EMAToonHideCurrency",
			},			
			push = {
				type = "input",
				name = L["PUSH_ALL_SETTINGS"],
				desc = L["PUSH_SETTINGS_INFO"],
				usage = "ema-info push",
				get = false,
				set = "EMASendSettings",
			},											
		},
	}
	return configuration
end

local function DebugMessage( ... )
	--EMA:Print( ... )
end
-------------------------------------------------------------------------------------------------------------
-- Command this module sends.
-------------------------------------------------------------------------------------------------------------

EMA.COMMAND_REQUEST_CURRENCY = "SendCurrency"
EMA.COMMAND_HERE_IS_CURRENCY = "HereIsCurrency"

-------------------------------------------------------------------------------------------------------------
-- Messages module sends.
-------------------------------------------------------------------------------------------------------------

-------------------------------------------------------------------------------------------------------------
-- Variables used by module.
-------------------------------------------------------------------------------------------------------------


-------------------------------------------------------------------------------------------------------------
-- Settings Dialogs.
-------------------------------------------------------------------------------------------------------------

local function SettingsCreate()
	EMA.settingsControl = {}
	-- Create the settings panel.
	EMAHelperSettings:CreateSettings(  
		EMA.settingsControl, 
		EMA.moduleDisplayName, 
		EMA.parentDisplayName, 
		EMA.SettingsPushSettingsClick,
		EMA.moduleIcon,
		EMA.moduleOrder	
	)
	local bottomOfInfo = EMA:SettingsCreateCurrency( EMAHelperSettings:TopOfSettings() )
	EMA.settingsControl.widgetSettings.content:SetHeight( -bottomOfInfo )	
	-- Help
	local helpTable = {}
	EMAHelperSettings:CreateHelp( EMA.settingsControl, helpTable, EMA:GetConfiguration() )		
end




function EMA:SettingsCreateCurrency( top )
	-- Get positions.
	local checkBoxHeight = EMAHelperSettings:GetCheckBoxHeight()
	local sliderHeight = EMAHelperSettings:GetSliderHeight()
	local mediaHeight = EMAHelperSettings:GetMediaHeight()	
	local editBoxHeight = EMAHelperSettings:GetEditBoxHeight()
	local buttonHeight = EMAHelperSettings:GetButtonHeight()
	local dropdownHeight = EMAHelperSettings:GetDropdownHeight() + 10
	local labelHeight = EMAHelperSettings:GetLabelHeight()
	local continueLabelHeight = 18
	local left = EMAHelperSettings:LeftOfSettings()
	local headingHeight = EMAHelperSettings:HeadingHeight()
	local headingWidth = EMAHelperSettings:HeadingWidth( true )
	local horizontalSpacing = EMAHelperSettings:GetHorizontalSpacing()
	local indent = horizontalSpacing * 12
	local verticalSpacing = EMAHelperSettings:GetVerticalSpacing()
	local halfWidth = (headingWidth - horizontalSpacing) / 2
	local thirdWidth = (headingWidth - (horizontalSpacing * 2)) / 3
	local halfWidthSlider = (headingWidth - horizontalSpacing) / 2
	local column2left = left + halfWidthSlider
	local left2 = left + thirdWidth
	local left3 = left + (thirdWidth * 2)
	local right = left + halfWidth + horizontalSpacing
	local movingTop = top
	-- A blank to get layout to show right?
	EMAHelperSettings:CreateHeading( EMA.settingsControl, "", movingTop, false )
	movingTop = movingTop - headingHeight
	EMAHelperSettings:CreateHeading( EMA.settingsControl, L["CHAT_TRIGGER"], movingTop, false )
	movingTop = movingTop - headingHeight
	EMA.settingsControl.checkBoxChatTrigger = EMAHelperSettings:CreateCheckBox( 
		EMA.settingsControl, 
		halfWidth, 
		left, 
		movingTop, 
		L["CHAT_TRIGGERS"],
		EMA.SettingsToggleChatTrigger,
		L["CHAT_TRIGGERS_HELP"]
	)
	movingTop = movingTop - checkBoxHeight
	EMAHelperSettings:CreateHeading( EMA.settingsControl, L["CURRENCY_HEADER"], movingTop, false )
	movingTop = movingTop - headingHeight
	EMA.settingsControl.checkBoxCurrencyGold = EMAHelperSettings:CreateCheckBox( 
		EMA.settingsControl, 
		halfWidth, 
		left, 
		movingTop, 
		L["GOLD"],
		EMA.SettingsToggleCurrencyGold,
		L["GOLD_HELP"]
	)
	EMA.settingsControl.checkBoxCurrencyGoldInGuildBank = EMAHelperSettings:CreateCheckBox( 
		EMA.settingsControl, 
		halfWidth, 
		column2left, 
		movingTop, 
		L["GOLD_GB"],
		EMA.SettingsToggleCurrencyGoldInGuildBank,
		L["GOLD_GB_HELP"]
	)
	movingTop = movingTop - checkBoxHeight
	EMA.settingsControl.checkBoxCurrencyShowBagSpace = EMAHelperSettings:CreateCheckBox( 
		EMA.settingsControl, 
		halfWidth, 
		left, 
		movingTop, 
		L["SHOW_BAG_SPACE"],
		EMA.SettingsToggleCurrencyShowBagSpace,
		L["SHOW_BAG_SPACE_HELP"]
	)	
	movingTop = movingTop - checkBoxHeight
	EMAHelperSettings:CreateHeading( EMA.settingsControl, L["CURRENCY"], movingTop, false )
	movingTop = movingTop - headingHeight
	-- Xpacs
	EMA.settingsControl.checkBoxCurrencyShowClassic = EMAHelperSettings:CreateCheckBox( 
		EMA.settingsControl, 
		thirdWidth, 
		left, 
		movingTop, 
		L["CURRENCY_CLASSIC"],
		EMA.SettingsToggleCurrencyClassic,
		L["CURRENCY_CLASSIC_HELP"]
	)	
	EMA.settingsControl.checkBoxCurrencyShowWarlordsofDraenor = EMAHelperSettings:CreateCheckBox( 
		EMA.settingsControl, 
		thirdWidth, 
		left2, 
		movingTop, 
		L["CURRENCY_WOD"],
		EMA.SettingsToggleCurrencyWarlordsofDraenor,
		L["CURRENCY_WOD_HELP"]
	)	
	EMA.settingsControl.checkBoxCurrencyShowLegion = EMAHelperSettings:CreateCheckBox( 
		EMA.settingsControl, 
		thirdWidth, 
		left3, 
		movingTop, 
		L["CURRENCY_LEGION"],
		EMA.SettingsToggleCurrencyLegion,
		L["CURRENCY_LEGION_HELP"]
	)	
	movingTop = movingTop - checkBoxHeight
	EMA.settingsControl.checkBoxCurrencyShowBattleforAzeroth = EMAHelperSettings:CreateCheckBox( 
		EMA.settingsControl, 
		thirdWidth, 
		left, 
		movingTop, 
		L["CURRENCY_BFA"],
		EMA.SettingsToggleCurrencyBattleforAzeroth,
		L["CURRENCY_BFA_HELP"]
	)	
	EMA.settingsControl.checkBoxCurrencyShowShadowlands = EMAHelperSettings:CreateCheckBox( 
		EMA.settingsControl, 
		thirdWidth, 
		left2, 
		movingTop, 
		L["CURRENCY_SHADOWLANDS"],
		EMA.SettingsToggleCurrencyShadowlands,
		L["CURRENCY_SHADOWLANDS_HELP"]
	)
	--Currency One & Two	
	movingTop = movingTop - checkBoxHeight
	EMA.settingsControl.editBoxCurrencyTypeOneID = EMAHelperSettings:CreateDropdown( 
		EMA.settingsControl,
		halfWidth,
		left + indent,
		movingTop,
		L["CURRENCY"]..L[" "]..L["1"]
	)	
	EMA.settingsControl.editBoxCurrencyTypeOneID:SetList( EMA.CurrDropDownBox() )
	EMA.settingsControl.editBoxCurrencyTypeOneID:SetCallback( "OnValueChanged",  EMA.EditBoxChangedCurrencyTypeOneID)
	EMA.settingsControl.editBoxCurrencyTypeTwoID = EMAHelperSettings:CreateDropdown( 
		EMA.settingsControl,
		halfWidth,
		right + indent,
		movingTop,
		L["CURRENCY"]..L[" "]..L["2"]
	)	
	EMA.settingsControl.editBoxCurrencyTypeTwoID:SetList( EMA.CurrDropDownBox() )
	EMA.settingsControl.editBoxCurrencyTypeTwoID:SetCallback( "OnValueChanged",  EMA.EditBoxChangedCurrencyTypeTwoID)	
	--Currency Three & Four
	movingTop = movingTop - dropdownHeight	
	EMA.settingsControl.editBoxCurrencyTypeThreeID = EMAHelperSettings:CreateDropdown( 
		EMA.settingsControl,
		halfWidth,
		left + indent,
		movingTop,
		L["CURRENCY"]..L[" "]..L["3"]
	)	
	EMA.settingsControl.editBoxCurrencyTypeThreeID:SetList( EMA.CurrDropDownBox() )
	EMA.settingsControl.editBoxCurrencyTypeThreeID:SetCallback( "OnValueChanged",  EMA.EditBoxChangedCurrencyTypeThreeID)	
	EMA.settingsControl.editBoxCurrencyTypeFourID = EMAHelperSettings:CreateDropdown( 
		EMA.settingsControl,
		halfWidth,
		right + indent,
		movingTop,
		L["CURRENCY"]..L[" "]..L["4"]
	)	
	EMA.settingsControl.editBoxCurrencyTypeFourID:SetList( EMA.CurrDropDownBox() )
	EMA.settingsControl.editBoxCurrencyTypeFourID:SetCallback( "OnValueChanged",  EMA.EditBoxChangedCurrencyTypeFourID)
	--Currency Five & Six
	movingTop = movingTop - dropdownHeight 
	EMA.settingsControl.editBoxCurrencyTypeFiveID = EMAHelperSettings:CreateDropdown( 
		EMA.settingsControl,
		halfWidth,
		left + indent,
		movingTop,
		L["CURRENCY"]..L[" "]..L["5"]
	)	
	EMA.settingsControl.editBoxCurrencyTypeFiveID:SetList( EMA.CurrDropDownBox() )
	EMA.settingsControl.editBoxCurrencyTypeFiveID:SetCallback( "OnValueChanged",  EMA.EditBoxChangedCurrencyTypeFiveID)	
	EMA.settingsControl.editBoxCurrencyTypeSixID = EMAHelperSettings:CreateDropdown( 
		EMA.settingsControl,
		halfWidth,
		right + indent,
		movingTop,
		L["CURRENCY"]..L[" "]..L["6"]
	)	
	EMA.settingsControl.editBoxCurrencyTypeSixID:SetList( EMA.CurrDropDownBox() )
	EMA.settingsControl.editBoxCurrencyTypeSixID:SetCallback( "OnValueChanged",  EMA.EditBoxChangedCurrencyTypeSixID)
	-- Other Stuff	
	movingTop = movingTop - dropdownHeight
	EMA.settingsControl.currencyButtonShowList = EMAHelperSettings:CreateButton( 
		EMA.settingsControl, 
		headingWidth, 
		left, 
		movingTop, 
		L["SHOW_CURRENCY"], 
		EMA.EMAToonRequestCurrency,
		L["SHOW_CURRENCY_HELP"]
	)
	movingTop = movingTop - buttonHeight
	EMA.settingsControl.checkBoxCurrencyOpenStartUpAll = EMAHelperSettings:CreateCheckBox( 
		EMA.settingsControl, 
		halfWidth, 
		left, 
		movingTop, 
		L["CURR_STARTUP"],
		EMA.SettingsToggleCurrencyOpenStartUpAll,
		L["CURR_STARTUP_HELP"]
	)
	EMA.settingsControl.checkBoxCurrencyOpenStartUpMaster = EMAHelperSettings:CreateCheckBox( 
		EMA.settingsControl, 
		halfWidth, 
		column2left, 
		movingTop, 
		L["CURR_STARTUP_MASTER"],
		EMA.SettingsToggleCurrencyOpenStartUpMaster,
		L["CURR_STARTUP_MASTER_HELP"]
	)	
	movingTop = movingTop - checkBoxHeight
	-- Create appearance & layout.
	EMAHelperSettings:CreateHeading( EMA.settingsControl, L["APPEARANCE_LAYOUT_HEALDER"], movingTop, true )
	movingTop = movingTop - headingHeight
	EMA.settingsControl.checkBoxCurrencyLockWindow = EMAHelperSettings:CreateCheckBox( 
		EMA.settingsControl, 
		headingWidth, 
		left, 
		movingTop, 
		L["LOCK_CURR_LIST"],
		EMA.SettingsToggleCurrencyLockWindow,
		L["LOCK_CURR_LIST_HELP"]
	)	
	movingTop = movingTop - checkBoxHeight		
	EMA.settingsControl.currencyScaleSlider = EMAHelperSettings:CreateSlider( 
		EMA.settingsControl, 
		headingWidth, 
		left, 
		movingTop, 
		L["SCALE"]
	)
	EMA.settingsControl.currencyScaleSlider:SetSliderValues( 0.5, 2, 0.01 )
	EMA.settingsControl.currencyScaleSlider:SetCallback( "OnValueChanged", EMA.SettingsChangeScale )
	movingTop = movingTop - sliderHeight - verticalSpacing
	EMA.settingsControl.currencyTransparencySlider = EMAHelperSettings:CreateSlider( 
		EMA.settingsControl, 
		headingWidth, 
		left, 
		movingTop, 
		L["TRANSPARENCY"]
	)
	EMA.settingsControl.currencyTransparencySlider:SetSliderValues( 0, 1, 0.01 )
	EMA.settingsControl.currencyTransparencySlider:SetCallback( "OnValueChanged", EMA.SettingsChangeTransparency )
	movingTop = movingTop - sliderHeight - verticalSpacing	
	EMA.settingsControl.currencyMediaBorder = EMAHelperSettings:CreateMediaBorder( 
		EMA.settingsControl, 
		halfWidthSlider, 
		left, 
		movingTop,
		L["BORDER_STYLE"]
	)
	EMA.settingsControl.currencyMediaBorder:SetCallback( "OnValueChanged", EMA.SettingsChangeBorderStyle )

	EMA.settingsControl.currencyBorderColourPicker = EMAHelperSettings:CreateColourPicker(
		EMA.settingsControl,
		halfWidthSlider,
		column2left + 15,
		movingTop - 15,
		L["BORDER COLOUR"]
	)
	EMA.settingsControl.currencyBorderColourPicker:SetHasAlpha( true )
	EMA.settingsControl.currencyBorderColourPicker:SetCallback( "OnValueConfirmed", EMA.SettingsBorderColourPickerChanged )	
	movingTop = movingTop - mediaHeight - verticalSpacing
	EMA.settingsControl.currencyMediaBackground = EMAHelperSettings:CreateMediaBackground( 
		EMA.settingsControl, 
		halfWidthSlider, 
		left, 
		movingTop,
		L["BACKGROUND"]
	)
	EMA.settingsControl.currencyMediaBackground:SetCallback( "OnValueChanged", EMA.SettingsChangeBackgroundStyle )
	EMA.settingsControl.currencyBackgroundColourPicker = EMAHelperSettings:CreateColourPicker(
		EMA.settingsControl,
		halfWidthSlider,
		column2left + 15,
		movingTop - 15,
		L["BG_COLOUR"]
	)
	EMA.settingsControl.currencyBackgroundColourPicker:SetHasAlpha( true )
	EMA.settingsControl.currencyBackgroundColourPicker:SetCallback( "OnValueConfirmed", EMA.SettingsBackgroundColourPickerChanged )
	movingTop = movingTop - mediaHeight - verticalSpacing
	--Font
	EMA.settingsControl.currencyMediaFont = EMAHelperSettings:CreateMediaFont( 
		EMA.settingsControl, 
		halfWidthSlider, 
		left, 
		movingTop,
		L["FONT"]
	)
	EMA.settingsControl.currencyMediaFont:SetCallback( "OnValueChanged", EMA.SettingsChangeFontStyle )
	EMA.settingsControl.currencyFontSize = EMAHelperSettings:CreateSlider( 
		EMA.settingsControl, 
		halfWidthSlider, 
		column2left, 
		movingTop, 
		L["FONT_SIZE"]
	)	
	EMA.settingsControl.currencyFontSize:SetSliderValues( 8, 20 , 1 )
	EMA.settingsControl.currencyFontSize:SetCallback( "OnValueChanged", EMA.SettingsChangeFontSize )
	movingTop = movingTop - mediaHeight - verticalSpacing
	EMA.settingsControl.currencySliderSpaceForName = EMAHelperSettings:CreateSlider( 
		EMA.settingsControl, 
		headingWidth, 
		left, 
		movingTop, 
		L["SPACE_FOR_NAME"]
	)
	EMA.settingsControl.currencySliderSpaceForName:SetSliderValues( 20, 200, 1 )
	EMA.settingsControl.currencySliderSpaceForName:SetCallback( "OnValueChanged", EMA.SettingsChangeSliderSpaceForName )
	movingTop = movingTop - sliderHeight - verticalSpacing
	EMA.settingsControl.currencySliderSpaceForGold = EMAHelperSettings:CreateSlider( 
		EMA.settingsControl, 
		headingWidth, 
		left, 
		movingTop, 
		L["SPACE_FOR_GOLD"]
	)
	EMA.settingsControl.currencySliderSpaceForGold:SetSliderValues( 20, 200, 1 )
	EMA.settingsControl.currencySliderSpaceForGold:SetCallback( "OnValueChanged", EMA.SettingsChangeSliderSpaceForGold )
	movingTop = movingTop - sliderHeight - verticalSpacing
	EMA.settingsControl.currencySliderSpaceForOther = EMAHelperSettings:CreateSlider( 
		EMA.settingsControl, 
		headingWidth, 
		left, 
		movingTop, 
		L["SPACE_FOR_OTHER"]
	)
	EMA.settingsControl.currencySliderSpaceForOther:SetSliderValues( 20, 200, 1 )
	EMA.settingsControl.currencySliderSpaceForOther:SetCallback( "OnValueChanged", EMA.SettingsChangeSliderSpaceForOther )
	movingTop = movingTop - sliderHeight - verticalSpacing
	EMA.settingsControl.currencySliderSpaceForPoints = EMAHelperSettings:CreateSlider( 
		EMA.settingsControl, 
		headingWidth, 
		left, 
		movingTop, 
		L["SPACE_FOR_POINTS"]
	)
	EMA.settingsControl.currencySliderSpaceForPoints:SetSliderValues( 20, 200, 1 )
	EMA.settingsControl.currencySliderSpaceForPoints:SetCallback( "OnValueChanged", EMA.SettingsChangeSliderSpaceForPoints )
	movingTop = movingTop - sliderHeight - verticalSpacing	
	EMA.settingsControl.currencySliderSpaceBetweenValues = EMAHelperSettings:CreateSlider( 
		EMA.settingsControl, 
		headingWidth, 
		left, 
		movingTop, 
		L["SPACE_BETWEEN_VALUES"]
	)
	EMA.settingsControl.currencySliderSpaceBetweenValues:SetSliderValues( 0, 20, 1 )
	EMA.settingsControl.currencySliderSpaceBetweenValues:SetCallback( "OnValueChanged", EMA.SettingsChangeSliderSpaceBetweenValues )
	movingTop = movingTop - sliderHeight - verticalSpacing	
	return movingTop	
end



-------------------------------------------------------------------------------------------------------------
-- Settings Populate.
-------------------------------------------------------------------------------------------------------------

function EMA:BeforeEMAProfileChanged()	
end

function EMA:OnEMAProfileChanged()	
	EMA:SettingsRefresh()
end

function EMA:SettingsRefresh()
	EMA.settingsControl.checkBoxChatTrigger:SetValue( EMA.db.currChatTrigger )
	EMA.settingsControl.checkBoxCurrencyGold:SetValue( EMA.db.currGold )
	EMA.settingsControl.checkBoxCurrencyGoldInGuildBank:SetValue( EMA.db.currGoldInGuildBank )
	EMA.settingsControl.checkBoxCurrencyGoldInGuildBank:SetDisabled( not EMA.db.currGold )
	EMA.settingsControl.checkBoxCurrencyShowBagSpace:SetValue( EMA.db.currBagSpace )
	EMA.settingsControl.checkBoxCurrencyShowClassic:SetValue( EMA.db.currClassicCurrencys )
	EMA.settingsControl.checkBoxCurrencyShowWarlordsofDraenor:SetValue( EMA.db.currWodCurrencys )
	EMA.settingsControl.checkBoxCurrencyShowLegion:SetValue( EMA.db.currLegionCurrencys )
	EMA.settingsControl.checkBoxCurrencyShowBattleforAzeroth:SetValue( EMA.db.currBattleforAzerothCurrencys) 
	EMA.settingsControl.checkBoxCurrencyShowShadowlands:SetValue( EMA.db.currShadowlands )
	EMA.settingsControl.editBoxCurrencyTypeOneID:SetValue( EMA.db.CcurrTypeOne )
	EMA.settingsControl.editBoxCurrencyTypeOneID:SetList( EMA.CurrDropDownBox() )
	EMA.settingsControl.editBoxCurrencyTypeTwoID:SetValue ( EMA.db.CcurrTypeTwo )	
	EMA.settingsControl.editBoxCurrencyTypeTwoID:SetList( EMA.CurrDropDownBox() )
	EMA.settingsControl.editBoxCurrencyTypeThreeID:SetValue ( EMA.db.CcurrTypeThree )
	EMA.settingsControl.editBoxCurrencyTypeThreeID:SetList( EMA.CurrDropDownBox() )
	EMA.settingsControl.editBoxCurrencyTypeFourID:SetValue ( EMA.db.CcurrTypeFour )
	EMA.settingsControl.editBoxCurrencyTypeFourID:SetList( EMA.CurrDropDownBox() )
	EMA.settingsControl.editBoxCurrencyTypeFiveID:SetValue ( EMA.db.CcurrTypeFive )
	EMA.settingsControl.editBoxCurrencyTypeFiveID:SetList( EMA.CurrDropDownBox() )
	EMA.settingsControl.editBoxCurrencyTypeSixID:SetValue ( EMA.db.CcurrTypeSix )
	EMA.settingsControl.editBoxCurrencyTypeSixID:SetList( EMA.CurrDropDownBox() )
	EMA.settingsControl.checkBoxCurrencyOpenStartUpAll:SetValue( EMA.db.currOpenStartUpAll )
	EMA.settingsControl.checkBoxCurrencyOpenStartUpMaster:SetValue( EMA.db.currOpenStartUpMaster )
	EMA.settingsControl.checkBoxCurrencyOpenStartUpMaster:SetDisabled( not EMA.db.currOpenStartUpAll )
	EMA.settingsControl.currencyTransparencySlider:SetValue( EMA.db.currencyFrameAlpha )
	EMA.settingsControl.currencyScaleSlider:SetValue( EMA.db.currencyScale )
	EMA.settingsControl.currencyMediaBorder:SetValue( EMA.db.currencyBorderStyle )
	EMA.settingsControl.currencyMediaBackground:SetValue( EMA.db.currencyBackgroundStyle )
	EMA.settingsControl.currencyBackgroundColourPicker:SetColor( EMA.db.currencyFrameBackgroundColourR, EMA.db.currencyFrameBackgroundColourG, EMA.db.currencyFrameBackgroundColourB, EMA.db.currencyFrameBackgroundColourA )
	EMA.settingsControl.currencyBorderColourPicker:SetColor( EMA.db.currencyFrameBorderColourR, EMA.db.currencyFrameBorderColourG, EMA.db.currencyFrameBorderColourB, EMA.db.currencyFrameBorderColourA )
	EMA.settingsControl.currencyMediaFont:SetValue( EMA.db.currencyFontStyle )
	EMA.settingsControl.currencyFontSize:SetValue( EMA.db.currencyFontSize )
	EMA.settingsControl.currencySliderSpaceForName:SetValue( EMA.db.currencyNameWidth )
	EMA.settingsControl.currencySliderSpaceForGold:SetValue( EMA.db.currencyGoldWidth )
	EMA.settingsControl.currencySliderSpaceForOther:SetValue( EMA.db.currencyOtherWidth )
	EMA.settingsControl.currencySliderSpaceForPoints:SetValue( EMA.db.currencyPointsWidth )
	EMA.settingsControl.currencySliderSpaceBetweenValues:SetValue( EMA.db.currencySpacingWidth )
	EMA.settingsControl.checkBoxCurrencyLockWindow:SetValue( EMA.db.currencyLockWindow )
	EMA.CurrDropDownBox()
	if EMA.currencyListFrameCreated == true then
		EMA:CurrencyListSetColumnWidth()
		EMA:SettingsUpdateBorderStyle()
		EMA:SettingsUpdateFontStyle()
		EMA:CurrencyUpdateWindowLock()
		EMAToonCurrencyListFrame:SetScale( EMA.db.currencyScale )
		EMA:UpdateHendingText()
		EMA:CurrencyListSetHeight()
	end
end

function EMA:SettingsPushSettingsClick( event )
	EMA:EMASendSettings()
end

function EMA:SettingsToggleChatTrigger( event, checked )
	EMA.db.currChatTrigger = checked
	EMA:SettingsRefresh()
end

function EMA:SettingsToggleCurrencyGold( event, checked )
	EMA.db.currGold = checked
	EMA:SettingsRefresh()
end

function EMA:SettingsToggleCurrencyGoldInGuildBank( event, checked )
	EMA.db.currGoldInGuildBank = checked
	EMA:SettingsRefresh()
end

function EMA:SettingsToggleCurrencyShowBagSpace( event, checked )
	EMA.db.currBagSpace = checked
	EMA:SettingsRefresh()
end	

function EMA:SettingsToggleCurrencyClassic( event, checked )
	EMA.db.currClassicCurrencys = checked
	EMA:AddCurrencyToTable()
	EMA:SettingsRefresh()
end	

function EMA:SettingsToggleCurrencyWarlordsofDraenor( event, checked )
	EMA.db.currWodCurrencys = checked
	EMA:AddCurrencyToTable()
	EMA:SettingsRefresh()
end	

function EMA:SettingsToggleCurrencyLegion( event, checked )
	EMA.db.currLegionCurrencys = checked
	EMA:AddCurrencyToTable()
	EMA:SettingsRefresh()
end	

function EMA:SettingsToggleCurrencyBattleforAzeroth( event, checked )
	EMA.db.currBattleforAzerothCurrencys = checked
	EMA:AddCurrencyToTable()
	EMA:SettingsRefresh()
end	

function EMA:SettingsToggleCurrencyShadowlands( event, checked )
	EMA.db.currShadowlands = checked
	EMA:AddCurrencyToTable()
	EMA:SettingsRefresh()
end	

function EMA:EditBoxChangedCurrencyTypeOneID( event, value )
	local currName, id = EMA:MatchCurrValue(value)
	EMA.db.CcurrTypeOne = id
	EMA.db.CcurrTypeOneName = currName
	EMA:EMAToonRequestCurrency()
	EMA:SettingsRefresh()
end

function EMA:EditBoxChangedCurrencyTypeTwoID( event, value )
	local currName, id = EMA:MatchCurrValue(value)
	EMA.db.CcurrTypeTwo = id
	EMA.db.CcurrTypeTwoName = currName
	EMA:EMAToonRequestCurrency()
	EMA:SettingsRefresh()
end

function EMA:EditBoxChangedCurrencyTypeThreeID( event, value )
	local currName, id = EMA:MatchCurrValue(value)
	EMA.db.CcurrTypeThree = id
	EMA.db.CcurrTypeThreeName = currName
	EMA:EMAToonRequestCurrency()
	EMA:SettingsRefresh()
end

function EMA:EditBoxChangedCurrencyTypeFourID( event, value )
	local currName, id = EMA:MatchCurrValue(value)
	EMA.db.CcurrTypeFour = id
	EMA.db.CcurrTypeFourName = currName
	EMA:EMAToonRequestCurrency()
	EMA:SettingsRefresh()
end

function EMA:EditBoxChangedCurrencyTypeFiveID( event, value )
	local currName, id = EMA:MatchCurrValue(value)
	
	EMA.db.CcurrTypeFive = id
	EMA.db.CcurrTypeFiveName = currName
	EMA:EMAToonRequestCurrency()
	EMA:SettingsRefresh()
end

function EMA:EditBoxChangedCurrencyTypeSixID( event, value )
	--EMA:Print("test", value)
	local currName, id = EMA:MatchCurrValue(value)
	EMA.db.CcurrTypeSix = id
	EMA.db.CcurrTypeSixName = currName
	EMA:EMAToonRequestCurrency()
	EMA:SettingsRefresh()
end

function EMA:SettingsToggleCurrencyOpenStartUpAll( event, checked )
	EMA.db.currOpenStartUpAll = checked
	EMA:SettingsRefresh()
end

function EMA:SettingsToggleCurrencyOpenStartUpMaster( event, checked )
	EMA.db.currOpenStartUpMaster = checked
	EMA:SettingsRefresh()
end

function EMA:SettingsChangeScale( event, value )
	EMA.db.currencyScale = tonumber( value )
	EMA:SettingsRefresh()
end

function EMA:SettingsChangeTransparency( event, value )
	EMA.db.currencyFrameAlpha = tonumber( value )
	EMA:SettingsRefresh()
end

function EMA:SettingsChangeBorderStyle( event, value )
	EMA.db.currencyBorderStyle = value
	EMA:SettingsRefresh()
end

function EMA:SettingsChangeBackgroundStyle( event, value )
	EMA.db.currencyBackgroundStyle = value
	EMA:SettingsRefresh()
end

function EMA:SettingsBackgroundColourPickerChanged( event, r, g, b, a )
	EMA.db.currencyFrameBackgroundColourR = r
	EMA.db.currencyFrameBackgroundColourG = g
	EMA.db.currencyFrameBackgroundColourB = b
	EMA.db.currencyFrameBackgroundColourA = a
	EMA:SettingsRefresh()
end

function EMA:SettingsBorderColourPickerChanged( event, r, g, b, a )
	EMA.db.currencyFrameBorderColourR = r
	EMA.db.currencyFrameBorderColourG = g
	EMA.db.currencyFrameBorderColourB = b
	EMA.db.currencyFrameBorderColourA = a
	EMA:SettingsRefresh()
end

function EMA:SettingsChangeFontStyle( event, value )
	EMA.db.currencyFontStyle = value
	EMA:SettingsRefresh()
end

function EMA:SettingsChangeFontSize( event, value )
	EMA.db.currencyFontSize = value
	EMA:SettingsRefresh()
end

function EMA:SettingsChangeSliderSpaceForName( event, value )
	EMA.db.currencyNameWidth = tonumber( value )
	EMA:SettingsRefresh()
end

function EMA:SettingsChangeSliderSpaceForGold( event, value )
	EMA.db.currencyGoldWidth = tonumber( value )
	EMA:SettingsRefresh()
end

function EMA:SettingsChangeSliderSpaceForOther( event, value )
	EMA.db.currencyOtherWidth = tonumber( value )
	EMA:SettingsRefresh()
end

function EMA:SettingsChangeSliderSpaceForPoints( event, value )
	EMA.db.currencyPointsWidth = tonumber( value )
	EMA:SettingsRefresh()
end

function EMA:SettingsChangeSliderSpaceBetweenValues( event, value )
	EMA.db.currencySpacingWidth = tonumber( value )
	EMA:SettingsRefresh()
end
		
function EMA:SettingsToggleCurrencyLockWindow( event, checked )
	EMA.db.currencyLockWindow = checked
	EMA:CurrencyUpdateWindowLock()
	EMA:SettingsRefresh()
end

-------------------------------------------------------------------------------------------------------------
-- Addon initialization, enabling and disabling.
-------------------------------------------------------------------------------------------------------------

-- Initialise the module.
function EMA:OnInitialize()
	EMA.currencyTotalGold = 0
	EMA.currencyListFrameCreated = false
	EMA.currencyFrameCharacterInfo = {}
	EMA.currentCurrencyValues = {}
	EMA.currTypes = {}
	-- Create the settings control.
	SettingsCreate()
	-- Initialise the EMAModule part of this module.
	EMA:EMAModuleInitialize( EMA.settingsControl.widgetSettings.frame )
	-- Create the currency list frame.
	EMA:CreateEMAToonCurrencyListFrame()
	EMA:AddCurrencyToTable()
	-- Populate the settings.
	EMA:SettingsRefresh()
end

-- Called when the addon is enabled.
function EMA:OnEnable()
	-- WoW events.
	EMA:RegisterEvent( "CHAT_MSG_PARTY", "DoChatCommand")
	EMA:RegisterEvent( "CHAT_MSG_GUILD", "DoChatCommand")
	EMA:RegisterEvent( "CHAT_MSG_PARTY_LEADER", "DoChatCommand")
	EMA:RegisterEvent( "CHAT_MSG_RAID", "DoChatCommand")
	EMA:RegisterEvent( "CHAT_MSG_RAID_LEADER", "DoChatCommand")
	--EMA:RegisterMessage( EMAApi.MESSAGE_MESSAGE_AREAS_CHANGED, "OnMessageAreasChanged" )
	if EMA.db.currOpenStartUpAll == true then
		if EMA.db.currOpenStartUpMaster == true then	
			if EMAApi.IsCharacterTheMaster( EMA.characterName ) == true then
				EMA:ScheduleTimer( "EMAToonRequestCurrency", 10 )
			end
		else		
			EMA:ScheduleTimer( "EMAToonRequestCurrency", 10 )
		end	
	end
end

-- Called when the addon is disabled.
function EMA:OnDisable()
end

-- Settings received.
function EMA:EMAOnSettingsReceived( characterName, settings )	
	if characterName ~= EMA.characterName then
		-- Update the settings.
		EMA.db.currChatTrigger = settings.currChatTrigger
		EMA.db.currGold = settings.currGold
		EMA.db.currGoldInGuildBank = settings.currGoldInGuildBank
		EMA.db.currBagSpace = settings.currBagSpace
		EMA.db.currClassicCurrencys = settings.currClassicCurrencys
		EMA.db.currWodCurrencys = settings.currWodCurrencys
		EMA.db.currLegionCurrencys = settings.currLegionCurrencys
		EMA.db.currBattleforAzerothCurrencys = settings.currBattleforAzerothCurrencys
		EMA.db.currShadowlands = settings.currShadowlands
		EMA.db.CcurrTypeOne = settings.CcurrTypeOne
		EMA.db.CcurrTypeOneName = settings.CcurrTypeOneName
		EMA.db.CcurrTypeTwo = settings.CcurrTypeTwo
		EMA.db.CcurrTypeTwoName = settings.CcurrTypeTwoName
		EMA.db.CcurrTypeThree = settings.CcurrTypeThree
		EMA.db.CcurrTypeThreeName = settings.CcurrTypeThreeName
		EMA.db.CcurrTypeFour = settings.CcurrTypeFour
		EMA.db.CcurrTypeFourName = settings.CcurrTypeFourName
		EMA.db.CcurrTypeFive = settings.CcurrTypeFive
		EMA.db.CcurrTypeFiveName = settings.CcurrTypeFiveName
		EMA.db.CcurrTypeSix = settings.CcurrTypeSix
		EMA.db.CcurrTypeSixName = settings.CcurrTypeSixName
		EMA.db.currOpenStartUpMaster = settings.currOpenStartUpMaster
		EMA.db.currOpenStartUpAll = settings.currOpenStartUpAll
		EMA.db.currencyScale = settings.currencyScale
		EMA.db.currencyFrameAlpha = settings.currencyFrameAlpha
		EMA.db.currencyFramePoint = settings.currencyFramePoint
		EMA.db.currencyFrameRelativePoint = settings.currencyFrameRelativePoint
		EMA.db.currencyFrameXOffset = settings.currencyFrameXOffset
		EMA.db.currencyFrameYOffset = settings.currencyFrameYOffset
		EMA.db.currencyFrameBackgroundColourR = settings.currencyFrameBackgroundColourR
		EMA.db.currencyFrameBackgroundColourG = settings.currencyFrameBackgroundColourG
		EMA.db.currencyFrameBackgroundColourB = settings.currencyFrameBackgroundColourB
		EMA.db.currencyFrameBackgroundColourA = settings.currencyFrameBackgroundColourA
		EMA.db.currencyFrameBorderColourR = settings.currencyFrameBorderColourR
		EMA.db.currencyFrameBorderColourG = settings.currencyFrameBorderColourG
		EMA.db.currencyFrameBorderColourB = settings.currencyFrameBorderColourB
		EMA.db.currencyFrameBorderColourA = settings.currencyFrameBorderColourA	
		EMA.db.currencyBorderStyle = settings.currencyBorderStyle
		EMA.db.currencyBackgroundStyle = settings.currencyBackgroundStyle
		EMA.db.currencyFontSize = settings.currencyFontSize
		EMA.db.currencyFontStyle = settings.currencyFontStyle
		EMA.db.currencyNameWidth = settings.currencyNameWidth
		EMA.db.currencyPointsWidth = settings.currencyPointsWidth
		EMA.db.currencyGoldWidth = settings.currencyGoldWidth
		EMA.db.currencyOtherWidth = settings.currencyOtherWidth
		EMA.db.currencySpacingWidth = settings.currencySpacingWidth
		EMA.db.currencyLockWindow = settings.currencyLockWindow
		-- Refresh the settings.
		EMA:SettingsRefresh()
		-- Tell the player.
		EMA:Print( L["SETTINGS_RECEIVED_FROM_A"]( characterName ) )
	end
end

function EMA:CurrDropDownBox()
	--EMA:Print("test21")
	EMAUtilities:ClearTable( EMA.simpleCurrList )
	for name, id in pairs( EMA.currTypes ) do
		--EMA:Print("testDropDown", name, id)
		local currName = EMA:CurrencyIconAndName( id )
		--EMA.simpleCurrList[id] = currName
		EMA.simpleCurrList[id] = currName		
	end
	EMA.simpleCurrList[0] = ""
	--table.sort(EMA.simpleCurrList, function(a,b) return a<b end)
	--table.concat(EMA.simpleCurrList, ", ")
	return EMA.simpleCurrList
end	


function EMA:MatchCurrValue(value)
	if value == 0 then	
		return "", 0
	end
	for name, id in pairs( EMA.currTypes ) do
		local currName = EMA:CurrencyIconAndName( id )
		if value == id then
			return currName, id
		end	
	end
end 


function EMA:DrawGroup1(container)
	for characterName, currencyFrameCharacterInfo in pairs( EMA.currencyFrameCharacterInfo ) do
		EMA:Print("test", characterName)
	end	
	
end	


function EMA:CreateEMAToonCurrencyListFrame()
	-- The frame.
	local frame = CreateFrame( "Frame", "EMAToonCurrencyListWindowFrame", UIParent, BackdropTemplateMixin and "BackdropTemplate" or nil )
	frame.obj = EMA
	frame:SetFrameStrata( "LOW" )
	frame:SetToplevel( false )
	frame:SetClampedToScreen( true )
	frame:EnableMouse( true )
	frame:SetMovable( true )	
	frame:RegisterForDrag( "LeftButton" )
	frame:SetScript( "OnDragStart", 
		function( this ) 
			if IsAltKeyDown() then
				this:StartMoving() 
			end
		end )
	frame:SetScript( "OnDragStop", 
		function( this ) 
			this:StopMovingOrSizing() 
			local point, relativeTo, relativePoint, xOffset, yOffset = this:GetPoint()
			EMA.db.currencyFramePoint = point
			EMA.db.currencyFrameRelativePoint = relativePoint
			EMA.db.currencyFrameXOffset = xOffset
			EMA.db.currencyFrameYOffset = yOffset
	end	)
	frame:SetWidth( 500 )
	frame:SetHeight( 200 )
	frame:ClearAllPoints()
	frame:SetPoint( EMA.db.currencyFramePoint, UIParent, EMA.db.currencyFrameRelativePoint, EMA.db.currencyFrameXOffset, EMA.db.currencyFrameYOffset )

	-- Create the title for the frame.
	local titleName = frame:CreateFontString( "EMAToonCurrencyListWindowFrameTitleText", "OVERLAY", "GameFontNormal" )
	titleName:SetPoint( "TOPLEFT", frame, "TOPLEFT", 3, -8 )
	titleName:SetTextColor( NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, 1.0 )
	titleName:SetText( L["CURRENCY"] )
	titleName:SetWidth( 200 )
	titleName:SetJustifyH( "LEFT" )
	titleName:SetWordWrap( false )
	frame.titleName = titleName
	
	-- Create the headings.
	local left = 10
	local spacing = 50
	local width = 50
	local top = -30
	local parentFrame = frame
	local r = 1.0
	local g = 0.96
	local b = 0.41
	local a = 1.0
	-- Set the characters name font string.
	local frameCharacterName = EMA.globalCurrencyFramePrefix.."TitleCharacterName"
	local frameCharacterNameText = parentFrame:CreateFontString( frameCharacterName.."Text", "OVERLAY", "GameFontNormal" )
	frameCharacterNameText:SetText( L["NAME"] )
	frameCharacterNameText:SetTextColor( r, g, b, a )
	frameCharacterNameText:SetPoint( "TOPLEFT", parentFrame, "TOPLEFT", left, top )
	frameCharacterNameText:SetWidth( width * 2.5 )
	frameCharacterNameText:SetJustifyH( "LEFT" )
	frame.characterNameText = frameCharacterNameText
	left = left + (spacing * 2)
	-- Set the Gold font string.
	local frameGold = EMA.globalCurrencyFramePrefix.."TitleGold"
	local frameGoldText = parentFrame:CreateFontString( frameGold.."Text", "OVERLAY", "GameFontNormal" )
	frameGoldText:SetText( L["GOLD"] )
	frameGoldText:SetTextColor( r, g, b, a )
	frameGoldText:SetPoint( "TOPLEFT", parentFrame, "TOPLEFT", left, top )
	frameGoldText:SetWidth( width )
	frameGoldText:SetJustifyH( "CENTER" )
	frame.GoldText = frameGoldText
	left = left + spacing	
	-- Set the BagSpace font string.
	local frameBagSpace = EMA.globalCurrencyFramePrefix.."TitleBagSpace"
	local frameBagSpaceText = parentFrame:CreateFontString( frameBagSpace.."Text", "OVERLAY", "GameFontNormal" )
	frameBagSpaceText:SetText( L["BAG_SPACE"] )
	frameBagSpaceText:SetTextColor( r, g, b, a )
	frameBagSpaceText:SetPoint( "TOPLEFT", parentFrame, "TOPLEFT", left, top )
	frameBagSpaceText:SetWidth( width )
	frameBagSpaceText:SetJustifyH( "CENTER" )
	frame.BagSpaceText = frameBagSpaceText
	left = left + spacing
	-- Set the TypeOne font string.
	local frameTypeOne = EMA.globalCurrencyFramePrefix.."TitleTypeOne"
	local frameTypeOneText = parentFrame:CreateFontString( frameTypeOne.."Text", "OVERLAY", "GameFontNormal" )
	frameTypeOneText:SetText( L["CURR"]..L["1"] )
	frameTypeOneText:SetTextColor( r, g, b, a )
	frameTypeOneText:SetPoint( "TOPLEFT", parentFrame, "TOPLEFT", left, top )
	frameTypeOneText:SetWidth( width )
	frameTypeOneText:SetJustifyH( "CENTER" )
	frame.TypeOneText = frameTypeOneText
	left = left + spacing
	-- Set the TypeTwo font string.
	local frameTypeTwo = EMA.globalCurrencyFramePrefix.."TitleTypeTwo"
	local frameTypeTwoText = parentFrame:CreateFontString( frameTypeTwo.."Text", "OVERLAY", "GameFontNormal" )
	frameTypeTwoText:SetText( L["CURR"]..L["2"] )
	frameTypeTwoText:SetTextColor( r, g, b, a )
	frameTypeTwoText:SetPoint( "TOPLEFT", parentFrame, "TOPLEFT", left, top )
	frameTypeTwoText:SetWidth( width )
	frameTypeTwoText:SetJustifyH( "CENTER" )
	frame.TypeTwoText = frameTypeTwoText
	left = left + spacing
	-- Set the TypeThree font string.
	local frameTypeThree = EMA.globalCurrencyFramePrefix.."TitleTypeThree"
	local frameTypeThreeText = parentFrame:CreateFontString( frameTypeThree.."Text", "OVERLAY", "GameFontNormal" )
	frameTypeThreeText:SetText( L["CURR"]..L["3"] )
	frameTypeThreeText:SetTextColor( r, g, b, a )
	frameTypeThreeText:SetPoint( "TOPLEFT", parentFrame, "TOPLEFT", left, top )
	frameTypeThreeText:SetWidth( width )
	frameTypeThreeText:SetJustifyH( "CENTER" )
	frame.TypeThreeText = frameTypeThreeText
	left = left + spacing	
	-- Set the TypeFour font string.
	local frameTypeFour = EMA.globalCurrencyFramePrefix.."TitleTypeFour"
	local frameTypeFourText = parentFrame:CreateFontString( frameTypeFour.."Text", "OVERLAY", "GameFontNormal" )
	frameTypeFourText:SetText( L["CURR"]..L["4"] )
	frameTypeFourText:SetTextColor( r, g, b, a )
	frameTypeFourText:SetPoint( "TOPLEFT", parentFrame, "TOPLEFT", left, top )
	frameTypeFourText:SetWidth( width )
	frameTypeFourText:SetJustifyH( "CENTER" )
	frame.TypeFourText = frameTypeFourText
	left = left + spacing
	-- Set the TypeFive font string.
	local frameTypeFive = EMA.globalCurrencyFramePrefix.."TitleTypeFive"
	local frameTypeFiveText = parentFrame:CreateFontString( frameTypeFive.."Text", "OVERLAY", "GameFontNormal" )
	frameTypeFiveText:SetText( L["CURR"]..L["5"] )
	frameTypeFiveText:SetTextColor( r, g, b, a )
	frameTypeFiveText:SetPoint( "TOPLEFT", parentFrame, "TOPLEFT", left, top )
	frameTypeFiveText:SetWidth( width )
	frameTypeFiveText:SetJustifyH( "CENTER" )
	frame.TypeFiveText = frameTypeFiveText
	left = left + spacing
	-- Set the TypeSix font string.
	local frameTypeSix = EMA.globalCurrencyFramePrefix.."TitleTypeSix"
	local frameTypeSixText = parentFrame:CreateFontString( frameTypeSix.."Text", "OVERLAY", "GameFontNormal" )
	frameTypeSixText:SetText( L["CURR"]..L["6"] )
	frameTypeSixText:SetTextColor( r, g, b, a )
	frameTypeSixText:SetPoint( "TOPLEFT", parentFrame, "TOPLEFT", left, top )
	frameTypeSixText:SetWidth( width )
	frameTypeSixText:SetJustifyH( "CENTER" )
	frame.TypeSixText = frameTypeSixText
	left = left + spacing
	-- Set the Total Gold font string.
	left = 10
	top = -50
	local frameTotalGoldTitle = EMA.globalCurrencyFramePrefix.."TitleTotalGold"
	local frameTotalGoldTitleText = parentFrame:CreateFontString( frameTotalGoldTitle.."Text", "OVERLAY", "GameFontNormal" )
	frameTotalGoldTitleText:SetText( L["TOTAL"] )
	frameTotalGoldTitleText:SetTextColor( r, g, b, a )
	frameTotalGoldTitleText:SetPoint( "TOPLEFT", parentFrame, "TOPLEFT", left, top )
	frameTotalGoldTitleText:SetWidth( width )
	frameTotalGoldTitleText:SetJustifyH( "LEFT" )
	frame.TotalGoldTitleText = frameTotalGoldTitleText

	local frameTotalGoldGuildTitle = EMA.globalCurrencyFramePrefix.."TitleTotalGoldGuild"
	local frameTotalGoldGuildTitleText = parentFrame:CreateFontString( frameTotalGoldGuildTitle.."Text", "OVERLAY", "GameFontNormal" )
	frameTotalGoldGuildTitleText:SetText( L["GUILD"] )
	frameTotalGoldGuildTitleText:SetTextColor( r, g, b, a )
	frameTotalGoldGuildTitleText:SetPoint( "TOPLEFT", parentFrame, "TOPLEFT", left, top )
	frameTotalGoldGuildTitleText:SetWidth( width )
	frameTotalGoldGuildTitleText:SetJustifyH( "LEFT" )
	frame.TotalGoldGuildTitleText = frameTotalGoldGuildTitleText
	
	local frameTotalGold = EMA.globalCurrencyFramePrefix.."TotalGold"
	local frameTotalGoldText = parentFrame:CreateFontString( frameTotalGold.."Text", "OVERLAY", "GameFontNormal" )
	frameTotalGoldText:SetText( "0" )
	frameTotalGoldText:SetTextColor( r, g, b, a )
	frameTotalGoldText:SetPoint( "TOPLEFT", parentFrame, "TOPLEFT", left, top )
	frameTotalGoldText:SetWidth( width )
	frameTotalGoldText:SetJustifyH( "RIGHT" )
	frame.TotalGoldText = frameTotalGoldText

	local frameTotalGoldGuild = EMA.globalCurrencyFramePrefix.."TotalGoldGuild"
	local frameTotalGoldGuildText = parentFrame:CreateFontString( frameTotalGoldGuild.."Text", "OVERLAY", "GameFontNormal" )
	frameTotalGoldGuildText:SetText( "0" )
	frameTotalGoldGuildText:SetTextColor( r, g, b, a )
	frameTotalGoldGuildText:SetPoint( "TOPLEFT", parentFrame, "TOPLEFT", left, top )
	frameTotalGoldGuildText:SetWidth( width )
	frameTotalGoldGuildText:SetJustifyH( "RIGHT" )
	frame.TotalGoldGuildText = frameTotalGoldGuildText
	
	-- Set frame width.
	frame:SetWidth( left + 10 )
	
	-- Set transparency of the the frame (and all its children).
	frame:SetAlpha( EMA.db.currencyFrameAlpha )
	
	-- Set scale.
	frame:SetScale( EMA.db.currencyScale )
	
	-- Set the global frame reference for this frame.
	EMAToonCurrencyListFrame = frame
	
	-- Close.
	local closeButton = CreateFrame( "Button", EMA.globalCurrencyFramePrefix.."ButtonClose", frame, "UIPanelCloseButton" )
	closeButton:SetScript( "OnClick", function() EMAToonCurrencyListFrame:Hide() end )
	closeButton:SetPoint( "TOPRIGHT", frame, "TOPRIGHT", 0, 0 )	
	frame.closeButton = closeButton
	
	-- Update.
	local updateButton = CreateFrame( "Button", EMA.globalCurrencyFramePrefix.."ButtonUpdate", frame, "UIPanelButtonTemplate" )
	updateButton:SetScript( "OnClick", function() EMA:EMAToonRequestCurrency() end )
	updateButton:SetPoint( "TOPRIGHT", frame, "TOPRIGHT", -30, -4 )
	updateButton:SetHeight( 22 )
	updateButton:SetWidth( 55 )
	updateButton:SetText( L["UPDATE"] )		
	
	frame.updateButton = updateButton
	EMA:SettingsUpdateBorderStyle()
	EMA:CurrencyUpdateWindowLock()
	EMA:SettingsUpdateFontStyle()
	EMAToonCurrencyListFrame:Hide()
	EMA.currencyListFrameCreated = true
	EMA:UpdateHendingText()
	EMA:CurrencyListSetHeight()
end

local function GetIcon(iD)
	local info = C_CurrencyInfo.GetCurrencyInfo(iD)
	if 	info ~= nil then
		local iconTextureString = strconcat(" |T"..info.iconFileID..":20|t")
		return iconTextureString
	end
end

function EMA:UpdateHendingText()
	local parentFrame = EMAToonCurrencyListFrame
	-- Gold
	local iconTextureString = strconcat(" |T".."133785"..":20|t")
	if iconTextureString ~= nil then
		parentFrame.GoldText:SetText( iconTextureString )
	end		
	-- BagSpace
	local iconTextureString = strconcat(" |T".."133633"..":20|t")
	if iconTextureString ~= nil then
		parentFrame.BagSpaceText:SetText( iconTextureString )
	end
	-- Type One
	local iconTextureString = GetIcon( EMA.db.CcurrTypeOne )
	if iconTextureString ~= nil then
		parentFrame.TypeOneText:SetText( iconTextureString )
	end		
	-- Type Two
	local iconTextureString = GetIcon( EMA.db.CcurrTypeTwo )
	if iconTextureString ~= nil then
		parentFrame.TypeTwoText:SetText( iconTextureString )
	end
	-- Type Three
	local iconTextureString = GetIcon( EMA.db.CcurrTypeThree )
	if iconTextureString ~= nil then
		parentFrame.TypeThreeText:SetText( iconTextureString )	
	end
	-- Type Four
	local iconTextureString = GetIcon( EMA.db.CcurrTypeFour )
	if iconTextureString ~= nil then
		parentFrame.TypeFourText:SetText( iconTextureString )
	end
	-- Type Five
	local iconTextureString = GetIcon( EMA.db.CcurrTypeFive )
	if iconTextureString ~= nil then
		parentFrame.TypeFiveText:SetText( iconTextureString )
	end
	-- Type six
	local iconTextureString = GetIcon( EMA.db.CcurrTypeSix )
	if iconTextureString ~= nil then
		parentFrame.TypeSixText:SetText( iconTextureString )
	end
end

function EMA:CurrencyUpdateWindowLock()
	if EMA.db.currencyLockWindow == false then
		EMAToonCurrencyListFrame:EnableMouse( true )
	else
		EMAToonCurrencyListFrame:EnableMouse( false )
	end
end

function EMA:SettingsUpdateBorderStyle()
	local borderStyle = EMA.SharedMedia:Fetch( "border", EMA.db.currencyBorderStyle )
	local backgroundStyle = EMA.SharedMedia:Fetch( "background", EMA.db.currencyBackgroundStyle )
	local frame = EMAToonCurrencyListFrame
	frame:SetBackdrop( {
		bgFile = backgroundStyle, 
		edgeFile = borderStyle, 
		tile = true, tileSize = frame:GetWidth(), edgeSize = 10, 
		insets = { left = 3, right = 3, top = 3, bottom = 3 }
	} )
	frame:SetBackdropColor( EMA.db.currencyFrameBackgroundColourR, EMA.db.currencyFrameBackgroundColourG, EMA.db.currencyFrameBackgroundColourB, EMA.db.currencyFrameBackgroundColourA )
	frame:SetBackdropBorderColor( EMA.db.currencyFrameBorderColourR, EMA.db.currencyFrameBorderColourG, EMA.db.currencyFrameBorderColourB, EMA.db.currencyFrameBorderColourA )
	frame:SetAlpha( EMA.db.currencyFrameAlpha )
	frame:ClearAllPoints()
	frame:SetPoint( EMA.db.currencyFramePoint, UIParent, EMA.db.currencyFrameRelativePoint, EMA.db.currencyFrameXOffset, EMA.db.currencyFrameYOffset )
end

function EMA:SettingsUpdateFontStyle()
	local textFont = EMA.SharedMedia:Fetch( "font", EMA.db.currencyFontStyle )
	local textSize = EMA.db.currencyFontSize
	local frame = EMAToonCurrencyListFrame
	frame.titleName:SetFont( textFont , textSize , "OUTLINE")
	frame.characterNameText:SetFont( textFont , textSize , "OUTLINE")
	frame.GoldText:SetFont( textFont , textSize , "OUTLINE")
	frame.BagSpaceText:SetFont( textFont , textSize , "OUTLINE")
	frame.TotalGoldGuildTitleText:SetFont( textFont , textSize , "OUTLINE")
	frame.TotalGoldGuildText:SetFont( textFont , textSize , "OUTLINE")
	frame.TotalGoldText:SetFont( textFont , textSize , "OUTLINE")
	frame.TotalGoldTitleText:SetFont( textFont , textSize , "OUTLINE")
	for characterName, currencyFrameCharacterInfo in pairs( EMA.currencyFrameCharacterInfo ) do
		--EMA:Print("test", characterName)
		--currencyFrameCharacterInfo.characterNameText:SetFont( textFont , textSize , "OUTLINE")
		currencyFrameCharacterInfo.characterNameText:SetFont( textFont , textSize , "OUTLINE")
		currencyFrameCharacterInfo.GoldText:SetFont( textFont , textSize , "OUTLINE")
		currencyFrameCharacterInfo.BagSpaceText:SetFont( textFont , textSize , "OUTLINE")
		currencyFrameCharacterInfo.TypeOneText:SetFont( textFont , textSize , "OUTLINE")
		currencyFrameCharacterInfo.TypeTwoText:SetFont( textFont , textSize , "OUTLINE")
		currencyFrameCharacterInfo.TypeThreeText:SetFont( textFont , textSize , "OUTLINE")
		currencyFrameCharacterInfo.TypeFourText:SetFont( textFont , textSize , "OUTLINE")
		currencyFrameCharacterInfo.TypeFiveText:SetFont( textFont , textSize , "OUTLINE")
		currencyFrameCharacterInfo.TypeSixText:SetFont( textFont , textSize , "OUTLINE")
	end
end

function EMA:CurrencyListSetHeight()
	local additionalLines = 0
	local addHeight = 0
	if EMA.db.currGold == true then
		if EMA.db.currGoldInGuildBank == true then
			additionalLines = 2
			addHeight = 7
		else
			additionalLines = 1
			addHeight = 5
		end
	end
	EMAToonCurrencyListFrame:SetHeight( 56 + (( EMAApi.GetTeamListMaximumOrderOnline() + additionalLines) * 15) + addHeight )
end

function EMA:CurrencyListSetColumnWidth()
	local nameWidth = EMA.db.currencyNameWidth
	local pointsWidth = EMA.db.currencyPointsWidth
	local goldWidth = EMA.db.currencyGoldWidth
	local otherWidth = EMA.db.currencyOtherWidth
	local spacingWidth = EMA.db.currencySpacingWidth
	local frameHorizontalSpacing = 10
	local numberOfPointsColumns = 0
	local parentFrame = EMAToonCurrencyListFrame
	local headingRowTopPoint = -30
	local left = frameHorizontalSpacing
	local haveGold = 0
	local haveOther = 0
	-- Heading rows.
	parentFrame.characterNameText:SetWidth( nameWidth )
	parentFrame.characterNameText:SetPoint( "TOPLEFT", parentFrame, "TOPLEFT", left, headingRowTopPoint )
	left = left + nameWidth + spacingWidth
 	if EMA.db.currGold == true then
		parentFrame.GoldText:SetWidth( goldWidth )
		parentFrame.GoldText:SetPoint( "TOPLEFT", parentFrame, "TOPLEFT", left, headingRowTopPoint )
		left = left + goldWidth + (spacingWidth * 3)
		parentFrame.GoldText:Show()
		haveGold = 1
	else
		parentFrame.GoldText:Hide()
		haveGold = 0
	end
	if EMA.db.currBagSpace == true then
		parentFrame.BagSpaceText:SetWidth( otherWidth )
		parentFrame.BagSpaceText:SetPoint( "TOPLEFT", parentFrame, "TOPLEFT", left, headingRowTopPoint )
		left = left + otherWidth + (spacingWidth * 3)
		parentFrame.BagSpaceText:Show()
		haveOther = 1
	else
		parentFrame.BagSpaceText:Hide()
		haveOther = 0
	end
	if EMA.db.CcurrTypeOneName == "" then
		parentFrame.TypeOneText:Hide()
	else	
		parentFrame.TypeOneText:SetWidth( pointsWidth )
		parentFrame.TypeOneText:SetPoint( "TOPLEFT", parentFrame, "TOPLEFT", left, headingRowTopPoint )
		left = left + pointsWidth + spacingWidth
		numberOfPointsColumns = numberOfPointsColumns + 1
		parentFrame.TypeOneText:Show()
	end
	if EMA.db.CcurrTypeTwoName == "" then
		parentFrame.TypeTwoText:Hide()
	else	
		parentFrame.TypeTwoText:SetWidth( pointsWidth )
		parentFrame.TypeTwoText:SetPoint( "TOPLEFT", parentFrame, "TOPLEFT", left, headingRowTopPoint )
		left = left + pointsWidth + spacingWidth
		numberOfPointsColumns = numberOfPointsColumns + 1
		parentFrame.TypeTwoText:Show()
	end
	if EMA.db.CcurrTypeThreeName == "" then
		parentFrame.TypeThreeText:Hide()
	else	
		parentFrame.TypeThreeText:SetWidth( pointsWidth )
		parentFrame.TypeThreeText:SetPoint( "TOPLEFT", parentFrame, "TOPLEFT", left, headingRowTopPoint )
		left = left + pointsWidth + spacingWidth
		numberOfPointsColumns = numberOfPointsColumns + 1
		parentFrame.TypeThreeText:Show()
	end	
	if EMA.db.CcurrTypeFourName == "" then
		parentFrame.TypeFourText:Hide()
	else	
		parentFrame.TypeFourText:SetWidth( pointsWidth )
		parentFrame.TypeFourText:SetPoint( "TOPLEFT", parentFrame, "TOPLEFT", left, headingRowTopPoint )
		left = left + pointsWidth + spacingWidth
		numberOfPointsColumns = numberOfPointsColumns + 1
		parentFrame.TypeFourText:Show()
	end
	if EMA.db.CcurrTypeFiveName == "" then
		parentFrame.TypeFiveText:Hide()
	else	
		parentFrame.TypeFiveText:SetWidth( pointsWidth )
		parentFrame.TypeFiveText:SetPoint( "TOPLEFT", parentFrame, "TOPLEFT", left, headingRowTopPoint )
		left = left + pointsWidth + spacingWidth
		numberOfPointsColumns = numberOfPointsColumns + 1
		parentFrame.TypeFiveText:Show()
	end
	if EMA.db.CcurrTypeSixName == "" then
		parentFrame.TypeSixText:Hide()
	else
		parentFrame.TypeSixText:SetWidth( pointsWidth )
		parentFrame.TypeSixText:SetPoint( "TOPLEFT", parentFrame, "TOPLEFT", left, headingRowTopPoint )
		left = left + pointsWidth + spacingWidth
		numberOfPointsColumns = numberOfPointsColumns + 1
		parentFrame.TypeSixText:Show()
	end
	-- Character rows.
	for characterName, currencyFrameCharacterInfo in pairs( EMA.currencyFrameCharacterInfo ) do
		if EMAPrivate.Team.GetCharacterOnlineStatus (characterName) == true then
			local left = frameHorizontalSpacing
			local characterRowTopPoint = currencyFrameCharacterInfo.characterRowTopPoint
				currencyFrameCharacterInfo.characterNameText:SetWidth( nameWidth )
				currencyFrameCharacterInfo.characterNameText:SetPoint( "TOPLEFT", parentFrame, "TOPLEFT", left, characterRowTopPoint )
				left = left + nameWidth + spacingWidth
			if EMA.db.currGold == true then
				currencyFrameCharacterInfo.GoldText:SetWidth( goldWidth )
				currencyFrameCharacterInfo.GoldText:SetPoint( "TOPLEFT", parentFrame, "TOPLEFT", left, characterRowTopPoint )
				left = left + goldWidth + (spacingWidth * 3)
				currencyFrameCharacterInfo.GoldText:Show()
			else
				currencyFrameCharacterInfo.GoldText:Hide()
			end
			if EMA.db.currBagSpace == true then
				currencyFrameCharacterInfo.BagSpaceText:SetWidth( otherWidth )
				currencyFrameCharacterInfo.BagSpaceText:SetPoint( "TOPLEFT", parentFrame, "TOPLEFT", left, characterRowTopPoint )
				left = left + otherWidth + (spacingWidth * 3)
				currencyFrameCharacterInfo.BagSpaceText:Show()
			else
				currencyFrameCharacterInfo.BagSpaceText:Hide()
			end
			if EMA.db.CcurrTypeOneName == "" then
				currencyFrameCharacterInfo.TypeOneText:Hide()
			else
				currencyFrameCharacterInfo.TypeOneText:SetWidth( pointsWidth )
				currencyFrameCharacterInfo.TypeOneText:SetPoint( "TOPLEFT", parentFrame, "TOPLEFT", left, characterRowTopPoint )
				left = left + pointsWidth + spacingWidth
				currencyFrameCharacterInfo.TypeOneText:Show()
			end
			if EMA.db.CcurrTypeTwoName == "" then
				currencyFrameCharacterInfo.TypeTwoText:Hide()
			else
				currencyFrameCharacterInfo.TypeTwoText:SetWidth( pointsWidth )
				currencyFrameCharacterInfo.TypeTwoText:SetPoint( "TOPLEFT", parentFrame, "TOPLEFT", left, characterRowTopPoint )
				left = left + pointsWidth + spacingWidth
				currencyFrameCharacterInfo.TypeTwoText:Show()
			end
			if EMA.db.CcurrTypeThreeName == "" then
				currencyFrameCharacterInfo.TypeThreeText:Hide()
			else	
				currencyFrameCharacterInfo.TypeThreeText:SetWidth( pointsWidth )
				currencyFrameCharacterInfo.TypeThreeText:SetPoint( "TOPLEFT", parentFrame, "TOPLEFT", left, characterRowTopPoint )
				left = left + pointsWidth + spacingWidth
				currencyFrameCharacterInfo.TypeThreeText:Show()
			end		
			if EMA.db.CcurrTypeFourName == "" then
				currencyFrameCharacterInfo.TypeFourText:Hide()
			else
				currencyFrameCharacterInfo.TypeFourText:SetWidth( pointsWidth )
				currencyFrameCharacterInfo.TypeFourText:SetPoint( "TOPLEFT", parentFrame, "TOPLEFT", left, characterRowTopPoint )
				left = left + pointsWidth + spacingWidth
				currencyFrameCharacterInfo.TypeFourText:Show()
			end
			if EMA.db.CcurrTypeFiveName == "" then
				currencyFrameCharacterInfo.TypeFiveText:Hide()
			else	
				currencyFrameCharacterInfo.TypeFiveText:SetWidth( pointsWidth )
				currencyFrameCharacterInfo.TypeFiveText:SetPoint( "TOPLEFT", parentFrame, "TOPLEFT", left, characterRowTopPoint )
				left = left + pointsWidth + spacingWidth
				currencyFrameCharacterInfo.TypeFiveText:Show()
	
			end
			if EMA.db.CcurrTypeSixName == "" then
				currencyFrameCharacterInfo.TypeSixText:Hide()
			else
				currencyFrameCharacterInfo.TypeSixText:SetWidth( pointsWidth )
				currencyFrameCharacterInfo.TypeSixText:SetPoint( "TOPLEFT", parentFrame, "TOPLEFT", left, characterRowTopPoint )
				left = left + pointsWidth + spacingWidth
				currencyFrameCharacterInfo.TypeSixText:Show()
			end		
		end
	end	
	-- Parent frame width and title.
	local finalParentWidth = frameHorizontalSpacing + nameWidth + spacingWidth + (haveGold * (goldWidth + (spacingWidth * 3))) + (haveOther * (otherWidth + (spacingWidth * 3))) + (numberOfPointsColumns * (pointsWidth + spacingWidth)) + frameHorizontalSpacing
	if finalParentWidth < 95 then
		finalParentWidth = 95
	end
	local widthOfCloseAndUpdateButtons = 70
	parentFrame.titleName:SetWidth( finalParentWidth - widthOfCloseAndUpdateButtons - frameHorizontalSpacing - frameHorizontalSpacing )
	parentFrame.titleName:SetPoint( "TOPLEFT", parentFrame, "TOPLEFT", frameHorizontalSpacing, -9 )
	if EMA.db.currGold == true then
		if numberOfPointsColumns > 1 then
			parentFrame.titleName:SetText( L["EMA_CURRENCY"] )
		else
			parentFrame.titleName:SetText( L["CURRENCY"] )
		end
	else
		if numberOfPointsColumns < 2 then
			parentFrame.titleName:SetText( "" )
		end
		if numberOfPointsColumns == 2 then
			parentFrame.titleName:SetText( L["CURR"] )
		end
		if (numberOfPointsColumns >= 3) and (numberOfPointsColumns <= 4) then
			parentFrame.titleName:SetText( L["CURRENCY"] )
		end
		if numberOfPointsColumns > 4 then
			parentFrame.titleName:SetText( L["EMA_CURRENCY"] )
		end
	end
	parentFrame:SetWidth( finalParentWidth )
	-- Total Gold.
	local nameLeft = frameHorizontalSpacing
	local goldLeft = frameHorizontalSpacing + nameWidth + spacingWidth
	--local guildTop = -35 - ((EMAApi.GetTeamListMaximumOrder() + 1) * 15) - 5
	--local goldTop = -35 - ((EMAApi.GetTeamListMaximumOrder() + 1) * 15) - 7	
	local guildTop = -35 - ((EMAApi.GetTeamListMaximumOrderOnline() + 1) * 15) - 5
	local goldTop = -35 - ((EMAApi.GetTeamListMaximumOrderOnline() + 1) * 15) - 7	
	if EMA.db.currGold == true then
		if EMA.db.currGoldInGuildBank == true then
			parentFrame.TotalGoldGuildTitleText:SetWidth( nameWidth )
			parentFrame.TotalGoldGuildTitleText:SetPoint( "TOPLEFT", parentFrame, "TOPLEFT", nameLeft, guildTop )
			parentFrame.TotalGoldGuildTitleText:Show()
			parentFrame.TotalGoldGuildText:SetWidth( goldWidth )
			parentFrame.TotalGoldGuildText:SetPoint( "TOPLEFT", parentFrame, "TOPLEFT", goldLeft, guildTop )
			parentFrame.TotalGoldGuildText:Show()
			--goldTop = -35 - ((EMAApi.GetTeamListMaximumOrder() + 2) * 15) - 5
			goldTop = -35 - ((EMAApi.GetTeamListMaximumOrderOnline() + 2) * 15) - 5
		else
			parentFrame.TotalGoldGuildTitleText:Hide()
			parentFrame.TotalGoldGuildText:Hide()			
		end
		parentFrame.TotalGoldTitleText:SetWidth( nameWidth )
		parentFrame.TotalGoldTitleText:SetPoint( "TOPLEFT", parentFrame, "TOPLEFT", nameLeft, goldTop )
		parentFrame.TotalGoldTitleText:Show()
		parentFrame.TotalGoldText:SetWidth( goldWidth )
		parentFrame.TotalGoldText:SetPoint( "TOPLEFT", parentFrame, "TOPLEFT", goldLeft, goldTop )
		parentFrame.TotalGoldText:Show()
	else
		parentFrame.TotalGoldTitleText:Hide()
		parentFrame.TotalGoldText:Hide()
		parentFrame.TotalGoldGuildTitleText:Hide()
		parentFrame.TotalGoldGuildText:Hide()	
	end
end

function EMA:CreateEMACurrencyFrameInfo( characterName, parentFrame )
	--EMA.Print("makelist", characterName)
	--if EMAPrivate.Team.GetCharacterOnlineStatus (characterName) == true then
	local left = 10
	local spacing = 50
	local width = 50
	local top = 0
	--local top = -35 + (-15 * EMAApi.GetPositionForCharacterName( characterName ))
	-- WHAT THE HELL IS GOING ON HERE! Ebony!
		local height1 = -35 + ( -15 * EMAApi.GetPositionForCharacterName( characterName) )
		local height2 = -35 + ( -15 * EMAApi.GetPositionForCharacterNameOnline( characterName) )
		if height1 < height2 then
			--EMA:Print("greater than ", characterName )
			top = height2
		elseif height1 > height2 then
			top = height2
		else
			top = height2
		end	
	--EMA:Print("Top", top)
	-- Create the table to hold the status bars for this character.	
	EMA.currencyFrameCharacterInfo[characterName] = {}
	-- Get the character info table.
	local currencyFrameCharacterInfo = EMA.currencyFrameCharacterInfo[characterName]
	currencyFrameCharacterInfo.characterRowTopPoint = top
	-- Set the characters name font string.
	local frameCharacterName = EMA.globalCurrencyFramePrefix.."CharacterName"
	local frameCharacterNameText = parentFrame:CreateFontString( frameCharacterName.."Text", "OVERLAY", "GameFontNormal" )
	frameCharacterNameText:SetText( Ambiguate( characterName , "none" ) )
	frameCharacterNameText:SetTextColor( 1.00, 1.00, 1.00, 1.00 )
	frameCharacterNameText:SetPoint( "TOPLEFT", parentFrame, "TOPLEFT", left, top )
	frameCharacterNameText:SetWidth( width * 2.5 )
	frameCharacterNameText:SetJustifyH( "LEFT" )
	currencyFrameCharacterInfo.characterNameText = frameCharacterNameText
	left = left + (spacing * 2)
	-- Set the Gold font string.
	local frameGold = EMA.globalCurrencyFramePrefix.."Gold"
	local frameGoldText = parentFrame:CreateFontString( frameGold.."Text", "OVERLAY", "GameFontNormal" )
	frameGoldText:SetText( "0" )
	frameGoldText:SetTextColor( 1.00, 1.00, 1.00, 1.00 )
	frameGoldText:SetPoint( "TOPLEFT", parentFrame, "TOPLEFT", left, top )
	frameGoldText:SetWidth( width )
	frameGoldText:SetJustifyH( "RIGHT" )
	currencyFrameCharacterInfo.GoldText = frameGoldText
	left = left + spacing	
	-- Set the BagSpace font string.
	local frameBagSpace = EMA.globalCurrencyFramePrefix.."BagSpace"
	local frameBagSpaceText = parentFrame:CreateFontString( frameBagSpace.."Text", "OVERLAY", "GameFontNormal" )
	frameBagSpaceText:SetText( "0" )
	frameBagSpaceText:SetTextColor( 1.00, 1.00, 1.00, 1.00 )
	frameBagSpaceText:SetPoint( "TOPLEFT", parentFrame, "TOPLEFT", left, top )
	frameBagSpaceText:SetWidth( width )
	frameBagSpaceText:SetJustifyH( "RIGHT" )
	currencyFrameCharacterInfo.BagSpaceText = frameBagSpaceText
	left = left + spacing
	-- Set the TypeOne font string.
	local frameTypeOne = EMA.globalCurrencyFramePrefix.."TypeOne"
	local frameTypeOneText = parentFrame:CreateFontString( frameTypeOne.."Text", "OVERLAY", "GameFontNormal" )
	frameTypeOneText:SetText( "0" )
	frameTypeOneText:SetTextColor( 1.00, 1.00, 1.00, 1.00 )
	frameTypeOneText:SetPoint( "TOPLEFT", parentFrame, "TOPLEFT", left, top )
	frameTypeOneText:SetWidth( width )
	frameTypeOneText:SetJustifyH( "CENTER" )
	currencyFrameCharacterInfo.TypeOneText = frameTypeOneText
	left = left + spacing
	-- Set the TypeTwo font string.
	local frameTypeTwo = EMA.globalCurrencyFramePrefix.."TypeTwo"
	local frameTypeTwoText = parentFrame:CreateFontString( frameTypeTwo.."Text", "OVERLAY", "GameFontNormal" )
	frameTypeTwoText:SetText( "0" )
	frameTypeTwoText:SetTextColor( 1.00, 1.00, 1.00, 1.00 )
	frameTypeTwoText:SetPoint( "TOPLEFT", parentFrame, "TOPLEFT", left, top )
	frameTypeTwoText:SetWidth( width )
	frameTypeTwoText:SetJustifyH( "CENTER" )
	currencyFrameCharacterInfo.TypeTwoText = frameTypeTwoText
	left = left + spacing
		-- Set the TypeThree font string.
	local frameTypeThree = EMA.globalCurrencyFramePrefix.."TypeThree"
	local frameTypeThreeText = parentFrame:CreateFontString( frameTypeThree.."Text", "OVERLAY", "GameFontNormal" )
	frameTypeThreeText:SetText( "0" )
	frameTypeThreeText:SetTextColor( 1.00, 1.00, 1.00, 1.00 )
	frameTypeThreeText:SetPoint( "TOPLEFT", parentFrame, "TOPLEFT", left, top )
	frameTypeThreeText:SetWidth( width )
	frameTypeThreeText:SetJustifyH( "CENTER" )
	currencyFrameCharacterInfo.TypeThreeText = frameTypeThreeText
	left = left + spacing
	-- Set the TypeFour font string.
	local frameTypeFour = EMA.globalCurrencyFramePrefix.."TypeFour"
	local frameTypeFourText = parentFrame:CreateFontString( frameTypeFour.."Text", "OVERLAY", "GameFontNormal" )
	frameTypeFourText:SetText( "0" )
	frameTypeFourText:SetTextColor( 1.00, 1.00, 1.00, 1.00 )
	frameTypeFourText:SetPoint( "TOPLEFT", parentFrame, "TOPLEFT", left, top )
	frameTypeFourText:SetWidth( width )
	frameTypeFourText:SetJustifyH( "CENTER" )
	currencyFrameCharacterInfo.TypeFourText = frameTypeFourText
	left = left + spacing
	-- Set the TypeFive font string.
	local frameTypeFive = EMA.globalCurrencyFramePrefix.."TypeFive"
	local frameTypeFiveText = parentFrame:CreateFontString( frameTypeFive.."Text", "OVERLAY", "GameFontNormal" )
	frameTypeFiveText:SetText( "0" )
	frameTypeFiveText:SetTextColor( 1.00, 1.00, 1.00, 1.00 )
	frameTypeFiveText:SetPoint( "TOPLEFT", parentFrame, "TOPLEFT", left, top )
	frameTypeFiveText:SetWidth( width )
	frameTypeFiveText:SetJustifyH( "CENTER" )
	currencyFrameCharacterInfo.TypeFiveText = frameTypeFiveText
	left = left + spacing
	-- Set the TypeSix font string.
	local frameTypeSix = EMA.globalCurrencyFramePrefix.."TypeSix"
	local frameTypeSixText = parentFrame:CreateFontString( frameTypeSix.."Text", "OVERLAY", "GameFontNormal" )
	frameTypeSixText:SetText( "0" )
	frameTypeSixText:SetTextColor( 1.00, 1.00, 1.00, 1.00 )
	frameTypeSixText:SetPoint( "TOPLEFT", parentFrame, "TOPLEFT", left, top )
	frameTypeSixText:SetWidth( width )
	frameTypeSixText:SetJustifyH( "CENTER" )
	currencyFrameCharacterInfo.TypeSixText = frameTypeSixText
	left = left + spacing
	EMA:SettingsUpdateFontStyle()
end

function EMA:ShowInformationPanel()
	if EMAToonCurrencyListWindowFrame:IsShown() then
		EMAToonCurrencyListFrame:Hide()
	else
		--EMA:Print("startup")
		EMA:EMAToonRequestCurrency()
		EMAToonCurrencyListFrame:Show()
	end	
end	

function EMA:EMAToonHideCurrency()
	EMAToonCurrencyListFrame:Hide()
end

function EMA:EMAToonRequestCurrency()
	-- Colour Light Red.
	local r = 1.0
	local g = 0.42
	local b = 0.42
	local a = 0.6
	for characterName, currencyFrameCharacterInfo in pairs( EMA.currencyFrameCharacterInfo ) do
		--EMA.Print("DoRequestCurrency", characterName)
		-- Change Hight if a new member joins the team or leaves the team.
		local height1 = currencyFrameCharacterInfo.characterRowTopPoint
		local height2 = -35 + ( -15 * EMAApi.GetPositionForCharacterNameOnline( characterName) )
			if height1 < height2 then
				currencyFrameCharacterInfo.characterRowTopPoint = height2
			elseif height1 > height2 then
				currencyFrameCharacterInfo.characterRowTopPoint = height2
			end	
		if EMAApi.GetCharacterOnlineStatus ( characterName ) == false then
			-- Hides currency for offline members.
			--EMA.Print("offlineRemove", characterName )
			currencyFrameCharacterInfo.characterNameText:Hide()
			currencyFrameCharacterInfo.GoldText:Hide()
			currencyFrameCharacterInfo.BagSpaceText:Hide()
			currencyFrameCharacterInfo.TypeOneText:Hide()
			currencyFrameCharacterInfo.TypeTwoText:Hide()
			currencyFrameCharacterInfo.TypeThreeText:Hide()
			currencyFrameCharacterInfo.TypeFourText:Hide()
			currencyFrameCharacterInfo.TypeFiveText:Hide()
			currencyFrameCharacterInfo.TypeSixText:Hide()
		else
			currencyFrameCharacterInfo.characterNameText:Show()
			currencyFrameCharacterInfo.GoldText:SetTextColor( r, g, b, a )
			currencyFrameCharacterInfo.BagSpaceText:SetTextColor( r, g, b, a )
			currencyFrameCharacterInfo.characterNameText:SetTextColor( r, g, b, a )
			currencyFrameCharacterInfo.TypeOneText:SetTextColor( r, g, b, a )
			currencyFrameCharacterInfo.TypeTwoText:SetTextColor( r, g, b, a )
			currencyFrameCharacterInfo.TypeThreeText:SetTextColor( r, g, b, a )
			currencyFrameCharacterInfo.TypeFourText:SetTextColor( r, g, b, a )
			currencyFrameCharacterInfo.TypeFiveText:SetTextColor( r, g, b, a )
			currencyFrameCharacterInfo.TypeSixText:SetTextColor( r, g, b, a )
		end
	end
	EMA.currencyTotalGold = 0
	if EMA.db.currGoldInGuildBank == true then
		if IsInGuild() then
			EMA.currencyTotalGold = GetGuildBankMoney()
		end
	end
	EMA:EMASendCommandToTeam( EMA.COMMAND_REQUEST_CURRENCY, "" )
	EMAToonCurrencyListFrame:Show()
	EMA.SettingsRefresh()
end

function EMA:DoSendCurrency( characterName, dummyValue )
	--EMA:Print("Test2")
	if EMAApi.GetCharacterOnlineStatus ( characterName ) == true then
		table.wipe( EMA.currentCurrencyValues )
		-- Gold
		EMA.currentCurrencyValues.currGold = GetMoney()
		-- BagSpace Maths
		local numFreeSlots, numTotalSlots = LibBagUtils:CountSlots("BAGS", 0)
		EMA.currentCurrencyValues.bagSpace = numFreeSlots
		EMA.currentCurrencyValues.bagSpaceMax = numTotalSlots
		--CcurrTypeOne
		local info = C_CurrencyInfo.GetCurrencyInfo( EMA.db.CcurrTypeOne )
		if info ~= nil then	
			EMA.currentCurrencyValues.currTypeOne = info.quantity
			EMA.currentCurrencyValues.currMaxTypeOne = info.maxQuantity
		end
		--CcurrTypeTwo
		local infoTwo = C_CurrencyInfo.GetCurrencyInfo( EMA.db.CcurrTypeTwo )
		if infoTwo ~= nil then	
			EMA.currentCurrencyValues.currTypeTwo = infoTwo.quantity
			EMA.currentCurrencyValues.currMaxTypeTwo = infoTwo.maxQuantity
		end
		--CcurrTypeThree
		local infoThree = C_CurrencyInfo.GetCurrencyInfo( EMA.db.CcurrTypeThree )
		if infoThree ~= nil then	
			EMA.currentCurrencyValues.currTypeThree = infoThree.quantity
			EMA.currentCurrencyValues.currMaxTypeThree = infoThree.maxQuantity
		end
		--CcurrTypeFour
		local infoFour = C_CurrencyInfo.GetCurrencyInfo( EMA.db.CcurrTypeFour )
		if infoFour ~= nil then	
			EMA.currentCurrencyValues.currTypeFour = infoFour.quantity
			EMA.currentCurrencyValues.currMaxTypeFour = infoFour.maxQuantity
		end
		--CcurrTypeFive
		local infoFive = C_CurrencyInfo.GetCurrencyInfo( EMA.db.CcurrTypeFive )
		if infoFive ~= nil then	
			EMA.currentCurrencyValues.currTypeFive = infoFive.quantity
			EMA.currentCurrencyValues.currMaxTypeFive = infoFive.maxQuantity
		end
		--CcurrTypeSix
		local infoSix = C_CurrencyInfo.GetCurrencyInfo( EMA.db.CcurrTypeSix )
		if infoSix ~= nil then
			EMA.currentCurrencyValues.currTypeSix = infoSix.quantity
			EMA.currentCurrencyValues.currMaxTypeSix = infoSix.maxQuantity
		end
		-- SEND DATA
		--EMA:Print("testsendData", info.quantity, info.maxQuantity)
		EMA:EMASendCommandToToon( characterName, EMA.COMMAND_HERE_IS_CURRENCY, EMA.currentCurrencyValues )
	else
		return
	end
end

function EMA:DoShowToonsCurrency( characterName, currencyValues )
	--EMA.Print("DoShowCurrency", characterName, currencyValues.currTypeOne, currencyValues.currMaxTypeOne )
	local parentFrame = EMAToonCurrencyListFrame
	
	-- Get (or create and get) the character information.
	local currencyFrameCharacterInfo = EMA.currencyFrameCharacterInfo[characterName]
		--EMA.Print("Frame", characterName)
	if currencyFrameCharacterInfo == nil then
		EMA:CreateEMACurrencyFrameInfo( characterName, parentFrame )
		currencyFrameCharacterInfo = EMA.currencyFrameCharacterInfo[characterName]
	end
	-- Colour white.
	local r = 1.0
	local g = 1.0
	local b = 1.0
	local a = 1.0
	local v = 0
	--Gold
	currencyFrameCharacterInfo.GoldText:SetTextColor( r, g, b, a )
	currencyFrameCharacterInfo.characterNameText:SetTextColor( r, g, b, a )
	currencyFrameCharacterInfo.GoldText:SetTextColor( r, g, b, a )
	-- BagSpace
	if currencyValues.bagSpace == 0 then 
		--EMA:Print("SetRed")
		currencyFrameCharacterInfo.BagSpaceText:SetTextColor( r, v, v, a )
	else
		--EMA:Print("SetWhite")
		currencyFrameCharacterInfo.BagSpaceText:SetTextColor( r, g, b, a )
	end
	if currencyValues.currTypeOne ~= nil then
		if currencyValues.currTypeOne == currencyValues.currMaxTypeOne and currencyValues.currTypeOne  > 0 then 
			--EMA:Print("SetRed")
			currencyFrameCharacterInfo.TypeOneText:SetTextColor( r, v, v, a )
		else
			--EMA:Print("SetWhite")
			currencyFrameCharacterInfo.TypeOneText:SetTextColor( r, g, b, a )
		end	
	end
	if currencyValues.currTypeTwo ~= nil then
		if currencyValues.currTypeTwo == currencyValues.currMaxTypeTwo and currencyValues.currTypeTwo  > 0 then 
			currencyFrameCharacterInfo.TypeTwoText:SetTextColor( r, v, v, a )
		else
			currencyFrameCharacterInfo.TypeTwoText:SetTextColor( r, g, b, a )
		end
	end
	if currencyValues.currTypeThree ~= nil then
		if currencyValues.currTypeThree == currencyValues.currMaxTypeThree and currencyValues.currTypeThree  > 0 then 
			currencyFrameCharacterInfo.TypeThreeText:SetTextColor( r, v, v, a )
		else
			currencyFrameCharacterInfo.TypeThreeText:SetTextColor( r, g, b, a )
		end
	end
	if currencyValues.currTypeFour ~= nil then
		if currencyValues.currTypeFour == currencyValues.currMaxTypeFour and currencyValues.currTypeFour  > 0 then 
			currencyFrameCharacterInfo.TypeFourText:SetTextColor( r, v, v, a )
		else
			currencyFrameCharacterInfo.TypeFourText:SetTextColor( r, g, b, a )
		end
	end
	if currencyValues.currTypeFive~= nil then
		if currencyValues.currTypeFive == currencyValues.currMaxTypeFive and currencyValues.currTypeFive  > 0 then 
			currencyFrameCharacterInfo.TypeFiveText:SetTextColor( r, v, v, a )
		else
			currencyFrameCharacterInfo.TypeFiveText:SetTextColor( r, g, b, a )
		end
	end
	if currencyValues.currTypeSix ~= nil then	
		if currencyValues.currTypeSix == currencyValues.currMaxTypeSix and currencyValues.currTypeSix > 0 then 
			currencyFrameCharacterInfo.TypeSixText:SetTextColor( r, v, v, a )
		else
			currencyFrameCharacterInfo.TypeSixText:SetTextColor( r, g, b, a )
		end
	end
	currencyFrameCharacterInfo.GoldText:SetText( EMAUtilities:FormatMoneyString( currencyValues.currGold ) )
	currencyFrameCharacterInfo.BagSpaceText:SetText( currencyValues.bagSpace..L["/"]..currencyValues.bagSpaceMax )
	currencyFrameCharacterInfo.TypeOneText:SetText( currencyValues.currTypeOne )
	currencyFrameCharacterInfo.TypeTwoText:SetText( currencyValues.currTypeTwo )
	currencyFrameCharacterInfo.TypeThreeText:SetText( currencyValues.currTypeThree )	
	currencyFrameCharacterInfo.TypeFourText:SetText( currencyValues.currTypeFour )
	currencyFrameCharacterInfo.TypeFiveText:SetText( currencyValues.currTypeFive )
	currencyFrameCharacterInfo.TypeSixText:SetText( currencyValues.currTypeSix )
	-- Total gold.
	EMA.currencyTotalGold = EMA.currencyTotalGold + currencyValues.currGold
	parentFrame.TotalGoldText:SetText( EMAUtilities:FormatMoneyString( EMA.currencyTotalGold ) )
	--parentFrame.TotalGoldText:SetText( GetCoinTextureString( EMA.currencyTotalGold ) )
	if IsInGuild() then
		parentFrame.TotalGoldGuildText:SetText( EMAUtilities:FormatMoneyString( GetGuildBankMoney() ) )
		--parentFrame.TotalGoldGuildText:SetText( GetCoinTextureString( GetGuildBankMoney() ) )
	end
	-- Update width of currency list.
	EMA:CurrencyListSetColumnWidth()
	EMAToonCurrencyListFrame:Show()
	--EMAToonCurrencyListFrameTwo:Show()
end


-------------------------------------------------------------------------------------------------------------
-- Team Information Stuff.
-------------------------------------------------------------------------------------------------------------

local trigger = {
	["!emahelp"] = true,
	["!gold"] = true,
	["!keys"] = true,
	["!ping"] = true,
	["!durability"] = true,
	["!durr"] = true,
	["!item"] = true,
	["!bagspace"] = true
}

function EMA:DoChatCommand( event, msg, playerName, ... )
	if EMA.db.currChatTrigger == false then
		return
	end
	--EMA:Print("test3", event, msg, playerName )
	msg = msg:lower()
	for keyword in pairs(trigger) do
		--EMA:Print("aa", msg, keyword, playerName)
		if msg:match(keyword) then
			if EMAApi.IsCharacterInTeam(playerName) == true then
				if keyword == "!gold" then
					--EMA:Print("triggerFound", keyword)
					EMA:TellTeamGold( event, msg, playerName)
				elseif keyword == "!keys" then
					EMA:TellTeamKeys( event, msg, playerName)
				elseif keyword == "!ping" then
					EMA:TellTeamPing( event, msg, playerName)
				elseif 	keyword == "!durability" or keyword == "!durr" then
					EMA:TellTeamDurr( event, msg, playerName)
				elseif keyword == "!item" then
					EMA:TellTeamItem( event, msg, playerName)
				elseif keyword == "!bagspace" then
					EMA:TellTeamBagspace( event, msg, playerName)
					
				elseif keyword == "!emahelp" then
					EMA:TriggerHelp( msg, playerName )
				break
				end	
			end	
		end
	end
end	

function EMA:TriggerHelp( msg, playerName )
	--EMA:Print("test?", playerName, EMA.CharacterName)
	if  playerName == EMA.characterName then
		EMA:Print( L["CHAT_TRIGGER"] )
		for keyword in pairs(trigger) do
		 EMA:Print(keyword)
		 end
	end
end

-- Report Gold. 
function EMA:TellTeamGold( event, msg, playerName )
	--EMA:Print("goldtest", event, msg)
	local money = GetMoney()
	local gold, silver, copper  = EMAUtilities:MoneyStringFormatted(money)
	local goldText = gold.." Gold "..silver.." Silver "..copper.." Copper"
	local channel = nil 
	if event == "CHAT_MSG_GUILD" then
		channel = "GUILD"
	elseif event == "CHAT_MSG_PARTY" or event == "CHAT_MSG_PARTY_LEADER" then
		channel = "PARTY"
	elseif event == "CHAT_MSG_RAID" or event == "CHAT_MSG_RAID_LEADER" then
		channel = "RAID"
	end
	if channel ~= nil then
		SendChatMessage(L["I_HAVE_X_GOLD"](goldText), channel) 
	end
end

-- KeyStones
function EMA:TellTeamKeys( event, msg, playerName)
	local KeyStone = EMA:LookForKeyStones()
	--EMA:Print("test", KeyStone)
	local channel = nil 
	if event == "CHAT_MSG_GUILD" then
		channel = "GUILD"
	elseif event == "CHAT_MSG_PARTY" or event == "CHAT_MSG_PARTY_LEADER" then
		channel = "PARTY"
	elseif event == "CHAT_MSG_RAID" or event == "CHAT_MSG_RAID_LEADER" then
		channel = "RAID"
	end
	if KeyStone == nil then 
		KeyStone = L["NO_KEYSTONE_FOUND"]
	end	
	
	if channel ~= nil and KeyStone ~= nil then
		SendChatMessage(L["MY_KEY_STONE_IS"](KeyStone), channel)
	end
end	

function EMA:LookForKeyStones()
	for bagID = 0, NUM_BAG_SLOTS do
		for slotID = 1,GetContainerNumSlots( bagID ),1 do 
			local item = Item:CreateFromBagAndSlot(bagID, slotID)
			if ( item ) then
				local bagItemID = item:GetItemID()
				local itemLink = item:GetItemLink()
				if ( bagItemID ) then
					--EMA:Print("test", bagItemID, itemLink)
					if (bagItemID == 158923) then
						return itemLink
					elseif (bagItemID == 123456) then
						return itemLink
					end
				end
			end	
		end	
	end	
end

-- Ping (System)
function EMA:TellTeamPing( event, msg, playerName)
	local _, _, latencyHome, latencyWorld = GetNetStats()
	local channel = nil 
	if event == "CHAT_MSG_GUILD" then
		channel = "GUILD"
	elseif event == "CHAT_MSG_PARTY" or event == "CHAT_MSG_PARTY_LEADER" then
		channel = "PARTY"
	elseif event == "CHAT_MSG_RAID" or event == "CHAT_MSG_RAID_LEADER" then
		channel = "RAID"
	end
	if channel ~= nil then
		SendChatMessage(L["MY_LATENCY_IS:X_MS_X_MS"](latencyHome,latencyWorld), channel)
	end
end	
 
 -- Durability
function EMA:TellTeamDurr( event, msg, playerName)
	local curTotal, maxTotal, broken = 0, 0, 0
	local durability = 100
	for i = 1, 17 do
		local curItemDurability, maxItemDurability = GetInventoryItemDurability(i)
		if (curItemDurability ~= nil) and (maxItemDurability ~= nil ) then
			--EMA:Print("£test", i, curItemDurability, maxItemDurability )
			curTotal = curTotal + curItemDurability
			maxTotal = maxTotal + maxItemDurability
			if maxItemDurability > 0 and curItemDurability == 0 then
				broken = broken + 1
			end
		end
	end
	local durabilityPercent = ( EMAUtilities:GetStatusPercent(curTotal, maxTotal) * 100 )
	local durabilityText = tostring(gsub( durabilityPercent, "%.[^|]+", "") )
	
	local channel = nil 
	if event == "CHAT_MSG_GUILD" then
		channel = "GUILD"
	elseif event == "CHAT_MSG_PARTY" or event == "CHAT_MSG_PARTY_LEADER" then
		channel = "PARTY"
	elseif event == "CHAT_MSG_RAID" or event == "CHAT_MSG_RAID_LEADER" then
		channel = "RAID"
	end
	if channel ~= nil then
		SendChatMessage(L["MY_CURRENT_DURABILITY_IS"](durabilityText)..L["%"], channel)
	end
end

-- Bag Item Scan:
function EMA:TellTeamItem( event, msg, playerName)
	--EMA:Print("item", event, msg, playerName )
	local _, item = strsplit(" ", msg, 2)
	local _, name = GetItemInfo( item )
	local countBags = GetItemCount( item )
	local countTotal = GetItemCount( item , true)
	local channel = nil 
	if event == "CHAT_MSG_GUILD" then
		channel = "GUILD"
	elseif event == "CHAT_MSG_PARTY" or event == "CHAT_MSG_PARTY_LEADER" then
		channel = "PARTY"
	elseif event == "CHAT_MSG_RAID" or event == "CHAT_MSG_RAID_LEADER" then
		channel = "RAID"
	end
	if channel ~= nil and name ~= nil then
		SendChatMessage(L["ITEMCOUNT:_x_BAGS_BANK"](name, countBags, countTotal), channel)
	end
end	

function EMA:TellTeamBagspace( event, msg, playerName)
	local numFreeSlots, numTotalSlots = LibBagUtils:CountSlots("BAGS", 0)
	local channel = nil
	if event == "CHAT_MSG_GUILD" then
		channel = "GUILD"
	elseif event == "CHAT_MSG_PARTY" or event == "CHAT_MSG_PARTY_LEADER" then
		channel = "PARTY"
	elseif event == "CHAT_MSG_RAID" or event == "CHAT_MSG_RAID_LEADER" then
		channel = "RAID"
	end
	if channel ~= nil then
		SendChatMessage(L["BAG_FREE_SPACE"](numFreeSlots, numTotalSlots), channel)
	end
end

-- A EMA command has been received.
function EMA:EMAOnCommandReceived( characterName, commandName, ... )
	if commandName == EMA.COMMAND_REQUEST_CURRENCY then
		EMA:DoSendCurrency( characterName, ... )
	end
	if commandName == EMA.COMMAND_HERE_IS_CURRENCY then
		EMA:DoShowToonsCurrency( characterName, ... )
	end
end

EMAApi.TestCodeCurr = testcode
