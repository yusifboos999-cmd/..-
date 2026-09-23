-- ============================================
-- 100% Synced Game-Timer & 1B+ Chat Finder
-- Steal an Egg! - Delta Executor
-- ============================================

local github_raw_url = "https://raw.githubusercontent.com/yusifboos999-cmd/..-/refs/heads/main/Main.lua"

local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer

-- قائمة أسماء الحيوانات النادرة (1B+)
local HighTier1BPets = {
    "aetheron", "archangel", "world burner", "nightflame", 
    "kitsune", "unicorn", "shattered colossus", "dreadscale", "equinox"
}

-- الكلمات المفتاحية لتنبيهات الشات
local RareSpawnKeywords = {
    "spawn", "eternal", "divine", "secret", "1b"
}

local guiName = "Delta_ExactTimer_1B_UI"
local parentGui = (gethui and gethui()) or CoreGui or LocalPlayer:WaitForChild("PlayerGui")

if parentGui:FindFirstChild(guiName) then
    parentGui[guiName]:Destroy()
end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = guiName
screenGui.ResetOnSpawn = false
screenGui.Parent = parentGui

-- 1. زر التبديل العائم
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

-- 2. الإطار الرئيسي
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
titleLabel.Text = "صايد 1B+ (عداد دقيق 100%) 💎"
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
statusLabel.Text = "⏱️ جاري جلب عداد اللعبة..."
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

-- تنفيذ الانتقال
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

-- دالة التنقل بين السيرفرات
local function serverHop()
    statusLabel.Text = "🔄 جاري البحث عن سيرفر جديد..."
    statusLabel.TextColor3 = Color3.fromRGB(0, 170, 255)
    
    task.spawn(function()
        local placeId = game.PlaceId
        local currentJobId = game.JobId
        local success, result = pcall(function()
            return HttpService:JSONDecode(game:HttpGet("https://games.roproxy.com/v1/games/" .. placeId .. "/servers/Public?sortOrder=Asc&limit=100"))
        end)

        local targetServer = nil
        if success and result and result.data then
            local validServers = {}
            for _, s in ipairs(result.data) do
                if type(s) == "table" and s.id ~= currentJobId and s.playing < s.maxPlayers then
                    table.insert(validServers, s.id)
                end
            end
            if #validServers > 0 then
                targetServer = validServers[math.random(1, #validServers)]
            end
        end

        executeTeleport(targetServer)
    end)
end

manualHopBtn.MouseButton1Click:Connect(serverHop)

-- دالة قراءة الوقت المتبقي المباشر من واجهة اللعبة (مثل أسفل اليمين)
local function getExactGameTimeLeft()
    local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
    if playerGui then
        for _, guiElement in ipairs(playerGui:GetDescendants()) do
            if guiElement:IsA("TextLabel") or guiElement:IsA("TextButton") then
                local txt = guiElement.Text
                -- قراءة صيغ مثل "in 4m 23s" أو "4m 23s"
                local m, s = string.match(txt, "(%d+)m%s*(%d+)s")
                if m and s then
                    return tonumber(m) * 60 + tonumber(s)
                end
                -- قراءة صيغ مثل "04:23"
                local m2, s2 = string.match(txt, "(%d+):(%d+)")
                if m2 and s2 and tonumber(m2) <= 5 then
                    return tonumber(m2) * 60 + tonumber(s2)
                end
            end
        end
    end

    -- احتياطي: استخدام وقت السيرفر الفعلي
    local serverTime = math.floor(Workspace:GetServerTimeNow())
    return 300 - (serverTime % 300)
end

-- دالة الفحص عبر الشات وأسماء المجسمات فقط
local function check1BPetAccurate()
    -- 1. فحص مجسمات الأرض
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("Model") or obj:IsA("BasePart") then
            local objName = string.lower(obj.Name)
            for _, petName in ipairs(HighTier1BPets) do
                if string.find(objName, petName) then
                    return "الحيوان: " .. obj.Name
                end
            end
        end
    end

    -- 2. فحص رسائل الشات
    local chatGui = LocalPlayer.PlayerGui:FindFirstChild("Chat") or CoreGui:FindFirstChild("Chat")
    if chatGui then
        for _, label in ipairs(chatGui:GetDescendants()) do
            if label:IsA("TextLabel") then
                local txt = string.lower(label.Text)
                for _, kw in ipairs(RareSpawnKeywords) do
                    if string.find(txt, kw) then
                        return "الشات: " .. label.Text
                    end
                end
            end
        end
    end

    return nil
end

-- نافذة السؤال المنبثقة (10 ثوانٍ)
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
            promptText.Text = "لم يترسبن حيوان نادر!\nهل تريد الانتقال لسيرفر آخر؟\n(" .. i .. " ثوانٍ)"
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

-- الحلقة الرئيسية المتزامنة تماماً مع اللعبة
task.spawn(function()
    while true do
        local timeLeft = getExactGameTimeLeft()
        
        while timeLeft > 1 do
            timeLeft = getExactGameTimeLeft()
            local mins = math.floor(timeLeft / 60)
            local secs = timeLeft % 60
            statusLabel.Text = string.format("⏳ باقي على رسبون اللعبة:\n%02d:%02d", mins, secs)
            statusLabel.TextColor3 = Color3.fromRGB(255, 200, 50)
            task.wait(0.5) -- تحديث سريع جداً لمنع أي تأخير
        end

        statusLabel.Text = "⚡ رسبن الماب الآن! جاري فحص الشات..."
        statusLabel.TextColor3 = Color3.fromRGB(0, 200, 255)
        task.wait(2.5) -- انتظار ثانيتين لوصول رسالة الشات والرسبون

        local foundPet = check1BPetAccurate()

        if foundPet then
            statusLabel.Text = "🎉 تم العثور على حيوان نادر!\n" .. foundPet
            statusLabel.TextColor3 = Color3.fromRGB(0, 255, 100)
            break
        else
            statusLabel.Text = "❌ لم يترسبن حيوان نادر."
            statusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
            showPrompt()
            break
        end
    end
end)
