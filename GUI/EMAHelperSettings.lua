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

local MAJOR, MINOR = "EMAHelperSettings-1.0", 2
local EMAHelperSettings, oldMinor = LibStub:NewLibrary( MAJOR, MINOR )

if not EMAHelperSettings then 
	return 
end

-- Locale.
local L = LibStub( "AceLocale-3.0" ):GetLocale( "Core" )

-- Get the ACE GUI Library.
local AceGUI = LibStub( "AceGUI-3.0" )

-- Register a manual layout function which does nothing, each child manually sets its size and position.
AceGUI:RegisterLayout( "EMAManual", function(content, children) end )


AceGUI:RegisterLayout("EMAuiFill",
	function(content, children)
		if children[1] then
			local offset = 12
			local height = content:GetHeight() - offset
			local width = content:GetWidth()
			children[1]:SetWidth(width)
			children[1]:SetHeight(height)
			children[1]:SetPoint( "TOPLEFT", 0, -offset )
			children[1]:ClearAllPoints()
			children[1].frame:Show()
			
		end
	end)


	-- A single control fills the whole content area
AceGUI:RegisterLayout("EMAFillAce3Fix",
	function(content, children)
		if children[1] then
			children[1].frame:Hide()
			local offset = 0
			local height = content:GetHeight()
			local width = content:GetWidth()
			children[1]:SetWidth(width)
			children[1]:SetHeight(height)
			children[1]:SetPoint("TOPLEFT", content)
			children[1]:ClearAllPoints()
			children[1].frame:Show()
			
		end
	end)
	
-------------------------------------------------------------------------------------------------------------
-- Spacing.
-------------------------------------------------------------------------------------------------------------

function EMAHelperSettings:GetHorizontalSpacing()
	return 2
end

function EMAHelperSettings:GetVerticalSpacing()
	return 2
end

-------------------------------------------------------------------------------------------------------------
-- Settings Frame.
-------------------------------------------------------------------------------------------------------------

function EMAHelperSettings:CreateSettings( settingsControl, displayName, parentDisplayName, pushSettingsCallback, moduleIcon, order )
	if moduleIcon == nil then
		moduleIcon = "Interface\\Icons\\Temp"
	end	
	
	if order == nil then
		order = 1000
	end	
	
	
	local containerWidgetSettings = AceGUI:Create( "SimpleGroup" )
	containerWidgetSettings:SetLayout( "Fill" )
	
	local widgetSettings = AceGUI:Create( "ScrollFrame" )
	widgetSettings:SetLayout( "EMAuiFill" )
	
	containerWidgetSettings:AddChild( widgetSettings )
	
	
	local button = AceGUI:Create( "Button" ) 
	if displayName == "News" then
		button:SetText( L["PUSH_ALL_SETTINGS"] )
	else	
		button:SetText( L["PUSH_SETTINGS"] )
	end
	containerWidgetSettings:AddChild( button )
	button:SetWidth( 200 )
	button:SetPoint( "TOPLEFT", containerWidgetSettings.frame, "TOPRIGHT", -200, 40 )
	button:SetCallback( "OnClick", pushSettingsCallback )
	settingsControl.widgetPushSettingsButton = button
	
	settingsControl.widgetSettingsHelp = widgetSettingsHelp
	settingsControl.containerWidgetSettings = containerWidgetSettings
	
	settingsControl.widgetSettings = widgetSettings
	EMAPrivate.SettingsFrame.Tree.Add( displayName, parentDisplayName, moduleIcon, order, settingsControl.containerWidgetSettings )
end

function EMAHelperSettings:TopOfSettings()
	return 0
end

function EMAHelperSettings:LeftOfSettings()
	return 0
end

-------------------------------------------------------------------------------------------------------------
-- Help.  Removed We need to keep this here incase some module needs CreateHelp
-------------------------------------------------------------------------------------------------------------

function EMAHelperSettings:CreateHelp( settingsControl, help, configuration )
end
	
-------------------------------------------------------------------------------------------------------------
-- Heading.
-------------------------------------------------------------------------------------------------------------

function EMAHelperSettings:HeadingWidth( hasScrollBar )
	
	local width = 800 - 230
	if hasScrollBar == true then
		return width - 20
	else
		return width
	end
end

function EMAHelperSettings:HeadingHeight()
	-- Defined as 18 in the AceGUI Heading Widget (added 2 more pixels for spacing purposes).
	return 20
end

function EMAHelperSettings:CreateHeading( settingsControl, text, top, hasScrollBar )
	-- Create a heading
	local heading = AceGUI:Create( "Heading" )
	heading:SetText( text )
	settingsControl.widgetSettings:AddChild( heading )
	heading:SetWidth( self:HeadingWidth( hasScrollBar ) )
	heading:SetPoint( "TOPLEFT", settingsControl.widgetSettings.content, "TOPLEFT", 0, top )
end

-------------------------------------------------------------------------------------------------------------
-- Frame backdrop.
-------------------------------------------------------------------------------------------------------------

function EMAHelperSettings:CreateBackdrop()
	local frameBackdrop  = {
		bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
		edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
		tile = true, tileSize = 16, edgeSize = 16,
		insets = { left = 3, right = 3, top = 5, bottom = 3 }
	}
	return frameBackdrop  
end

-------------------------------------------------------------------------------------------------------------
-- ToolTip.
-------------------------------------------------------------------------------------------------------------


local function onControlEnter(widget, event, value)
	GameTooltip:ClearLines()
	GameTooltip:SetOwner(widget.frame, "ANCHOR_TOP")
	GameTooltip:AddLine(widget.text and widget.text:GetText() or widget.label:GetText())
	GameTooltip:AddLine(widget:GetUserData("tooltip"), 1, 1, 1, 1)
	GameTooltip:Show()
end

local function onControlLeave() GameTooltip:Hide() end

-------------------------------------------------------------------------------------------------------------
-- Button.
-------------------------------------------------------------------------------------------------------------

function EMAHelperSettings:GetButtonHeight()
	-- Defined as 24 in the AceGUI Button Widget .
	return 24
end

function EMAHelperSettings:CreateButton( settingsControl, width, left, top, text, buttonCallback, toolTip )
	local button = AceGUI:Create( "Button" )
	button:SetText( text )
	settingsControl.widgetSettings:AddChild( button )
	button:SetWidth( width )
	button:SetPoint( "TOPLEFT", settingsControl.widgetSettings.content, "TOPLEFT", left, top )
	button:SetCallback( "OnClick", buttonCallback )	
	--button:SetUserData("key", "keyword") -- needed/??
	button:SetUserData("tooltip", toolTip)
	button:SetCallback("OnEnter", onControlEnter)
	button:SetCallback("OnLeave", onControlLeave)		
	return button
end

-------------------------------------------------------------------------------------------------------------
-- Icon.
-------------------------------------------------------------------------------------------------------------


function EMAHelperSettings:Icon( settingsControl, sizeW, sizeH, image, left, top, text, buttonCallback, toolTip )
	local icon = AceGUI:Create( "Icon" )
	icon:SetLabel( text )
	icon:SetImage ( image )
	icon:SetImageSize( sizeW, sizeH )
	settingsControl.widgetSettings:AddChild( icon )
	icon:SetPoint( "TOPLEFT", settingsControl.widgetSettings.content, "TOPLEFT", left, top )
	icon:SetCallback( "OnClick", buttonCallback )	
	icon:SetUserData("tooltip", toolTip)
	icon:SetCallback("OnEnter", onControlEnter)
	icon:SetCallback("OnLeave", onControlLeave)		
	return icon
end

-------------------------------------------------------------------------------------------------------------
-- CheckBox.
-------------------------------------------------------------------------------------------------------------

function EMAHelperSettings:GetCheckBoxHeight()
	-- Defined as 24 in the AceGUI CheckBox Widget.
	return 24
end

function EMAHelperSettings:GetRadioBoxHeight()
	-- Defined as 16 in the AceGUI CheckBox Widget (added 4 pixels for spacing).
	return 20
end

function EMAHelperSettings:CreateCheckBox( settingsControl, width, left, top, text, checkBoxCallback, toolTip )
	local button = AceGUI:Create( "CheckBox" )
	button:SetLabel( text )
	settingsControl.widgetSettings:AddChild( button )
	button:SetWidth( width )
	button:SetPoint( "TOPLEFT", settingsControl.widgetSettings.content, "TOPLEFT", left, top )
	button:SetCallback( "OnValueChanged", checkBoxCallback )
	button:SetUserData("tooltip", toolTip)
	button:SetCallback("OnEnter", onControlEnter)
	button:SetCallback("OnLeave", onControlLeave)
	return button
end

-------------------------------------------------------------------------------------------------------------
-- EditBox.
-------------------------------------------------------------------------------------------------------------

function EMAHelperSettings:GetEditBoxHeight()
	-- Defined as 44 (with label) in the AceGUI EditBox Widget.
	return 44
end

function EMAHelperSettings:CreateEditBox( settingsControl, width, left, top, text, toolTip )
	local editBox = AceGUI:Create( "EditBox" )
	editBox:SetLabel( text )
	settingsControl.widgetSettings:AddChild( editBox )
	editBox:SetWidth( width )
	editBox:SetPoint( "TOPLEFT", settingsControl.widgetSettings.content, "TOPLEFT", left, top )
	editBox:SetUserData("tooltip", toolTip)
	editBox:SetCallback("OnEnter", onControlEnter)
	editBox:SetCallback("OnLeave", onControlLeave)
	return editBox
end

-------------------------------------------------------------------------------------------------------------
-- Multi EditBox.
-------------------------------------------------------------------------------------------------------------

function EMAHelperSettings:CreateMultiEditBox( settingsControl, width, left, top, text, lines, toolTip )
	local editBox = AceGUI:Create( "MultiLineEditBox" )
	editBox:SetLabel( text )
	settingsControl.widgetSettings:AddChild( editBox )
	editBox:SetWidth( width )
	editBox:SetPoint( "TOPLEFT", settingsControl.widgetSettings.content, "TOPLEFT", left, top )
	editBox:SetNumLines( lines )
	editBox:SetUserData("tooltip", toolTip)
	editBox:SetCallback("OnEnter", onControlEnter)
	editBox:SetCallback("OnLeave", onControlLeave)
	return editBox
end

-------------------------------------------------------------------------------------------------------------
-- Keybinding.
-------------------------------------------------------------------------------------------------------------

function EMAHelperSettings:GetKeyBindingHeight()
	-- Defined as 44 (with label) in the AceGUI Keybinding Widget.
	return 44
end

function EMAHelperSettings:CreateKeyBinding( settingsControl, width, left, top, text )
	local keyBinding = AceGUI:Create( "EMAKeybinding" )
	keyBinding:SetLabel( text )
	settingsControl.widgetSettings:AddChild( keyBinding )
	keyBinding:SetWidth( width )
	keyBinding:SetPoint( "TOPLEFT", settingsControl.widgetSettings.content, "TOPLEFT", left, top )
	return keyBinding
end

-------------------------------------------------------------------------------------------------------------
-- Dropdown.
-------------------------------------------------------------------------------------------------------------

function EMAHelperSettings:GetDropdownHeight()
	-- Defined as 44 (with label) in the AceGUI Dropdown Widget.
	return 44
end

function EMAHelperSettings:CreateDropdown( settingsControl, width, left, top, text )
	local dropdown = AceGUI:Create( "Dropdown" )
	dropdown:ClearAllPoints()
	dropdown:SetLabel( text )
	settingsControl.widgetSettings:AddChild( dropdown )
	dropdown:SetWidth( width )
	dropdown:SetPoint( "TOPLEFT", settingsControl.widgetSettings.content, "TOPLEFT", left, top )
	return dropdown
end

-------------------------------------------------------------------------------------------------------------
-- Icon.
-------------------------------------------------------------------------------------------------------------

function EMAHelperSettings:GetIconHeight()
	return 32
end


function EMAHelperSettings:CreateIcon( settingsControl, width, left, top, iconName )
	--print("testGUI", text, icon, iconSize )
	local icon = AceGUI:Create( "Label" )
	icon:SetImage( iconName )
	icon:SetImageSize( 32, 32 )
	settingsControl.widgetSettings:AddChild( icon )
	icon:SetWidth( width )
	icon:SetPoint( "TOPLEFT", settingsControl.widgetSettings.content, "TOPLEFT", left, top )
	return icon
end

-------------------------------------------------------------------------------------------------------------
-- FreeLabel.
-------------------------------------------------------------------------------------------------------------

function EMAHelperSettings:CreateFreeLabel( settingsControl, width, left, top, text )
	local label = AceGUI:Create( "Label" )
	label:SetText( text )
	settingsControl.widgetSettings:AddChild( label )
	label:SetWidth( width )
	label:SetPoint( "TOPLEFT", settingsControl.widgetSettings.content, "TOPLEFT", left, top )
	return label
end

-------------------------------------------------------------------------------------------------------------
-- NormalLabel.
-------------------------------------------------------------------------------------------------------------

function EMAHelperSettings:GetLabelHeight()
	-- Defined as 24 in the AceGUI EMA NormalLabel Widget.
	return 24
end

function EMAHelperSettings:CreateLabel( settingsControl, width, left, top, text )
	local label = AceGUI:Create( "EMANormalLabel" )
	label:SetText( text )
	settingsControl.widgetSettings:AddChild( label )
	label:SetWidth( width )
	label:SetPoint( "TOPLEFT", settingsControl.widgetSettings.content, "TOPLEFT", left, top )
	return label
end


-------------------------------------------------------------------------------------------------------------
-- Label continue.
-------------------------------------------------------------------------------------------------------------

function EMAHelperSettings:GetContinueLabelHeight()
	-- Defined as 14 in the AceGUI EMA ContinueLabel Widget.
	return 14
end

function EMAHelperSettings:CreateContinueLabel( settingsControl, width, left, top, text )
	local label = AceGUI:Create( "EMAContinueLabel" )
	label:SetText( text )
	settingsControl.widgetSettings:AddChild( label )
	label:SetWidth( width )
	label:SetPoint( "TOPLEFT", settingsControl.widgetSettings.content, "TOPLEFT", left, top )
	return label
end

-------------------------------------------------------------------------------------------------------------
-- Slider.
-------------------------------------------------------------------------------------------------------------

function EMAHelperSettings:GetSliderHeight()
	return 45
end

function EMAHelperSettings:CreateSlider( settingsControl, width, left, top, text )
	local slider = AceGUI:Create( "Slider" )
	slider:SetLabel( text )
	settingsControl.widgetSettings:AddChild( slider )
	slider:SetWidth( width )
	slider:SetPoint( "TOPLEFT", settingsControl.widgetSettings.content, "TOPLEFT", left, top )
	slider:SetSliderValues( 0, 100, 1 )
	slider:SetValue( 0 )
	return slider
end

-------------------------------------------------------------------------------------------------------------
-- Colour pickers.
-------------------------------------------------------------------------------------------------------------

function EMAHelperSettings:GetColourPickerHeight()
	return 25
end

function EMAHelperSettings:CreateColourPicker( settingsControl, width, left, top, text )
	local picker = AceGUI:Create( "ColorPicker" )
	picker:SetLabel( text )
	settingsControl.widgetSettings:AddChild( picker )
	picker:SetWidth( width )
	picker:SetPoint( "TOPLEFT", settingsControl.widgetSettings.content, "TOPLEFT", left, top )
	return picker
end

-------------------------------------------------------------------------------------------------------------
-- Media.
-------------------------------------------------------------------------------------------------------------

function EMAHelperSettings:GetMediaHeight()
	return 45
end

-------------------------------------------------------------------------------------------------------------
-- Media Status Bar.
-------------------------------------------------------------------------------------------------------------

function EMAHelperSettings:CreateMediaStatus( settingsControl, width, left, top, text )
	local media = AceGUI:Create( "LSM30_Statusbar" )
	media:SetLabel( text )
	media:SetWidth( width )
	media:SetPoint( "TOPLEFT", settingsControl.widgetSettings.content, "TOPLEFT", left, top )
	media:SetList()
	settingsControl.widgetSettings:AddChild( media )
	return media
end

-------------------------------------------------------------------------------------------------------------
-- Media Border.
-------------------------------------------------------------------------------------------------------------

function EMAHelperSettings:CreateMediaBorder( settingsControl, width, left, top, text )
	local media = AceGUI:Create( "LSM30_Border" )
	media:SetLabel( text )
	media:SetWidth( width )
	media:SetPoint( "TOPLEFT", settingsControl.widgetSettings.content, "TOPLEFT", left, top )
	media:SetList()
	settingsControl.widgetSettings:AddChild( media )
	return media
end

-------------------------------------------------------------------------------------------------------------
-- Media Background.
-------------------------------------------------------------------------------------------------------------

function EMAHelperSettings:CreateMediaBackground( settingsControl, width, left, top, text )
	local media = AceGUI:Create( "LSM30_Background" )
	media:SetLabel( text )
	media:SetWidth( width )
	media:SetPoint( "TOPLEFT", settingsControl.widgetSettings.content, "TOPLEFT", left, top )
	media:SetList()
	settingsControl.widgetSettings:AddChild( media )
	return media
end

-------------------------------------------------------------------------------------------------------------
-- Media Font.
-------------------------------------------------------------------------------------------------------------

function EMAHelperSettings:CreateMediaFont( settingsControl, width, left, top, text )
	local media = AceGUI:Create( "LSM30_Font" )
	media:SetLabel( text )
	media:SetWidth( width )
	media:SetPoint( "TOPLEFT", settingsControl.widgetSettings.content, "TOPLEFT", left, top )
	media:SetList()
	settingsControl.widgetSettings:AddChild( media )
	return media
end

-------------------------------------------------------------------------------------------------------------
-- Media Sound.
-------------------------------------------------------------------------------------------------------------

function EMAHelperSettings:CreateMediaSound( settingsControl, width, left, top, text )
	local media = AceGUI:Create( "LSM30_Sound" )
	media:SetLabel( text )
	media:SetWidth( width )
	media:SetPoint( "TOPLEFT", settingsControl.widgetSettings.content , "TOPLEFT", left, top )
	media:SetList()
	settingsControl.widgetSettings:AddChild( media )
	return media
end

-------------------------------------------------------------------------------------------------------------
-- FauxScrollFrame.
-------------------------------------------------------------------------------------------------------------

--
-- List Structure
--
-- Required to be passed into the function.
--
-- list.listFrameName - String (name of list frame)
-- list.parentFrame - Frame (parent frame for the list)
-- list.listTop - Number (top location in parent frame) 
-- list.listLeft - Number (left location in parent frame)
-- list.listWidth - Number (width of list) 
-- list.rowHeight - Number (height of row)
-- list.rowsToDisplay - Number (number of rows to display)
-- list.columnsToDisplay - Number (number of columns to display)
-- list.columnInformation - Table (table of columns information)
-- list.columnInformation[x]- Table (table of column information)
-- list.columnInformation[x].width - Number[0,100] (percentage of width to use for this column)
-- list.columnInformation[x].alignment - String (column text alignment string: "LEFT", "CENTER" or "RIGHT")
-- list.scrollRefreshCallback - Function (called when the list is scrolled, no parameters)
-- list.rowClickCallback - Function (called when a column in a row is clicked, parameters: self, rowNumber, columnNumber)
--
-- Created by the function.
--
-- list.listFrame - Frame (list frame holder)
-- list.listScrollFrame - Frame (list frame holder)
-- list.listHeight - Number (height of list - decided by number of display rows * height of each row)
-- list.rows - Table
-- list.rows[x] - Frame (row frame)
-- list.rows[x].highlight - Texture (row frame texture for highlight)
-- list.rows[x].columns - Table
-- list.rows[x].columns[y] - Frame (column frame)
-- list.rows[x].columns[y].rowNumber - Number (the row number of this row)
-- list.rows[x].columns[y].columnNumber - Number (the column number of this column)
-- list.rows[x].columns[y].textString - FontString (where text for column goes)
--

function EMAHelperSettings:CreateScrollList( list )
	-- Position and size constants.
	local columnSpacing = 6
	local widthOfScrollBar = 16
	local rowVerticalSpacing = 3
	local rowWidth = list.listWidth - ( columnSpacing * 2 ) - widthOfScrollBar
	list.listHeight = list.rowsToDisplay * list.rowHeight + ( rowVerticalSpacing * 2 )
	-- Create the holder frame.
	list.listFrame = CreateFrame( "Frame", list.listFrameName, list.parentFrame, BackdropTemplateMixin and "BackdropTemplate" or nil )
	list.listFrame:SetBackdrop( self:CreateBackdrop() )
	list.listFrame:SetBackdropColor( 0.1, 0.1, 0.1, 0.5 )
	list.listFrame:SetBackdropBorderColor( 0.4, 0.4, 0.4 )
	list.listFrame:SetPoint( "TOPLEFT", list.parentFrame, "TOPLEFT", list.listLeft, list.listTop )
	list.listFrame:SetWidth( list.listWidth )
	list.listFrame:SetHeight( list.listHeight )
	-- Create the scroll frame.
	list.listScrollFrame = CreateFrame(
		"ScrollFrame", 
		list.listFrame:GetName().."ScrollFrame", 
		list.listFrame, 
		"FauxScrollFrameTemplate"
	)
	list.listScrollFrame:SetPoint( "TOPLEFT", list.listFrame, "TOPLEFT", 0, -4 )
	list.listScrollFrame:SetPoint( "BOTTOMRIGHT", list.listFrame, "BOTTOMRIGHT", -26, 3 )
	list.listScrollFrame:SetScript( "OnVerticalScroll", 
		function( self, offset )
			FauxScrollFrame_OnVerticalScroll( 
				self, 
				offset, 
				list.rowHeight, 
				list.scrollRefreshCallback )			
		end 
	)
	-- Create frames for scroll table rows and columns.
	list.rows = {}
	for iterateDisplayRows = 1, list.rowsToDisplay do 
		local displayRow = CreateFrame( 
			"Frame",
			list.listFrame:GetName().."Row"..iterateDisplayRows, 
			list.listFrame	
		)
		displayRow:SetWidth( rowWidth )
		displayRow:SetHeight( list.rowHeight )
		displayRow:SetPoint( 
			"TOPLEFT", 
			list.listFrame, 
			"TOPLEFT", 
			columnSpacing, 
			( -1 * rowVerticalSpacing ) - ( list.rowHeight * ( iterateDisplayRows - 1 ) )
		)
		displayRow.highlight = displayRow:CreateTexture( nil, "OVERLAY" )
		displayRow.highlight:SetAllPoints( displayRow )
		list.rows[iterateDisplayRows] = displayRow		
		displayRow.columns = {}
		local columnPosition = 0
		for iterateDisplayColumns = 1, list.columnsToDisplay do
			local displayColumn = CreateFrame(
				"Button",
				displayRow:GetName().."Column"..iterateDisplayColumns, 
				displayRow,
				"SecureActionButtonTemplate"
			)
			if InCombatLockdown() == true then
				return
			end	
			
			displayColumn.rowNumber = iterateDisplayRows
			displayColumn.columnNumber = iterateDisplayColumns
			displayColumn.textString = displayRow:CreateFontString( 
				displayColumn:GetName().."Text", 
				"OVERLAY", 
				"GameFontHighlight" 
			)
			local columnWidth = ( list.columnInformation[iterateDisplayColumns].width / 100 ) * 
				( rowWidth - ( columnSpacing * ( list.columnsToDisplay - 1 ) ) )
			displayColumn:SetPoint( "TOPLEFT", displayRow, "TOPLEFT", columnPosition, 0 )
			displayColumn:SetWidth( columnWidth )
			displayColumn:SetHeight( list.rowHeight )				
			if InCombatLockdown() == false then
				displayColumn:EnableMouse( true )
				displayColumn:RegisterForClicks( "AnyUp" )	
			end
			displayColumn:SetScript( "PostClick", 
				function( self, button )
					if button == "LeftButton" then
						list.rowClickCallback( self, displayColumn.rowNumber, displayColumn.columnNumber )
					end
					if button == "RightButton" then
						if list.rowRightClickCallback ~= nil then
							list.rowRightClickCallback( displayColumn.rowNumber, displayColumn.columnNumber )
						end
					end
				end 
			)
			displayColumn:SetScript("OnEnter",
				function(self)
					if list.rowMouseOverCallBack_OnEnter ~= nil then
						list.rowMouseOverCallBack_OnEnter( displayColumn.rowNumber, displayColumn.columnNumber )
					end
				end 
			)	
			displayColumn:SetScript("OnLeave", 
				function(self)
					if list.rowMouseOverCallBack_OnLeave ~= nil then
						list.rowMouseOverCallBack_OnLeave( displayColumn.rowNumber, displayColumn.columnNumber ) 
					end
				end 
			)
			displayColumn.textString:SetJustifyH( list.columnInformation[iterateDisplayColumns].alignment )
			displayColumn.textString:SetAllPoints( displayColumn )
			displayRow.columns[iterateDisplayColumns] = displayColumn
			columnPosition = columnPosition + columnWidth + columnSpacing
		end
	end
end
	
function EMAHelperSettings:SetFauxScrollFramePosition( scrollFrame, position, maxPosition, rowHeight )
	FauxScrollFrame_SetOffset( scrollFrame, position )
	local scrollBar = getglobal( scrollFrame:GetName().."ScrollBar" )
	if scrollBar ~= nil then
		local minScroll, maxScroll = scrollBar:GetMinMaxValues()
		scrollBar:SetValue( minScroll + ( ( maxScroll - minScroll + (2 * rowHeight) ) * position / maxPosition ) )
	end
end
