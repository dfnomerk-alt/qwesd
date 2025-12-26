local Version = "17.6.1"
local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/download/1.6.62/main.lua"))()
local http = game:GetService("HttpService")

-- // 1. THEME COLLECTION (WindUI Custom Themes) // --
WindUI:AddTheme({
    Name = "Cyber Midnight",
    Accent = Color3.fromHex("#7775F2"),
    Background = Color3.fromHex("#050505"),
    BackgroundTransparency = 0,
    Outline = Color3.fromHex("#1A1A1A"),
    Text = Color3.fromHex("#FFFFFF"),
    Placeholder = Color3.fromHex("#444444"),
    Button = Color3.fromHex("#121212"),
    Icon = Color3.fromHex("#7775F2"),
    Hover = Color3.fromHex("#FFFFFF"),
    WindowBackground = Color3.fromHex("#050505"),
    WindowShadow = Color3.fromHex("#000000"),
    TabTitle = Color3.fromHex("#FFFFFF"),
    ElementBackground = Color3.fromHex("#0A0A0A"),
    Toggle = Color3.fromHex("#7775F2"),
    ToggleBar = Color3.fromHex("#FFFFFF"),
})

WindUI:AddTheme({
    Name = "Rose Gold",
    Accent = Color3.fromHex("#FF7B9C"),
    Background = Color3.fromHex("#0F0D0E"),
    BackgroundTransparency = 0,
    Outline = Color3.fromHex("#261F22"),
    Text = Color3.fromHex("#FCEFF9"),
    Placeholder = Color3.fromHex("#5E5158"),
    Button = Color3.fromHex("#1C1719"),
    Icon = Color3.fromHex("#FF7B9C"),
    Hover = Color3.fromHex("#FFD1DC"),
    WindowBackground = Color3.fromHex("#0F0D0E"),
    WindowShadow = Color3.fromHex("#000000"),
    TabTitle = Color3.fromHex("#FCEFF9"),
    ElementBackground = Color3.fromHex("#151213"),
    Toggle = Color3.fromHex("#FF7B9C"),
    ToggleBar = Color3.fromHex("#FFFFFF"),
})

WindUI:AddTheme({
    Name = "Emerald Forest",
    Accent = Color3.fromHex("#30ff6a"),
    Background = Color3.fromHex("#080D0A"),
    BackgroundTransparency = 0,
    Outline = Color3.fromHex("#141F18"),
    Text = Color3.fromHex("#EFFFF4"),
    Placeholder = Color3.fromHex("#4B5E53"),
    Button = Color3.fromHex("#0F1712"),
    Icon = Color3.fromHex("#30ff6a"),
    Hover = Color3.fromHex("#FFFFFF"),
    WindowBackground = Color3.fromHex("#080D0A"),
    WindowShadow = Color3.fromHex("#000000"),
    TabTitle = Color3.fromHex("#EFFFF4"),
    ElementBackground = Color3.fromHex("#0C120F"),
    Toggle = Color3.fromHex("#30ff6a"),
    ToggleBar = Color3.fromHex("#FFFFFF"),
})

-- // 2. CORE CONFIGURATION // --
local Config = {
    TargetName = "",
    Price = 100,
    MaxWeight = 2.0, 
    TargetAmount = 1,
    Delay = 6.0,      
    LoopDelay = 10.0, 
    IsRunning = false,
    AutoLoop = false,
    MaxBoothItems = 50,
    BlacklistedUUIDs = {},
    WebhookURL = "",
    PanicOnAdmin = true,
    AntiAFK = true, 
    StartTime = os.time()
}

local Stats = { Sold = 0, Gems = 0, CurrentlyListed = 0, CurrentTokens = 0, Status = "Idle" }

-- // 3. UI WINDOW SETUP // --
local Window = WindUI:CreateWindow({
    Title = "AFK MARKET",
    SubTitle = "ipowfu verified", 
    Author = "Misthios",
    Theme = "Cyber Midnight", -- Pilih tema di sini
    Icon = "solar:shield-check-bold",
    Transparent = false, 
    Acrylic = false,     
    TransparencyValue = 0,
    Topbar = { 
        Height = 44, 
        ButtonsType = "Mac",
        ButtonsPosition = "Right" 
    }
})

-- // 4. TAGS (iPowfu & Version) // --
Window:Tag({
    Title = "iPowfu",
    Icon = "solar:verified-check-bold",
    Color = Color3.fromHex("#30ff6a"),
    Radius = 8,
})

Window:Tag({
    Title = "v17.6.1",
    Icon = "github",
    Color = Color3.fromHex("#7775F2"),
    Radius = 8,
})

-- // 5. TABS SETUP // --
local MonitorTab = Window:Tab({ Title = "Dashboard", Icon = "solar:chart-bold", IconColor = Color3.fromHex("#AF52DE") })
local MainTab = Window:Tab({ Title = "Scanner", Icon = "solar:scanner-bold", IconColor = Color3.fromHex("#007AFF") })
local EliteTab = Window:Tab({ Title = "AFK Perks", Icon = "solar:ghost-bold", IconColor = Color3.fromHex("#FF3B30") })
local SettingTab = Window:Tab({ Title = "Settings", Icon = "solar:settings-bold", IconColor = Color3.fromHex("#8E8E93") })

-- // 6. DASHBOARD ENGINE // --
local DashSec = MonitorTab:Section({ Title = "System Monitor" })
local StatusBtn = DashSec:Button({ Title = "Status: Idle" })
local TokenBtn = DashSec:Button({ Title = "Wallet: Initializing..." })
local BoothBtn = DashSec:Button({ Title = "Booth: 0/50 Items" })
local SessionBtn = DashSec:Button({ Title = "Session Profit: 0 Tokens" })
local TimeBtn = DashSec:Button({ Title = "Uptime: 0h 0m" })

task.spawn(function()
    local RS = game:GetService("ReplicatedStorage")
    local DataService = require(RS.Modules.DataService)
    local lp = game.Players.LocalPlayer

    local function forceSync()
        local data = nil
        pcall(function() data = DataService:GetData() end)
        if data and data.TradeData then
            Stats.CurrentTokens = data.TradeData.Tokens
            TokenBtn:SetTitle("Wallet: " .. string.format("%.0f", Stats.CurrentTokens) .. " Tokens")
        end
    end

    DataService:GetPathSignal("TradeData/Tokens"):Connect(forceSync)
    forceSync()

    while task.wait(1) do
        local diff = os.difftime(os.time(), Config.StartTime)
        local h, m = math.floor(diff/3600), math.floor((diff%3600)/60)
        TimeBtn:SetTitle("Uptime: " .. string.format("%dh %dm", h, m))
        StatusBtn:SetTitle("Status: " .. Stats.Status)
        
        local bGui = lp.PlayerGui:FindFirstChild("TradeBooth") or lp.PlayerGui:FindFirstChild("Booth")
        if bGui then
            local listFrame = bGui:FindFirstChild("List", true) or bGui:FindFirstChild("ScrollingFrame", true)
            if listFrame then
                local count = 0
                for _, child in pairs(listFrame:GetChildren()) do
                    if (child:IsA("Frame") or child:IsA("ImageButton")) and child.Name ~= "Add" and not child:IsA("UIComponent") then
                        if child:FindFirstChild("Item", true) or child:FindFirstChild("Price", true) then count = count + 1 end
                    end
                end
                Stats.CurrentlyListed = count
                BoothBtn:SetTitle("Booth: " .. count .. "/50 Items")
            end
        end
    end
end)

-- // 7. SCANNER (DIVINER) LOGIC // --
function StartRhythmScan()
    Stats.Status = "Scanning"
    task.spawn(function()
        local RS = game:GetService("ReplicatedStorage")
        while Config.AutoLoop do
            if Stats.CurrentlyListed >= Config.MaxBoothItems then
                Stats.Status = "Booth Full (Waiting)"
                repeat task.wait(5) until Stats.CurrentlyListed < Config.MaxBoothItems or not Config.AutoLoop
                if not Config.AutoLoop then break end
            end

            Config.IsRunning = true
            Stats.Status = "Listing Items"
            local bp = game.Players.LocalPlayer:FindFirstChild("Backpack")
            if bp and Config.TargetName ~= "" then
                local putInCycle = 0
                for _, item in pairs(bp:GetChildren()) do
                    if putInCycle >= Config.TargetAmount or (Stats.CurrentlyListed + putInCycle) >= Config.MaxBoothItems then break end
                    if string.find(item.Name:lower(), Config.TargetName:lower()) then
                        local weight = tonumber(string.match(item.Name, "%d+%.?%d*")) or 0
                        local uuid = item:GetAttribute("PET_UUID")
                        if uuid and weight <= Config.MaxWeight and not Config.BlacklistedUUIDs[uuid] then
                            local ok = RS.GameEvents.TradeEvents.Booths.CreateListing:InvokeServer("Pet", tostring(uuid), Config.Price)
                            if ok then
                                Config.BlacklistedUUIDs[uuid] = true
                                putInCycle = putInCycle + 1
                            end
                            task.wait(Config.Delay)
                        end
                    end
                end
            end
            Stats.Status = "Standby (Delay)"
            task.wait(Config.LoopDelay)
            Config.IsRunning = false
        end
        Stats.Status = "Idle"
    end)
end

-- // 8. UI TABS SETUP // --
local TargetSec = MainTab:Section({ Title = "Pet Configuration" })
TargetSec:Input({ Title = "Nama Pet Target", Callback = function(v) Config.TargetName = v end })
TargetSec:Input({ Title = "Set Harga Jual", Callback = function(v) Config.Price = tonumber(v) or 100 end })
TargetSec:Input({ Title = "Jumlah Pet Per Siklus", Value = "1", Callback = function(v) Config.TargetAmount = tonumber(v) or 1 end })

MainTab:Section({ Title = "Execution" }):Toggle({ 
    Title = "Auto Rhythm Active", 
    Value = false, 
    Callback = function(s) Config.AutoLoop = s if s then StartRhythmScan() end end 
})

local EliteSec = EliteTab:Section({ Title = "Elite AFK Protection" })
EliteSec:Toggle({ Title = "Anti-AFK Jump", Value = true, Callback = function(v) Config.AntiAFK = v end })

task.spawn(function()
    while task.wait(10) do
        if Config.AntiAFK then
            local lp = game.Players.LocalPlayer
            if lp.Character and lp.Character:FindFirstChild("Humanoid") then
                lp.Character.Humanoid.Jump = true
            end
            game:GetService("VirtualUser"):CaptureController()
            game:GetService("VirtualUser"):ClickButton2(Vector2.new())
        end
    end
end)

local SetSec = SettingTab:Section({ Title = "System Connection" })
SetSec:Input({ Title = "Webhook URL", Callback = function(v) Config.WebhookURL = v end })

-- // 9. GLOBAL EVENTS // --
game:GetService("ReplicatedStorage").GameEvents.TradeEvents.Booths.AddToHistory.OnClientEvent:Connect(function(data)
    if data and data.seller and data.seller.userId == game.Players.LocalPlayer.UserId then
        Stats.Sold = Stats.Sold + 1
        Stats.Gems = Stats.Gems + (data.price or 0)
        SessionBtn:SetTitle("Session Profit: " .. Stats.Gems .. " Tokens")
    end
end)
