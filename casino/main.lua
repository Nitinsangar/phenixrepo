--[[
	Casino Manager
	
	Author: Keller  aka "Jak the Coder"
	
	This is set up so a main process thread is constantly in listener mode so long as the tables are open.
	Individual players will have separate process threads spawned for their play which will be responsible
		for the actual functioning of each player's interaction with each table.
]]

declare ("casino", {})
casino.version = "1.2.3"
dofile ("data/data.lua")
dofile ("games/games.lua")
if not messaging then
	dofile ("messaging.lua")
end
dofile ("util.lua")
dofile ("ui/ui.lua")
dofile ("debug.lua")

function casino:Help ()
	purchaseprint (string.format ("Casino v %s", casino.version))
	purchaseprint ("Commands\n")
	purchaseprint ("\tadd_game <playerName> <gameName> - Add a game for a given player to the open tables list")
	purchaseprint ("\tremove_game <playerName> - Removes a game for the given player")
	purchaseprint ("\topen_account <playerName> <amt> - Open a bank account for a player")
	purchaseprint ("\tclose_account <playerName> - Closes a player's account (without cashout)")
	purchaseprint ("\tban <playerName> - Bans a player from playing in the casino")
	purchaseprint ("\tunban <playerName> - Removes a player fromt the ban list")
	purchaseprint ("\tbank - Displays all existing bank accounts")
	purchaseprint ("\tgames - Displays all currently running games")
	purchaseprint ("\treservations - Displays all players on the waiting list")
	purchaseprint ("\tstats - Displays win/loss record for all games and money bet vs paidout by bank")
	purchaseprint ("\tstatus - Displays all bank account, open game, and wait list information, plus the house thread status")
	purchaseprint ("\treset - Resets the randomization of the casino")
	purchaseprint ("\thelp - Prints this list")
	purchaseprint ("\tbackup - Backs up all bank account information")
	purchaseprint ("\tstart [true/false] - Starts up the Casino (if passing true/false determines debug mode)")
	purchaseprint ("\tstop - Shuts down the Casino")
	purchaseprint ("\toptions - Brings up the admin screen")
end

function casino:OpenSettings ()
	local frame = casino.ui:CreateSettingsUI ()
	ShowDialog (frame, iup.CENTER, iup.CENTER)
	frame.active = "YES"
end

local debugMode = false
function casino:OpenTables (args)
	if not casino.data.tablesOpen then
		debugMode = (args [2] == "true")
		casino:Reset ()
		casino:Print ("Casino is Open")
		if not casino.data.houseThread or coroutine.status (casino.data.houseThread) == "dead" then
			-- Create house thread
			casino.data.houseThread = coroutine.create (casino.RunPlayerProcesses)
		end
		
		-- Start plotter thread
		if debugMode then
			RegisterEvent (casino.data.debug, "CHAT_MSG_GROUP")
		else
			RegisterEvent (casino.data, "CHAT_MSG_PRIVATE")
		end
		casino.bank:Open (casino)
		if casino.data.contactPlayers then
			RegisterEvent (casino.data.com, "PLAYER_ENTERED_SECTOR")
			casino.data.contactActive = true
		end
		casino.data.tablesOpen = true
		if coroutine.status (casino.data.houseThread) == "suspended" then
			messaging:Start (casino)
			casino:RunThreads ()
			casino:RunBackup ()
			if casino.data.useAnnouncements then
				casino:RunAnnouncements ()
			end
			
			casino.data.wins = 0
			casino.data.losses = 0
			casino.data.totalBet = 0
			casino.data.totalPaidout = 0
			casino.bank.assets = casino.bank:GetTotalAssets ()
			
			-- Make announcement that the casino is open.  Give casino sector
			if not debugMode then
				SendChat (string.format ("The %s is Open in %s!", casino.data.name, LocationStr (GetCurrentSectorid ())), "CHANNEL", 100)
			end
		end
	end
end

function casino:CloseTables ()
	-- Make announcement that the casino is closed
	if casino.data.tablesOpen then
		casino.data.tablesOpen = false
		messaging:Stop (casino)
		if not debugMode then
			SendChat (string.format ("The %s is Closed!", casino.data.name), "CHANNEL", 100)
		end
		
		if casino.data.contactActive then
			UnregisterEvent (casino.data.com, "PLAYER_ENTERED_SECTOR")
		end
		casino.bank:Close (casino)
		if debugMode then
			UnregisterEvent (casino.data.debug, "CHAT_MSG_GROUP")
		else
			UnregisterEvent (casino.data, "CHAT_MSG_PRIVATE")
		end
		debugMode = false
	end
end

casino.arguments = {
	add_game = casino.AddGame,
	remove_game = casino.RemoveGame,
	open_account = casino.AddAccount,
	close_account = casino.RemoveAccount,
	ban = casino.BanPlayer,
	unban = casino.UnbanPlayer,
	bank = casino.DisplayAccounts,
	games = casino.DisplayGames,
	reservations = casino.DisplayWaitQueue,
	stats = casino.DisplayGameStats,
	status = casino.Status,
	reset = casino.Reset,
	help = casino.Help,
	backup = casino.data.SaveAccountInfo,
	options = casino.OpenSettings,
	start = casino.OpenTables,
	stop = casino.CloseTables
}
function casino.Start (obj, args)
	if args then
		local f = casino.arguments [args [1]:lower ()] or casino.Help
		f (casino, args)
	else
		casino:Help ()
	end
end
RegisterUserCommand ("casino", casino.Start)
