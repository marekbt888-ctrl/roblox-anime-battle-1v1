local MatchmakingSystem = {}
local waitingPlayers = {}
local activePlayers = {}

function MatchmakingSystem:AddPlayerToQueue(player)
	if not waitingPlayers[player.UserId] then
		waitingPlayers[player.UserId] = {
			Player = player,
			JoinTime = tick(),
		}
		print(player.Name .. " joined queue. Waiting players: " .. #waitingPlayers)
		self:CheckForMatch()
	end
end

function MatchmakingSystem:RemovePlayerFromQueue(player)
	if waitingPlayers[player.UserId] then
		waitingPlayers[player.UserId] = nil
		print(player.Name .. " left queue")
	end
end

function MatchmakingSystem:CheckForMatch()
	local players = {}
	for userId, data in pairs(waitingPlayers) do
		table.insert(players, data.Player)
	end
	
	if #players >= 2 then
		local player1 = players[1]
		local player2 = players[2]
		
		waitingPlayers[player1.UserId] = nil
		waitingPlayers[player2.UserId] = nil
		
		self:StartMatch(player1, player2)
	end
end

function MatchmakingSystem:StartMatch(player1, player2)
	print("Match started: " .. player1.Name .. " vs " .. player2.Name)
	activePlayers[player1.UserId] = player2.UserId
	activePlayers[player2.UserId] = player1.UserId
	
	-- Signal to game manager to start battle
	local event = game:GetService("ReplicatedStorage"):WaitForChild("MatchStarted")
	event:FireAllClients(player1, player2)
end

function MatchmakingSystem:EndMatch(player)
	if activePlayers[player.UserId] then
		activePlayers[player.UserId] = nil
	end
end

function MatchmakingSystem:GetWaitingCount()
	local count = 0
	for _ in pairs(waitingPlayers) do count = count + 1 end
	return count
end

return MatchmakingSystem
