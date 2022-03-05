--------------------------------------------------------------------------------------------
print("000/addme start")
print("Console Instant Action On PC")
-----------------------

-- functionality to add strings 
if( modStringTable == nil ) then
	modStringTable = {} -- table to hold custom strings 
	
	-- function to add custom strings  
	function addModString(stringId, content)
		modStringTable[stringId] = ScriptCB_tounicode(content)
	end 

	if oldScriptCB_getlocalizestr == nil then 
		-- Overwrite 'ScriptCB_getlocalizestr()' to first check for the strings we added
		print("redefine: ScriptCB_getlocalizestr() ")

		oldScriptCB_getlocalizestr = ScriptCB_getlocalizestr
		ScriptCB_getlocalizestr = function (...)
			local stringId = " "
			if( table.getn(arg) > 0 ) then 
				stringId = arg[1]
			end
			if( modStringTable[stringId] ~= nil) then -- first check 'our' strings
				retVal = modStringTable[stringId]
			else 
				retVal = oldScriptCB_getlocalizestr( unpack(arg) )
			end 
			return retVal 
		end
	end 
end
-- Force 'IFText_fnSetString' to use strings from our 'modStringTable' too 
if ( oldIFText_fnSetString == nil )then 
    oldIFText_fnSetString = IFText_fnSetString
    IFText_fnSetString = function(...)
        if( table.getn(arg) > 1 and modStringTable[arg[2]] ~= nil ) then 
            arg[2] = modStringTable[arg[2]]
            IFText_fnSetUString(unpack(arg))
            return 
        end 
        oldIFText_fnSetString(unpack(arg))
    end 
end 

addModString("ifs.console.action","Instant Action (alt)")
-- 
-------------------------------------------------------------------------------------------
--function RedefineExpandMissionList() 

    --print("RedefineExpandMissionList: Gonna Do the files")
    ScriptCB_DoFile("missionlist_mod")
    --print("RedefineExpandMissionList: Did the Files")

    -- Expands the maplist from a bunch of modes to a flatter list.
    -- If bForMP is true, it expands the MP list. If false, it expands
    -- the SP list. 
    missionlist_ExpandMaplist = function (bForMP)
        print("missionlist_ExpandMaplist: calling re-defined version")
        if(not gSortedMaplist) then
            table.sort(sp_missionselect_listbox_contents, missionlist_mapsorthelper) 
            table.sort(mp_missionselect_listbox_contents, missionlist_mapsorthelper) 
            gSortedMaplist = 1
        end

        local i,j,k,v,Num
        local SourceList
        if(bForMP) then
            SourceList = mp_missionselect_listbox_contents
        else
            SourceList = sp_missionselect_listbox_contents
        end

        -- Blank dest list for starters
        missionselect_listbox_contents = {}

        local expand_maps_for_pc = false
        if( expand_maps_for_pc ) then
            if(gPlatformStr == "PC") then
                local FilterList = gMapModes
            Num = 1 -- where next entry in missionselect_listbox_contents will go
            for i = 1,table.getn(SourceList) do
                    for j = 1,table.getn(FilterList) do
                        local Tag = FilterList[j].key
                        if(SourceList[i][Tag]) then
                            -- Start with blank row
                            missionselect_listbox_contents[Num] = {}
                            -- Copy all items in this table row
                            for k,v in SourceList[i] do
                                missionselect_listbox_contents[Num][k] = v
                                --                  print(" Copying ", k, missionselect_listbox_contents[Num][k])
                            end
                            -- But, we want to rename it in the process, adding in the mapname
                            missionselect_listbox_contents[Num].mapluafile = 
                                string.format(SourceList[i].mapluafile, "%s", FilterList[j].subst)
                            --              print("Added luafile ", missionselect_listbox_contents[Num].mapluafile)

                            Num = Num + 1 -- move on in output list
                        end -- SourceList[i].Tag exists
                    end -- k loop over filters
            end -- i loop over input maps
                return
            end
        end

        for i = 1,table.getn(SourceList) do
            if(SourceList[i].mapluafile ~= gAllMapsStr) then
                -- Copy row
                missionselect_listbox_contents[i] = SourceList[i]
                missionselect_listbox_contents[i].bIsWildcard = nil
            end -- Mapluafile is not our magic constant
            -- for multiple selection
            missionselect_listbox_contents[i].bSelected = nil
        end -- i loop over input maps
        --print("++++bSelected clear")
        --remove "all maps" because we have "select all" button -- add it back in! -BAD_AL
        missionselect_listbox_contents[table.getn(SourceList) + 1] = { mapluafile = gAllMapsStr, bIsWildcard = 1,}

        -- TODO: alphabetize the list now?
    end
--end 
-------------------------------------------------------------------------------------------
--local original_PushScreen = ScriptCB_PushScreen
--ScriptCB_PushScreen = function(screenName)
--    if( screenName == "ifs_spacetraining") then
--        original_PushScreen("ifs_sp2_era")
--    else
--        original_PushScreen(screenName)
--    end
--end

----- Redefine the accept handler for 'ifs_sp_campaign'----
print("Plumb in the Console instant action screen (hijack 'spacetraining' button )")
-- take over the 'spacetraining' button
--print("tprint(ifs_sp_campaign):")
--tprint(ifs_sp_campaign) -- print out the screen to see which element to set the text on 
--print("ifs_sp_campaign.buttons.spacetraining.label == " ..type(ifs_sp_campaign.buttons.spacetraining.label)) -- nil if error, it's type if it exists 
IFText_fnSetString(ifs_sp_campaign.buttons.spacetraining.label, "Instant Action (ALT)")  -- set new text on spacetraining button

-- handle spacetraining button press
ifs_sp_campaign.old_Input_Accept = ifs_sp_campaign.Input_Accept
        
ifs_sp_campaign.Input_Accept = function(this)
    print("ifs_sp_campaign.Input_Accept: ".. tostring(this.CurButton))
    if(this.CurButton == "spacetraining") then
        print("Push: ifs_missionselect_console")
        ifelm_shellscreen_fnPlaySound(this.acceptSound)
        ScreenToPush = ifs_missionselect_console
        ifs_movietrans_PushScreen(ifs_missionselect_console)
    else
        ifs_sp_campaign.old_Input_Accept(this)
    end
end

ScriptCB_DoFile("ifs_missionselect_console")
-----------------------------------------------------------
print("000/addme end")