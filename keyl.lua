repeat wait() until game:IsLoaded()

getgenv().lilix = getgenv().lilix or nil
getgenv().relix = getgenv().relix or nil

getgenv().key = getgenv().key or nil
getgenv().luarmor_api = getgenv().luarmor_api or nil
getgenv().key_expire = getgenv().key_expire or nil
getgenv().key_note = getgenv().key_note or nil
getgenv().key_executions = getgenv().key_executions or nil

if not LPH_OBFUSCATED then
	LPH_JIT_MAX = function(...) return ... end
	LPH_NO_VIRTUALIZE = function(f) return f end
	LPH_NO_UPVALUES = function(...) return ... end
	LPH_CRASH = function(...) return ... end
else
	print = function() end
	warn = function() end
end

local cloneref = cloneref or function(o) return o end
local CoreGui = cloneref(game:GetService("CoreGui"))
local TweenService = cloneref(game:GetService("TweenService"))
local UserInputService = cloneref(game:GetService("UserInputService"))
local Players = cloneref(game:GetService("Players"))
local TextService = cloneref(game:GetService("TextService"))
local HttpService = cloneref(game:GetService("HttpService"))
local Lighting = cloneref(game:GetService("Lighting"))
local Workspace = cloneref(game:GetService("Workspace"))
local IsMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled and not UserInputService.MouseEnabled

local Folder_Configs = {
	Directory = "solixhub",
	Configs = "solixhub/Configs",
	Assets = "solixhub/Assets",
	Themes = "solixhub/Themes"
}

for _, Folder in pairs(Folder_Configs) do
	if not isfolder(Folder) then
		makefolder(Folder)
	end
end

local GameId = tostring(game.GameId)
local GameConfigFolder = Folder_Configs.Configs .. "/" .. GameId

if not isfolder(GameConfigFolder) then
	makefolder(GameConfigFolder)
end

local GameList = {
	["3808223175"] = { id = "4fe2dfc202115670b1813277df916ab2", keyless = true }, -- Jujutsu Infinite
	["994732206"]  = { id = "e2718ddebf562c5c4080dfce26b09398", keyless = true }, -- Blox Fruits
	["1511883870"] = { id = "fefdf5088c44beb34ef52ed6b520507c", keyless = true }, -- Shindo Life
	["6035872082"] = { id = "3bb7969a9ecb9e317b0a24681327c2e2", keyless = true }, -- Rivals
	["245662005"]  = { id = "21ad7f491e4658e9dc9529a60c887c6e", keyless = true }, -- Jailbreak
	["7018190066"] = { id = "98f5c64a0a9ecca29517078597bbcbdb", keyless = true }, -- Dead Rails
	["7326934954"] = { id = "00e140acb477c5ecde501c1d448df6f9", keyless = true }, -- 99 Nights in the Forest
	["7671049560"] = { id = "c0b41e859f576fb70183206224d4a75f", keyless = true }, -- The Forge
	["9363735110"] = { id = "4948419832e0bd4aa588e628c45b6f8d", keyless = true }, -- Escape Tsunami For Brainrots!
	["5130394318"] = { id = "3e7a75a970118d0f0cf629369524dc7d", keyless = true }, -- Bizarre Lineage
	["9186719164"] = { id = "892ccfefdc8834199a2a6e5856a8da67", keyless = true }, -- Sailor Piece
	["9787206684"] = { id = "a29d0ba0c834bf7d9ccd4b615fce834f", keyless = true }, -- Be a Lucky Block
	["9875383684"] = { id = "e29724bc620c1a6d1a45818c4f71b1d0", keyless = true } -- Be a Brainrot
}

local Config = {
	File = "solixhub/savedkey.txt",
	Title = "Solix Hub Free 15+ Games",
	Description = "Lifetime key access is available for a one time payment of $15 via solixhub.com",
	Linkvertise = "https://ads.luarmor.net/get_key?for=Solix_Hub_Linkvertise-OWlLHDMCHADk",
	Rinku = "https://ads.luarmor.net/get_key?for=Solix_Hub_Rinku-pqJCGTqnTsng",
	Discord = "https://discord.gg/solixhub",
	Shop = "https://solixhub.com/",
}

local ErrorMessages = {
	KEY_EXPIRED = "Your key has expired. Please renew it to continue.",
	KEY_BANNED = "This key has been blacklisted. Contact support for assistance.",
	KEY_INCORRECT = "The provided key is incorrect or no longer valid.",
	KEY_INVALID = "Invalid key format. Please check your key and try again.",
	SCRIPT_ID_INCORRECT = "The provided script ID does not exist or has been removed.",
	SCRIPT_ID_INVALID = "This script has been deleted by its owner.",
	SECURITY_ERROR = "Security validation failed (Cloudflare check). Please retry.",
	TIME_ERROR = "Invalid client time detected. Please sync your system clock.",
	UNKNOWN_ERROR = "An unknown error occurred. Please contact support."
}

local GameConfig = GameList[GameId]

if not GameConfig then
	Players.LocalPlayer:Kick("This game is not supported.")
	return
end

local ScriptId = GameConfig.id
local IsKeyless = GameConfig.keyless

if hookfunction and hookmetamethod then
	getgenv().lilix = true
else
	getgenv().lilix = false
end

if IsMobile then
	getgenv().relix = true
else
	getgenv().relix = false
end

local function DeleteFile(v)
	if isfile(v) then
		delfile(v)
	end
end

local LuarmorApi = loadstring(game:HttpGet("https://sdkapi-public.luarmor.net/library.lua"))()
LuarmorApi.script_id = ScriptId

if IsKeyless then
		LuarmorApi.load_script()
	end)
	return
end

local Library do
	local wait = task.wait
	local spawn = task.spawn
	local delay = task.delay

	local LocalPlayer = Players.LocalPlayer
	local Mouse = LocalPlayer:GetMouse()

	local FromRGB = Color3.fromRGB
	local FromHSV = Color3.fromHSV
	local FromHex = Color3.fromHex

	local RGBSequence = ColorSequence.new
	local RGBSequenceKeypoint = ColorSequenceKeypoint.new
	local NumSequence = NumberSequence.new
	local NumSequenceKeypoint = NumberSequenceKeypoint.new

	local UDim2New = UDim2.new
	local UDimNew = UDim.new
	local UDim2FromOffset = UDim2.fromOffset
	local Vector2New = Vector2.new
	local Vector3New = Vector3.new

	local MathClamp = math.clamp
	local MathFloor = math.floor
	local MathAbs = math.abs
	local MathSin = math.sin

	local TableInsert = table.insert
	local TableFind = table.find
	local TableRemove = table.remove
	local TableConcat = table.concat
	local TableClone = table.clone
	local TableUnpack = table.unpack

	local StringFormat = string.format
	local StringFind = string.find
	local StringGSub = string.gsub
	local StringLower = string.lower
	local StringLen = string.len

	local InstanceNew = Instance.new

	local RectNew = Rect.new

	local GetUI = gethui or function()
		local Success, Result = pcall(function()
			return game:GetService("CoreGui")
		end)
		return Success and Result or nil
	end

	local function SafeGetUI()
		local Success, Result = pcall(GetUI)

		if Success and Result then
			return Result
		end

		return game:GetService("CoreGui")
	end

	Library = {
		Theme = {
			["Background"] = FromRGB(15, 12, 16),
			["Inline"] = FromRGB(22, 20, 24),
			["Border"] = FromRGB(41, 37, 45),
			["Text"] = FromRGB(255, 255, 255),
			["Inactive Text"] = FromRGB(185, 185, 185),
			["Accent"] = FromRGB(232, 186, 248),
			["Element"] = FromRGB(36, 32, 39),
		},

		Tween = {
			Time = 0.3,
			Style = Enum.EasingStyle.Quad,
			Direction = Enum.EasingDirection.Out
		},

		Connections = { },
		Threads = { },
		ThemeMap = { },
		ThemeItems = { },

		Holder = nil,
		NotifHolder = nil,
		Font = nil
	}

	Library.__index = Library

	local Tween = { } do
		Tween.__index = Tween

		Tween.Create = function(self, Item, Info, Goal, IsRawItem)
			Item = IsRawItem and Item or Item.Instance
			Info = Info or TweenInfo.new(Library.Tween.Time, Library.Tween.Style, Library.Tween.Direction)

			local NewTween = {
				Tween = TweenService:Create(Item, Info, Goal),
				Info = Info,
				Goal = Goal,
				Item = Item
			}

			NewTween.Tween:Play()
			setmetatable(NewTween, Tween)

			return NewTween
		end

		Tween.Get = function(self)
			if not self.Tween then
				return
			end
			return self.Tween, self.Info, self.Goal
		end

		Tween.Pause = function(self)
			if self.Tween then
				self.Tween:Pause()
			end
		end

		Tween.Play = function(self)
			if self.Tween then
				self.Tween:Play()
			end
		end

		Tween.Clean = function(self)
			if self.Tween then
				Tween:Pause()
			end
			self = nil
		end
	end

	local Instances = { } do
		Instances.__index = Instances

		Instances.Create = function(self, Class, Properties)
			local Success, Result = pcall(function()
				local NewItem = {
					Instance = InstanceNew(Class),
					Properties = Properties,
					Class = Class
				}

				setmetatable(NewItem, Instances)

				for Property, Value in pairs(NewItem.Properties) do
					pcall(function()
						NewItem.Instance[Property] = Value
					end)
				end

				return NewItem
			end)

			if Success and Result then
				return Result
			end

			return {
				Instance = nil,
				Properties = Properties or {},
				Class = Class,
				_Protected = true
			}
		end

		Instances.AddToTheme = function(self, Properties)
			if not self.Instance then
				return
			end

			Library:AddToTheme(self, Properties)

			return self
		end

		Instances.Connect = function(self, Event, Callback)
			if not self.Instance or not self.Instance[Event] then
				return
			end

			return Library:Connect(self.Instance[Event], Callback)
		end

		Instances.Tween = function(self, Info, Goal)
			if not self.Instance then
				return
			end

			return Tween:Create(self, Info, Goal)
		end

		Instances.Clean = function(self)
			if self.Instance then
				self.Instance:Destroy()
			end

			self = nil
		end

		Instances.MakeDraggable = function(self)
			if not self.Instance then
				return
			end

			local Gui = self.Instance
			local Dragging = false
			local DragStart
			local StartPosition
			local Changed

			self:Connect("InputBegan", function(Input)
				if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
					Dragging = true
					DragStart = Input.Position
					StartPosition = Gui.Position

					if Changed then
						return
					end

					Changed = Input.Changed:Connect(function()
						if Input.UserInputState == Enum.UserInputState.End then
							Dragging = false
							if Changed then
								Changed:Disconnect()
								Changed = nil
							end
						end
					end)
				end
			end)

			UserInputService.InputChanged:Connect(function(Input)
				if (Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch) and Dragging then

					local Scale = UIScale and UIScale.Scale or 1
					local DragDelta = (Input.Position - DragStart) / Scale

					self:Tween(TweenInfo.new(0.16, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
						Position = UDim2New(
							StartPosition.X.Scale,
							StartPosition.X.Offset + DragDelta.X,
							StartPosition.Y.Scale,
							StartPosition.Y.Offset + DragDelta.Y
						)
					})
				end
			end)

			return Dragging
		end
	end

	local CustomFont = { } do
		function CustomFont:New(Name, Weight, Style, Data)
			if not isfile(Data.Id) then
				writefile(Data.Id, game:HttpGet(Data.Url))
			end

			local AssetSuccess, AssetId = pcall(getcustomasset, Data.Id)
			if not AssetSuccess then
				return Font.fromEnum(Enum.Font.Gotham)
			end

			local FontData = {
				name = Name,
				faces = {
					{
						name = Name,
						weight = Weight,
						style = Style,
						assetId = AssetId
					}
				}
			}

			local FontPath = Folder_Configs.Assets .. "/" .. Name .. ".font"
			if not isfile(FontPath) then
				writefile(FontPath, HttpService:JSONEncode(FontData))
			end

			local FontAssetSuccess, FontAssetId = pcall(getcustomasset, FontPath)
			if not FontAssetSuccess then
				return Font.fromEnum(Enum.Font.Gotham)
			end

			return Font.new(FontAssetId)
		end

		local FontSuccess = pcall(function()
			Library.Font = CustomFont:New("InterSemibold", 400, "Regular", {
				Id = "InterSemibold",
				Url = "https://raw.githubusercontent.com/sametexe001/luas/main/fonts/InterSemibold.ttf"
			})
		end)

		if not FontSuccess then
			Library.Font = Font.fromEnum(Enum.Font.Gotham)
		end
	end

	Library.Holder = Instances:Create("ScreenGui", {
		Parent = SafeGetUI(),
		Name = "\0",
		ZIndexBehavior = Enum.ZIndexBehavior.Global,
		DisplayOrder = 2,
		ResetOnSpawn = false
	})

	wait()

	Library.NotifHolder = Instances:Create("Frame", {
		Parent = Library.Holder.Instance,
		Name = "\0",
		Size = UDim2New(0, 0, 1, 0),
		Position = UDim2New(1, 0, 0, 0),
		AnchorPoint = Vector2New(1, 0),
		BackgroundColor3 = FromRGB(0, 0, 0),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		AutomaticSize = Enum.AutomaticSize.X
	})

	Library.NotifLayoutOrder = 0

	Instances:Create("UIListLayout", {
		Parent = Library.NotifHolder.Instance,
		Name = "\0",
		SortOrder = Enum.SortOrder.LayoutOrder,
		HorizontalAlignment = Enum.HorizontalAlignment.Right,
		Padding = UDimNew(0, 20)
	})

	Instances:Create("UIPadding", {
		Parent = Library.NotifHolder.Instance,
		Name = "\0",
		PaddingLeft = UDimNew(0, 12),
		PaddingRight = UDimNew(0, 12),
		PaddingTop = UDimNew(0, 12),
		PaddingBottom = UDimNew(0, 12)
	})

	Library.Thread = function(self, Function)
		local NewThread = coroutine.create(Function)

		coroutine.wrap(function()
			coroutine.resume(NewThread)
		end)()

		TableInsert(self.Threads, NewThread)

		return NewThread
	end

	Library.Connect = function(self, Event, Callback)
		local NewConnection = {
			Event = Event,
			Callback = Callback,
			Name = StringFormat("conn_%s", HttpService:GenerateGUID(false)),
			Connection = nil
		}

		Library.Thread(self, function()
			NewConnection.Connection = Event:Connect(Callback)
		end)

		TableInsert(self.Connections, NewConnection)
		return NewConnection
	end

	Library.AddToTheme = function(self, Item, Properties)
		Item = Item.Instance or Item

		local ThemeData = {
			Item = Item,
			Properties = Properties,
		}

		for Property, Value in pairs(ThemeData.Properties) do
			if type(Value) == "string" then
				Item[Property] = self.Theme[Value] or Value
			elseif type(Value) == "function" then
				Item[Property] = Value()
			end
		end

		TableInsert(self.ThemeItems, ThemeData)

		self.ThemeMap[Item] = ThemeData
	end

	local function ToTime(a)
		if not a then
			return "No Key"
		elseif a < 0 then
			return "Lifetime"
		end

		local days = MathFloor(a / 86400)
		local hours = MathFloor((a % 86400) / 3600)
		local minutes = MathFloor((a % 3600) / 60)
		local seconds = a % 60

		if days > 0 then
			return StringFormat("%dd %dh %dm %ds", days, hours, minutes, seconds)
		elseif hours > 0 then
			return StringFormat("%dh %dm %ds", hours, minutes, seconds)
		elseif minutes > 0 then
			return StringFormat("%dm %ds", minutes, seconds)
		else
			return StringFormat("%ds", seconds)
		end
	end

	local function GetTextSize(Text, Width)
		local Success, Result = pcall(function()
			return TextService:GetTextSize(Text, 14, Library.Font, Vector2New(Width, 10000))
		end)

		if not Success or not Result then
			Result = TextService:GetTextSize(Text, 14, Enum.Font.SourceSans, Vector2New(Width, 10000))
		end

		return Result
	end

	Library.Notification = function(self, Data)
		wait()
		Library.NotifLayoutOrder = (Library.NotifLayoutOrder or 0) + 1

		local TitleText = Data.Title or Data.Name or ""
		local DescText = Data.Description or ""
		local Duration = Data.Duration or 5

		local PaddingH = 6
		local PaddingV = 5
		local Gap = 5
		local BarGap = 4
		local BarH = 3
		local MaxWidth = 330

		local function GetTextSize(Text, FontSize, Width)
			local Font = Library.Font

			if typeof(Font) ~= "EnumItem" or Font.EnumType ~= Enum.Font then
				Font = Enum.Font.Gotham
			end

			if Width <= 0 then
				Width = 10000
			end

			return TextService:GetTextSize(Text, FontSize, Font, Vector2.new(Width, 10000))
		end

		local TitleSize = GetTextSize(TitleText, 14, MaxWidth)
		local DescAvailableWidth = MaxWidth - PaddingH * 2
		local DescSize = DescText ~= "" and GetTextSize(DescText, 12, DescAvailableWidth) or Vector2.new(DescAvailableWidth, 28)

		local TitleH = math.max(math.ceil(math.max(TitleSize.Y, 1)), 15)
		local DescH = math.max(math.ceil(math.max(DescSize.Y, 1)), 14)

		if DescH < 28 then DescH = 28 end

		local ContentWidth = math.max(math.ceil(math.max(TitleSize.X, 1)), math.ceil(math.max(DescSize.X, 1)), 100)
		ContentWidth = math.min(math.max(ContentWidth + PaddingH * 2, 100), MaxWidth)

		local SizeY = PaddingV + TitleH + Gap + DescH + BarGap + BarH + PaddingV

		local Items = {} do
			Items["Notification"] = Instances:Create("Frame", {
				Parent = Library.NotifHolder.Instance,
				Name = "\0",
				BackgroundColor3 = Library.Theme["Background"],
				BackgroundTransparency = 1,
				BorderColor3 = FromRGB(0, 0, 0),
				BorderSizePixel = 0,
				LayoutOrder = Library.NotifLayoutOrder,
				Size = UDim2New(0, ContentWidth, 0, SizeY)
			}):AddToTheme({BackgroundColor3 = 'Background'})

			Instances:Create("UICorner", {
				Parent = Items["Notification"].Instance,
				Name = "\0",
				CornerRadius = UDimNew(0, 5)
			})

			Instances:Create("UIPadding", {
				Parent = Items["Notification"].Instance,
				Name = "\0",
				PaddingLeft = UDimNew(0, PaddingH),
				PaddingRight = UDimNew(0, PaddingH),
				PaddingTop = UDimNew(0, PaddingV),
				PaddingBottom = UDimNew(0, PaddingV)
			})

			Items["Title"] = Instances:Create("TextLabel", {
				Parent = Items["Notification"].Instance,
				Name = "\0",
				Size = UDim2New(1, 0, 0, TitleH),
				BackgroundTransparency = 1,
				BorderColor3 = FromRGB(0, 0, 0),
				BorderSizePixel = 0,
				Text = TitleText,
				TextColor3 = Library.Theme["Text"],
				TextSize = 14,
				FontFace = Library.Font,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextYAlignment = Enum.TextYAlignment.Top,
				TextWrapped = true,
				TextTransparency = 1
			}):AddToTheme({TextColor3 = 'Text'})

			Items["Description"] = Instances:Create("TextLabel", {
				Parent = Items["Notification"].Instance,
				Name = "\0",
				Size = UDim2New(1, -PaddingH * 2, 0, DescH),
				Position = UDim2New(0, PaddingH, 0, TitleH + Gap),
				BackgroundTransparency = 1,
				BorderColor3 = FromRGB(0, 0, 0),
				BorderSizePixel = 0,
				Text = DescText,
				TextColor3 = Library.Theme["Text"],
				TextSize = 12,
				FontFace = Library.Font,
				TextTransparency = 1,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextYAlignment = Enum.TextYAlignment.Top,
				TextWrapped = true,
				TextTruncate = Enum.TextTruncate.None,
				RichText = false,
				TextScaled = false,
				AutomaticSize = Enum.AutomaticSize.Y
			}):AddToTheme({TextColor3 = 'Text'})

			Instances:Create("UITextSizeConstraint", {
				Parent = Items["Description"].Instance,
				Name = "\0",
				MinTextSize = 12,
				MaxTextSize = 12
			})

			Items["Duration"] = Instances:Create("Frame", {
				Parent = Items["Notification"].Instance,
				Name = "\0",
				Size = UDim2New(1, 0, 0, BarH),
				Position = UDim2New(0, 0, 0, TitleH + Gap + DescH + BarGap),
				BackgroundColor3 = Library.Theme["Inline"],
				BackgroundTransparency = 1,
				BorderColor3 = FromRGB(0, 0, 0),
				BorderSizePixel = 0
			}):AddToTheme({BackgroundColor3 = 'Inline'})

			Instances:Create("UICorner", {
				Parent = Items["Duration"].Instance,
				Name = "\0",
				CornerRadius = UDimNew(0, 5)
			})

			Items["Accent"] = Instances:Create("Frame", {
				Parent = Items["Duration"].Instance,
				Name = "\0",
				Size = UDim2New(1, 0, 1, 0),
				BackgroundColor3 = Data.Color,
				BorderColor3 = FromRGB(0, 0, 0),
				BorderSizePixel = 0
			})

			Instances:Create("UICorner", {
				Parent = Items["Accent"].Instance,
				Name = "\0",
				CornerRadius = UDimNew(0, 5)
			})
		end

		local FadeInfo = TweenInfo.new(1, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out, 0, false, 0)
		local BarInfo = TweenInfo.new(Duration, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)

		local Frames = { Items["Notification"], Items["Duration"] }
		local TextLabels = { Items["Title"] }
		local DescLabel = Items["Description"]

		Library:Thread(function()
			for _, Item in Frames do
				Item:Tween(FadeInfo, {BackgroundTransparency = 0})
			end

			for _, Item in TextLabels do
				Item:Tween(FadeInfo, {TextTransparency = 0})
			end

			DescLabel:Tween(FadeInfo, {TextTransparency = 0.4})

			Items["Notification"]:Tween(FadeInfo, {Size = UDim2New(0, ContentWidth, 0, SizeY)})
			Items["Accent"]:Tween(BarInfo, {Size = UDim2New(0, 0, 1, 0)})

			delay(Duration + 0.1, function()
				for _, Item in Frames do
					Item:Tween(FadeInfo, {BackgroundTransparency = 1})
				end

				for _, Item in TextLabels do
					Item:Tween(FadeInfo, {TextTransparency = 1})
				end

				DescLabel:Tween(FadeInfo, {TextTransparency = 1})

				Items["Notification"]:Tween(FadeInfo, {Size = UDim2New(0, 0, 0, SizeY)})
				wait(0.5)
				Items["Notification"]:Clean()
			end)
		end)
	end

	local BlurEffect = Instances:Create("BlurEffect", {
		Name = "\0",
		Size = 0,
		Parent = Lighting
	})

	local Items = { } do
		Items["ScreenGui"] = Instances:Create("ScreenGui", {
			Parent = SafeGetUI(),
			Name = "\0",
			ZIndexBehavior = Enum.ZIndexBehavior.Global,
			DisplayOrder = 999,
			ResetOnSpawn = false,
			IgnoreGuiInset = true
		})

		Items["Overlay"] = Instances:Create("Frame", {
			Parent = Items["ScreenGui"].Instance,
			Name = "\0",
			Size = UDim2New(1, 0, 1, 0),
			BackgroundColor3 = FromRGB(0, 0, 0),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			ZIndex = 1
		})

		Items["MainFrame"] = Instances:Create("Frame", {
			Parent = Items["ScreenGui"].Instance,
			Name = "\0",
			Size = UDim2New(0, 0, 0, 0),
			Position = UDim2New(0.5, 0, 0.5, 0),
			AnchorPoint = Vector2New(0.5, 0.5),
			BackgroundColor3 = Library.Theme["Background"],
			BackgroundTransparency = 0.15,
			BorderSizePixel = 0,
			ZIndex = 2
		}):AddToTheme({BackgroundColor3 = 'Background'})

		Instances:Create("UICorner", {
			Parent = Items["MainFrame"].Instance,
			Name = "\0",
			CornerRadius = UDimNew(0, 8)
		})

		Items["MainStroke"] = Instances:Create("UIStroke", {
			Parent = Items["MainFrame"].Instance,
			Name = "\0",
			Color = Library.Theme["Border"],
			Thickness = 1,
			Transparency = 1,
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		}):AddToTheme({Color = 'Border'})

		Items["TitleLabel"] = Instances:Create("TextLabel", {
			Parent = Items["MainFrame"].Instance,
			Name = "\0",
			Size = UDim2New(1, 0, 0, 40),
			Position = UDim2New(0, 0, 0, 20),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Text = Config.Title,
			TextColor3 = Library.Theme["Accent"],
			TextSize = 28,
			FontFace = Library.Font,
			TextTransparency = 1,
			ZIndex = 2
		}):AddToTheme({TextColor3 = 'Accent'})

		Items["SubtitleLabel"] = Instances:Create("TextLabel", {
			Parent = Items["MainFrame"].Instance,
			Name = "\0",
			Size = UDim2New(1, 0, 0, 20),
			Position = UDim2New(0, 0, 0, 65),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Text = Config.Description,
			TextColor3 = Library.Theme["Inactive Text"],
			TextSize = 13,
			FontFace = Library.Font,
			TextTransparency = 1,
			ZIndex = 2
		}):AddToTheme({TextColor3 = 'Inactive Text'})

		Items["Line"] = Instances:Create("Frame", {
			Parent = Items["MainFrame"].Instance,
			Name = "\0",
			Size = UDim2New(0.84, 0, 0, 1),
			Position = UDim2New(0.08, 0, 0, 95),
			BackgroundColor3 = Library.Theme["Border"],
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			ZIndex = 2
		}):AddToTheme({BackgroundColor3 = 'Border'})

		Items["TextBoxContainer"] = Instances:Create("Frame", {
			Parent = Items["MainFrame"].Instance,
			Name = "\0",
			Size = UDim2New(0, 480, 0, 50),
			Position = UDim2New(0.5, 0, 0, 115),
			AnchorPoint = Vector2New(0.5, 0),
			BackgroundColor3 = Library.Theme["Element"],
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			ZIndex = 2
		}):AddToTheme({BackgroundColor3 = 'Element'})

		Instances:Create("UICorner", {
			Parent = Items["TextBoxContainer"].Instance,
			Name = "\0",
			CornerRadius = UDimNew(0, 5)
		})

		Instances:Create("UIGradient", {
			Parent = Items["TextBoxContainer"].Instance,
			Name = "\0",
			Rotation = 90,
			Color = RGBSequence({
				RGBSequenceKeypoint(0, FromRGB(255, 255, 255)),
				RGBSequenceKeypoint(1, FromRGB(216, 216, 216))
			})
		})

		Items["TextBoxStroke"] = Instances:Create("UIStroke", {
			Parent = Items["TextBoxContainer"].Instance,
			Name = "\0",
			Color = Library.Theme["Border"],
			Thickness = 1,
			Transparency = 1,
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		}):AddToTheme({Color = 'Border'})

		Items["KeyTextBox"] = Instances:Create("TextBox", {
			Parent = Items["TextBoxContainer"].Instance,
			Name = "\0",
			Size = UDim2New(1, -24, 1, 0),
			Position = UDim2New(0, 12, 0, 0),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			ZIndex = 2,
			Text = "",
			TextColor3 = Library.Theme["Text"],
			TextSize = 15,
			FontFace = Library.Font,
			PlaceholderText = "Paste your key here...",
			PlaceholderColor3 = Library.Theme["Inactive Text"],
			TextXAlignment = Enum.TextXAlignment.Left,
			TextTransparency = 1,
			CursorPosition = -1,
			ClearTextOnFocus = false
		}):AddToTheme({TextColor3 = 'Text', PlaceholderColor3 = 'Inactive Text'})

		Items["CloseButton"] = Instances:Create("TextButton", {
			Parent = Items["MainFrame"].Instance,
			Name = "\0",
			Size = UDim2New(0, 30, 0, 30),
			Position = UDim2New(1, -40, 0, 10),
			BackgroundColor3 = Library.Theme["Element"],
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Text = "X",
			TextColor3 = Library.Theme["Text"],
			TextSize = 18,
			FontFace = Library.Font,
			AutoButtonColor = false,
			TextTransparency = 1,
			ZIndex = 2
		}):AddToTheme({BackgroundColor3 = 'Element', TextColor3 = 'Text'})

		Instances:Create("UICorner", {
			Parent = Items["CloseButton"].Instance,
			Name = "\0",
			CornerRadius = UDimNew(0, 5)
		})

		Items["CloseStroke"] = Instances:Create("UIStroke", {
			Parent = Items["CloseButton"].Instance,
			Name = "\0",
			Color = Library.Theme["Border"],
			Thickness = 1,
			Transparency = 1,
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		}):AddToTheme({Color = 'Border'})
	end

	local Buttons = { }

	local function CreateButton(Text, Position)
		local Button = Instances:Create("TextButton", {
			Parent = Items["MainFrame"].Instance,
			Name = "\0",
			Size = UDim2New(0, 220, 0, 45),
			Position = Position,
			AnchorPoint = Vector2New(0.5, 0),
			BackgroundColor3 = Library.Theme["Element"],
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Text = Text,
			TextColor3 = Library.Theme["Text"],
			TextSize = IsMobile and 13 or 15,
			FontFace = Library.Font,
			AutoButtonColor = false,
			TextTransparency = 1,
			ZIndex = 2
		}):AddToTheme({BackgroundColor3 = 'Element', TextColor3 = 'Text'})

		Instances:Create("UICorner", {
			Parent = Button.Instance,
			Name = "\0",
			CornerRadius = UDimNew(0, 5)
		})

		Instances:Create("UIGradient", {
			Parent = Button.Instance,
			Name = "\0",
			Rotation = 90,
			Color = RGBSequence({
				RGBSequenceKeypoint(0, FromRGB(255, 255, 255)),
				RGBSequenceKeypoint(1, FromRGB(216, 216, 216))
			})
		})

		Items["ButtonStroke"] = Instances:Create("UIStroke", {
			Parent = Button.Instance,
			Name = "\0",
			Color = Library.Theme["Border"],
			Thickness = 1,
			Transparency = 1,
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		}):AddToTheme({Color = 'Border'})

		TableInsert(Buttons, {Button = Button, Stroke = Items["ButtonStroke"]})
		return Button
	end

	if IsMobile then
		Items["Button1"] = CreateButton("Get Key (Linkvertise)", UDim2New(0.5, 0, 0, 185))
		Items["Button2"] = CreateButton("Get Key (Rinku)", UDim2New(0.5, 0, 0, 240))
		Items["Button3"] = CreateButton("Join Discord", UDim2New(0.5, 0, 0, 295))
		Items["Button4"] = CreateButton("Buy Standard Key", UDim2New(0.5, 0, 0, 350))

		for _, Button in Buttons do
			Button.Button.Instance.Size = UDim2New(0, 320, 0, 42)
		end
	else
		Items["Button1"] = CreateButton("Get Key (Linkvertise)", UDim2New(0.25, 0, 0, 190))
		Items["Button2"] = CreateButton("Get Key (Rinku)", UDim2New(0.75, 0, 0, 190))
		Items["Button3"] = CreateButton("Join Discord", UDim2New(0.25, 0, 0, 255))
		Items["Button4"] = CreateButton("Buy Standard Key", UDim2New(0.75, 0, 0, 255))
	end

	local TweenData = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

	local function CloseUI()
		BlurEffect:Tween(TweenData, {Size = 0})
		Items["Overlay"]:Tween(TweenData, {BackgroundTransparency = 1})

		Items["TitleLabel"]:Tween(TweenData, {TextTransparency = 1})
		Items["SubtitleLabel"]:Tween(TweenData, {TextTransparency = 1})
		Items["Line"]:Tween(TweenData, {BackgroundTransparency = 1})
		Items["TextBoxContainer"]:Tween(TweenData, {BackgroundTransparency = 1})
		Items["TextBoxStroke"]:Tween(TweenData, {Transparency = 1})
		Items["KeyTextBox"]:Tween(TweenData, {TextTransparency = 1})
		Items["CloseButton"]:Tween(TweenData, {BackgroundTransparency = 1, TextTransparency = 1})
		Items["CloseStroke"]:Tween(TweenData, {Transparency = 1})
		Items["MainStroke"]:Tween(TweenData, {Transparency = 1})

		for _, Button in Buttons do
			Button.Button:Tween(TweenData, {BackgroundTransparency = 1, TextTransparency = 1})
			Button.Stroke:Tween(TweenData, {Transparency = 1})
		end

		Items["MainFrame"]:Tween(TweenData, {Size = UDim2New(0, 0, 0, 0)})
		wait(0.35)
		BlurEffect:Clean()
		Items["ScreenGui"]:Clean()
	end

	local function ValidateKey(Key)
		local CleanedKey = Key:gsub("%s", "")

		if not string.match(CleanedKey, "^[A-Za-z0-9]+$") or #CleanedKey ~= 32 then
			Library:Notification({
				Title = "Error",
				Description = "Invalid key format. Key must be 32 characters.",
				Color = FromRGB(255, 60, 60),
				Duration = 5
			})
			return false
		end

		if CleanedKey ~= Key then
			Library:Notification({
				Title = "Info",
				Description = "Extra spaces detected, verifying without spaces...",
				Color = FromRGB(237, 170, 0),
				Duration = 5
			})
		end

		local Success, Result = pcall(LuarmorApi.check_key, CleanedKey)

		if not Success then
			Library:Notification({
				Title = "Error",
				Description = "Network error. Please try again.",
				Color = FromRGB(255, 60, 60),
				Duration = 5
			})
			return false
		end

		if Result.code == "KEY_VALID" then
			script_key = CleanedKey

			if not isfile(Config.File) then
				pcall(writefile, Config.File, CleanedKey)
			elseif readfile(Config.File) ~= CleanedKey then
				pcall(writefile, Config.File, CleanedKey)
			end

			getgenv().key = CleanedKey
			getgenv().luarmor_api = LuarmorApi
			getgenv().key_expire = Result.data and Result.data.auth_expire or 0
			getgenv().key_note = Result.data and Result.data.note or ""
			getgenv().key_executions = Result.data and Result.data.total_executions or 0

			Library:Notification({
				Title = "Success",
				Description = "Key expires in: " .. ToTime(getgenv().key_expire - os.time()),
				Color = FromRGB(60, 255, 60),
				Duration = 5
			})

			wait(1.5)
			CloseUI()

			if not (
				GameId == "3808223175" -- Jujutsu Infinite
					or GameId == "994732206" -- Blox Fruits
					or GameId == "1511883870" -- Shindo Life
					or GameId == "7018190066" -- Dead Rails
					or GameId == "7671049560" -- The Forge
					or GameId == "9363735110" -- Escape Tsunami For Brainrots!
					or GameId == "5130394318" -- Bizarre Lineage
					or GameId == "9186719164" -- Sailor Piece
					or GameId == "9787206684" -- Be a Lucky Block
					or GameId == "9875383684" -- Be a Brainrot
				) and not getgenv().lilix then
				LocalPlayer:Kick("This executor is not supported for this game.")
			end

			pcall(function()
				LuarmorApi.load_script()
			end)

			return true
		end

		if ErrorMessages[Result.code] then
			if Result.code == "SECURITY_ERROR" or Result.code == "UNKNOWN_ERROR" then
				LocalPlayer:Kick(ErrorMessages[Result.code])
			else
				DeleteFile(Config.File)
				Library:Notification({
					Title = "Error",
					Description = ErrorMessages[Result.code],
					Color = FromRGB(255, 60, 60),
					Duration = 5
				})
			end
			return false
		end

		LocalPlayer:Kick("Key check failed:\nCode: " .. Result.code)
		return false
	end

	for _, Button in Buttons do
		Button.Button:Connect("MouseEnter", function()
			Button.Button:Tween(TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = IsMobile and UDim2New(0, 330, 0, 45) or UDim2New(0, 230, 0, 48)})
		end)
		Button.Button:Connect("MouseLeave", function()
			Button.Button:Tween(TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = IsMobile and UDim2New(0, 320, 0, 42) or UDim2New(0, 220, 0, 45)})
		end)
		Button.Button:Connect("MouseButton1Down", function()
			Button.Button:Tween(TweenInfo.new(0.08), {Size = IsMobile and UDim2New(0, 310, 0, 40) or UDim2New(0, 210, 0, 42)})
		end)
		Button.Button:Connect("MouseButton1Up", function()
			Button.Button:Tween(TweenInfo.new(0.08), {Size = IsMobile and UDim2New(0, 320, 0, 42) or UDim2New(0, 220, 0, 45)})
		end)
	end

	Items["Button1"]:Connect("MouseButton1Click", function()
		if setclipboard then
			setclipboard(Config.Linkvertise)
		end
		Library:Notification({
			Title = "Link Copied",
			Description = "Linkvertise link copied to clipboard",
			Color = FromRGB(60, 255, 60),
			Duration = 5
		})
	end)

	Items["Button2"]:Connect("MouseButton1Click", function()
		if setclipboard then
			setclipboard(Config.Rinku)
		end
		Library:Notification({
			Title = "Link Copied",
			Description = "Rinku link copied to clipboard",
			Color = FromRGB(60, 255, 60),
			Duration = 5
		})
	end)

	Items["Button3"]:Connect("MouseButton1Click", function()
		if setclipboard then
			setclipboard(Config.Discord)
		end
		Library:Notification({
			Title = "Discord Copied",
			Description = "Discord invite copied to clipboard",
			Color = FromRGB(60, 255, 60),
			Duration = 5
		})
	end)

	Items["Button4"]:Connect("MouseButton1Click", function()
		if setclipboard then
			setclipboard(Config.Shop)
		end
		Library:Notification({
			Title = "Link Copied",
			Description = "Standard key shop link copied",
			Color = FromRGB(60, 255, 60),
			Duration = 5
		})
	end)

	Items["KeyTextBox"]:Connect("FocusLost", function()
		if Items["KeyTextBox"].Instance.Text == "" then
			return
		end

		if not ValidateKey(Items["KeyTextBox"].Instance.Text) then
			Items["KeyTextBox"].Instance.Text = ""
		end
	end)

	Items["CloseButton"]:Connect("MouseButton1Click", function()
		CloseUI()
	end)

	Items["CloseButton"]:Connect("MouseEnter", function()
		Items["CloseButton"]:Tween(TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2New(0, 35, 0, 35)})
	end)

	Items["CloseButton"]:Connect("MouseLeave", function()
		Items["CloseButton"]:Tween(TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2New(0, 30, 0, 30)})
	end)

	Items["MainFrame"]:MakeDraggable()

	local UIScale = InstanceNew("UIScale")
	UIScale.Scale = 1
	UIScale.Parent = Items["ScreenGui"].Instance

	local function GetViewportSize()
		local Camera = Workspace.CurrentCamera
		return (Camera and Camera.ViewportSize) or Vector2.new(1920, 1080)
	end

	local function SetMobileScale()
		local Viewport = GetViewportSize()

		if IsMobile then
			local Scale = MathClamp(Viewport.Y / 500, 0.5, 1.5)
			UIScale.Scale = Scale
		else
			UIScale.Scale = 1
		end
	end

	if IsMobile then
		Items["MainFrame"].Instance.Size = UDim2New(0, 380, 0, 440)
		Items["TitleLabel"].Instance.TextSize = 22
		Items["SubtitleLabel"].Instance.TextSize = 10
		Items["TextBoxContainer"].Instance.Size = UDim2New(0, 340, 0, 45)
		SetMobileScale()
	end

	local FinalSize = IsMobile and UDim2New(0, 380, 0, 440) or UDim2New(0, 580, 0, 340)
	local TweenInfo2 = TweenInfo.new(1, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out)

	BlurEffect:Tween(TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = 24})
	Items["Overlay"]:Tween(TweenInfo.new(0.3), {BackgroundTransparency = 0.3})
	Items["MainFrame"]:Tween(TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = FinalSize})

	wait(0.3)

	Items["TitleLabel"]:Tween(TweenInfo2, {TextTransparency = 0})
	Items["SubtitleLabel"]:Tween(TweenInfo2, {TextTransparency = 0})
	Items["Line"]:Tween(TweenInfo2, {BackgroundTransparency = 0})
	Items["TextBoxContainer"]:Tween(TweenInfo2, {BackgroundTransparency = 0})
	Items["TextBoxStroke"]:Tween(TweenInfo2, {Transparency = 0})
	Items["KeyTextBox"]:Tween(TweenInfo2, {TextTransparency = 0})
	Items["CloseButton"]:Tween(TweenInfo2, {BackgroundTransparency = 0, TextTransparency = 0})
	Items["CloseStroke"]:Tween(TweenInfo2, {Transparency = 0})
	Items["MainStroke"]:Tween(TweenInfo2, {Transparency = 0})

	for _, Button in Buttons do
		Button.Button:Tween(TweenInfo2, {BackgroundTransparency = 0, TextTransparency = 0})
		Button.Stroke:Tween(TweenInfo2, {Transparency = 0})
	end

	spawn(function()
		while wait(0.3) do
			local SavedKey = (isfile(Config.File) and readfile(Config.File)) or (script_key ~= "" and script_key) or nil

			if SavedKey and ValidateKey(SavedKey) then
				return
			end
		end
	end)
end
