-- ESP Aimbot Gui (Original Design + Full Features, No Minimize button)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

-- ScreenGui parent PlayerGui
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "RafsanUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = player:WaitForChild("PlayerGui")

-- Icon button (R)
local Icon = Instance.new("TextButton", ScreenGui)
Icon.Name = "IconBtn"
Icon.Text = "R"
Icon.Size = UDim2.new(0, 50, 0, 50)
Icon.Position = UDim2.new(0, 20, 0, 220)
Icon.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
Icon.TextColor3 = Color3.fromRGB(255, 0, 0)
Icon.Font = Enum.Font.SourceSansBold
Icon.TextSize = 28
Icon.BorderSizePixel = 2
Icon.BorderColor3 = Color3.fromRGB(255, 0, 0)
Icon.ZIndex = 10
Icon.Active = true
Icon.Draggable = true

-- Main Frame
local Main = Instance.new("Frame", ScreenGui)
Main.Name = "MainFrame"
Main.Size = UDim2.new(0, 300, 0, 350)
Main.Position = UDim2.new(0.5, -150, 0.5, -175)
Main.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Main.BorderSizePixel = 2
Main.BorderColor3 = Color3.fromRGB(60, 60, 60)
Main.Visible = false
Main.Active = true
Main.Draggable = true

-- Title Bar
local Title = Instance.new("TextLabel", Main)
Title.Name = "TitleLabel"
Title.Size = UDim2.new(1, 0, 0, 40)
Title.Position = UDim2.new(0, 5, 0, 5)
Title.Text = "(FPS)🔫 GUN GROUNDS FFA - MADE BY RAFSAN ZAMI"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.BackgroundTransparency = 1
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 14
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.BorderSizePixel = 0

-- Close Button (X)
local Close = Instance.new("TextButton", Main)
Close.Name = "CloseBtn"
Close.Size = UDim2.new(0, 30, 0, 30)
Close.Position = UDim2.new(1, -35, 0, 7)
Close.Text = "X"
Close.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
Close.TextColor3 = Color3.fromRGB(255, 255, 255)
Close.Font = Enum.Font.SourceSansBold
Close.TextSize = 14
Close.BorderSizePixel = 0

-- Tabs Container
local TabContainer = Instance.new("Frame", Main)
TabContainer.Name = "TabContainer"
TabContainer.Size = UDim2.new(1, -10, 0, 30)
TabContainer.Position = UDim2.new(0, 5, 0, 50)
TabContainer.BackgroundTransparency = 1

-- Tabs
local TabNames = {"ESP HACKES", "AIM HACKES", "VISUAL HACKES", "ABOUT"}
local tabButtons = {}

local totalTabWidth = 0
for i, name in ipairs(TabNames) do
	local TabBtn = Instance.new("TextButton", TabContainer)
	TabBtn.Name = name:gsub("%s", "") .. "Btn"
	TabBtn.Size = UDim2.new(0, 70, 1, 0)
	TabBtn.Position = UDim2.new(0, (i - 1) * 75, 0, 0)
	TabBtn.Text = name
	TabBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
	TabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	TabBtn.Font = Enum.Font.SourceSans
	TabBtn.TextSize = 12
	TabBtn.BorderSizePixel = 0
	tabButtons[name] = TabBtn
	totalTabWidth = totalTabWidth + 70 + 5
end

local offsetX = (300 - totalTabWidth + 5) / 2
TabContainer.Position = UDim2.new(0, offsetX, 0, 50)

-- Content Container
local Container = Instance.new("ScrollingFrame", Main)
Container.Name = "ContentContainer"
Container.Size = UDim2.new(1, -10, 1, -100)
Container.Position = UDim2.new(0, 5, 0, 85)
Container.BackgroundTransparency = 1
Container.BorderSizePixel = 0
Container.ScrollBarThickness = 6
Container.CanvasSize = UDim2.new(0, 0, 0, 0)
Container.ClipsDescendants = true
Container.VerticalScrollBarInset = Enum.ScrollBarInset.Always

-- Variables for toggles
local espGlow = false
local espLine = false
local espMiddle = false
local espDots = false
local espCircle = false
local espRainbow = false
local aimbotOn = false

-- Store ESP highlights, lines, dots, circle
local highlights = {}
local lines = {}
local dots = {}
local circle = nil

-- Clear children function
local function ClearContainer()
	for _, child in pairs(Container:GetChildren()) do
		if child:IsA("TextButton") then
			child:Destroy()
		end
	end
end

-- Create toggle button helper (with padding)
local function createToggle(text, yPos, callback)
	local Btn = Instance.new("TextButton", Container)
	Btn.Size = UDim2.new(0.98, 0, 0, 30)
	Btn.Position = UDim2.new(0.01, 0, 0, yPos)
	Btn.Text = text .. " [OFF]"
	Btn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
	Btn.TextColor3 = Color3.fromRGB(200, 200, 200)
	Btn.Font = Enum.Font.SourceSans
	Btn.TextSize = 13
	Btn.BorderSizePixel = 0
	local state = false
	Btn.MouseButton1Click:Connect(function()
		state = not state
		Btn.Text = text .. " [" .. (state and "ON" or "OFF") .. "]"
		if callback then callback(state) end
	end)
	return Btn
end

-- Update rainbow color helper
local function getRainbowColor()
	return Color3.fromHSV((tick() * 0.5) % 1, 1, 1)
end

-- Clear highlights
local function clearHighlights()
	for _, hl in pairs(highlights) do
		if hl and hl.Parent then
			hl:Destroy()
		end
	end
	highlights = {}
end

-- Clear lines
local function clearLines()
	for _, line in pairs(lines) do
		line:Remove()
	end
	lines = {}
end

-- Clear dots
local function clearDots()
	for _, dot in pairs(dots) do
		dot:Remove()
	end
	dots = {}
end

-- Remove circle
local function clearCircle()
	if circle then
		circle:Remove()
		circle = nil
	end
end

-- Update ESP Glow highlights
local function updateESPGlow()
	clearHighlights()
	if espGlow then
		for _, plr in pairs(Players:GetPlayers()) do
			if plr ~= player and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
				if not plr.Character:FindFirstChild("ESPHighlight") then
					local hl = Instance.new("Highlight")
					hl.Name = "ESPHighlight"
					hl.FillColor = espRainbow and getRainbowColor() or Color3.new(1, 1, 0)
					hl.OutlineColor = Color3.new(1, 0.85, 0)
					hl.Parent = plr.Character
					table.insert(highlights, hl)
				end
			end
		end
	else
		clearHighlights()
	end
end

-- Update ESP Lines and Middle line
local function updateESPLines()
	clearLines()
	if not espLine and not espMiddle then return end
	for _, plr in pairs(Players:GetPlayers()) do
		if plr ~= player and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
			local root = plr.Character.HumanoidRootPart
			local pos, onScreen = camera:WorldToViewportPoint(root.Position)
			if onScreen then
				local line = Drawing.new("Line")
				line.Thickness = 2
				line.Transparency = 1
				line.Color = espRainbow and getRainbowColor() or Color3.new(1, 1, 0)
				line.Visible = true
				local fromX = camera.ViewportSize.X / 2
				local fromY = espLine and 0 or camera.ViewportSize.Y / 2 -- espLine from top, espMiddle from center
				line.From = Vector2.new(fromX, fromY)
				line.To = Vector2.new(pos.X, pos.Y)
				table.insert(lines, line)
			end
		end
	end
end

-- Update ESP Dots (balls)
local function updateESPDots()
	clearDots()
	if not espDots then return end
	for _, plr in pairs(Players:GetPlayers()) do
		if plr ~= player and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
			local root = plr.Character.HumanoidRootPart
			local pos, onScreen = camera:WorldToViewportPoint(root.Position)
			if onScreen then
				local dot = Drawing.new("Circle")
				dot.Radius = 6
				dot.Thickness = 2
				dot.Filled = true
				dot.Transparency = 1
				dot.Color = espRainbow and getRainbowColor() or Color3.new(1, 1, 0)
				dot.Visible = true
				dot.Position = Vector2.new(pos.X, pos.Y)
				table.insert(dots, dot)
			end
		end
	end
end

-- Update ESP Circle (static center circle)
local function updateESPCircle()
	if espCircle then
		if not circle then
			circle = Drawing.new("Circle")
			circle.Radius = 95 -- 190 diameter / 2
			circle.Thickness = 2
			circle.Filled = false
			circle.Transparency = 1
			circle.Color = espRainbow and getRainbowColor() or Color3.new(1, 1, 0)
			circle.Visible = true
		end
		-- Position at screen center
		circle.Position = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
		circle.Color = espRainbow and getRainbowColor() or Color3.new(1, 1, 0)
	else
		clearCircle()
	end
end

-- Update all ESP visuals per frame
RunService.RenderStepped:Connect(function()
	updateESPGlow()
	updateESPLines()
	updateESPDots()
	updateESPCircle()
end)

-- Aimbot lock to nearest enemy head
RunService.RenderStepped:Connect(function()
	if aimbotOn then
		local nearestHead = nil
		local shortestDist = math.huge
		for _, plr in pairs(Players:GetPlayers()) do
			if plr ~= player and plr.Character and plr.Character:FindFirstChild("Head") and plr.Character:FindFirstChild("Humanoid") and plr.Character.Humanoid.Health > 0 then
				local head = plr.Character.Head
				local dist = (head.Position - camera.CFrame.Position).Magnitude
				if dist < shortestDist then
					shortestDist = dist
					nearestHead = head
				end
			end
		end
		if nearestHead then
			camera.CFrame = CFrame.new(camera.CFrame.Position, nearestHead.Position)
		end
	end
end)

-- Fill ESP tab content
local function ShowESPTab()
	ClearContainer()
	local features = {
		{ name = "ESP Glow", callback = function(state)
			espGlow = state
			updateESPGlow()
		end },
		{ name = "ESP Line", callback = function(state)
			espLine = state
			updateESPLines()
		end },
		{ name = "ESP Middle", callback = function(state)
			espMiddle = state
			updateESPLines()
		end },
		{ name = "ESP Dots", callback = function(state)
			espDots = state
			updateESPDots()
		end },
		{ name = "ESP Circle", callback = function(state)
			espCircle = state
			updateESPCircle()
		end },
		{ name = "ESP Rainbow", callback = function(state)
			espRainbow = state
			updateESPGlow()
			updateESPLines()
			updateESPDots()
			updateESPCircle()
		end },
	}
	for i, feat in ipairs(features) do
		createToggle(feat.name, (i - 1) * 35, feat.callback)
	end
	-- Adjust CanvasSize for scrolling
	Container.CanvasSize = UDim2.new(0, 0, 0, #features * 35)
end

-- Fill AIM tab content
local function ShowAIMTab()
	ClearContainer()
	createToggle("Aimbot", 0, function(state)
		aimbotOn = state
	end)
	Container.CanvasSize = UDim2.new(0, 0, 0, 35)
end

-- Fill VISUAL tab content
local function ShowVisualTab()
	ClearContainer()
	local Label = Instance.new("TextLabel", Container)
	Label.Size = UDim2.new(1, 0, 0, 30)
	Label.Position = UDim2.new(0, 0, 0, 10)
	Label.Text = "THIS HACK IS NO LONGER AVAILABLE"
	Label.TextColor3 = Color3.fromRGB(255, 255, 255)
	Label.BackgroundTransparency = 1
	Label.Font = Enum.Font.SourceSansBold
	Label.TextSize = 14
	Container.CanvasSize = UDim2.new(0, 0, 0, 40)
end

-- About toggle flag
local aboutActive = false

-- Tab button click behavior
for name, btn in pairs(tabButtons) do
	btn.MouseButton1Click:Connect(function()
		if name == "ABOUT" then
			if not aboutActive then
				for _, t in pairs(tabButtons) do
					if t ~= btn then
						t.Visible = false
					end
				end
				btn.Text = "BACK"
				ClearContainer()
				aboutActive = true
			else
				btn.Text = "ABOUT"
				for _, t in pairs(tabButtons) do
					t.Visible = true
				end
				ClearContainer()
				aboutActive = false
			end
		else
			for _, t in pairs(tabButtons) do
				t.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
				t.Visible = true
			end
			btn.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
			aboutActive = false
			tabButtons["ABOUT"].Text = "ABOUT"
			if name == "ESP HACKES" then
				ShowESPTab()
			elseif name == "AIM HACKES" then
				ShowAIMTab()
			elseif name == "VISUAL HACKES" then
				ShowVisualTab()
			end
		end
	end)
end

-- Initially show ESP tab and highlight it
tabButtons["ESP HACKES"].BackgroundColor3 = Color3.fromRGB(70, 70, 70)
ShowESPTab()

-- Icon toggles main frame visibility
Icon.MouseButton1Click:Connect(function()
	Main.Visible = not Main.Visible
end)

-- Close button hides main frame
Close.MouseButton1Click:Connect(function()
	Main.Visible = false
end)
