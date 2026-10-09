-- Services

local UIS = game:GetService("UserInputService")
local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")
local Teams = game:GetService("Teams")
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local GuiService = game:GetService("GuiService")

-- States

local states = {
	PlayerEsp = false,
	AlwaysDay = false,
	DroneEsp = false,
	PlayerTracers = false,
	DroneTracers = false,
	ShowDistance = true,
	AcroNoise = false,
	Radar = false,
	ThreatPanel = false,
	CustomFov = false,
	DroneChams = false,
	PlayerChams = false,
	FpsPanel = false
}

-- Shared state (used across sections)

local menuOpen = false
local clipFrames = {}
local chamsPool = {}

-- Toggle callbacks registered by feature blocks below, consumed by the menu

local Actions = {}

local theme = {
	Background = Color3.fromRGB(14, 12, 19),
	Sidebar = Color3.fromRGB(18, 15, 26),
	Element = Color3.fromRGB(28, 23, 40),
	Hover = Color3.fromRGB(38, 31, 54),
	Stroke = Color3.fromRGB(56, 46, 82),
	Accent = Color3.fromRGB(155, 90, 255),
	Danger = Color3.fromRGB(215, 65, 95),
	Safe = Color3.fromRGB(88, 200, 130),
	Medium = Color3.fromRGB(233, 169, 74),
	SwitchOff = Color3.fromRGB(38, 31, 54),
	Knob = Color3.fromRGB(210, 205, 225),
	Text = Color3.fromRGB(240, 237, 248),
	DimText = Color3.fromRGB(152, 145, 175)
}

local widgetConfig = {
	RadarRange = 300,
	FieldOfView = 90,
	ThreatThreshold = 150
}

local binds = {
	MenuToggle = Enum.KeyCode.RightShift,
	PlayerEsp = Enum.KeyCode.X,
	DroneEsp = Enum.KeyCode.Z,
	AlwaysDay = Enum.KeyCode.K,
	PlayerTracers = Enum.KeyCode.B,
	DroneTracers = Enum.KeyCode.N,
	AcroNoise = Enum.KeyCode.J,
	Radar = Enum.KeyCode.V,
	ThreatPanel = Enum.KeyCode.G,
	CustomFov = Enum.KeyCode.T,
	DroneChams = Enum.KeyCode.Y,
	PlayerChams = Enum.KeyCode.C,
	FpsPanel = Enum.KeyCode.H
}

local SetMenu
local hintLabel

-- Assigned inside feature blocks, used across blocks

local CreateEspChip
local EnableDrag

local function Create(className, properties, children)
	local inst = Instance.new(className)

	for property, value in pairs(properties) do
		inst[property] = value
	end

	if children then
		for _, child in ipairs(children) do
			child.Parent = inst
		end
	end

	return inst
end

local function Tween(inst, props, info)
	TweenService:Create(inst, info or TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), props):Play()
end

local LANGUAGES = {
	RU = {
		TAB_FUNCTIONS = "Функции",
		TAB_SETTINGS = "Настройки",
		TAB_CREDITS = "Автор",
		FN_PLAYER_ESP = "ESP игроков",
		FN_PLAYER_TRACERS = "Трейсеры игроков",
		FN_DRONE_ESP = "ESP дронов",
		FN_DRONE_TRACERS = "Трейсеры дронов",
		FN_RADAR = "Радар",
		FN_THREAT_PANEL = "Панель угрозы",
		FN_CUSTOM_FOV = "Поле зрения",
		FN_DRONE_CHAMS = "Чамсы дронов",
		FN_PLAYER_CHAMS = "Чамсы игроков",
		FN_ACRO_NOISE = "Убрать помехи FPV",
		FN_FPS_PING = "FPS / Ping",
		FN_ALWAYS_DAY = "Всегда день",
		FN_OPEN_MENU = "Открыть / Закрыть меню",
		ESP_AI = "ИИ",
		SECTION_SAFE = "Безопасно",
		SECTION_MEDIUM = "Средний риск",
		SECTION_HIGH = "Высокий риск",
		SET_ORIGIN = "Начало трейсеров",
		SET_DISTANCE = "Показывать дистанцию",
		SET_THICKNESS = "Толщина трейсеров",
		SET_FOV = "Поле зрения (FOV)",
		SET_RADAR_RANGE = "Дальность радара (м)",
		SET_THREAT = "Порог угрозы (м)",
		SET_TEAMS = "Команды (ESP / трейсеры)",
		OPT_CENTER = "Центр",
		OPT_BOTTOM = "Низ",
		HINT = "[%s] показать / скрыть",
		TEAM_DEFENDERS = "Defenders",
		TEAM_CIVILIANS = "Civilians",
		TEAM_OPERATORS = "Operators",
		TEAM_NEUTRAL = "Neutral",
		THREAT_IDLE = "ОЖИДАНИЕ",
		THREAT_TRACKING = "ОТСЛЕЖИВАНИЕ",
		THREAT_CRITICAL = "ЦЕЛЬ БЛИЗКО!",
		SPEED_CLOSING = "сближение %d м/с",
		SPEED_RECEDING = "отход %d м/с",
		CREDITS_LOVE = "Сделано с любовью",
		CREDITS_AUTHORS = "SKeLeTON5227, Shade",
		CREDITS_THANKS = "Спасибо за использование 💜"
	},
	EN = {
		TAB_FUNCTIONS = "Functions",
		TAB_SETTINGS = "Settings",
		TAB_CREDITS = "Credits",
		FN_PLAYER_ESP = "Player ESP",
		FN_PLAYER_TRACERS = "Player Tracers",
		FN_DRONE_ESP = "Drone ESP",
		FN_DRONE_TRACERS = "Drone Tracers",
		FN_RADAR = "Radar",
		FN_THREAT_PANEL = "Threat Panel",
		FN_CUSTOM_FOV = "Field of View",
		FN_DRONE_CHAMS = "Drone Chams",
		FN_PLAYER_CHAMS = "Player Chams",
		FN_ACRO_NOISE = "FPV Noise Removal",
		FN_FPS_PING = "FPS / Ping",
		FN_ALWAYS_DAY = "Always Day",
		FN_OPEN_MENU = "Open / Close Menu",
		ESP_AI = "AI",
		SECTION_SAFE = "Safe",
		SECTION_MEDIUM = "Medium risk",
		SECTION_HIGH = "High risk",
		SET_ORIGIN = "Tracer Origin",
		SET_DISTANCE = "Show Distance",
		SET_THICKNESS = "Tracer Thickness",
		SET_FOV = "Field of View (FOV)",
		SET_RADAR_RANGE = "Radar Range (m)",
		SET_THREAT = "Threat Threshold (m)",
		SET_TEAMS = "Teams (ESP / Tracers)",
		OPT_CENTER = "Center",
		OPT_BOTTOM = "Bottom",
		HINT = "[%s] show / hide",
		TEAM_DEFENDERS = "Defenders",
		TEAM_CIVILIANS = "Civilians",
		TEAM_OPERATORS = "Operators",
		TEAM_NEUTRAL = "Neutral",
		THREAT_IDLE = "STANDBY",
		THREAT_TRACKING = "TRACKING",
		THREAT_CRITICAL = "TARGET CLOSE!",
		SPEED_CLOSING = "closing %d m/s",
		SPEED_RECEDING = "receding %d m/s",
		CREDITS_LOVE = "Made with love",
		CREDITS_AUTHORS = "SKeLeTON5227, Shade",
		CREDITS_THANKS = "Thanks for using 💜"
	},
	PL = {
		TAB_FUNCTIONS = "Funkcje",
		TAB_SETTINGS = "Opcje",
		TAB_CREDITS = "Autorzy",
		FN_PLAYER_ESP = "ESP graczy",
		FN_PLAYER_TRACERS = "Trailery graczy",
		FN_DRONE_ESP = "ESP dronów",
		FN_DRONE_TRACERS = "Trailery dronów",
		FN_RADAR = "Radar",
		FN_THREAT_PANEL = "Panel zagrożeń",
		FN_CUSTOM_FOV = "Pole widzenia",
		FN_DRONE_CHAMS = "Chamsy dronów",
		FN_PLAYER_CHAMS = "Chamsy graczy",
		FN_ACRO_NOISE = "Usuń szumy FPV",
		FN_FPS_PING = "FPS / Ping",
		FN_ALWAYS_DAY = "Zawsze dzień",
		FN_OPEN_MENU = "Otwórz / Zamknij menu",
		ESP_AI = "AI",
		SECTION_SAFE = "Bezpieczne",
		SECTION_MEDIUM = "Średnie ryzyko",
		SECTION_HIGH = "Wysokie ryzyko",
		SET_ORIGIN = "Początek trailerów",
		SET_DISTANCE = "Pokazuj odległość",
		SET_THICKNESS = "Grubość trailerów",
		SET_FOV = "Pole widzenia (FOV)",
		SET_RADAR_RANGE = "Zasięg radaru (m)",
		SET_THREAT = "Próg zagrożenia (m)",
		SET_TEAMS = "Drużyny (ESP / trailery)",
		OPT_CENTER = "Środek",
		OPT_BOTTOM = "Dół",
		HINT = "[%s] pokaż / ukryj",
		TEAM_DEFENDERS = "Defenders",
		TEAM_CIVILIANS = "Civilians",
		TEAM_OPERATORS = "Operators",
		TEAM_NEUTRAL = "Neutral",
		THREAT_IDLE = "CZUWANIE",
		THREAT_TRACKING = "ŚLEDZENIE",
		THREAT_CRITICAL = "CEL BLISKO!",
		SPEED_CLOSING = "zbliżanie %d m/s",
		SPEED_RECEDING = "oddalanie %d m/s",
		CREDITS_LOVE = "Zrobione z miłością",
		CREDITS_AUTHORS = "SKeLeTON5227, Shade",
		CREDITS_THANKS = "Dzięki za korzystanie 💜"
	},
	UK = {
		TAB_FUNCTIONS = "Функції",
		TAB_SETTINGS = "Налаштування",
		TAB_CREDITS = "Автори",
		FN_PLAYER_ESP = "ESP гравців",
		FN_PLAYER_TRACERS = "Трейсери гравців",
		FN_DRONE_ESP = "ESP дронів",
		FN_DRONE_TRACERS = "Трейсери дронів",
		FN_RADAR = "Радар",
		FN_THREAT_PANEL = "Панель загроз",
		FN_CUSTOM_FOV = "Поле зору",
		FN_DRONE_CHAMS = "Чами дронів",
		FN_PLAYER_CHAMS = "Чами гравців",
		FN_ACRO_NOISE = "Прибрати шуми FPV",
		FN_FPS_PING = "FPS / Ping",
		FN_ALWAYS_DAY = "Завжди день",
		FN_OPEN_MENU = "Відкрити / Закрити меню",
		ESP_AI = "ШІ",
		SECTION_SAFE = "Безпечно",
		SECTION_MEDIUM = "Середній ризик",
		SECTION_HIGH = "Високий ризик",
		SET_ORIGIN = "Початок трейсерів",
		SET_DISTANCE = "Показувати відстань",
		SET_THICKNESS = "Товщина трейсерів",
		SET_FOV = "Поле зору (FOV)",
		SET_RADAR_RANGE = "Дальність радару (м)",
		SET_THREAT = "Поріг загрози (м)",
		SET_TEAMS = "Команди (ESP / трейсери)",
		OPT_CENTER = "Центр",
		OPT_BOTTOM = "Низ",
		HINT = "[%s] показати / сховати",
		TEAM_DEFENDERS = "Defenders",
		TEAM_CIVILIANS = "Civilians",
		TEAM_OPERATORS = "Operators",
		TEAM_NEUTRAL = "Neutral",
		THREAT_IDLE = "ОЧІКУВАННЯ",
		THREAT_TRACKING = "ВІДСТЕЖУВАННЯ",
		THREAT_CRITICAL = "ЦІЛЬ БЛИЗЬКО!",
		SPEED_CLOSING = "зближення %d м/с",
		SPEED_RECEDING = "відхід %d м/с",
		CREDITS_LOVE = "Створено з любов'ю",
		CREDITS_AUTHORS = "SKeLeTON5227, Shade",
		CREDITS_THANKS = "Дякуємо за використання 💜"
	}
}

local lang = "EN"
local localizedLabels = {}

local function Localize(key, ...)
	return string.format(LANGUAGES[lang][key], ...)
end

local function RegisterText(inst, key)
	localizedLabels[key] = inst
	inst.Text = Localize(key)
	return inst
end

local function ApplyLanguage()
	for key, inst in pairs(localizedLabels) do
		inst.Text = Localize(key)
	end

	if hintLabel then
		hintLabel.Text = Localize("HINT", binds.MenuToggle.Name)
	end
end

-- Player handles (needed by the language picker below)

local localPlayer = Players.LocalPlayer
local playerGui = localPlayer.PlayerGui

-- Language picker (shown once at startup)

do
	local pickerGui = Create("ScreenGui", {
		Name = "PantsirLangPicker",
		ResetOnSpawn = false,
		DisplayOrder = 10000,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	})

	pcall(function()
		pickerGui.Parent = (type(gethui) == "function" and gethui()) or game:GetService("CoreGui")
	end)

	if not pickerGui.Parent then
		pickerGui.Parent = playerGui
	end

	local frame = Create("CanvasGroup", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0.5, 0, 0.45, 0),
		Size = UDim2.new(0, 300, 0, 250),
		BackgroundColor3 = theme.Background,
		BorderSizePixel = 0,
		GroupTransparency = 1,
		Parent = pickerGui
	}, {
		Create("UIScale", {Scale = 0.9}),
		Create("UICorner", {CornerRadius = UDim.new(0, 10)}),
		Create("UIStroke", {Color = theme.Accent, Thickness = 1, Transparency = 0.5}),
		Create("UIPadding", {
			PaddingTop = UDim.new(0, 14),
			PaddingBottom = UDim.new(0, 14),
			PaddingLeft = UDim.new(0, 16),
			PaddingRight = UDim.new(0, 16)
		})
	})

	local pickerScale = frame:FindFirstChildOfClass("UIScale")

	task.defer(function()
		TweenService:Create(frame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {GroupTransparency = 0}):Play()
		TweenService:Create(pickerScale, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Scale = 1}):Play()
	end)

	Create("TextLabel", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 52),
		Font = Enum.Font.GothamMedium,
		Text = "Select language  ·  Выберите язык\nWybierz język  ·  Виберіть мову",
		TextSize = 13,
		TextColor3 = theme.Text,
		TextWrapped = true,
		Parent = frame
	})

	local languages = {
		{Code = "RU", Label = "Русский"},
		{Code = "EN", Label = "English"},
		{Code = "PL", Label = "Polski"},
		{Code = "UK", Label = "Українська"}
	}

	for index, item in ipairs(languages) do
		local button = Create("TextButton", {
			Position = UDim2.new(0, 0, 0, 58 + (index - 1) * 40),
			Size = UDim2.new(1, 0, 0, 34),
			BackgroundColor3 = theme.Element,
			BorderSizePixel = 0,
			AutoButtonColor = false,
			Font = Enum.Font.GothamMedium,
			Text = item.Label,
			TextSize = 14,
			TextColor3 = theme.DimText,
			Parent = frame
		}, {
			Create("UICorner", {CornerRadius = UDim.new(0, 7)}),
			Create("UIStroke", {Color = theme.Stroke, Transparency = 0.6})
		})

		button.MouseEnter:Connect(function()
			Tween(button, {BackgroundColor3 = theme.Hover, TextColor3 = theme.Text})
		end)

		button.MouseLeave:Connect(function()
			Tween(button, {BackgroundColor3 = theme.Element, TextColor3 = theme.DimText})
		end)

		button.MouseButton1Click:Connect(function()
			lang = item.Code
			ApplyLanguage()

			Tween(frame, {GroupTransparency = 1}, TweenInfo.new(0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.In))
			Tween(pickerScale, {Scale = 0.92}, TweenInfo.new(0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.In))

			task.delay(0.18, function()
				pickerGui:Destroy()
			end)

			task.delay(0.35, function()
				SetMenu(true)
			end)
		end)
	end
end

-- Connections

local connections = {
	PlayerEsp = {},
	AlwaysDay = nil
}

-- Teams

local defendersTeam = Teams:WaitForChild("Defenders")
local operatorsTeam = Teams:WaitForChild("Operators")
local civiliansTeam = Teams:WaitForChild("Civilians")

-- Variables

local dronesFolder = game.Workspace.Drones.SpawnedDrones
local destroyedFolder = workspace:FindFirstChild("DestroyedDrones")

-- ESP shared

local espRegistry = {}
local droneEspEntries = {}

local DRONE_ESP_COLOR = Color3.fromRGB(155, 90, 255)
local DRONE_TRACER_COLOR = Color3.fromRGB(155, 90, 255)
local DRONE_RADAR_COLOR = Color3.fromRGB(155, 90, 255)
local DRONE_DANGER_COLOR = Color3.fromRGB(255, 105, 180)
local DRONE_AI_COLOR = Color3.fromRGB(150, 155, 168)

local teamFilter = {
	Defenders = true,
	Civilians = true,
	Operators = true,
	Neutral = true
}

local function GetTeamColor(player)
	if player.Team == defendersTeam then
		return Color3.fromRGB(2, 221, 255)
	elseif player.Team == civiliansTeam then
		return Color3.fromRGB(34, 206, 54)
	elseif player.Team == operatorsTeam then
		return Color3.fromRGB(255, 131, 133)
	else
		return Color3.new(1, 1, 1)
	end
end

local function IsTeamEnabled(player)
	if player.Team == defendersTeam then
		return teamFilter.Defenders
	elseif player.Team == civiliansTeam then
		return teamFilter.Civilians
	elseif player.Team == operatorsTeam then
		return teamFilter.Operators
	end

	return teamFilter.Neutral
end

-- Finds the drone the local player is currently piloting.
-- The game writes a CurrentCameraMode attribute onto the drone the local
-- camera is attached to, so its presence marks the piloted one.

local function GetPilotedDrone()
	local fallback = nil

	for _, drone in ipairs(dronesFolder:GetChildren()) do
		if drone:IsA("Model")
			and drone:GetAttribute("CurrentCameraMode") ~= nil
			and drone:GetAttribute("Destroyed") ~= true
		then
			if drone:GetAttribute("OwnerUserId") == localPlayer.UserId then
				return drone
			end

			fallback = fallback or drone
		end
	end

	return fallback
end

-- Physical body position, valid even while piloting a drone

local function GetPlayerPosition()
	local character = localPlayer.Character
	local root = character and character:FindFirstChild("HumanoidRootPart")

	return root and root.Position
end

-- Position of whatever the local player "is": piloted drone, or the body

local function GetObserverPosition()
	local piloted = GetPilotedDrone()

	if piloted then
		local droneModel = piloted:FindFirstChildWhichIsA("Model")
		local part = droneModel and droneModel:FindFirstChildWhichIsA("BasePart", true)

		if part then
			return part.Position
		end
	end

	return GetPlayerPosition()
end

local function GetNearestDrone(fromPosition, excludeDrone)
	if not fromPosition then
		return nil
	end

	local nearest, nearestDistance = nil, math.huge

	for _, drone in ipairs(dronesFolder:GetChildren()) do
		if drone:IsA("Model") and drone ~= excludeDrone then
			local droneModel = drone:FindFirstChildWhichIsA("Model")
			local part = droneModel and droneModel:FindFirstChildWhichIsA("BasePart", true)

			if part then
				local distance = (part.Position - fromPosition).Magnitude

				if distance < nearestDistance then
					nearestDistance = distance
					nearest = drone
				end
			end
		end
	end

	return nearest
end

-- Runs a point-provider in isolation: on failure logs the error ONCE and
-- returns nil, so a bad attribute/game state can never kill render loops

local diagShown = {}

local function IsValidPoint(v)
	return typeof(v) == "Vector3"
		and v.X == v.X and v.Y == v.Y and v.Z == v.Z
end

local function TryPoint(name, fn)
	local ok, result = pcall(fn)

	if ok and result ~= nil and not IsValidPoint(result) then
		ok = false
		result = "non-finite or non-vector point"
	end

	if not ok and not diagShown[name] then
		diagShown[name] = true

		pcall(function()
			print("[FemboyHub] " .. name .. " error: " .. tostring(result))
		end)
	end

	if ok then
		return result
	end

	return nil
end

RunService.PreRender:Connect(function()
	local camera = workspace.CurrentCamera
	local reference = TryPoint("observer", GetObserverPosition) or (camera and camera.CFrame.Position)
	local piloted = GetPilotedDrone()
	local nearestDrone = nil

	if reference and (states.DroneEsp or states.DroneTracers) then
		nearestDrone = GetNearestDrone(reference, piloted)
	end

	-- Own piloted drone is excluded from drone ESP

	if piloted and droneEspEntries[piloted] then
		local ownEsp = piloted:FindFirstChild("DroneEsp")

		if ownEsp then
			ownEsp:Destroy()
		end

		droneEspEntries[piloted] = nil
	end

	for index = #espRegistry, 1, -1 do
		local entry = espRegistry[index]
		local part = entry.Part

		if not part or not part.Parent or not entry.Label.Parent then
			table.remove(espRegistry, index)
		elseif reference then
			local distance = (part.Position - reference).Magnitude

			if distance == distance then
				entry.Label.Text = string.format("%dm", math.floor(distance + 0.5))
				entry.Label.Visible = states.ShowDistance
			end

			if entry.Gui then
				local want = IsTeamEnabled(entry.Player)

				if entry.Gui.Enabled ~= want then
					entry.Gui.Enabled = want
				end
			end
		end
	end

	for drone, entry in pairs(droneEspEntries) do
		if not entry.Part or not entry.Part.Parent then
			droneEspEntries[drone] = nil
		else
			if nearestDrone then
				local color = (drone == nearestDrone) and DRONE_DANGER_COLOR or DRONE_ESP_COLOR
				entry.Stroke.Color = color
				entry.Dot.BackgroundColor3 = color
			end

			if entry.Sub then
				local wantSub, wantColor

				if entry.OwnerId then
					local owner = Players:GetPlayerByUserId(entry.OwnerId)

					if owner then
						wantSub = owner.DisplayName
						wantColor = GetTeamColor(owner)
					end
				end

				if not wantSub then
					wantSub = Localize("ESP_AI")
					wantColor = DRONE_AI_COLOR
				end

				if entry.Sub.Text ~= wantSub then
					entry.Sub.Text = wantSub
				end

				entry.Sub.TextColor3 = wantColor
			end
		end
	end
end)

-- ==================== PLAYER ESP BLOCK ====================

do
function CreateEspChip(parent, text, accentColor, subText)
	local chip = Instance.new("Frame")
	chip.Name = "Chip"
	chip.AnchorPoint = Vector2.new(0.5, 0)
	chip.Position = UDim2.new(0.5, 0, 0, 4)
	chip.Size = UDim2.new(0, 0, 0, 26)
	chip.AutomaticSize = Enum.AutomaticSize.X
	chip.BackgroundColor3 = Color3.fromRGB(15, 17, 22)
	chip.BackgroundTransparency = 0.08
	chip.BorderSizePixel = 0
	chip.Parent = parent

	local corners = Instance.new("UICorner")
	corners.CornerRadius = UDim.new(1, 0)
	corners.Parent = chip

	local gradient = Instance.new("UIGradient")
	gradient.Rotation = 90
	gradient.Color = ColorSequence.new(Color3.fromRGB(255, 255, 255), Color3.fromRGB(185, 191, 204))
	gradient.Parent = chip

	local stroke = Instance.new("UIStroke")
	stroke.Color = accentColor
	stroke.Transparency = 0.25
	stroke.Thickness = 1
	stroke.Parent = chip

	local layout = Instance.new("UIListLayout")
	layout.FillDirection = Enum.FillDirection.Horizontal
	layout.VerticalAlignment = Enum.VerticalAlignment.Center
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.Padding = UDim.new(0, 7)
	layout.Parent = chip

	local padding = Instance.new("UIPadding")
	padding.PaddingLeft = UDim.new(0, 10)
	padding.PaddingRight = UDim.new(0, 10)
	padding.Parent = chip

	local dot = Instance.new("Frame")
	dot.Name = "Dot"
	dot.LayoutOrder = 1
	dot.Size = UDim2.new(0, 7, 0, 7)
	dot.BackgroundColor3 = accentColor
	dot.BorderSizePixel = 0
	dot.Parent = chip

	local dotCorners = Instance.new("UICorner")
	dotCorners.CornerRadius = UDim.new(1, 0)
	dotCorners.Parent = dot

	local label = Instance.new("TextLabel")
	label.Name = "Label"
	label.LayoutOrder = 2
	label.BackgroundTransparency = 1
	label.AutomaticSize = Enum.AutomaticSize.X
	label.Size = UDim2.new(0, 0, 0, 14)
	label.Font = Enum.Font.GothamMedium
	label.TextSize = 13
	label.TextColor3 = Color3.fromRGB(240, 242, 247)
	label.Text = text
	label.Parent = chip

	local subLabel = nil

	if subText then
		subLabel = Instance.new("TextLabel")
		subLabel.Name = "Sub"
		subLabel.LayoutOrder = 3
		subLabel.BackgroundTransparency = 1
		subLabel.AutomaticSize = Enum.AutomaticSize.X
		subLabel.Size = UDim2.new(0, 0, 0, 14)
		subLabel.Font = Enum.Font.Gotham
		subLabel.TextSize = 12
		subLabel.TextColor3 = DRONE_AI_COLOR
		subLabel.TextXAlignment = Enum.TextXAlignment.Left
		subLabel.Text = subText
		subLabel.Parent = chip
	end

	local distanceLabel = Instance.new("TextLabel")
	distanceLabel.Name = "Distance"
	distanceLabel.AnchorPoint = Vector2.new(0.5, 0)
	distanceLabel.Position = UDim2.new(0.5, 0, 0, 33)
	distanceLabel.Size = UDim2.new(0, 100, 0, 13)
	distanceLabel.BackgroundTransparency = 1
	distanceLabel.Font = Enum.Font.Gotham
	distanceLabel.TextSize = 11
	distanceLabel.TextColor3 = Color3.fromRGB(198, 203, 213)
	distanceLabel.TextTransparency = 0.1
	distanceLabel.TextXAlignment = Enum.TextXAlignment.Center
	distanceLabel.Text = ""
	distanceLabel.Parent = parent

	return {
		Stroke = stroke,
		Dot = dot,
		Label = label,
		Sub = subLabel,
		Distance = distanceLabel
	}
end

-- PlayerEsp

local function PlayerEspGraphics(player, character)
	if not character then return end
	if character:FindFirstChild("PlayerEsp") then return end

	local rootPart = character:WaitForChild("HumanoidRootPart")
	if not rootPart then return end

	local gui = Instance.new("BillboardGui")
	gui.Name = "PlayerEsp"
	gui.AlwaysOnTop = true
	gui.Size = UDim2.new(0, 240, 0, 50)
	gui.StudsOffset = Vector3.new(0, 3, 0)
	gui.LightInfluence = 0
	gui.Adornee = rootPart
	gui.Parent = character

	local elements = CreateEspChip(gui, player.DisplayName, GetTeamColor(player))

	local function UpdateTeam()
		local color = GetTeamColor(player)
		elements.Stroke.Color = color
		elements.Dot.BackgroundColor3 = color
	end

	UpdateTeam()

	local teamConnection = player:GetPropertyChangedSignal("Team"):Connect(UpdateTeam)

	gui.Destroying:Connect(function()
		teamConnection:Disconnect()
	end)

	table.insert(espRegistry, {Part = rootPart, Label = elements.Distance, Gui = gui, Player = player})
end

local function RemovePlayerEsp(player)
	local character = player.Character

	if character then
		local esp = character:FindFirstChild("PlayerEsp")

		if esp then
			esp:Destroy()
		end
	end
end

local function PlayerEspFunc(player)
	if states.PlayerEsp then
		if player.Character then
			task.spawn(PlayerEspGraphics, player, player.Character)
		end

		if not connections.PlayerEsp[player] then
			connections.PlayerEsp[player] = player.CharacterAdded:Connect(function(character)
				if states.PlayerEsp then
					task.spawn(PlayerEspGraphics, player, character)
				end
			end)
		end
	else
		RemovePlayerEsp(player)
		local connection = connections.PlayerEsp[player]
		if connection then
			connection:Disconnect()
			connections.PlayerEsp[player] = nil
		end
	end
end

local function PlayerEsp()

	states.PlayerEsp = not states.PlayerEsp

	for _, player in Players:GetPlayers() do
		PlayerEspFunc(player)
	end
end

-- Player removing

Players.PlayerRemoving:Connect(function(player)

	local connection = connections.PlayerEsp[player]

	if connection then
		connection:Disconnect()
		connections.PlayerEsp[player] = nil
	end

end)

-- Player adding

Players.PlayerAdded:Connect(function(player)
	if states.PlayerEsp then
		PlayerEspFunc(player)
	end
end)

Actions.PlayerEsp = PlayerEsp

end -- PLAYER ESP BLOCK

-- ==================== ALWAYS DAY BLOCK ====================

do
local function AlwaysDayLogic()
	if states.AlwaysDay then
		if connections.AlwaysDay then return end
		connections.AlwaysDay = RunService.PreRender:Connect(function()
			Lighting.ClockTime = 12.0
		end)
	else
		if not connections.AlwaysDay then return end

		connections.AlwaysDay:Disconnect()
		connections.AlwaysDay = nil
	end
end

local function AlwaysDay()
	states.AlwaysDay = not states.AlwaysDay

	AlwaysDayLogic()
end

Actions.AlwaysDay = AlwaysDay

end -- ALWAYS DAY BLOCK

-- ==================== ACRO / FPV NOISE BLOCK ====================

do
local acroWatchers = {}

local function IsAcroNoiseTarget(descendant)
	return descendant.Name == "Noise" or descendant.Name == "Noise2" or descendant.Name == "ImageTexture"
end

local function IsAcroCross(gui)
	return string.lower(gui.Name) == "acrocross"
end

local function SweepAcroCross(gui)
	for _, descendant in ipairs(gui:GetDescendants()) do
		if IsAcroNoiseTarget(descendant) then
			descendant:Destroy()
		end
	end
end

local function SweepFpvCrossVT(gui)
	local main = gui:FindFirstChild("Main")

	if not main then
		return
	end

	for _, name in ipairs({"Down", "Left", "Right", "Up", "Noise", "Noise2"}) do
		local child = main:FindFirstChild(name)

		if child then
			child:Destroy()
		end
	end

	for _, child in ipairs(main:GetChildren()) do
		if child:IsA("ImageLabel") then
			child:Destroy()
		end
	end
end

local function WatchAcroCross(gui)
	if acroWatchers[gui] then
		return
	end

	if not gui.Parent then
		return
	end

	SweepAcroCross(gui)

	acroWatchers[gui] = gui.DescendantAdded:Connect(function(descendant)
		if states.AcroNoise and IsAcroNoiseTarget(descendant) then
			descendant:Destroy()
		end
	end)
end

local function ClearAcroWatchers()
	for _, connection in pairs(acroWatchers) do
		connection:Disconnect()
	end

	table.clear(acroWatchers)
end

local function RescanFpv()
	for _, gui in ipairs(playerGui:GetChildren()) do
		if gui.Name == "FPVCrossVT" then
			SweepFpvCrossVT(gui)
		elseif IsAcroCross(gui) then
			SweepAcroCross(gui)
		end
	end
end

local function UpgradeFpv(gui)
	if not states.AcroNoise then
		return
	end

	if gui.Name == "FPVCrossVT" then
		SweepFpvCrossVT(gui)
	elseif IsAcroCross(gui) then
		WatchAcroCross(gui)
	end
end

local function AcroNoiseToggle()
	states.AcroNoise = not states.AcroNoise

	if states.AcroNoise then
		RescanFpv()
	else
		ClearAcroWatchers()
	end
end

local function OnFpvAdded(gui)
	if gui.Name == "FPVCrossVT" or IsAcroCross(gui) then
		task.spawn(UpgradeFpv, gui)
	end
end

playerGui.ChildAdded:Connect(OnFpvAdded)

for _, gui in ipairs(playerGui:GetChildren()) do
	OnFpvAdded(gui)
end

Actions.AcroNoise = AcroNoiseToggle

end -- ACRO / FPV NOISE BLOCK

-- ==================== DRONE ESP BLOCK ====================

do
local function RemoveDroneEsp(drone)
	local esp = drone:FindFirstChild("DroneEsp")

	if esp then
		esp:Destroy()
	end

	droneEspEntries[drone] = nil
end

local function DroneEspGraphics(drone)
	if not states.DroneEsp then
		return
	end

	if not drone:IsA("Model") then
		return
	end

	if drone == GetPilotedDrone() then
		return
	end

	if drone:FindFirstChild("DroneEsp") then
		return
	end

	local droneModel = drone:FindFirstChildWhichIsA("Model")

	if not droneModel then
		return
	end

	local adornee = droneModel:FindFirstChildWhichIsA("BasePart", true)

	if not adornee then
		return
	end

	local gui = Instance.new("BillboardGui")
	gui.Name = "DroneEsp"
	gui.AlwaysOnTop = true
	gui.Size = UDim2.new(0, 240, 0, 50)
	gui.StudsOffset = Vector3.new(0, 2.5, 0)
	gui.LightInfluence = 0
	gui.Adornee = adornee
	gui.Parent = drone

	local ownerId = drone:GetAttribute("OwnerUserId")
	local subText = Localize("ESP_AI")

	if ownerId then
		local owner = Players:GetPlayerByUserId(ownerId)

		if owner then
			subText = owner.DisplayName
		end
	end

	local elements = CreateEspChip(gui, droneModel.Name, DRONE_ESP_COLOR, subText)

	table.insert(espRegistry, {Part = adornee, Label = elements.Distance})

	droneEspEntries[drone] = {
		Part = adornee,
		Stroke = elements.Stroke,
		Dot = elements.Dot,
		Sub = elements.Sub,
		OwnerId = ownerId
	}
end

-- Existing drones

local function EnsureDroneEsp(drone)
	for _ = 1, 30 do
		if not states.DroneEsp then
			return
		end

		if drone.Parent ~= dronesFolder then
			return
		end

		DroneEspGraphics(drone)

		if drone:FindFirstChild("DroneEsp") then
			return
		end

		task.wait(0.1)
	end
end

local function LoadDroneEsp()
	for _, drone in ipairs(dronesFolder:GetChildren()) do
		task.spawn(EnsureDroneEsp, drone)
	end
end

-- New drone spawned

dronesFolder.ChildAdded:Connect(function(drone)
	task.spawn(EnsureDroneEsp, drone)
end)

-- Drone moved from SpawnedDrones

dronesFolder.ChildRemoved:Connect(function(drone)
	RemoveDroneEsp(drone)
end)

-- Drone ESP toggle

local function DroneEsp()
	states.DroneEsp = not states.DroneEsp

	if states.DroneEsp then
		LoadDroneEsp()
	else
		for _, drone in ipairs(dronesFolder:GetChildren()) do
			RemoveDroneEsp(drone)
		end
	end
end

Actions.DroneEsp = DroneEsp

end -- DRONE ESP BLOCK

-- Tracer config + Drawing availability stay top-level (settings page writes into them)

local tracerConfig = {
	Origin = "Center", -- "Center" or "Bottom"
	Thickness = 1
}

local drawingAvailable = false

pcall(function()
	drawingAvailable = type(Drawing) == "table" and type(Drawing.new) == "function"
end)

-- ==================== TRACERS BLOCK ====================

do
local tracerPools = {
	PlayerTracers = {},
	DroneTracers = {}
}

local tracerConnections = {
	PlayerTracers = nil,
	DroneTracers = nil
}

local function GetTracerOrigin(camera)
	local viewport = camera.ViewportSize

	if tracerConfig.Origin == "Center" then
		return Vector2.new(viewport.X / 2, viewport.Y / 2)
	end

	return Vector2.new(viewport.X / 2, viewport.Y)
end

local function GetTracerTarget(camera, worldPosition)
	local viewport = camera.ViewportSize
	local point, onScreen = camera:WorldToViewportPoint(worldPosition)

	if onScreen then
		return Vector2.new(point.X, point.Y)
	end

	local relative = camera.CFrame:PointToObjectSpace(worldPosition)
	local direction = Vector2.new(relative.X, -relative.Y)

	if direction.Magnitude < 0.001 then
		if relative.Z > 0 then
			direction = Vector2.new(0, 1)
		else
			return nil
		end
	end

	direction = direction.Unit

	local halfSize = viewport / 2
	local scaleX = direction.X ~= 0 and halfSize.X / math.abs(direction.X) or math.huge
	local scaleY = direction.Y ~= 0 and halfSize.Y / math.abs(direction.Y) or math.huge
	local scale = math.min(scaleX, scaleY)

	return Vector2.new(viewport.X / 2, viewport.Y / 2) + direction * scale
end

-- Liang-Barsky segment vs GUI frame (viewport coordinates).
-- Returns up to two sub-segments (s1From, s1To, s2From, s2To).

local function ClipSegmentAgainstRect(fromPoint, toPoint, frame)
	local minPoint = frame.AbsolutePosition + GuiService:GetGuiInset()
	local maxPoint = minPoint + frame.AbsoluteSize
	local delta = toPoint - fromPoint

	local p = {-delta.X, delta.X, -delta.Y, delta.Y}
	local q = {
		fromPoint.X - minPoint.X,
		maxPoint.X - fromPoint.X,
		fromPoint.Y - minPoint.Y,
		maxPoint.Y - fromPoint.Y
	}

	local tEnter, tExit = 0, 1

	for i = 1, 4 do
		if p[i] == 0 then
			if q[i] < 0 then
				return fromPoint, toPoint, nil, nil
			end
		else
			local t = q[i] / p[i]

			if p[i] < 0 then
				if t > tExit then
					return fromPoint, toPoint, nil, nil
				end

				if t > tEnter then
					tEnter = t
				end
			else
				if t < tEnter then
					return fromPoint, toPoint, nil, nil
				end

				if t < tExit then
					tExit = t
				end
			end
		end
	end

	if tEnter > 0 and tEnter < 1 then
		if tExit < 1 then
			return fromPoint, fromPoint + delta * tEnter, fromPoint + delta * tExit, toPoint
		end

		return fromPoint, fromPoint + delta * tEnter, nil, nil
	end

	if tExit < 1 then
		return fromPoint + delta * tExit, toPoint, nil, nil
	end

	return fromPoint, fromPoint, nil, nil
end

-- Clips a tracer against every visible registered frame (menu + panels)

local function BuildClippedSegments(fromPoint, toPoint)
	local segments = {{fromPoint, toPoint}}

	for _, frame in ipairs(clipFrames) do
		if frame.Visible and frame.AbsoluteSize.X > 0 then
			local nextSegments = {}

			for _, segment in ipairs(segments) do
				local s1From, s1To, s2From, s2To = ClipSegmentAgainstRect(segment[1], segment[2], frame)

				table.insert(nextSegments, {s1From, s1To})

				if s2From then
					table.insert(nextSegments, {s2From, s2To})
				end
			end

			segments = nextSegments
		end
	end

	return segments
end

local function AcquireTracerLine(pool, key)
	local tracer = pool[key]

	if not tracer then
		local mainLine = Drawing.new("Line")
		mainLine.Thickness = 1
		mainLine.Transparency = 1
		mainLine.Visible = false

		tracer = {line = mainLine, extras = {}}
		pool[key] = tracer
	end

	return tracer
end

local function HideTracer(tracer)
	tracer.line.Visible = false

	for _, extraLine in pairs(tracer.extras) do
		extraLine.Visible = false
	end
end

local function ApplyTracerDraw(tracer, segments, color, thickness)
	for index = #tracer.extras + 1, #segments - 1 do
		local extraLine = Drawing.new("Line")
		extraLine.Thickness = 1
		extraLine.Transparency = 1
		extraLine.Visible = false
		tracer.extras[index] = extraLine
	end

	for index, segment in ipairs(segments) do
		local drawLine = index == 1 and tracer.line or tracer.extras[index - 1]

		if (segment[2] - segment[1]).Magnitude < 2 then
			drawLine.Visible = false
		else
			drawLine.From = segment[1]
			drawLine.To = segment[2]
			drawLine.Color = color
			drawLine.Thickness = thickness
			drawLine.Visible = true
		end
	end

	for index = #segments, #tracer.extras do
		local extraLine = tracer.extras[index]

		if extraLine then
			extraLine.Visible = false
		end
	end
end

local function ClearTracerPool(pool)
	for _, tracer in pairs(pool) do
		tracer.line:Remove()

		for _, extraLine in pairs(tracer.extras) do
			extraLine:Remove()
		end
	end

	table.clear(pool)
end

local function UpdatePlayerTracers()
	local camera = workspace.CurrentCamera

	if not camera then
		return
	end

	local origin = GetTracerOrigin(camera)

	for _, player in ipairs(Players:GetPlayers()) do
		local tracer = AcquireTracerLine(tracerPools.PlayerTracers, player)
		local target = nil

		if player ~= localPlayer and IsTeamEnabled(player) then
			local character = player.Character
			local rootPart = character and character:FindFirstChild("HumanoidRootPart")

			if rootPart then
				target = GetTracerTarget(camera, rootPart.Position)
			end
		end

		if target then
			ApplyTracerDraw(
				tracer,
				BuildClippedSegments(origin, target),
				GetTeamColor(player),
				tracerConfig.Thickness
			)
		else
			HideTracer(tracer)
		end
	end
end

local function UpdateDroneTracers()
	local camera = workspace.CurrentCamera

	if not camera then
		return
	end

	local origin = GetTracerOrigin(camera)
	local piloted = GetPilotedDrone()
	local nearestDrone = GetNearestDrone(TryPoint("observer", GetObserverPosition) or camera.CFrame.Position, piloted)

	for _, drone in ipairs(dronesFolder:GetChildren()) do
		local tracer = AcquireTracerLine(tracerPools.DroneTracers, drone)
		local isNearest = drone == nearestDrone
		local target = nil

		if drone:IsA("Model") and drone ~= piloted then
			local droneModel = drone:FindFirstChildWhichIsA("Model")
			local part = droneModel and droneModel:FindFirstChildWhichIsA("BasePart", true)

			if part then
				target = GetTracerTarget(camera, part.Position)
			end
		end

		if target then
			ApplyTracerDraw(
				tracer,
				BuildClippedSegments(origin, target),
				isNearest and DRONE_DANGER_COLOR or DRONE_TRACER_COLOR,
				isNearest and tracerConfig.Thickness + 1 or tracerConfig.Thickness
			)
		else
			HideTracer(tracer)
		end
	end
end

local function UpdateTracersConnection(kind, updateFunction)
	if states[kind] then
		if not tracerConnections[kind] then
			tracerConnections[kind] = RunService.PreRender:Connect(updateFunction)
		end
	else
		if not tracerConnections[kind] then
			return
		end

		tracerConnections[kind]:Disconnect()
		tracerConnections[kind] = nil
		ClearTracerPool(tracerPools[kind])
	end
end

local function PlayerTracers()
	if not drawingAvailable then
		return
	end

	states.PlayerTracers = not states.PlayerTracers

	UpdateTracersConnection("PlayerTracers", UpdatePlayerTracers)
end

local function DroneTracers()
	if not drawingAvailable then
		return
	end

	states.DroneTracers = not states.DroneTracers

	UpdateTracersConnection("DroneTracers", UpdateDroneTracers)
end

Players.PlayerRemoving:Connect(function(player)
	local tracer = tracerPools.PlayerTracers[player]

	if tracer then
		tracer.line:Remove()

		for _, extraLine in pairs(tracer.extras) do
			extraLine:Remove()
		end

		tracerPools.PlayerTracers[player] = nil
	end
end)

dronesFolder.ChildRemoved:Connect(function(drone)
	local tracer = tracerPools.DroneTracers[drone]

	if tracer then
		tracer.line:Remove()

		for _, extraLine in pairs(tracer.extras) do
			extraLine:Remove()
		end

		tracerPools.DroneTracers[drone] = nil
	end

	local cham = chamsPool[drone]

	if cham then
		cham:Destroy()
		chamsPool[drone] = nil
	end
end)

Actions.PlayerTracers = PlayerTracers
Actions.DroneTracers = DroneTracers

end -- TRACERS BLOCK

-- ==================== WIDGETS + CHAMS BLOCK ====================

do
function EnableDrag(target, handle)
	local dragging = false
	local dragStart, startPos

	handle.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = target.Position
		end
	end)

	UIS.InputChanged:Connect(function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			local delta = input.Position - dragStart

			target.Position = UDim2.new(
				startPos.X.Scale, startPos.X.Offset + delta.X,
				startPos.Y.Scale, startPos.Y.Offset + delta.Y
			)
		end
	end)

	UIS.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = false
		end
	end)
end

local widgetGui = Create("ScreenGui", {
	Name = "PantsirWidgets",
	ResetOnSpawn = false,
	DisplayOrder = 9998,
	ZIndexBehavior = Enum.ZIndexBehavior.Sibling
})

local widgetParented = pcall(function()
	widgetGui.Parent = (type(gethui) == "function" and gethui()) or game:GetService("CoreGui")
end)

if not widgetParented then
	widgetGui.Parent = playerGui
end

local function CreateWidgetPanel(name, position, width)
	local panel = Create("CanvasGroup", {
		Name = name,
		Position = position,
		Size = UDim2.new(0, width, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundColor3 = theme.Background,
		BackgroundTransparency = 0.08,
		BorderSizePixel = 0,
		Visible = false,
		Parent = widgetGui
	}, {
		Create("UICorner", {CornerRadius = UDim.new(0, 9)}),
		Create("UIStroke", {Color = theme.Stroke, Thickness = 1, Transparency = 0.35}),
		Create("UIPadding", {
			PaddingTop = UDim.new(0, 8),
			PaddingBottom = UDim.new(0, 10),
			PaddingLeft = UDim.new(0, 12),
			PaddingRight = UDim.new(0, 12)
		})
	})

	table.insert(clipFrames, panel)

	return panel
end

-- FPS / Ping panel

local fpsPanel = CreateWidgetPanel("FpsPanel", UDim2.new(0, 12, 0, 12), 132)

Create("TextLabel", {
	BackgroundTransparency = 1,
	Size = UDim2.new(1, 0, 0, 14),
	Font = Enum.Font.GothamBold,
	Text = "SYSTEM",
	TextSize = 12,
	TextColor3 = theme.Accent,
	TextXAlignment = Enum.TextXAlignment.Left,
	Parent = fpsPanel
})

local fpsLabel = Create("TextLabel", {
	BackgroundTransparency = 1,
	Position = UDim2.new(0, 0, 0, 20),
	Size = UDim2.new(1, 0, 0, 22),
	Font = Enum.Font.GothamBold,
	Text = "FPS --",
	TextSize = 17,
	TextColor3 = theme.Text,
	TextXAlignment = Enum.TextXAlignment.Left,
	Parent = fpsPanel
})

local pingLabel = Create("TextLabel", {
	BackgroundTransparency = 1,
	Position = UDim2.new(0, 0, 0, 46),
	Size = UDim2.new(1, 0, 0, 16),
	Font = Enum.Font.Gotham,
	Text = "Ping --",
	TextSize = 13,
	TextColor3 = theme.DimText,
	TextXAlignment = Enum.TextXAlignment.Left,
	Parent = fpsPanel
})

EnableDrag(fpsPanel, fpsPanel)

-- Threat panel

local threatPanel = CreateWidgetPanel("ThreatPanel", UDim2.new(0.5, -120, 0, 12), 240)

local threatStroke = threatPanel:FindFirstChildOfClass("UIStroke")

local threatHeader = Create("TextLabel", {
	BackgroundTransparency = 1,
	Size = UDim2.new(1, 0, 0, 14),
	Font = Enum.Font.GothamBold,
	Text = "",
	TextSize = 12,
	TextColor3 = theme.DimText,
	TextXAlignment = Enum.TextXAlignment.Left,
	Parent = threatPanel
})

local threatDistance = Create("TextLabel", {
	BackgroundTransparency = 1,
	Position = UDim2.new(0, 0, 0, 20),
	Size = UDim2.new(1, 0, 0, 28),
	Font = Enum.Font.GothamBold,
	Text = "--",
	TextSize = 24,
	TextColor3 = theme.Text,
	TextXAlignment = Enum.TextXAlignment.Left,
	Parent = threatPanel
})

local threatSpeed = Create("TextLabel", {
	BackgroundTransparency = 1,
	Position = UDim2.new(0, 0, 0, 52),
	Size = UDim2.new(1, 0, 0, 16),
	Font = Enum.Font.Gotham,
	Text = "",
	TextSize = 13,
	TextColor3 = theme.DimText,
	TextXAlignment = Enum.TextXAlignment.Left,
	Parent = threatPanel
})

EnableDrag(threatPanel, threatPanel)

local threatState = {
	lastKey = nil,
	lastDistance = nil,
	speed = 0
}

-- Radar (Drawing)

local radarBackdrop = Create("Frame", {
	Name = "RadarBackdrop",
	AnchorPoint = Vector2.new(0.5, 0.5),
	Size = UDim2.new(0, 240, 0, 240),
	BackgroundColor3 = theme.Background,
	BackgroundTransparency = 0.06,
	BorderSizePixel = 0,
	Visible = false,
	Parent = widgetGui
}, {
	Create("UICorner", {CornerRadius = UDim.new(0, 10)})
})

local nearestDroneCache = nil

local radarState = {
	center = nil,
	half = 112,
	scan = 0,
	dragging = false,
	grabOffset = nil,
	lastYaw = nil,
	border = nil,
	crossH = nil,
	crossV = nil,
	scanline = nil,
	centerDot = nil,
	blips = {},
	labels = {}
}

local function RadarNewCircle(filled)
	local circle = Drawing.new("Circle")
	circle.NumSides = 48
	circle.Filled = filled
	circle.Visible = false
	return circle
end

local function RadarEnsureStatics()
	if radarState.border or not drawingAvailable then
		return
	end

	radarState.border = Drawing.new("Square")
	radarState.border.Thickness = 2
	radarState.border.Color = theme.Accent
	radarState.border.Transparency = 0.45
	radarState.border.Filled = false
	radarState.border.Visible = false

	radarState.crossH = Drawing.new("Line")
	radarState.crossV = Drawing.new("Line")

	for _, line in ipairs({radarState.crossH, radarState.crossV}) do
		line.Thickness = 1
		line.Color = theme.Stroke
		line.Transparency = 0.75
		line.Visible = false
	end

	radarState.scanline = Drawing.new("Line")
	radarState.scanline.Thickness = 1
	radarState.scanline.Color = theme.Accent
	radarState.scanline.Transparency = 0.5
	radarState.scanline.Visible = false

	radarState.centerDot = RadarNewCircle(true)
	radarState.centerDot.Radius = 2
	radarState.centerDot.Color = Color3.new(1, 1, 1)
	radarState.centerDot.Transparency = 0.4
end

local function RadarAcquireBlip(entity)
	local blip = radarState.blips[entity]

	if not blip then
		blip = RadarNewCircle(true)
		blip.Thickness = 3
		blip.Transparency = 0.05
		radarState.blips[entity] = blip
	end

	return blip
end

local function RadarAcquireLabel(entity)
	local label = radarState.labels[entity]

	if not label then
		label = Drawing.new("Text")
		label.Size = 13
		label.Center = true
		label.Outline = true
		label.Visible = false
		radarState.labels[entity] = label
	end

	return label
end

UIS.InputBegan:Connect(function(input)
	if not states.Radar or not radarState.center then
		return
	end

	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		local mousePos = Vector2.new(input.Position.X, input.Position.Y)

		if (mousePos - radarState.center).Magnitude <= radarState.half + 14 then
			radarState.dragging = true
			radarState.grabOffset = mousePos - radarState.center
		end
	end
end)

UIS.InputChanged:Connect(function(input)
	if radarState.dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
		local camera = workspace.CurrentCamera

		if camera then
			local viewport = camera.ViewportSize
			local target = Vector2.new(input.Position.X, input.Position.Y) - radarState.grabOffset

			radarState.center = Vector2.new(
				math.clamp(target.X, radarState.half, viewport.X - radarState.half),
				math.clamp(target.Y, radarState.half + 36, viewport.Y - radarState.half)
			)
		end
	end
end)

UIS.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		radarState.dragging = false
	end
end)

local function RadarRender(delta, camera)
	local visible = states.Radar
	local half = radarState.half

	radarBackdrop.Visible = visible

	if not visible or not drawingAvailable or not camera then
		-- Radar disabled: hide everything it left on screen

		if radarState.border then
			radarState.border.Visible = false
			radarState.crossH.Visible = false
			radarState.crossV.Visible = false
			radarState.scanline.Visible = false
			radarState.centerDot.Visible = false
		end

		for _, blip in pairs(radarState.blips) do
			blip.Visible = false
		end

		for _, label in pairs(radarState.labels) do
			label.Visible = false
		end

		return
	end

	RadarEnsureStatics()

	if not radarState.border then
		return
	end

	local center = radarState.center

	if not center then
		local viewport = camera.ViewportSize
		center = Vector2.new(viewport.X - half - 20, half + 56)
		radarState.center = center
	end

	local inset = GuiService:GetGuiInset()

	radarBackdrop.Position = UDim2.fromOffset(center.X - inset.X, center.Y - inset.Y)

	-- Blips are measured from the piloted drone (or the body), rotation follows the view

	local originPosition = TryPoint("observer", GetObserverPosition) or camera.CFrame.Position

	radarState.border.Position = center - Vector2.new(half, half)
	radarState.border.Size = Vector2.new(half * 2, half * 2)
	radarState.border.Visible = visible

	radarState.crossH.From = center - Vector2.new(half, 0)
	radarState.crossH.To = center + Vector2.new(half, 0)
	radarState.crossH.Visible = visible

	radarState.crossV.From = center - Vector2.new(0, half)
	radarState.crossV.To = center + Vector2.new(0, half)
	radarState.crossV.Visible = visible

	radarState.scan = (radarState.scan + delta * 60) % (half * 2)

	radarState.scanline.From = center + Vector2.new(-half, radarState.scan - half)
	radarState.scanline.To = center + Vector2.new(half, radarState.scan - half)
	radarState.scanline.Visible = visible

	radarState.centerDot.Position = center
	radarState.centerDot.Visible = visible

	local desired = {}

	if visible then
		local range = widgetConfig.RadarRange

		for _, drone in ipairs(dronesFolder:GetChildren()) do
			if drone:IsA("Model") then
				local droneModel = drone:FindFirstChildWhichIsA("Model")
				local part = droneModel and droneModel:FindFirstChildWhichIsA("BasePart", true)

				if part then
					desired[drone] = {
						World = part.Position,
						Color = (drone == nearestDroneCache) and DRONE_DANGER_COLOR or DRONE_RADAR_COLOR,
						Radius = (drone == nearestDroneCache) and 7 or 5.5
					}
				end
			end
		end

		for _, player in ipairs(Players:GetPlayers()) do
			if player ~= localPlayer and IsTeamEnabled(player) then
				local character = player.Character
				local rootPart = character and character:FindFirstChild("HumanoidRootPart")

				if rootPart then
					desired[player] = {
						World = rootPart.Position,
						Color = GetTeamColor(player),
						Radius = 5
					}
				end
			end
		end
	end

	for entity, blip in pairs(radarState.blips) do
		if not desired[entity] then
			blip:Remove()
			radarState.blips[entity] = nil
		end
	end

	for entity, label in pairs(radarState.labels) do
		if not desired[entity] then
			label:Remove()
			radarState.labels[entity] = nil
		end
	end

	for entity, info in pairs(desired) do
		-- Yaw-only projection: radar ignores camera pitch, targets stay put
		-- while looking up/down

		local offset = info.World - originPosition
		local lookFlat = Vector3.new(camera.CFrame.LookVector.X, 0, camera.CFrame.LookVector.Z)

		if lookFlat.Magnitude > 0.001 then
			lookFlat = lookFlat.Unit
			radarState.lastYaw = lookFlat
		elseif radarState.lastYaw then
			lookFlat = radarState.lastYaw
		else
			lookFlat = Vector3.new(0, 0, -1)
		end

		local rightFlat = Vector3.new(-lookFlat.Z, 0, lookFlat.X)

		local flat = Vector2.new(
			offset.X * rightFlat.X + offset.Z * rightFlat.Z,
			-(offset.X * lookFlat.X + offset.Z * lookFlat.Z)
		)

		local distance = flat.Magnitude

		local blip = RadarAcquireBlip(entity)
		local direction = distance > 0.01 and flat.Unit or Vector2.zero
		local drawDistance = math.min(distance, widgetConfig.RadarRange)

		local maxAxis = math.max(half - info.Radius - 6, 0)

		local offsetPixels

		if distance > widgetConfig.RadarRange then
			-- Pin to the square border along the target direction (no circle!)

			local edgeScale = math.min(
				maxAxis / math.max(math.abs(direction.X), 1e-6),
				maxAxis / math.max(math.abs(direction.Y), 1e-6)
			)

			offsetPixels = direction * edgeScale
			blip.Transparency = 0.45
		else
			offsetPixels = direction * drawDistance * (half / widgetConfig.RadarRange)
			blip.Transparency = 0.05
		end

		local blipPosition = center + offsetPixels

		blip.Position = blipPosition
		blip.Color = info.Color
		blip.Radius = info.Radius
		blip.Visible = true

		local label = RadarAcquireLabel(entity)
		label.Text = math.floor(distance + 0.5) .. "m"
		label.Position = blipPosition + Vector2.new(0, info.Radius + 10)
		label.Color = info.Color
		label.Visible = true
	end
end

-- Chams

local playerChamsPool = {}
local droneChamsConnection = nil
local playerChamsConnection = nil

local function AcquireHighlight(pool, target)
	local highlight = pool[target]

	if not highlight or highlight.Parent == nil then
		highlight = Instance.new("Highlight")
		highlight.Name = "PantsirCham"
		highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
		highlight.FillTransparency = 0.55
		highlight.OutlineTransparency = 0
		highlight.Enabled = true
		highlight.Parent = target
		pool[target] = highlight
	end

	return highlight
end

local function ClearHighlights(pool)
	for _, highlight in pairs(pool) do
		highlight:Destroy()
	end

	table.clear(pool)
end

local function UpdateDroneChams()
	for _, drone in ipairs(dronesFolder:GetChildren()) do
		if drone:IsA("Model") then
			local highlight = AcquireHighlight(chamsPool, drone)

			highlight.FillColor = Color3.fromRGB(140, 60, 255)
			highlight.OutlineColor = Color3.fromRGB(170, 100, 255)
		end
	end

	for drone, highlight in pairs(chamsPool) do
		if not drone:IsDescendantOf(workspace) then
			highlight:Destroy()
			chamsPool[drone] = nil
		end
	end
end

local function UpdatePlayerChams()
	local seen = {}

	for _, player in ipairs(Players:GetPlayers()) do
		if player ~= localPlayer and IsTeamEnabled(player) then
			local character = player.Character

			if character and character:FindFirstChild("HumanoidRootPart") then
				local highlight = AcquireHighlight(playerChamsPool, character)

				-- Team color, same as the ESP pill accent

				highlight.FillColor = GetTeamColor(player)
				highlight.OutlineColor = GetTeamColor(player)

				seen[character] = true
			end
		end
	end

	for character, highlight in pairs(playerChamsPool) do
		if not seen[character] then
			highlight:Destroy()
			playerChamsPool[character] = nil
		end
	end
end

local function UpdateChamsConnections()
	if states.DroneChams then
		if not droneChamsConnection then
			droneChamsConnection = RunService.PreRender:Connect(UpdateDroneChams)
		end
	else
		if droneChamsConnection then
			droneChamsConnection:Disconnect()
			droneChamsConnection = nil
		end

		ClearHighlights(chamsPool)
	end

	if states.PlayerChams then
		if not playerChamsConnection then
			playerChamsConnection = RunService.PreRender:Connect(UpdatePlayerChams)
		end
	else
		if playerChamsConnection then
			playerChamsConnection:Disconnect()
			playerChamsConnection = nil
		end

		ClearHighlights(playerChamsPool)
	end
end

-- Threat panel render

local function ThreatRender(delta, camera)
	threatPanel.Visible = states.ThreatPanel

	if not states.ThreatPanel or not camera then
		return
	end

	local part = nil
	local distance = nil

	-- Threat is always measured from the physical body, even while piloting

	local playerPos = TryPoint("playerPos", GetPlayerPosition)
	local threatDrone = GetNearestDrone(playerPos, GetPilotedDrone())

	if threatDrone then
		local droneModel = threatDrone:FindFirstChildWhichIsA("Model")
		part = droneModel and droneModel:FindFirstChildWhichIsA("BasePart", true)
	end

	if part and playerPos then
		local d = (part.Position - playerPos).Magnitude

		if d == d then
			distance = d
		end
	end

	if distance then
		local key = threatDrone.Name

		if threatState.lastKey ~= key then
			threatState.lastKey = key
			threatState.lastDistance = nil
			threatState.speed = 0
		end

		if threatState.lastDistance then
			local instant = (threatState.lastDistance - distance) / delta

			threatState.speed = threatState.speed + (instant - threatState.speed) * math.min(delta * 6, 1)
		end

		threatState.lastDistance = distance

		threatDistance.Text = string.format("%d m", math.floor(distance + 0.5))

		if threatState.speed > 0.5 then
			threatSpeed.Text = Localize("SPEED_CLOSING", math.floor(threatState.speed + 0.5))
		else
			threatSpeed.Text = Localize("SPEED_RECEDING", math.floor(-threatState.speed + 0.5))
		end

		if distance <= widgetConfig.ThreatThreshold then
			threatHeader.Text = Localize("THREAT_CRITICAL")
			threatHeader.TextColor3 = theme.Danger
			threatStroke.Color = theme.Danger
			threatDistance.TextColor3 = theme.Danger
		else
			threatHeader.Text = Localize("THREAT_TRACKING")
			threatHeader.TextColor3 = theme.Accent
			threatStroke.Color = theme.Stroke
			threatDistance.TextColor3 = theme.Text
		end
	else
		threatState.lastKey = nil
		threatState.lastDistance = nil
		threatState.speed = 0

		threatHeader.Text = Localize("THREAT_IDLE")
		threatHeader.TextColor3 = theme.DimText
		threatStroke.Color = theme.Stroke
		threatDistance.Text = "--"
		threatDistance.TextColor3 = theme.Text
		threatSpeed.Text = ""
	end
end

-- Master widget loop

local fpsFrames = 0
local fpsTime = 0
local pingTime = 0

RunService.PreRender:Connect(function(delta)
	delta = math.min(delta, 0.1)

	fpsPanel.Visible = states.FpsPanel

	local camera = workspace.CurrentCamera

	if camera and states.CustomFov then
		camera.FieldOfView = widgetConfig.FieldOfView
	end

	nearestDroneCache = nil

	if camera and (states.Radar or states.ThreatPanel or states.DroneChams) then
		nearestDroneCache = GetNearestDrone(TryPoint("observer", GetObserverPosition) or camera.CFrame.Position)
	end

	fpsFrames = fpsFrames + 1
	fpsTime = fpsTime + delta

	if states.FpsPanel and fpsTime >= 0.5 then
		fpsLabel.Text = string.format("FPS %d", math.floor(fpsFrames / fpsTime + 0.5))
		fpsFrames = 0
		fpsTime = 0
	end

	pingTime = pingTime + delta

	if states.FpsPanel and pingTime >= 1 then
		pingTime = 0

		local ok, ping = pcall(localPlayer.GetNetworkPing, localPlayer)

		if ok then
			pingLabel.Text = string.format("Ping %d ms", math.floor(ping * 1000 + 0.5))
		end
	end

	RadarRender(delta, camera)
	ThreatRender(delta, camera)
end)

-- Widget toggles

local function Radar()
	states.Radar = not states.Radar
end

local function ThreatPanelToggle()
	states.ThreatPanel = not states.ThreatPanel
	threatState.lastKey = nil
end

local function CustomFov()
	states.CustomFov = not states.CustomFov

	local camera = workspace.CurrentCamera

	if not states.CustomFov and camera then
		camera.FieldOfView = 70
	end
end

local function DroneChams()
	states.DroneChams = not states.DroneChams
	UpdateChamsConnections()
end

local function PlayerChams()
	states.PlayerChams = not states.PlayerChams
	UpdateChamsConnections()
end

local function FpsPanelToggle()
	states.FpsPanel = not states.FpsPanel
	fpsPanel.Visible = states.FpsPanel
end

Actions.Radar = Radar
Actions.ThreatPanel = ThreatPanelToggle
Actions.CustomFov = CustomFov
Actions.DroneChams = DroneChams
Actions.PlayerChams = PlayerChams
Actions.FpsPanel = FpsPanelToggle

end -- WIDGETS + CHAMS BLOCK

-- ==================== DOMAIN EXPANSION BLOCK ====================
-- Hidden client-side cinematic, activated by typing "domain" on the keyboard.
-- Everything is purely visual and local: entities caught inside are frozen
-- only on this client, the server never knows about any of this.

do

-- Tunables

local DOMAIN_DURATION = 30
local DOMAIN_CAST_TIME = 2.0
local DOMAIN_COLLAPSE_TIME = 1.2
local DOMAIN_RADIUS = 120

-- TODO: замени на свои rbxassetid (0 = звук выключен)

local SOUND_CAST_ID = 0
local SOUND_AMBIENT_ID = 0

-- Palette

local VOID_PURPLE = Color3.fromRGB(124, 78, 255)
local VOID_PALE = Color3.fromRGB(196, 176, 255)
local VOID_DEEP = Color3.fromRGB(24, 12, 48)

-- State

local voidState = {
	active = false,
	collapsing = false,
	t0 = 0,
	scanAcc = 1,
	center = nil,
	holePos = nil,
	spin = 0,
	ringTilt = nil,
	sphere = nil,
	core = nil,
	ringsModel = nil,
	emitters = {},
	frozen = {},
	instances = {},
	conns = {},
	joints = nil,
	savedFov = nil
}

local function VoidNew(className, props, children)
	local inst = Create(className, props, children)
	table.insert(voidState.instances, inst)
	return inst
end

local function VoidConn(conn)
	table.insert(voidState.conns, conn)
	return conn
end

-- Full teardown: releases pins, restores pose/fx, destroys everything

local function VoidCleanup()
	if not voidState.active then
		return
	end

	voidState.active = false
	voidState.collapsing = false
	voidState.gen = (voidState.gen or 0) + 1

	for part in pairs(voidState.frozen) do
		local data = voidState.frozen[part]
		voidState.frozen[part] = nil

		pcall(function()
			if data.hl then
				data.hl:Destroy()
			end

			if data.conn then
				data.conn:Disconnect()
			end

			if data.humanoid then
				data.humanoid.WalkSpeed = data.ws or 16
				data.humanoid.JumpPower = data.jp or 50
			end
		end)
	end

	pcall(function()
		local char = localPlayer.Character
		local hrp = char and char:FindFirstChild("HumanoidRootPart")

		if hrp then
			hrp.Anchored = false
		end
	end)

	if voidState.joints then
		for joint, c0 in pairs(voidState.joints) do
			pcall(function()
				joint.C0 = c0
			end)
		end

		voidState.joints = nil
	end

	for _, conn in ipairs(voidState.conns) do
		pcall(function()
			conn:Disconnect()
		end)
	end

	table.clear(voidState.conns)

	for _, inst in ipairs(voidState.instances) do
		pcall(function()
			inst:Destroy()
		end)
	end

	table.clear(voidState.instances)
	table.clear(voidState.emitters)

	if voidState.savedFov and not states.CustomFov then
		local cam = workspace.CurrentCamera

		if cam then
			cam.FieldOfView = voidState.savedFov
		end
	end

	voidState.savedFov = nil
	voidState.center = nil
	voidState.sphere = nil
	voidState.core = nil
	voidState.ringsModel = nil
	voidState.holePos = nil
end

-- Freezing

local function VoidCapture(part, kind)
	if voidState.frozen[part] then
		return
	end

	local data = {kind = kind, cf = part.CFrame}

	if kind == "player" then
		local character = part.Parent
		local humanoid = character and character:FindFirstChildOfClass("Humanoid")

		if humanoid then
			data.humanoid = humanoid
			data.ws = humanoid.WalkSpeed
			data.jp = humanoid.JumpPower
			humanoid.WalkSpeed = 0
			humanoid.JumpPower = 0
		end

		local animator = humanoid and humanoid:FindFirstChildOfClass("Animator")

		if animator then
			for _, track in ipairs(animator:GetPlayingAnimationTracks()) do
				pcall(function()
					track:Stop(0.15)
				end)
			end

			data.conn = VoidConn(animator.AnimationPlayed:Connect(function(track)
				pcall(function()
					track:Stop(0.1)
				end)
			end))
		end

		if character then
			data.hl = VoidNew("Highlight", {
				Name = "VoidCapture",
				FillColor = VOID_DEEP,
				OutlineColor = VOID_PURPLE,
				FillTransparency = 0.45,
				OutlineTransparency = 0.1,
				DepthMode = Enum.HighlightDepthMode.AlwaysOnTop,
				Parent = character
			})
		end
	else
		local model = part.Parent

		if model and model:IsA("Model") then
			data.hl = VoidNew("Highlight", {
				Name = "VoidCapture",
				FillColor = VOID_DEEP,
				OutlineColor = VOID_PURPLE,
				FillTransparency = 0.55,
				OutlineTransparency = 0.05,
				DepthMode = Enum.HighlightDepthMode.AlwaysOnTop,
				Parent = model
			})
		end
	end

	voidState.frozen[part] = data
end

local function VoidRelease(part)
	local data = voidState.frozen[part]

	if not data then
		return
	end

	voidState.frozen[part] = nil

	pcall(function()
		if data.hl then
			data.hl:Destroy()
		end

		if data.conn then
			data.conn:Disconnect()
		end

		if data.humanoid then
			data.humanoid.WalkSpeed = data.ws or 16
			data.humanoid.JumpPower = data.jp or 50
		end
	end)
end

local function VoidScan()
	local center = voidState.center

	if not center then
		return
	end

	local piloted = GetPilotedDrone()

	for _, pl in ipairs(Players:GetPlayers()) do
		if pl ~= localPlayer then
			local ch = pl.Character
			local hrp = ch and ch:FindFirstChild("HumanoidRootPart")

			if hrp then
				local d = (hrp.Position - center).Magnitude

				if d == d then
					if d <= DOMAIN_RADIUS then
						VoidCapture(hrp, "player")
					else
						VoidRelease(hrp)
					end
				end
			end
		end
	end

	for _, drone in ipairs(dronesFolder:GetChildren()) do
		if drone:IsA("Model") then
			local dm = drone:FindFirstChildWhichIsA("Model")
			local bp = dm and dm:FindFirstChildWhichIsA("BasePart", true)

			if bp then
				if drone == piloted then
					VoidRelease(bp)
				else
					local d = (bp.Position - center).Magnitude

					if d == d then
						if d <= DOMAIN_RADIUS then
							VoidCapture(bp, "drone")
						else
							VoidRelease(bp)
						end
					end
				end
			end
		end
	end
end

-- Caster stance (R6 characters; silently skipped otherwise)

local function ApplyVoidPose()
	local char = localPlayer.Character
	local torso = char and char:FindFirstChild("Torso")

	if not torso then
		return
	end

	local joints = {}
	voidState.joints = joints

	local hrp = char:FindFirstChild("HumanoidRootPart")

	if hrp then
		hrp.Anchored = true
	end

	local function bend(name, angles)
		local joint = torso:FindFirstChild(name)

		if joint then
			joints[joint] = joint.C0

			Tween(joint, {C0 = joint.C0 * angles}, TweenInfo.new(0.9, Enum.EasingStyle.Back, Enum.EasingDirection.Out))
		end
	end

	bend("Right Shoulder", CFrame.Angles(0, 0, math.rad(120)))
	bend("Left Shoulder", CFrame.Angles(0, 0, math.rad(-120)))
	bend("Neck", CFrame.Angles(math.rad(16), 0, 0))
end

-- Screen atmosphere

local function BuildScreenFx()
	local cc = VoidNew("ColorCorrectionEffect", {
		Name = "VoidCC",
		Saturation = 0,
		Brightness = 0,
		Contrast = 0,
		TintColor = Color3.new(1, 1, 1),
		Parent = game:GetService("Lighting")
	})

	local blur = VoidNew("BlurEffect", {
		Name = "VoidBlur",
		Size = 0,
		Parent = game:GetService("Lighting")
	})

	Tween(cc, {Saturation = -0.75, Contrast = 0.12, Brightness = -0.06, TintColor = Color3.fromRGB(192, 178, 255)}, TweenInfo.new(1.6, Enum.EasingStyle.Quad, Enum.EasingDirection.Out))
	Tween(blur, {Size = 7}, TweenInfo.new(1.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out))
end

-- Overlay gui: dim + vignette + kanji title

local function BuildOverlay(gen)
	local overlayGui = VoidNew("ScreenGui", {
		Name = "VoidOverlay",
		ResetOnSpawn = false,
		IgnoreGuiInset = true,
		DisplayOrder = 10001,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	})

	local parented = pcall(function()
		overlayGui.Parent = (type(gethui) == "function" and gethui()) or game:GetService("CoreGui")
	end)

	if not parented then
		overlayGui.Parent = playerGui
	end

	local dim = VoidNew("Frame", {
		BackgroundColor3 = Color3.new(0.02, 0.008, 0.05),
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1),
		Parent = overlayGui
	})

	Tween(dim, {BackgroundTransparency = 0.45}, TweenInfo.new(1.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out))

	-- Asset-free vignette built from four gradient edges

	local vignette = VoidNew("Frame", {
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1),
		Parent = overlayGui
	})

	local function edge(size, pos, rotation, opaqueAtStart)
		local frame = Instance.new("Frame")
		frame.BackgroundColor3 = Color3.new(0, 0, 0)
		frame.BorderSizePixel = 0
		frame.Size = size
		frame.Position = pos
		frame.Parent = vignette

		local gradient = Instance.new("UIGradient")
		gradient.Rotation = rotation
		gradient.Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, opaqueAtStart),
			NumberSequenceKeypoint.new(1, 1)
		})
		gradient.Parent = frame
	end

	edge(UDim2.fromScale(1, 0.26), UDim2.fromScale(0, 0), 90, 0.35)
	edge(UDim2.fromScale(1, 0.26), UDim2.fromScale(0, 0.74), -90, 0.35)
	edge(UDim2.fromScale(0.22, 1), UDim2.fromScale(0, 0), 0, 0.35)
	edge(UDim2.fromScale(0.22, 1), UDim2.fromScale(0.78, 0), 180, 0.35)

	-- Title card

	local title = VoidNew("TextLabel", {
		BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.4),
		Size = UDim2.fromScale(0.72, 0.2),
		Font = Enum.Font.GothamBold,
		Text = "領域展開",
		TextScaled = true,
		TextColor3 = Color3.fromRGB(228, 214, 255),
		TextTransparency = 1,
		ZIndex = 3,
		Parent = overlayGui
	}, {
		Create("UIStroke", {Color = VOID_PURPLE, Thickness = 2, Transparency = 1}),
		Create("UIGradient", {Color = ColorSequence.new(Color3.new(1, 1, 1), VOID_PALE)})
	})

	local sub = VoidNew("TextLabel", {
		BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.53),
		Size = UDim2.fromScale(0.6, 0.045),
		Font = Enum.Font.GothamMedium,
		Text = "無限虚空  ·  I N F I N I T E   V O I D",
		TextScaled = true,
		TextColor3 = VOID_PALE,
		TextTransparency = 1,
		ZIndex = 3,
		Parent = overlayGui
	})

	local titleStroke = title:FindFirstChildOfClass("UIStroke")

	local titleScale = VoidNew("UIScale", {Scale = 1.16, Parent = title})

	task.defer(function()
		Tween(titleScale, {Scale = 1}, TweenInfo.new(1.1, Enum.EasingStyle.Quart, Enum.EasingDirection.Out))
		Tween(title, {TextTransparency = 0.04}, TweenInfo.new(1.1, Enum.EasingStyle.Quart, Enum.EasingDirection.Out))
		Tween(sub, {TextTransparency = 0.15}, TweenInfo.new(1.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out))

		if titleStroke then
			Tween(titleStroke, {Transparency = 0.25}, TweenInfo.new(1.1, Enum.EasingStyle.Quart, Enum.EasingDirection.Out))
		end
	end)

	-- Fade the card out shortly before collapse

	task.delay(DOMAIN_DURATION - 0.5, function()
		if voidState.active and voidState.gen == gen then
			Tween(title, {TextTransparency = 1}, TweenInfo.new(0.7))
			Tween(sub, {TextTransparency = 1}, TweenInfo.new(0.7))

			if titleStroke then
				Tween(titleStroke, {Transparency = 1}, TweenInfo.new(0.7))
			end
		end
	end)
end

-- Domain geometry: barrier sphere, starfield, black hole with accretion rings

local function BuildSphere(centerPos)
	local sphere = VoidNew("Part", {
		Name = "VoidBarrier",
		Shape = Enum.PartType.Ball,
		Material = Enum.Material.ForceField,
		Color = VOID_PURPLE,
		Transparency = 1,
		Anchored = true,
		CanCollide = false,
		CanQuery = false,
		CanTouch = false,
		CastShadow = false,
		Size = Vector3.new(1, 1, 1),
		CFrame = CFrame.new(centerPos),
		Parent = workspace
	})

	Tween(sphere, {Size = Vector3.one * (DOMAIN_RADIUS * 2), Transparency = 0.55}, TweenInfo.new(0.75, Enum.EasingStyle.Quint, Enum.EasingDirection.Out))

	voidState.sphere = sphere

	-- Starfield volume

	local fieldPart = VoidNew("Part", {
		Name = "VoidField",
		Transparency = 1,
		Anchored = true,
		CanCollide = false,
		CanQuery = false,
		CanTouch = false,
		CastShadow = false,
		Size = Vector3.new(DOMAIN_RADIUS * 1.7, DOMAIN_RADIUS * 1.7, DOMAIN_RADIUS * 1.7),
		CFrame = CFrame.new(centerPos),
		Parent = workspace
	})

	local stars = VoidNew("ParticleEmitter", {
		Name = "VoidStars",
		Texture = "rbxasset://textures/particles/sparkles_main.dds",
		Color = ColorSequence.new(Color3.new(1, 1, 1), Color3.fromRGB(182, 152, 255)),
		Size = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0.4),
			NumberSequenceKeypoint.new(1, 0.12)
		}),
		Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0.15),
			NumberSequenceKeypoint.new(0.8, 0.55),
			NumberSequenceKeypoint.new(1, 1)
		}),
		Lifetime = NumberRange.new(4, 9),
		Rate = 110,
		Speed = NumberRange.new(0.05, 0.7),
		SpreadAngle = Vector2.new(180, 180),
		Shape = Enum.ParticleEmitterShape.Sphere,
		LightEmission = 1,
		LightInfluence = 0,
		Rotation = NumberRange.new(0, 360),
		SRotSpeed = NumberRange.new(-60, 60),
		LockedToPart = true,
		Parent = fieldPart
	})

	-- Soft white blobs drifting around

	local motes = VoidNew("ParticleEmitter", {
		Name = "VoidMotes",
		Texture = "rbxasset://textures/particles/sparkles_main.dds",
		Color = ColorSequence.new(Color3.new(1, 1, 1), Color3.fromRGB(215, 205, 245)),
		Size = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 1.4),
			NumberSequenceKeypoint.new(1, 2.6)
		}),
		Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0.7),
			NumberSequenceKeypoint.new(0.5, 0.85),
			NumberSequenceKeypoint.new(1, 1)
		}),
		Lifetime = NumberRange.new(6, 11),
		Rate = 16,
		Speed = NumberRange.new(0.1, 0.5),
		SpreadAngle = Vector2.new(180, 180),
		Shape = Enum.ParticleEmitterShape.Sphere,
		LightEmission = 0.9,
		LightInfluence = 0,
		LockedToPart = true,
		Parent = fieldPart
	})

	table.insert(voidState.emitters, stars)
	table.insert(voidState.emitters, motes)
end

local function BuildBlackHole(centerPos)
	local holePos = centerPos + Vector3.new(0, math.min(70, DOMAIN_RADIUS * 0.5), 0)
	voidState.holePos = holePos

	local core = VoidNew("Part", {
		Name = "VoidCore",
		Shape = Enum.PartType.Ball,
		Material = Enum.Material.SmoothPlastic,
		Color = Color3.new(0, 0, 0),
		Reflectance = 0,
		Anchored = true,
		CanCollide = false,
		CanQuery = false,
		CanTouch = false,
		CastShadow = false,
		Size = Vector3.new(16, 16, 16),
		CFrame = CFrame.new(holePos),
		Parent = workspace
	})

	VoidNew("PointLight", {
		Color = VOID_PURPLE,
		Brightness = 3,
		Range = DOMAIN_RADIUS * 0.7,
		Parent = core
	})

	VoidNew("Part", {
		Name = "VoidShell",
		Shape = Enum.PartType.Ball,
		Material = Enum.Material.ForceField,
		Color = VOID_PURPLE,
		Transparency = 0.4,
		Anchored = true,
		CanCollide = false,
		CanQuery = false,
		CanTouch = false,
		CastShadow = false,
		Size = Vector3.new(21, 21, 21),
		CFrame = CFrame.new(holePos),
		Parent = workspace
	})

	voidState.core = core

	-- Accretion rings: counter-rotating orbits of neon sparks

	local ringsModel = VoidNew("Model", {Name = "VoidRings", Parent = workspace})
	voidState.ringsModel = ringsModel
	voidState.ringTilt = CFrame.Angles(math.rad(-14), 0, math.rad(7))

	local function buildRing(radius, count, color, baseSize)
		for i = 1, count do
			local a = (i / count) * math.pi * 2
			local size = baseSize + math.abs(math.sin(i * 7.13)) * 0.9

			local orb = Instance.new("Part")
			orb.Name = "VoidSpark"
			orb.Shape = Enum.PartType.Ball
			orb.Material = Enum.Material.Neon
			orb.Color = color
			orb.Size = Vector3.new(size, size, size)
			orb.Anchored = true
			orb.CanCollide = false
			orb.CanQuery = false
			orb.CanTouch = false
			orb.CastShadow = false
			orb.CFrame = CFrame.new(holePos) * voidState.ringTilt * CFrame.new(math.cos(a) * radius, math.sin(i * 3.7) * 1.6, math.sin(a) * radius)
			orb.Parent = ringsModel
		end
	end

	buildRing(34, 46, VOID_PURPLE, 0.55)
	buildRing(52, 58, VOID_PALE, 0.4)
	buildRing(74, 66, Color3.fromRGB(140, 105, 230), 0.3)
end

-- Collapse

local function VoidCollapse()
	if voidState.collapsing then
		return
	end

	voidState.collapsing = true

	for part in pairs(voidState.frozen) do
		VoidRelease(part)
	end

	if voidState.sphere then
		Tween(voidState.sphere, {Size = Vector3.new(2, 2, 2), Transparency = 1}, TweenInfo.new(DOMAIN_COLLAPSE_TIME, Enum.EasingStyle.Quint, Enum.EasingDirection.In))
	end

	if voidState.core then
		Tween(voidState.core, {Size = Vector3.new(1, 1, 1)}, TweenInfo.new(DOMAIN_COLLAPSE_TIME, Enum.EasingStyle.Quint, Enum.EasingDirection.In))
	end

	for _, emitter in ipairs(voidState.emitters) do
		pcall(function()
			emitter.Enabled = false
		end)
	end

	for _, inst in ipairs(voidState.instances) do
		if inst:IsA("ColorCorrectionEffect") then
			Tween(inst, {Saturation = 0, Brightness = 0, Contrast = 0, TintColor = Color3.new(1, 1, 1)}, TweenInfo.new(DOMAIN_COLLAPSE_TIME))
		elseif inst:IsA("BlurEffect") then
			Tween(inst, {Size = 0}, TweenInfo.new(DOMAIN_COLLAPSE_TIME))
		end
	end

	if voidState.joints then
		for joint, c0 in pairs(voidState.joints) do
			pcall(function()
				Tween(joint, {C0 = c0}, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out))
			end)
		end

		local hrp = localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart")

		if hrp then
			hrp.Anchored = false
		end
	end

	task.delay(DOMAIN_COLLAPSE_TIME + 0.15, VoidCleanup)
end

-- Cast

local function StartDomain()
	if voidState.active then
		return
	end

	local char = localPlayer.Character
	local hrp = char and char:FindFirstChild("HumanoidRootPart")
	local rootPos = GetPlayerPosition()

	if not hrp or not rootPos then
		return
	end

	voidState.active = true
	voidState.collapsing = false
	voidState.gen = (voidState.gen or 0) + 1
	voidState.t0 = os.clock()
	voidState.scanAcc = 1
	voidState.center = rootPos

	local gen = voidState.gen

	ApplyVoidPose()
	BuildScreenFx()
	BuildSphere(rootPos)
	BuildBlackHole(rootPos)
	BuildOverlay(gen)

	if SOUND_CAST_ID ~= 0 then
		local s = VoidNew("Sound", {
			SoundId = "rbxassetid://" .. tostring(SOUND_CAST_ID),
			Volume = 1,
			Parent = hrp
		})

		s:Play()
	end

	if SOUND_AMBIENT_ID ~= 0 then
		local amb = VoidNew("Sound", {
			SoundId = "rbxassetid://" .. tostring(SOUND_AMBIENT_ID),
			Volume = 0.7,
			Looped = true,
			Parent = hrp
		})

		amb:Play()
	end

	-- Death / respawn aborts everything safely

	local humanoid = char:FindFirstChildOfClass("Humanoid")

	if humanoid then
		VoidConn(humanoid.Died:Connect(VoidCleanup))
	end

	VoidConn(localPlayer.CharacterAdded:Connect(VoidCleanup))

	-- FOV punch (skipped when the menu's custom FOV owns the camera)

	local cam = workspace.CurrentCamera

	if cam and not states.CustomFov then
		voidState.savedFov = cam.FieldOfView

		Tween(cam, {FieldOfView = voidState.savedFov + 20}, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out))

		task.delay(1.3, function()
			if voidState.active and voidState.gen == gen and cam.Parent then
				Tween(cam, {FieldOfView = voidState.savedFov}, TweenInfo.new(0.9, Enum.EasingStyle.Quad, Enum.EasingDirection.Out))
			end
		end)
	end
end

-- Cheat code listener: type "domain"

local keyBuffer = ""

UIS.InputBegan:Connect(function(input, gpe)
	if gpe then
		return
	end

	if input.UserInputType ~= Enum.UserInputType.Keyboard then
		return
	end

	local name = input.KeyCode.Name

	if #name ~= 1 or not name:match("%a") then
		return
	end

	keyBuffer = keyBuffer .. string.lower(name)

	if #keyBuffer > 12 then
		keyBuffer = string.sub(keyBuffer, -6)
	end

	if string.sub(keyBuffer, -6) == "domain" then
		keyBuffer = ""

		pcall(function()
			print("[FemboyHub] Domain Expansion triggered")
		end)

		local ok, err = pcall(StartDomain)

		if not ok then
			pcall(function()
				print("[FemboyHub] domain start error: " .. tostring(err))
			end)
		end
	end
end)

-- Per-frame driver: pins, ring spin, pulses, scanning, phase transitions

VoidConn(RunService.PreRender:Connect(function(delta)
	if not voidState.active then
		return
	end

	local ok, err = pcall(function()
		delta = math.min(delta, 0.1)

		local now = os.clock()
		local elapsed = now - voidState.t0

		for part, data in pairs(voidState.frozen) do
			part.CFrame = data.cf
		end

		if voidState.ringsModel and voidState.holePos then
			voidState.spin = voidState.spin + delta * 1.15
			voidState.ringsModel:PivotTo(CFrame.new(voidState.holePos) * voidState.ringTilt * CFrame.Angles(0, voidState.spin, 0))
		end

		if voidState.core then
			voidState.core.Size = Vector3.one * (16 + math.sin(now * 2.3) * 1.7)
		end

		if voidState.sphere and elapsed > DOMAIN_CAST_TIME then
			voidState.sphere.Transparency = 0.55 + math.sin(now * 1.7) * 0.08
		end

		voidState.scanAcc = voidState.scanAcc + delta

		if voidState.scanAcc >= 0.15 and elapsed >= DOMAIN_CAST_TIME * 0.5 then
			voidState.scanAcc = 0
			VoidScan()
		end

		if elapsed >= DOMAIN_CAST_TIME + DOMAIN_DURATION then
			VoidCollapse()
		end
	end)

	if not ok and not voidState.loopErrShown then
		voidState.loopErrShown = true

		pcall(function()
			print("[FemboyHub] domain loop error: " .. tostring(err))
		end)
	end
end))

end -- DOMAIN EXPANSION BLOCK

-- ==================== MENU BLOCK ====================

do

local WINDOW_WIDTH = 660
local WINDOW_HEIGHT = 400
local TITLE_HEIGHT = 46
local SIDEBAR_WIDTH = 176

local pageTweenInfo = TweenInfo.new(0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

local actionsList = {
	{NameKey = "FN_PLAYER_ESP", Id = "PlayerEsp", Callback = Actions.PlayerEsp},
	{NameKey = "FN_PLAYER_TRACERS", Id = "PlayerTracers", Callback = Actions.PlayerTracers},
	{NameKey = "FN_DRONE_ESP", Id = "DroneEsp", Callback = Actions.DroneEsp},
	{NameKey = "FN_DRONE_TRACERS", Id = "DroneTracers", Callback = Actions.DroneTracers},
	{NameKey = "FN_RADAR", Id = "Radar", Callback = Actions.Radar},
	{NameKey = "FN_THREAT_PANEL", Id = "ThreatPanel", Callback = Actions.ThreatPanel},
	{NameKey = "FN_CUSTOM_FOV", Id = "CustomFov", Callback = Actions.CustomFov},
	{NameKey = "FN_DRONE_CHAMS", Id = "DroneChams", Callback = Actions.DroneChams},
	{NameKey = "FN_PLAYER_CHAMS", Id = "PlayerChams", Callback = Actions.PlayerChams},
	{NameKey = "FN_ACRO_NOISE", Id = "AcroNoise", Callback = Actions.AcroNoise},
	{NameKey = "FN_FPS_PING", Id = "FpsPanel", Callback = Actions.FpsPanel},
	{NameKey = "FN_ALWAYS_DAY", Id = "AlwaysDay", Callback = Actions.AlwaysDay}
}

local screenGui = Create("ScreenGui", {
	Name = "PantsirMenu",
	ResetOnSpawn = false,
	DisplayOrder = 9999,
	ZIndexBehavior = Enum.ZIndexBehavior.Sibling
})

local parented = pcall(function()
	screenGui.Parent = (type(gethui) == "function" and gethui()) or game:GetService("CoreGui")
end)

if not parented then
	screenGui.Parent = playerGui
end

local RefreshToggles
local StartRebind
local FinishRebind
local ApplyMinimize
local SwitchPage
local rebindingId = nil
local minimized = false
local openedOnce = false

local main = Create("CanvasGroup", {
	Name = "Main",
	AnchorPoint = Vector2.new(0.5, 0),
	Position = UDim2.new(0.35, 0, 0.3, 0),
	Size = UDim2.new(0, WINDOW_WIDTH, 0, WINDOW_HEIGHT),
	BackgroundColor3 = theme.Background,
	BorderSizePixel = 0,
	ClipsDescendants = true,
	Visible = false,
	GroupTransparency = 1,
	Parent = screenGui
}, {
	Create("UICorner", {CornerRadius = UDim.new(0, 10)}),
	Create("UIStroke", {Color = theme.Stroke, Thickness = 1, Transparency = 0.35})
})

local uiScale = Create("UIScale", {Scale = 0.94, Parent = main})

table.insert(clipFrames, main)

local titleBar = Create("Frame", {
	Name = "TitleBar",
	Size = UDim2.new(1, 0, 0, TITLE_HEIGHT),
	BackgroundTransparency = 1,
	Active = true,
	Parent = main
}, {
	Create("Frame", {
		AnchorPoint = Vector2.new(0.5, 1),
		Position = UDim2.new(0.5, 0, 1, 0),
		Size = UDim2.new(1, -24, 0, 1),
		BackgroundColor3 = theme.Accent,
		BackgroundTransparency = 0.6,
		BorderSizePixel = 0
	}),
	Create("Frame", {
		Position = UDim2.new(0, 14, 0.5, -4),
		Size = UDim2.new(0, 8, 0, 8),
		BackgroundColor3 = theme.Accent,
		BorderSizePixel = 0
	}, {
		Create("UICorner", {CornerRadius = UDim.new(0, 3)})
	})
})

Create("TextLabel", {
	BackgroundTransparency = 1,
	Position = UDim2.new(0, 32, 0, 0),
	Size = UDim2.new(0, 86, 1, 0),
	Font = Enum.Font.GothamBold,
	Text = "Femboy",
	TextSize = 17,
	TextColor3 = theme.Text,
	TextXAlignment = Enum.TextXAlignment.Left,
	Parent = titleBar
})

Create("TextLabel", {
	BackgroundTransparency = 1,
	Position = UDim2.new(0, 98, 0, 0),
	Size = UDim2.new(0, 44, 1, 0),
	Font = Enum.Font.GothamBold,
	Text = "Hub",
	TextSize = 17,
	TextColor3 = theme.Accent,
	TextXAlignment = Enum.TextXAlignment.Left,
	Parent = titleBar
})

Create("TextLabel", {
	BackgroundTransparency = 1,
	Position = UDim2.new(0, 146, 0, 0),
	Size = UDim2.new(0, 44, 1, 0),
	Font = Enum.Font.Gotham,
	Text = "v1.0",
	TextSize = 11,
	TextColor3 = theme.DimText,
	TextXAlignment = Enum.TextXAlignment.Left,
	Parent = titleBar
})

local function CreateTitleButton(offsetX, text)
	return Create("TextButton", {
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, offsetX, 0.5, 0),
		Size = UDim2.new(0, 26, 0, 26),
		BackgroundColor3 = theme.Element,
		BorderSizePixel = 0,
		AutoButtonColor = false,
		Font = Enum.Font.GothamBold,
		Text = text,
		TextSize = 14,
		TextColor3 = theme.DimText,
		Parent = titleBar
	}, {
		Create("UICorner", {CornerRadius = UDim.new(0, 6)})
	})
end

local minimizeButton = CreateTitleButton(-44, "-")
local closeButton = CreateTitleButton(-10, "X")

minimizeButton.MouseEnter:Connect(function()
	Tween(minimizeButton, {BackgroundColor3 = theme.Hover, TextColor3 = theme.Text})
end)

minimizeButton.MouseLeave:Connect(function()
	Tween(minimizeButton, {BackgroundColor3 = theme.Element, TextColor3 = theme.DimText})
end)

minimizeButton.MouseButton1Click:Connect(function()
	ApplyMinimize(not minimized)
end)

closeButton.MouseEnter:Connect(function()
	Tween(closeButton, {BackgroundColor3 = theme.Danger, TextColor3 = Color3.new(1, 1, 1)})
end)

closeButton.MouseLeave:Connect(function()
	Tween(closeButton, {BackgroundColor3 = theme.Element, TextColor3 = theme.DimText})
end)

closeButton.MouseButton1Click:Connect(function()
	SetMenu(false)
end)

local body = Create("Frame", {
	Name = "Body",
	Position = UDim2.new(0, 0, 0, TITLE_HEIGHT),
	Size = UDim2.new(1, 0, 1, -TITLE_HEIGHT),
	BackgroundTransparency = 1,
	Parent = main
})

local sidebar = Create("Frame", {
	Name = "Sidebar",
	Size = UDim2.new(0, SIDEBAR_WIDTH, 1, 0),
	BackgroundColor3 = theme.Sidebar,
	BorderSizePixel = 0,
	Parent = body
}, {
	Create("UIPadding", {
		PaddingTop = UDim.new(0, 10),
		PaddingLeft = UDim.new(0, 10),
		PaddingRight = UDim.new(0, 10)
	}),
	Create("UIListLayout", {
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = UDim.new(0, 4)
	})
})

Create("Frame", {
	Position = UDim2.new(0, SIDEBAR_WIDTH, 0, 0),
	Size = UDim2.new(0, 1, 1, 0),
	BackgroundColor3 = theme.Stroke,
	BackgroundTransparency = 0.45,
	BorderSizePixel = 0,
	Parent = body
})

hintLabel = Create("TextLabel", {
	AnchorPoint = Vector2.new(0.5, 1),
	Position = UDim2.new(0, SIDEBAR_WIDTH / 2, 1, -8),
	Size = UDim2.new(0, SIDEBAR_WIDTH, 0, 14),
	BackgroundTransparency = 1,
	Font = Enum.Font.Gotham,
	TextSize = 11,
	TextColor3 = theme.DimText,
	Text = "",
	Parent = body
})

local contentArea = Create("Frame", {
	Name = "ContentArea",
	Position = UDim2.new(0, SIDEBAR_WIDTH, 0, 0),
	Size = UDim2.new(1, -SIDEBAR_WIDTH, 1, 0),
	BackgroundTransparency = 1,
	ClipsDescendants = true,
	Parent = body
})

-- Pages

local pages = {}
local tabButtons = {}
local currentPage = nil

local tabNames = {"TAB_FUNCTIONS", "TAB_SETTINGS", "TAB_CREDITS"}

local function CreatePage(index, sorted)
	local page = Create("CanvasGroup", {
		Name = "Page" .. index,
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
		GroupTransparency = 1,
		Visible = false,
		Parent = contentArea
	})

	local children = {
		Create("UIPadding", {
			PaddingTop = UDim.new(0, 12),
			PaddingBottom = UDim.new(0, 12),
			PaddingLeft = UDim.new(0, 14),
			PaddingRight = UDim.new(0, 14)
		})
	}

	if sorted ~= false then
		table.insert(children, Create("UIListLayout", {
			SortOrder = Enum.SortOrder.LayoutOrder,
			Padding = UDim.new(0, 2)
		}))
	end

	local scroll = Create("ScrollingFrame", {
		Name = "Scroll",
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ScrollBarThickness = 3,
		ScrollBarImageColor3 = theme.Accent,
		CanvasSize = UDim2.new(0, 0, 0, 0),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		ScrollingDirection = Enum.ScrollingDirection.Y,
		Parent = page
	}, children)

	pages[index] = page
	return scroll
end

for index, name in ipairs(tabNames) do
	local button = Create("TextButton", {
		Size = UDim2.new(1, 0, 0, 42),
		BackgroundColor3 = theme.Element,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		AutoButtonColor = false,
		Font = Enum.Font.GothamMedium,
		TextSize = 14,
		TextColor3 = theme.DimText,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = sidebar
	}, {
		Create("UIPadding", {PaddingLeft = UDim.new(0, 12)}),
		Create("UICorner", {CornerRadius = UDim.new(0, 7)})
	})

	local indicator = Create("Frame", {
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.new(0, -7, 0.5, 0),
		Size = UDim2.new(0, 3, 0, 18),
		BackgroundColor3 = theme.Accent,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Parent = button
	}, {
		Create("UICorner", {CornerRadius = UDim.new(1, 0)})
	})

	RegisterText(button, name)

	button.MouseEnter:Connect(function()
		if currentPage ~= index then
			Tween(button, {BackgroundTransparency = 0.6})
		end
	end)

	button.MouseLeave:Connect(function()
		if currentPage ~= index then
			Tween(button, {BackgroundTransparency = 1})
		end
	end)

	button.MouseButton1Click:Connect(function()
		SwitchPage(index)
	end)

	tabButtons[index] = {Button = button, Indicator = indicator}
end

function SwitchPage(index)
	if currentPage == index then return end

	local previous = currentPage
	currentPage = index

	for i, tab in ipairs(tabButtons) do
		local active = i == index

		Tween(tab.Button, {BackgroundTransparency = active and 0 or 1})
		Tween(tab.Button, {TextColor3 = active and theme.Text or theme.DimText})
		Tween(tab.Indicator, {BackgroundTransparency = active and 0 or 1})
	end

	local oldPage = previous and pages[previous]
	local newPage = pages[index]

	if oldPage then
		Tween(oldPage, {GroupTransparency = 1}, pageTweenInfo)
		Tween(oldPage, {Position = UDim2.new(0, -18, 0, 0)}, pageTweenInfo)

		task.delay(pageTweenInfo.Time, function()
			if currentPage ~= previous then
				oldPage.Visible = false
			end
		end)
	end

	newPage.Visible = true
	newPage.GroupTransparency = 1
	newPage.Position = UDim2.new(0, 18, 0, 0)

	Tween(newPage, {GroupTransparency = 0}, pageTweenInfo)
	Tween(newPage, {Position = UDim2.new(0, 0, 0, 0)}, pageTweenInfo)
end

-- Page: Functions

local pageFunctions = CreatePage(1)

local switches = {}
local bindButtons = {}

local function ApplySwitch(switch, enabled, instant)
	local info = TweenInfo.new(instant and 0 or 0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

	TweenService:Create(switch.button, info, {BackgroundColor3 = enabled and theme.Accent or theme.SwitchOff}):Play()

	TweenService:Create(switch.knob, info, {
		Position = enabled and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8),
		BackgroundColor3 = enabled and Color3.new(1, 1, 1) or theme.Knob
	}):Play()
end

function RefreshToggles(instant)
	for _, action in ipairs(actionsList) do
		ApplySwitch(switches[action.Id], states[action.Id], instant)
	end
end

local function CreateBindButton(row, id, offsetX)
	local button = Create("TextButton", {
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, offsetX, 0.5, 0),
		Size = UDim2.new(0, 54, 0, 24),
		BackgroundColor3 = theme.Element,
		BorderSizePixel = 0,
		AutoButtonColor = false,
		Font = Enum.Font.GothamMedium,
		Text = binds[id].Name,
		TextSize = 12,
		TextColor3 = theme.DimText,
		Parent = row
	}, {
		Create("UICorner", {CornerRadius = UDim.new(0, 6)}),
		Create("UIStroke", {Color = theme.Stroke, Transparency = 0.5})
	})

	button.MouseEnter:Connect(function()
		Tween(button, {BackgroundColor3 = theme.Hover})
	end)

	button.MouseLeave:Connect(function()
		if rebindingId ~= id then
			Tween(button, {BackgroundColor3 = theme.Element})
		end
	end)

	button.MouseButton1Click:Connect(function()
		StartRebind(id)
	end)

	bindButtons[id] = button
	return button
end

local actionById = {}

for _, action in ipairs(actionsList) do
	actionById[action.Id] = action
end

local function CreateSectionHeader(order, nameKey, color)
	local row = Create("Frame", {
		Size = UDim2.new(1, 0, 0, 32),
		BackgroundTransparency = 1,
		LayoutOrder = order,
		Parent = pageFunctions
	})

	local label = Create("TextLabel", {
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 14, 0, 4),
		Size = UDim2.new(1, -28, 0, 16),
		Font = Enum.Font.GothamBold,
		TextSize = 11,
		TextColor3 = color,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = row
	})

	RegisterText(label, nameKey)

	Create("Frame", {
		Position = UDim2.new(0, 14, 1, -6),
		Size = UDim2.new(1, -28, 0, 1),
		BackgroundColor3 = color,
		BackgroundTransparency = 0.8,
		BorderSizePixel = 0,
		Parent = row
	})
end

-- Sections ordered by ban risk: pure client visuals, injected instances /
-- replication fights, game HUD tampering

local riskSections = {
	{Key = "SECTION_SAFE", Color = theme.Safe, Ids = {
		"PlayerEsp", "PlayerTracers", "DroneEsp", "DroneTracers",
		"Radar", "ThreatPanel", "FpsPanel", "CustomFov"
	}},
	{Key = "SECTION_MEDIUM", Color = theme.Medium, Ids = {
		"DroneChams", "PlayerChams", "AlwaysDay"
	}},
	{Key = "SECTION_HIGH", Color = theme.Danger, Ids = {
		"AcroNoise"
	}}
}

local rowOrder = 0

for _, section in ipairs(riskSections) do
	rowOrder = rowOrder + 1
	CreateSectionHeader(rowOrder, section.Key, section.Color)

	for _, id in ipairs(section.Ids) do
		local action = actionById[id]
		rowOrder = rowOrder + 1

		local row = Create("Frame", {
			Size = UDim2.new(1, 0, 0, 42),
			BackgroundColor3 = theme.Hover,
			BackgroundTransparency = 1,
			LayoutOrder = rowOrder,
			Parent = pageFunctions
		})

		row.MouseEnter:Connect(function()
			Tween(row, {BackgroundTransparency = 0.7})
		end)

		row.MouseLeave:Connect(function()
			Tween(row, {BackgroundTransparency = 1})
		end)

		local nameLabel = Create("TextLabel", {
			BackgroundTransparency = 1,
			Position = UDim2.new(0, 14, 0, 0),
			Size = UDim2.new(1, -160, 1, 0),
			Font = Enum.Font.GothamMedium,
			TextSize = 13,
			TextColor3 = theme.Text,
			TextXAlignment = Enum.TextXAlignment.Left,
			Parent = row
		})

		RegisterText(nameLabel, action.NameKey)

		CreateBindButton(row, action.Id, -66)

		local switch = Create("TextButton", {
			AnchorPoint = Vector2.new(1, 0.5),
			Position = UDim2.new(1, -12, 0.5, 0),
			Size = UDim2.new(0, 42, 0, 22),
			BackgroundColor3 = theme.SwitchOff,
			BorderSizePixel = 0,
			Text = "",
			AutoButtonColor = false,
			Parent = row
		}, {
			Create("UICorner", {CornerRadius = UDim.new(1, 0)}),
			Create("UIStroke", {Color = theme.Stroke, Transparency = 0.6})
		})

		local knob = Create("Frame", {
			Position = UDim2.new(0, 3, 0.5, -8),
			Size = UDim2.new(0, 16, 0, 16),
			BackgroundColor3 = theme.Knob,
			BorderSizePixel = 0,
			Parent = switch
		}, {
			Create("UICorner", {CornerRadius = UDim.new(1, 0)})
		})

		switch.MouseEnter:Connect(function()
			if not states[action.Id] then
				Tween(switch, {BackgroundColor3 = theme.Hover})
			end
		end)

		switch.MouseLeave:Connect(function()
			if not states[action.Id] then
				Tween(switch, {BackgroundColor3 = theme.SwitchOff})
			end
		end)

		switch.MouseButton1Click:Connect(function()
			action.Callback()
			RefreshToggles()
		end)

		switches[action.Id] = {button = switch, knob = knob}
	end
end

Create("Frame", {
	Size = UDim2.new(1, -24, 0, 1),
	BackgroundColor3 = theme.Stroke,
	BackgroundTransparency = 0.55,
	BorderSizePixel = 0,
	LayoutOrder = 90,
	Parent = pageFunctions
})

local menuRow = Create("Frame", {
	Size = UDim2.new(1, 0, 0, 42),
	BackgroundTransparency = 1,
	LayoutOrder = 91,
	Parent = pageFunctions
})

local menuRowLabel = Create("TextLabel", {
	BackgroundTransparency = 1,
	Position = UDim2.new(0, 14, 0, 0),
	Size = UDim2.new(1, -160, 1, 0),
	Font = Enum.Font.GothamMedium,
	TextSize = 13,
	TextColor3 = theme.Text,
	TextXAlignment = Enum.TextXAlignment.Left,
	Parent = menuRow
})

RegisterText(menuRowLabel, "FN_OPEN_MENU")

CreateBindButton(menuRow, "MenuToggle", -12)

-- Page: Settings

local pageSettings = CreatePage(2)

local function CreateSettingsRow(order, nameKey)
	local row = Create("Frame", {
		Size = UDim2.new(1, 0, 0, 42),
		BackgroundColor3 = theme.Hover,
		BackgroundTransparency = 1,
		LayoutOrder = order,
		Parent = pageSettings
	})

	row.MouseEnter:Connect(function()
		Tween(row, {BackgroundTransparency = 0.7})
	end)

	row.MouseLeave:Connect(function()
		Tween(row, {BackgroundTransparency = 1})
	end)

	local nameLabel = Create("TextLabel", {
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 14, 0, 0),
		Size = UDim2.new(1, -190, 1, 0),
		Font = Enum.Font.GothamMedium,
		TextSize = 13,
		TextColor3 = theme.Text,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = row
	})

	RegisterText(nameLabel, nameKey)

	return row, nameLabel
end

local function CreateSwitch(parent)
	local button = Create("TextButton", {
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -12, 0.5, 0),
		Size = UDim2.new(0, 42, 0, 22),
		BackgroundColor3 = theme.SwitchOff,
		BorderSizePixel = 0,
		Text = "",
		AutoButtonColor = false,
		Parent = parent
	}, {
		Create("UICorner", {CornerRadius = UDim.new(1, 0)}),
		Create("UIStroke", {Color = theme.Stroke, Transparency = 0.6})
	})

	local knob = Create("Frame", {
		Position = UDim2.new(0, 3, 0.5, -8),
		Size = UDim2.new(0, 16, 0, 16),
		BackgroundColor3 = theme.Knob,
		BorderSizePixel = 0,
		Parent = button
	}, {
		Create("UICorner", {CornerRadius = UDim.new(1, 0)})
	})

	return {button = button, knob = knob}
end

-- Tracer origin option

local originRow = CreateSettingsRow(1, "SET_ORIGIN")
local originButtons = {}

local function RefreshOriginButtons()
	for id, button in pairs(originButtons) do
		local active = tracerConfig.Origin == id
		button.BackgroundColor3 = active and theme.Accent or theme.Element
		button.TextColor3 = active and Color3.new(1, 1, 1) or theme.DimText
	end
end

local originContainer = Create("Frame", {
	AnchorPoint = Vector2.new(1, 0.5),
	Position = UDim2.new(1, -12, 0.5, 0),
	Size = UDim2.new(0, 136, 0, 26),
	BackgroundTransparency = 1,
	Parent = originRow
}, {
	Create("UIListLayout", {
		FillDirection = Enum.FillDirection.Horizontal,
		VerticalAlignment = Enum.VerticalAlignment.Center,
		HorizontalAlignment = Enum.HorizontalAlignment.Right,
		Padding = UDim.new(0, 6)
	})
})

for _, id in ipairs({"Center", "Bottom"}) do
	local button = Create("TextButton", {
		Size = UDim2.new(0, 64, 0, 26),
		BackgroundColor3 = theme.Element,
		BorderSizePixel = 0,
		AutoButtonColor = false,
		Font = Enum.Font.GothamMedium,
		TextSize = 12,
		TextColor3 = theme.DimText,
		Parent = originContainer
	}, {
		Create("UICorner", {CornerRadius = UDim.new(0, 6)})
	})

	RegisterText(button, id == "Center" and "OPT_CENTER" or "OPT_BOTTOM")

	button.MouseButton1Click:Connect(function()
		tracerConfig.Origin = id
		RefreshOriginButtons()
	end)

	originButtons[id] = button
end

RefreshOriginButtons()

-- Distance toggle

local distanceRow = CreateSettingsRow(2, "SET_DISTANCE")
local distanceSwitchObject = CreateSwitch(distanceRow)

distanceSwitchObject.button.MouseButton1Click:Connect(function()
	states.ShowDistance = not states.ShowDistance
	ApplySwitch(distanceSwitchObject, states.ShowDistance)
end)

-- Steppers

local function CreateStepperRow(order, name, min, max, step, initial, onChanged)
	local row = CreateSettingsRow(order, name)

	local container = Create("Frame", {
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -12, 0.5, 0),
		Size = UDim2.new(0, 100, 0, 26),
		BackgroundTransparency = 1,
		Parent = row
	}, {
		Create("UIListLayout", {
			FillDirection = Enum.FillDirection.Horizontal,
			VerticalAlignment = Enum.VerticalAlignment.Center,
			Padding = UDim.new(0, 4)
		})
	})

	local function CreateStepperButton(text)
		return Create("TextButton", {
			Size = UDim2.new(0, 26, 0, 26),
			BackgroundColor3 = theme.Element,
			BorderSizePixel = 0,
			AutoButtonColor = false,
			Font = Enum.Font.GothamBold,
			Text = text,
			TextSize = 14,
			TextColor3 = theme.DimText
		}, {
			Create("UICorner", {CornerRadius = UDim.new(0, 6)})
		})
	end

	local minusButton = CreateStepperButton("-")
	minusButton.Parent = container

	local valueLabel = Create("TextLabel", {
		Size = UDim2.new(0, 40, 0, 26),
		BackgroundTransparency = 1,
		Font = Enum.Font.GothamMedium,
		Text = tostring(initial),
		TextSize = 13,
		TextColor3 = theme.Text
	})
	valueLabel.Parent = container

	local plusButton = CreateStepperButton("+")
	plusButton.Parent = container

	local value = initial

	local function Refresh()
		valueLabel.Text = tostring(value)

		minusButton.BackgroundColor3 = value <= min and theme.Background or theme.Element
		plusButton.BackgroundColor3 = value >= max and theme.Background or theme.Element
	end

	minusButton.MouseButton1Click:Connect(function()
		value = math.max(min, value - step)
		Refresh()
		onChanged(value)
	end)

	plusButton.MouseButton1Click:Connect(function()
		value = math.min(max, value + step)
		Refresh()
		onChanged(value)
	end)

	Refresh()
end

CreateStepperRow(3, "SET_THICKNESS", 1, 4, 1, tracerConfig.Thickness, function(value)
	tracerConfig.Thickness = value
end)

CreateStepperRow(4, "SET_FOV", 30, 120, 5, widgetConfig.FieldOfView, function(value)
	widgetConfig.FieldOfView = value

	if states.CustomFov then
		local camera = workspace.CurrentCamera

		if camera then
			camera.FieldOfView = value
		end
	end
end)

CreateStepperRow(5, "SET_RADAR_RANGE", 100, 8000, 100, widgetConfig.RadarRange, function(value)
	widgetConfig.RadarRange = value
end)

CreateStepperRow(6, "SET_THREAT", 50, 500, 25, widgetConfig.ThreatThreshold, function(value)
	widgetConfig.ThreatThreshold = value
end)

-- Team filter

CreateSettingsRow(7, "SET_TEAMS")

local teamMeta = {
	{Key = "Defenders", NameKey = "TEAM_DEFENDERS", Color = Color3.fromRGB(2, 221, 255), Order = 8},
	{Key = "Civilians", NameKey = "TEAM_CIVILIANS", Color = Color3.fromRGB(34, 206, 54), Order = 9},
	{Key = "Operators", NameKey = "TEAM_OPERATORS", Color = Color3.fromRGB(255, 131, 133), Order = 10},
	{Key = "Neutral", NameKey = "TEAM_NEUTRAL", Color = Color3.fromRGB(255, 255, 255), Order = 11}
}

for _, meta in ipairs(teamMeta) do
	local row, nameLabel = CreateSettingsRow(meta.Order, meta.NameKey)
	nameLabel.TextColor3 = meta.Color

	local switch = CreateSwitch(row)
	ApplySwitch(switch, teamFilter[meta.Key], true)

	switch.button.MouseButton1Click:Connect(function()
		teamFilter[meta.Key] = not teamFilter[meta.Key]
		ApplySwitch(switch, teamFilter[meta.Key])
	end)
end

-- Page: Credits

local pageCredits = CreatePage(3, false)

Create("TextLabel", {
	BackgroundTransparency = 1,
	Position = UDim2.new(0, 0, 0, 96),
	Size = UDim2.new(1, 0, 0, 32),
	Font = Enum.Font.GothamBold,
	Text = "Femboy Hub",
	TextSize = 24,
	TextColor3 = theme.Text,
	TextXAlignment = Enum.TextXAlignment.Center,
	Parent = pageCredits
})

local creditsVersion = Create("TextLabel", {
	BackgroundTransparency = 1,
	Position = UDim2.new(0, 0, 0, 132),
	Size = UDim2.new(1, 0, 0, 16),
	Font = Enum.Font.Gotham,
	Text = "version 1.0",
	TextSize = 12,
	TextColor3 = theme.Accent,
	TextXAlignment = Enum.TextXAlignment.Center,
	Parent = pageCredits
})

-- Divider lives inside the version label, so it always shares its exact center

Create("Frame", {
	AnchorPoint = Vector2.new(0.5, 0),
	Position = UDim2.new(0.5, 0, 0, 36),
	Size = UDim2.new(0, 140, 0, 1),
	BackgroundColor3 = theme.Accent,
	BackgroundTransparency = 0.55,
	BorderSizePixel = 0,
	Parent = creditsVersion
})

local creditsLove = Create("TextLabel", {
	BackgroundTransparency = 1,
	Position = UDim2.new(0, 0, 0, 190),
	Size = UDim2.new(1, 0, 0, 18),
	Font = Enum.Font.GothamMedium,
	TextSize = 14,
	TextColor3 = theme.Text,
	TextXAlignment = Enum.TextXAlignment.Center,
	Parent = pageCredits
})

RegisterText(creditsLove, "CREDITS_LOVE")

local creditsAuthors = Create("TextLabel", {
	BackgroundTransparency = 1,
	Position = UDim2.new(0, 0, 0, 216),
	Size = UDim2.new(1, 0, 0, 16),
	Font = Enum.Font.GothamBold,
	TextSize = 13,
	TextColor3 = theme.Accent,
	TextXAlignment = Enum.TextXAlignment.Center,
	Parent = pageCredits
})

RegisterText(creditsAuthors, "CREDITS_AUTHORS")

local creditsThanks = Create("TextLabel", {
	BackgroundTransparency = 1,
	Position = UDim2.new(0, 0, 0, 242),
	Size = UDim2.new(1, 0, 0, 16),
	Font = Enum.Font.Gotham,
	TextSize = 12,
	TextColor3 = theme.DimText,
	TextXAlignment = Enum.TextXAlignment.Center,
	Parent = pageCredits
})

RegisterText(creditsThanks, "CREDITS_THANKS")

-- Rebind logic

function StartRebind(id)
	if rebindingId then
		FinishRebind(nil)
	end

	rebindingId = id

	local button = bindButtons[id]
	button.Text = "..."
	button.TextColor3 = theme.Accent
	Tween(button:FindFirstChildOfClass("UIStroke"), {Color = theme.Accent, Transparency = 0})
end

function FinishRebind(key)
	local id = rebindingId
	if not id then return end

	rebindingId = nil

	if key then
		binds[id] = key
	end

	local button = bindButtons[id]
	button.Text = binds[id].Name
	button.TextColor3 = theme.DimText
	Tween(button:FindFirstChildOfClass("UIStroke"), {Color = theme.Stroke, Transparency = 0.5})

	if id == "MenuToggle" then
		hintLabel.Text = Localize("HINT", binds.MenuToggle.Name)
	end
end

-- Open / close / minimize

local menuTweenInfo = TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

function ApplyMinimize(value, instant)
	minimized = value
	minimizeButton.Text = value and "+" or "-"
	hintLabel.Visible = not value

	local size = UDim2.new(0, WINDOW_WIDTH, 0, value and TITLE_HEIGHT or WINDOW_HEIGHT)
	Tween(main, {Size = size}, instant and TweenInfo.new(0) or TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.Out))
end

function SetMenu(open)
	menuOpen = open

	if rebindingId then
		FinishRebind(nil)
	end

	if open then
		ApplyMinimize(false, true)

		main.Visible = true

		if not openedOnce then
			openedOnce = true

			main.GroupTransparency = 1
			uiScale.Scale = 0.86

			TweenService:Create(uiScale, TweenInfo.new(0.45, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Scale = 1}):Play()
			TweenService:Create(main, TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {GroupTransparency = 0}):Play()
		else
			main.GroupTransparency = 1
			uiScale.Scale = 0.94

			TweenService:Create(main, menuTweenInfo, {GroupTransparency = 0}):Play()
			TweenService:Create(uiScale, menuTweenInfo, {Scale = 1}):Play()
		end
	else
		local hide = TweenService:Create(main, menuTweenInfo, {GroupTransparency = 1})

		hide.Completed:Once(function()
			if not menuOpen then
				main.Visible = false
			end
		end)

		hide:Play()
		TweenService:Create(uiScale, menuTweenInfo, {Scale = 0.94}):Play()
	end
end

-- Dragging

EnableDrag(main, titleBar)

-- Input

UIS.InputBegan:Connect(function(input, gpe)

	if rebindingId then
		if input.UserInputType == Enum.UserInputType.Keyboard then
			if input.KeyCode == Enum.KeyCode.Escape then
				FinishRebind(nil)
			elseif input.KeyCode ~= Enum.KeyCode.Unknown then
				FinishRebind(input.KeyCode)
			end
		end

		return
	end

	if gpe then
		return
	end

	if input.UserInputType ~= Enum.UserInputType.Keyboard then
		return
	end

	if input.KeyCode == binds.MenuToggle then
		SetMenu(not menuOpen)
		return
	end

	for _, action in ipairs(actionsList) do
		if input.KeyCode == binds[action.Id] then
			action.Callback()
			RefreshToggles()
			break
		end
	end

end)

-- Init

RefreshToggles(true)
ApplySwitch(distanceSwitchObject, states.ShowDistance, true)
SwitchPage(1)

end -- MENU BLOCK