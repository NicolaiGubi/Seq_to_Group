--[[
Made by

      ::::::::  :::    ::: ::::::::: ::::::::::: 
    :+:    :+: :+:    :+: :+:    :+:    :+:      
   +:+        +:+    +:+ +:+    +:+    +:+       
  :#:        +#+    +:+ +#++:++#+     +#+        
 +#+   +#+# +#+    +#+ +#+    +#+    +#+         
#+#    #+# #+#    #+# #+#    #+#    #+#          
########   ########  ######### ###########       

nicolaigubi@gmail.com


        INFO:
        This plugin creates a sequence with a range of groups.
        You are asked for the beginning group number and the ending group.
        You are also asked for a name to the sequence.
        You'll get a sequence with cues that have matching cue numbers and 
        labels as you source groups.
        
        WARNING:
        If you give the sequence a name of an exixting sequence then all 
        existing cues WILL BE LOST!!
        Your BlindEdit programmer will be cleared!!
--]]

cmd = gma.cmd
feedback = gma.feedback
getvar = gma.show.getvar
getobj = gma.show.getobj
progress = gma.gui.progress
confirm = gma.gui.confirm
sleep = gma.sleep
input = gma.textinput
int = math.tointeger

--***********************************************************
-- Get the User input and if valid run the store group loop 
--***********************************************************
function GetUserInput()
-- Asks if the user want to run the plugin. If yes then it continues else it terminates.
	if confirm('!! Please confirm !!','Plugin might overwrite existing groups + clear Preview Programmer - continue?') then

-- Ask user for sequence number. If it has been typed before, then use previous input
		if getvar('LuaStG_SeqNum') then
			seq_number = input('What is the sequence number?',getvar('LuaStG_SeqNum'))
		else
			seq_number = input('What is the sequence number?','Enter Sequence number')
		end

-- Ask user for the first group number. If it has been typed before, then use previous input
		if getvar('LuaStG_FirstGroup') then
			first_group = input('What is the first group number?',getvar('LuaStG_FirstGroup'))
		else
			first_group = input('What is the first group number?','Enter Group number')
		end

-- Test the input is strings and exist
		if type(seq_number) == 'string' and type(first_group) == 'string' then
			cmd('setvar $LuaStG_SeqNum = '..int(seq_number))         	-- Stores the sequence number in a show variable
			cmd('setvar $LuaStG_FirstGroup = '..int(first_group))  		-- Stores the first group number in a show variable

			--Creates the sequence handle and test if sequence exists
			seq_handle = getobj.handle('sequence '..seq_number)
			if seq_handle then 
				StoreGroup() --Runs the store group loop
			else
				if confirm('!! PLUGIN ERROR !!','Your input was not correct - Try again?') then --Sequence doesn't exist, ask if try again
					GetUserInput() --User tries again
				else
					Cleanup() --User aborts
				end
			end
		else

		--The user input isn't strings - end plugin
			if confirm('!! PLUGIN ERROR !!','Your input was not correct - Try again?') then --Input isn't correct, ask if try again
				GetUserInput() --User tries again
			else
				Cleanup() --User aborts
			end
		end
	else
		Cleanup() --User didn't want to run plugin
	end
end

--***********************************************************
-- Get the Cue label/name
--***********************************************************
function GetCueName(n)
  local cue = getobj.child(seq_handle,n)    --Creates handle for current cue
    if getobj.label(cue) then      			--Tests if cue has label 
      cue_name = getobj.label(cue)      	--Stores label string
    else
      cue_name = getobj.name(cue)       	--Store name string
    end
end

--***********************************************************
-- Progress bar
--***********************************************************
function ProgressRun(n)
   if(n==1) then                                			--Check if first time 
      progress_bar = progress.start('Step number')         	--Create the progress bar
      progress.setrange(progress_bar,1,last_cue)            --Creates the range of the bar
      progress.settext(progress_bar,'Sequence To Groups')  	--Sets a text
    elseif(n==last_cue) then                          		--Last run
      progress.stop(progress_bar)                          	--Ends the progress bar
   else
      progress.set(progress_bar,n);                        	--Not first and not last; Sets a progress value
   end
end

--***********************************************************
-- The looping store group function
--***********************************************************
function StoreGroup ()
	last_cue = getobj.amount(seq_handle) - 1      							--Gets and save the amount of cues
	first_cue = 1
	cue_counter = 1
	for cue_counter = first_cue, last_cue, 1 do       						--Store loop
		ProgressRun(cue_counter)           									--Runs the progress bar function
		GetCueName(cue_counter)            									--Gets the current cue label/name
		cue_number = getobj.number(getobj.child(seq_handle,cue_counter)) 	--Gets the cue number for the current cue
    
		cmd('Preview Sequence '..seq_number..' Cue '..cue_number)     		--Previews the current cue
		sleep(0.02)                                       					--Gives the console a little time
		cmd('ClearAll')                                 					--Clears preview programmer
		cmd('Ifoutput')                                 					--Selects fixtures with output
		sleep(0.02)                                       					--Gives the console a little time	
		cmd('Store group '..int(first_group)..' "'..cue_name..'" /o /nc')	--Stores the group
		sleep(0.02)                                       					--Gives the console a little time
		cmd('ClearAll')                                 					--Clears preview programmer
		cmd('PreviewEdit Off')                          					--Exits preview
		first_group = first_group + 1                                   	--Advances the group number
    
	end
end

--***********************************************************
-- CleanUp function
--***********************************************************
function Cleanup()
     gma.echo("Cleanup called") 	--Give a feedback in system monitor that plugin has ended
     progress.stop(progress_bar)    --Stops the progress bar if running
end


return GetUserInput, Cleanup
