object. global 'FEApi' {
	AlignTypes = object {
		Align = 1, 
		CFrame = 2, 
		Weld = 3
	};
	HatManager = object {
		Player = nil;
		Character = nil;
		Hats = {};
		Aligns = {};
		FixHats = function(character)
			local Hats, HatNameIndexs, HatsLength = {}, {}, 0
			for i, v in pairs(character:GetChildren()) do
				if (v:IsA("Accessory")) then
					table.insert(Hats, v)
					HatsLength = HatsLength + 1
				end
			end
			for i, v in pairs(Hats) do
				for j, k in pairs(Hats) do
					local HatSize = "_" .. tostring(math.ceil(v:FindFirstChild("Handle").Size.x)) .. "x" .. tostring(math.ceil(v:FindFirstChild("Handle").Size.y)) .. "x" .. tostring(math.ceil(v:FindFirstChild("Handle").Size.z))
					if v ~= k and v.Name == k.Name then
						if (HatNameIndexs[v.Name .. HatSize]) then
							HatNameIndexs[v.Name .. HatSize] = HatNameIndexs[v.Name .. HatSize] + 1
						else
							HatNameIndexs[v.Name .. HatSize] = 1
						end
						v.Name = v.Name .. HatSize .. "_" .. tostring(HatNameIndexs[v.Name .. HatSize])
						break
					elseif j == HatsLength then
						v.Name = v.Name .. HatSize
					end
				end
			end
			return true
		end;
		new = function(player, character, hats)
			local self = table.new(FEApi.HatManager)
			self.Player = player
			self.Character = character
			self.Hats = hats
			return self
		end;
		delete = function(self)
			for i, v in pairs(self.Aligns) do
				if v.Type == FEApi.AlignTypes.Align then
					self.Character:FindFirstChild(i):FindFirstChild("Handle"):FindFirstChildOfClass("AlignPosition").Attachment1 = v.Backup.AlignPositionAtt
					self.Character:FindFirstChild(i):FindFirstChild("Handle"):FindFirstChildOfClass("AlignOrientation").Attachment1 = v.Backup.AlignOrientationAtt
					v.Athp:Destroy()
					v.Atho:Destroy()
					self.Aligns[i] = nil
				elseif v.Type == FEApi.AlignTypes.CFrame then
					v.Connection:Disconnect()
					self.Aligns[i] = nil
				end
			end
			for i, v in pairs(self) do
				self[i] = nil
			end
			return nil
		end;
		set = function(self, character, hats)
			self.Character = character or self.Character
			self.Hats = hats or self.Hats
			return self
		end;
		fixHats = function(self)
			FEApi.HatManager.FixHats(workspace:FindFirstChild(self.Player.Name))
			return true
		end;
		editHat = function(self, name)
			if type(getgenv().HatEditor) ~= "table" then getgenv().HatEditor = {} end
			if type(getgenv().HatEditor[name]) ~= "table" then getgenv().HatEditor[name] = {} end
			getgenv().HatEditor.delete = function(name)
				for i, v in pairs(getgenv().HatEditor) do
					if type(v) == "table" and type(v.EndEdit) == "function" then
						v.EndEdit()
						getgenv().HatEditor[i] = nil
					else
						getgenv().HatEditor[i] = nil
					end
				end
				getgenv().HatEditor = nil
			end
			getgenv().HatEditor.StartEdit = function(name)
				self:editHat(name)
			end
			getgenv().HatEditor[name].RemoveHat = function()
				workspace:FindFirstChild(self.Player.Name):FindFirstChild(name):Destroy()
				if self.Aligns[name] ~= nil and self.Aligns[name].Type == FEApi.AlignTypes.Align then
					getgenv().HatEditor[name].EndOffsetMode()
					self.Aligns[name].Athp:Destroy()
					self.Aligns[name].Atho:Destroy()
					self.Aligns[i] = nil
				elseif self.Aligns[name] ~= nil and self.Aligns[name].Type == FEApi.AlignTypes.CFrame then
					getgenv().HatEditor[name].EndOffsetMode()
					self.Aligns[name].Connection:Disconnect()
					self.Aligns[i] = nil
				end
				return true
			end
			getgenv().HatEditor[name].RemoveMesh = function()
				workspace:FindFirstChild(self.Player.Name):FindFirstChild(name).Handle:FindFirstChildOfClass("SpecialMesh"):Destroy()
				return true
			end
			getgenv().HatEditor[name].EndEdit = function()
				getgenv().HatEditor[name].EndOffsetMode()
				getgenv().HatEditor[name].RemoveHat = nil
				getgenv().HatEditor[name].RemoveMesh = nil
				getgenv().HatEditor[name].OffsetMode = nil
				getgenv().HatEditor[name].EndOffsetMode = nil
				getgenv().HatEditor[name].EndEdit = nil
				getgenv().HatEditor[name] = nil
			end
			if self.Aligns[name] == nil then return false end
			getgenv().HatEditor[name].OffsetMode = function()
				getgenv().HatEditor[name] = setmetatable(getgenv().HatEditor[name], {
					__newindex = function(t, k, v)
						if k == "Position" and type(v) == "vector" then
							self.Aligns[name].Athp.Position = v
						elseif k == "Rotation" and type(v) == "vector" then
							self.Aligns[name].Atho.Rotation = v
						elseif k == "Orientation" and type(v) == "vector" then
							self.Aligns[name].Atho.Orientation = v
						elseif k == "CFrame" and type(v) == "userdata" then
							self.Aligns[name].CFrame = v
						end
						return
					end
				})
			end
			getgenv().HatEditor[name].EndOffsetMode = function()
				getgenv().HatEditor[name] = setmetatable(getgenv().HatEditor[name], {})
			end
		end;
		align = function(self)
			self.Aligns = {}
			if (type(self.Character) ~= "userdata") then return end
			for i, v in pairs(self.Hats) do
				if (type(v) == "table" and
					type(v.Target) == "userdata" and
					type(v.Type) == "number") then
					if v.Type == FEApi.AlignTypes.Align then
						local Athp = Instance.new("Attachment", v.Target)
						local Atho = Instance.new("Attachment", v.Target)
						local OriginAlignPos = self.Character:FindFirstChild(i):FindFirstChild("Handle"):FindFirstChildOfClass("AlignPosition").Attachment1
						local OriginAlignOri = self.Character:FindFirstChild(i):FindFirstChild("Handle"):FindFirstChildOfClass("AlignOrientation").Attachment1
						Athp.Name = "Attachment1"
						Atho.Name = "Attachment2"
						if v.Position ~= nil then Athp.Position = v.Position end
						if v.Rotation ~= nil then Atho.Rotation = v.Rotation end
						if v.Orientation ~= nil then Atho.Orientation = v.Orientation end
						self.Character:FindFirstChild(i):FindFirstChild("Handle"):FindFirstChildOfClass("AlignPosition").Attachment1 = Athp
						self.Character:FindFirstChild(i):FindFirstChild("Handle"):FindFirstChildOfClass("AlignOrientation").Attachment1 = Atho
						self.Aligns[i] = {
							Type = FEApi.AlignTypes.Align,
							Athp = Athp, 
							Atho = Atho,
							Backup = {
								AlignPositionAtt = OriginAlignPos,
								AlignOrientationAtt = OriginAlignOri
							}
						}
					elseif v.Type == FEApi.AlignTypes.CFrame then
						local connection = game:GetService("RunService").Heartbeat:Connect(function()
							workspace:FindFirstChild(self.Player.Name):FindFirstChild(i).Handle.CFrame = v.Target.CFrame * ((self.Aligns[i] or {}).CFrame or v.CFrame or CFrame.new())
						end)
						pcall(function()
							if (v.FixCFrame) then
								workspace:FindFirstChild(self.Player.Name):FindFirstChild(i).Handle:FindFirstChildOfClass("AlignPosition"):Destroy()
								workspace:FindFirstChild(self.Player.Name):FindFirstChild(i).Handle:FindFirstChildOfClass("AlignOrientation"):Destroy()
							end
						end)
						self.Aligns[i] = {
							Type = FEApi.AlignTypes.CFrame,
							Connection = connection, 
							CFrame = v.CFrame
						}
					end
				end
			end
			return self.Aligns
		end;
	}
}