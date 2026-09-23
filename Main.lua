-- ============================================
-- Mobile Main Menu Server Hop (Delta Executor)
-- ============================================

local github_raw_url = "https://raw.githubusercontent.com/yusifboos999-cmd/..-/refs/heads/main/Main.lua"

local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer

-- إزالة الواجهة القديمة لتجنب تكرار القوائم
local guiName = "Delta_MobileMainMenu_UI"
local parentGui = (gethui and gethui()) or CoreGui or LocalPlayer:WaitForChild("PlayerGui")

if parentGui:FindFirstChild(guiName) then
    parentGui[guiName]:Destroy()
end

-- إنشاء الشاشة الرئيسية
local screenGui = Instance.new("ScreenGui")
screenGui.Name = guiName
screenGui.ResetOnSpawn = false
screenGui.Parent = parentGui

-- 1. زر التبديل العائم (Toggle Button) - مخصص للجوال
local toggleBtn = Instance.new("TextButton")
toggleBtn.Name = "ToggleButton"
toggleBtn.Size = UDim2.new(0, 45, 0, 45)
toggleBtn.Position = UDim2.new(0.02, 0, 0.25, 0)
toggleBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
toggleBtn.TextColor3 = Color3.fromRGB(0, 170, 255)
toggleBtn.Text = "📜"
toggleBtn.TextSize = 22
toggleBtn.Active = true
toggleBtn.Draggable = true
toggleBtn.Parent = screenGui

local toggleCorner = Instance.new("UICorner")
toggleCorner.CornerRadius = UDim.new(0, 12)
toggleCorner.Parent = toggleBtn

local toggleStroke = Instance.new("UIStroke")
toggleStroke.Color = Color3.fromRGB(0, 170, 255)
toggleStroke.Thickness = 2
toggleStroke.Parent = toggleBtn

-- 2. إطار القائمة الرئيسية (Main Menu Frame)
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 260, 0, 170)
mainFrame.Position = UDim2.new(0.5, -130, 0.3, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Visible = true
mainFrame.Parent = screenGui

local frameCorner = Instance.new("UICorner")
frameCorner.CornerRadius = UDim.new(0, 14)
frameCorner.Parent = mainFrame

local frameStroke = Instance.new("UIStroke")
frameStroke.Color = Color3.fromRGB(0, 170, 255)
frameStroke.Thickness = 2
frameStroke.Parent = mainFrame

-- عنوان القائمة (Main Menu Title)
local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, -40, 0, 35)
titleLabel.Position = UDim2.new(0, 12, 0, 2)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "القائمة الرئيسية | Main Menu"
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.TextSize = 14
titleLabel.Font = Enum.Font.SourceSansBold
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Parent = mainFrame

-- زر إغلاق القائمة (X)
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 26, 0, 26)
closeBtn.Position = UDim2.new(1, -32, 0, 6)
closeBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.Text = "✕"
closeBtn.TextSize = 14
closeBtn.Font = Enum.Font.SourceSansBold
closeBtn.Parent = mainFrame

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 6)
closeCorner.Parent = closeBtn

-- زر تغيير السيرفر داخل القائمة
local hopBtn = Instance.new("TextButton")
hopBtn.Size = UDim2.new(0.9, 0, 0, 42)
hopBtn.Position = UDim2.new(0.05, 0, 0.28, 0)
hopBtn.BackgroundColor3 = Color3.fromRGB(0, 140, 240)
hopBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
hopBtn.Text = "تغيير السيرفر 🔄"
hopBtn.TextSize = 16
hopBtn.Font = Enum.Font.SourceSansBold
hopBtn.Parent = mainFrame

local hopCorner = Instance.new("UICorner")
hopCorner.CornerRadius = UDim.new(0, 8)
hopCorner.Parent = hopBtn

-- زر إعادة دخول نفس السيرفر
local rejoinBtn = Instance.new("TextButton")
rejoinBtn.Size = UDim2.new(0.9, 0, 0, 42)
rejoinBtn.Position = UDim2.new(0.05, 0, 0.60, 0)
rejoinBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
rejoinBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
rejoinBtn.Text = "إعادة دخول نفس السيرفر 🔁"
rejoinBtn.TextSize = 14
rejoinBtn.Font = Enum.Font.SourceSansBold
rejoinBtn.Parent = mainFrame

local rejoinCorner = Instance.new("UICorner")
rejoinCorner.CornerRadius = UDim.new(0, 8)
rejoinCorner.Parent = rejoinBtn

-- البرمجة والأوامر
toggleBtn.MouseButton1Click:Connect(function()
    mainFrame.Visible = not mainFrame.Visible
end)

closeBtn.MouseButton1Click:Connect(function()
    mainFrame.Visible = false
end)

local isHopping = false

local function executeTeleport(targetJobId)
    local queueFunc = queue_on_teleport or syn.queue_on_teleport or queueonteleport
    if queueFunc then
        queueFunc(string.format('loadstring(game:HttpGet("%s"))()', github_raw_url))
    end
    
    if targetJobId then
        TeleportService:TeleportToPlaceInstance(game.PlaceId, targetJobId, LocalPlayer)
    else
        TeleportService:Teleport(game.PlaceId, LocalPlayer)
    end
end

local function hop()
    if isHopping then return end
    isHopping = true
    hopBtn.Text = "جاري البحث..."

    task.spawn(function()
        local placeId = game.PlaceId
        local currentJobId = game.JobId
        local servers = {}
        local cursor = ""

        -- جلب السيرفرات عبر البروكسي RoProxy لتجاوز الحظر
        for page = 1, 3 do
            local url = "https://games.roproxy.com/v1/games/" .. placeId .. "/servers/Public?sortOrder=Asc&limit=100"
            if cursor ~= "" then
                url = url .. "&cursor=" .. cursor
            end

            local success, result = pcall(function()
                local req = game:HttpGet(url)
                return HttpService:JSONDecode(req)
            end)

            if success and result and result.data then
                for _, s in ipairs(result.data) do
                    if type(s) == "table" and s.id ~= currentJobId and s.playing < s.maxPlayers then
                        table.insert(servers, s.id)
                    end
                end
                
                if result.nextPageCursor then
                    cursor = result.nextPageCursor
                else
                    break
                end
            else
                break
            end
            
            if #servers > 20 then break end
        end

        if #servers > 0 then
            local targetServer = servers[math.random(1, #servers)]
            hopBtn.Text = "جاري الانتقال..."
            executeTeleport(targetServer)
        else
            -- خيار احتياطي لتغيير السيرفر عشوائياً إذا تعذر الوصول لـ API
            hopBtn.Text = "انتقال عشوائي..."
            executeTeleport(nil)
        end
    end)
end

hopBtn.MouseButton1Click:Connect(hop)

rejoinBtn.MouseButton1Click:Connect(function()
    rejoinBtn.Text = "جاري إعادة الدخول..."
    executeTeleport(game.JobId)
end)
