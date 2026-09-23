-- ============================================
-- 5-Min Synced Timer & 1B+ Finder (Delta Executor)
-- Steal an Egg! - Mobile Friendly
-- ============================================

local github_raw_url = "https://raw.githubusercontent.com/yusifboos999-cmd/..-/refs/heads/main/Main.lua"

local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer

-- قائمة حيوانات الـ 1B+ المطلوب التنبيه عليها
local HighTier1BPets = {
    "Aetheron", "ArchAngel", "World Burner", "Nightflame", 
    "Kitsune", "Unicorn", "Shattered Colossus", "Dreadscale", "Equinox"
}

local guiName = "Delta_5Min_1BPrompt_UI"
local parentGui = (gethui and gethui()) or CoreGui or LocalPlayer:WaitForChild("PlayerGui")

if parentGui:FindFirstChild(guiName) then
    parentGui[guiName]:Destroy()
end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = guiName
screenGui.ResetOnSpawn = false
screenGui.Parent = parentGui

-- 1. زر التبديل العائم (Toggle Button)
local toggleBtn = Instance.new("TextButton")
toggleBtn.Name = "ToggleButton"
toggleBtn.Size = UDim2.new(0, 45, 0, 45)
toggleBtn.Position = UDim2.new(0.02, 0, 0.25, 0)
toggleBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
toggleBtn.TextColor3 = Color3.fromRGB(0, 255, 150)
toggleBtn.Text = "💎"
toggleBtn.TextSize = 22
toggleBtn.Active = true
toggleBtn.Draggable = true
toggleBtn.Parent = screenGui

local toggleCorner = Instance.new("UICorner")
toggleCorner.CornerRadius = UDim.new(0, 12)
toggleCorner.Parent = toggleBtn

local toggleStroke = Instance.new("UIStroke")
toggleStroke.Color = Color3.fromRGB(0, 255, 150)
toggleStroke.Thickness = 2
toggleStroke.Parent = toggleBtn

-- 2. إطار القائمة الرئيسية
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 270, 0, 145)
mainFrame.Position = UDim2.new(0.5, -135, 0.25, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = screenGui

local frameCorner = Instance.new("UICorner")
frameCorner.CornerRadius = UDim.new(0, 14)
frameCorner.Parent = mainFrame

local frameStroke = Instance.new("UIStroke")
frameStroke.Color = Color3.fromRGB(0, 255, 150)
frameStroke.Thickness = 2
frameStroke.Parent = mainFrame

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, -10, 0, 30)
titleLabel.Position = UDim2.new(0, 10, 0, 5)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "صايد 1B+ (عداد 5 دقائق) ⏱️"
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.TextSize = 13
titleLabel.Font = Enum.Font.SourceSansBold
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Parent = mainFrame

local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(0.92, 0, 0, 55)
statusLabel.Position = UDim2.new(0.04, 0, 0.26, 0)
statusLabel.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
statusLabel.TextColor3 = Color3.fromRGB(255, 200, 50)
statusLabel.Text = "⏱️ جاري حساب وقت رسبون الماب..."
statusLabel.TextSize = 13
statusLabel.TextWrapped = true
statusLabel.Font = Enum.Font.SourceSansBold
statusLabel.Parent = mainFrame

local statusCorner = Instance.new("UICorner")
statusCorner.CornerRadius = UDim.new(0, 8)
statusCorner.Parent = statusLabel

local manualHopBtn = Instance.new("TextButton")
manualHopBtn.Size = UDim2.new(0.92, 0, 0, 32)
manualHopBtn.Position = UDim2.new(0.04, 0, 0.72, 0)
manualHopBtn.BackgroundColor3 = Color3.fromRGB(0, 140, 240)
manualHopBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
manualHopBtn.Text = "تغيير السيرفر يدوياً 🔄"
manualHopBtn.TextSize = 13
manualHopBtn.Font = Enum.Font.SourceSansBold
manualHopBtn.Parent = mainFrame

local manualCorner = Instance.new("UICorner")
manualCorner.CornerRadius = UDim.new(0, 6)
manualCorner.Parent = manualHopBtn

toggleBtn.MouseButton1Click:Connect(function()
    mainFrame.Visible = not mainFrame.Visible
end)

-- وظيفة الانتقال عبر queue_on_teleport
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

local function serverHop()
    statusLabel.Text = "🔄 جاري البحث عن سيرفر جديد..."
    statusLabel.TextColor3 = Color3.fromRGB(0, 170, 255)
    
    task.spawn(function()
        local placeId = game.PlaceId
        local currentJobId = game.JobId
        local servers = {}

        local success, result = pcall(function()
            local req = game:HttpGet("https://games.roproxy.com/v1/games/" .. placeId .. "/servers/Public?sortOrder=Asc&limit=100")
            return HttpService:JSONDecode(req)
        end)

        if success and result and result.data then
            for _, s in ipairs(result.data) do
                if type(s) == "table" and s.id ~= currentJobId and s.playing < s.maxPlayers then
                    table.insert(servers, s.id)
                end
            end
        end

        if #servers > 0 then
            executeTeleport(servers[math.random(1, #servers)])
        else
            executeTeleport(nil)
        end
    end)
end

manualHopBtn.MouseButton1Click:Connect(serverHop)

-- فحص السيرفر بحثاً عن حيوان 1B+
local function check1BPetInServer()
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("Model") or obj:IsA("BasePart") then
            for _, petName in ipairs(HighTier1BPets) do
                if string.find(string.lower(obj.Name), string.lower(petName)) then
                    return obj.Name
                end
            end
        end
    end

    for _, gui in ipairs(Workspace:GetDescendants()) do
        if gui:IsA("TextLabel") or gui:IsA("TextButton") then
            local txt = gui.Text
            if string.find(txt, "B/s") or string.find(txt, "B") then
                for num in string.gmatch(txt, "(%d+%.?%d*)B") do
                    local val = tonumber(num)
                    if val and val >= 1.0 then
                        return "حيوان (" .. txt .. ")"
                    end
                end
            end
        end
    end

    return nil
end

-- نافذة السؤال المنبثقة (تظهر لمدة 10 ثوانٍ)
local function showPrompt()
    local promptFrame = Instance.new("Frame")
    promptFrame.Name = "PromptFrame"
    promptFrame.Size = UDim2.new(0, 280, 0, 150)
    promptFrame.Position = UDim2.new(0.5, -140, 0.4, 0)
    promptFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 38)
    promptFrame.Active = true
    promptFrame.Draggable = true
    promptFrame.Parent = screenGui

    local pCorner = Instance.new("UICorner")
    pCorner.CornerRadius = UDim.new(0, 12)
    pCorner.Parent = promptFrame

    local pStroke = Instance.new("UIStroke")
    pStroke.Color = Color3.fromRGB(255, 170, 0)
    pStroke.Thickness = 2
    pStroke.Parent = promptFrame

    local promptText = Instance.new("TextLabel")
    promptText.Size = UDim2.new(0.9, 0, 0, 55)
    promptText.Position = UDim2.new(0.05, 0, 0.1, 0)
    promptText.BackgroundTransparency = 1
    promptText.TextColor3 = Color3.fromRGB(255, 255, 255)
    promptText.TextSize = 13
    promptText.TextWrapped = true
    promptText.Font = Enum.Font.SourceSansBold
    promptText.Parent = promptFrame

    local yesBtn = Instance.new("TextButton")
    yesBtn.Size = UDim2.new(0.42, 0, 0, 38)
    yesBtn.Position = UDim2.new(0.05, 0, 0.62, 0)
    yesBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 80)
    yesBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    yesBtn.Text = "نعم 🚀"
    yesBtn.TextSize = 14
    yesBtn.Font = Enum.Font.SourceSansBold
    yesBtn.Parent = promptFrame

    local yesCorner = Instance.new("UICorner")
    yesCorner.CornerRadius = UDim.new(0, 8)
    yesCorner.Parent = yesBtn

    local noBtn = Instance.new("TextButton")
    noBtn.Size = UDim2.new(0.42, 0, 0, 38)
    noBtn.Position = UDim2.new(0.53, 0, 0.62, 0)
    noBtn.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
    noBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    noBtn.Text = "لا ❌"
    noBtn.TextSize = 14
    noBtn.Font = Enum.Font.SourceSansBold
    noBtn.Parent = promptFrame

    local noCorner = Instance.new("UICorner")
    noCorner.CornerRadius = UDim.new(0, 8)
    noCorner.Parent = noBtn

    local responded = false

    yesBtn.MouseButton1Click:Connect(function()
        if responded then return end
        responded = true
        promptFrame:Destroy()
        serverHop()
    end)

    noBtn.MouseButton1Click:Connect(function()
        if responded then return end
        responded = true
        promptFrame:Destroy()
        statusLabel.Text = "تم اختيار البقاء في السيرفر الحالي 👍"
        statusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    end)

    task.spawn(function()
        for i = 10, 1, -1 do
            if responded then break end
            promptText.Text = "لم يتم العثور على حيوان 1B+!\nهل تريد الانتقال لسيرفر يعطي حيوان 1B؟\n(" .. i .. " ثوانٍ)"
            task.wait(1)
        end
        if not responded then
            responded = true
            promptFrame:Destroy()
            statusLabel.Text = "انتهى الوقت: البقاء في السيرفر الحالي 👍"
            statusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
        end
    end)
end

-- حساب المتبقي لانتهاء دورة الـ 5 دقائق متزامنة مع الساعة
local function getTimeRemainingIn5MinCycle()
    local now = os.time()
    local secondsLeft = 300 - (now % 300)
    return secondsLeft
end

-- الدورة الرئيسية المزامنة
task.spawn(function()
    while true do
        local timeLeft = getTimeRemainingIn5MinCycle()
        
        -- إذا كان باقي أكثر من ثوانٍ معدودة، نعرض العداد التنازلي
        while timeLeft > 2 do
            timeLeft = getTimeRemainingIn5MinCycle()
            local mins = math.floor(timeLeft / 60)
            local secs = timeLeft % 60
            statusLabel.Text = string.format("⏳ باقي على رسبون الماب القادم:\n%02d:%02d", mins, secs)
            statusLabel.TextColor3 = Color3.fromRGB(255, 200, 50)
            task.wait(1)
        end

        -- وصلنا لوقت الرسبون بالضبط
        statusLabel.Text = "⚡ رسبن الماب الآن! جاري فحص الحيوانات..."
        statusLabel.TextColor3 = Color3.fromRGB(0, 200, 255)
        task.wait(2) -- انتظار ثانيتين لتحميل كائنات الماب الجديدة

        local found1BPet = check1BPetInServer()

        if found1BPet then
            statusLabel.Text = "🎉 تم العثور على حيوان 1B+!\n" .. found1BPet
            statusLabel.TextColor3 = Color3.fromRGB(0, 255, 100)
            break -- يتوقف السكربت لتستمتع بالحيوان
        else
            statusLabel.Text = "❌ لم يترسبن حيوان 1B+."
            statusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
            showPrompt()
            break -- إظهار نافذة التنبيه والخيار للمستخدم
        end
    end
end)
