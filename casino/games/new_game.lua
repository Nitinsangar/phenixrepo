--[[
	New Game Template
	
	Use this template to create additional games
]]
casino.games.newgame = {}
casino.games.newgame.version = "0.1"
-- Uncomment these to install
--casino.games.newgame.name = "My New Game"
--casino.games.newgame.isPlayable = true

-- Define game controller.  Any defined functions which are not used may be removed
-- e.g. Close is defined in the generic game controller, it may be removed if not needed

function casino.games.newgame.GetController (game, config, simulator)
	local mygame = casino.games:BaseController  (game, config, simulator)
	
	-- Use this property for a "Hello" type message to the player
	mygame.startup = "Welcome to My Game!  Remember, I'm watching, so don't cheat.  Have fun!"
	
	-- Use the canPlay property to determine if the game will accept bets before allowing play
	--mygame.canPlay = true 			-- would allow play immediately.  No bets would be allowed.  Any bets are automatic
	--mygame.canPlay = false			-- would require bets to be made before play is allowed
	-- If allowing bets, make sure to set canPlay back to false when play is completed
	
	-- Use this function to send basic help about the game interface back to the user
	function mygame:Help ()
		mygame:SendMessage ("Just send !casino play to play")
	end
	
	-- Override this function to approve of a bet
	-- Add any additional checks you want.  If the basic checks are sufficient, this function can be deleted
	function mygame:IsValidBet (amt)
		if amt == 0 then
			return false, "You must bet something to play!"
			
		elseif game.acct.balance < amt then
			return false, "You cannot bet more money than you have!"
			
		else
			return true, ""
		end
	end
	
	-- Used for processing any commands outside the basic command set (i.e. bet, play, and quit/leave)
	-- May set state variables for use by play
	function mygame:ParseKey (key, args)
	end
	
	-- This is the basic game function
	-- Runs the game for the player and changes any state variables being used by the game
	function mygame:Play (req)
	end
	
	-- Used to clean up any resources used by the game before being removed by the casino server
	function mygame:Close ()
	end
	
	return mygame
end

-- Use this functino to build a GUI to admin the game
function casino.games.newgame.CreateConfigUI (game, simulateButton)
	
	-- Set up the UI content for the config screen.  All controls except the simulate button are already
	-- injected by the basic screen
	local ui = iup.vbox {
		iup.label {title = game.name .. " v" .. game.version, font=casino.ui.font},
		iup.fill {size = 15},
		iup.hbox {
			iup.label {title = "Nothing to Configure", font=casino.ui.font},
			iup.fill {};
			expand = "YES"
		},
		iup.fill {size = 5},
		iup.fill {},
		iup.hbox {
			iup.fill {},
			saveButton,
			cancelButton; };
	}
	
	-- Use this function to build a simulation to run in order to test game settings
	function ui:DoSimulation ()
		-- Set up test
		local simulator = casino.games:CreateSimulator ("test", 0, {
			-- put any game specific properties in here
		})
		-- Build any additional functions onto the resulting simulator object
		-- Use the config object to set custom configurations in your game
		local config = {}
		local simulation = casino.games:CreateGame ("mygame", "test", config, simulator)
		
		-- Run your test by calling the various functions on the simulator as you would in a real game
		-- e.g. simulation.controller.ProcessRequest ("bet 3")
		-- or simulations.controller.ProcessRequest ("play")
		--
		-- Create a message result from the simulations and output to an information dialog
		-- e.g. local msg = "Just a Result"
		-- casino.ui:CreateInfoUI ("My Test", msg)
	end
	
	function ui:DoSave ()
	end
	
	function ui:DoCancel ()
	end
	
	return ui
end

-- If exists, returns any game data to be saved in the plugin configuration
function casino.games.newgame:GetGameData ()
end

function casino.games.newgame:SetGameData (data)
end