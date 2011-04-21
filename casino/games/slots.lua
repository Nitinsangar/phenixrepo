--[[
	Slots Games
]]

function casino.games:Slots (game)
	local slots = casino.games:Game (game)
	
	math.random (1, 100)
	local probabilities = {
		assigned = {5, 8, 10, 14, 15, 14, 12, 10, 7, 5},
		assumed = {}
	}
	for k=1, 10 do
		probabilities.assumed [k] = 0
		for j=1, k-1 do
			probabilities.assumed [k] = probabilities.assumed [k] + probabilities.assigned [j]
		end
	end
	
	function slots:GetSlotSymbol (distribution)
		local index = math.random (1, 100)
		local token = 0
		for j=1, 10 do
			if index > distribution [j] then
				token = token + 1
			end
		end
	
		return token
	end
	
	function slots:CheckTwoOfAKind (roll)
		local a, b, c = string.match (roll, "|(%d+)|(%d+)|(%d+)|")
		if a == b or a == c or b == c then
			return true
		else
			return false
		end
	end
	
	function slots:CheckThreeOfAKind (roll)
		local a, b, c = string.match (roll, "|(%d+)|(%d+)|(%d+)|")
		if a == b and a == c then
			return true
		else
			return false
		end
	end
	
	function slots:Play (req)
	end
	
	return slots
end
