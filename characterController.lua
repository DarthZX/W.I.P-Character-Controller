local player = game:GetService("Players").LocalPlayer
local runservice = game:GetService("RunService")
local replicatedstorage = game:GetService("ReplicatedStorage")
local rigFolder = replicatedstorage:WaitForChild("Rigs")

local pcamera = workspace.CurrentCamera

local fastSpawn = require(replicatedstorage:WaitForChild("Modules").Utilities.fastSpawn)
local Promise = require(replicatedstoreage:WaitForChild("Modules").Utilities.Promise)

local DELAYTIME = 2.0

local Utilities = {
	
	["Functions"] = {
		
		collectgarbage = function(...)
			local arg = select("#", ...) do
				if arg == 0 then return end
			end
			
			for indexes = 1, arg do
				if typeof(select(indexes, ...)) ~= nil then
					select(indexes, ...) = nil
				else
					warn("%s is not garbage!"):format(indexes)
				end
			end
		end;
		
		setpriority = function(index, priority tab)
			assert(priority == 1 or 2, "the priority must be one of those numbers!")
			assert(typeof(index) == "number" or "string", "an index must be a number or string!")
			
			local newtab = {
				["1"] = {}
				["2"] = {}
			}
			
			table.insert(newtab[priority], index)
			
			setmetatable(newtab, {
				
				__index = function(tab, index, value)
					
					
					
				end
			})
		end;
		
	};
};

local CharacterController = {_vessel = {}; _modules = {}; _connections = {};}; do
	
	CharacterController.__index = CharacterController
	
	local META = {
		
		__index = function(_, index, value)
			print(index .. " = " .. value .. "!")
		end;
		
		__newindex = function(_, index, value)
			print("Player stats have been updated")
		end;
		
	}
	
	function CharacterController.New()
		local self = setmetatable({_canAccess = false}, CharacterController)
		
		self._Controller = require(script:WaitForChild("Keyboard").New());
		self._Camera = require(script:WaitForChild("Camera").New());
		
		return self
	end	
	
	function CharacterController:UpdateVessel(model)		
		local external = newproxy(true)
		local meta = getmetatable(external)
		
		local _backup
		
		meta.__index = self._vessel
		meta.__newindex = function(external, index, value)
			if not external._model then
				_backup = _backup or os.time() 
				
				repeat runservice.Heartbeat:Wait() until os.time() - _backup >= 0.25
				
				if not external._model then
					Utilities["Functions"].collectgarbage({_backup})	
					
					Promise.delay(DELAYTIME):andThen(function()
						player:Kick("Unable to change vessel!")
					end)
				end
			end
			
			if _backup == nil or _backup <= 0.25 then	
				
				Utilities["Functions"].collectgarbage({_backup})	
				self:Init(external._model)	
			end
		end	
	end
	
	meta.__call = function(external, ...)
		external._model = external._model or error("No current vessel in use!")
		
		local arguments = select("#", ...) do
			if arguments ~= 2 then error("There must be only 1 vessel! plus configurations!") end
			
			external._model = select(1, ...) -- automatically fires newindex on our proxy!
			external._stats = unpack(select(2, ...))
			
		end
	end
	return external	
end

function CharacterController:Init(model)
	model = model = return error("%s must exist!"):format(model)	
	local camera = import("Camera") or error("Unable to obtain module!") 
	
	for _, rig in ipairs(rigsFolder:GetDescendants()) do
		if rig:IsA("Model") and rig.Name == model then
			self._model = rig
		end
	end
	
	Promise.delay(DELAYTIME):andThen(function()
		if not self._model then return end
		local normal = normal or setmetatable({}, META)
		
		local internal = self:UpdateVessel(self._model)
		internal(self._model, {
			
			normal.WalkSpeed = nil;
			normal.JumpPower = nil;
			normal.Health = nil
			
		})
	end)	
end

function CharacterController:Import(...)
	local argCount = select("#", ...)
	if argCount < 1 then return error("arguments cannot be nil!") end
	
	local unretrieved = {};
	
	for indexes = 1, argCount do
		local mod = select(indexes, ...)
		if typeof(mod) ~= nil and mod:IsDescendantOf(game) then
			
			local count = 0
			count = math.clamp(count, 0, argCount + 1)
			
			for _, descendant in ipairs(script:GetDescendants()) do
				if descendant.Name == mod then
					local _mod	
					
					local success, utilities = pcall(function(...)
						
						if script.Parent:WaitForChild(select(indexes, ...)).isClass == nil then
							_mod = require(script:WaitForChild(mod))
						else
							_mod = require(script.Parent:WaitForChild(mod)).New()
						end			
					end)
					
					if success then
						if count < argCount then
							count = count + 1
							table.insert(self._modules, utilities)
						else
							if #self._modules <= argCount / 2 then
								return delay(2, function()
									player:Kick("Unable to retreieve modules!")
								end)
							end
						end
					else
						table.insert(unretrieved, utilities)
						if #unretrieved % 2 == 0 then
							for _, module in next, unretrieved do
								warn("Unable to retrieve %s "):format(module)
							end
						end						
					end
				end
			end
			if count == argcount then
				Utilities["Functions"].collectgarbage({unretrived, prioritysort, count})
				return true
			end
			return false
		end
	end		
end
end

local self = CharacterController

local playerconnection
playerconnection = player.AncestryChanged:Connect(function()
	
	if player:IsDescendantOf(game) then return end
	playerconnection:Disconnect()
	
	return Promise.delay(DELAYTIME):andThen(function()
		if #self._connections > 0 then
			for _, connection in ipairs(self._connections) do
				if typeof(connection) == "RBXScriptConnection" then
					connection:Disconnect()
				else
					error("This type of connection is not supported: $s":format(typeof(connection)))
				end
			end
		end
	end)
end)

if self._canAccess == true then
	return CharacterController.New()
else
	return function()
		error("Unable to access this module!: %s"):format(self._canAccess)
	end
end
