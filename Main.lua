-- ============================================
-- 5-Min Synced Timer & Accurate 1B+ Finder
-- Steal an Egg! - Delta Executor
-- ============================================

local github_raw_url = "https://raw.githubusercontent.com/yusifboos999-cmd/..-/refs/heads/main/Main.lua"

local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer

-- قائمة السيرفرات المزارة لمنع التكرار
if _G.VisitedServers == nil then
    _G.VisitedServers = {}
end
table.insert(_G.VisitedServers, game.JobId)

-- قائمة الحيوانات العالية (1B+)
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
titleLabel.Text = "صايد 1B+ (دقيق وتلقائي) 💎"
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

-- الانتقال وتمرير قائمة السيرفرات المزارة للسكربت الجديد
local function executeTeleport(targetJobId)
    local queueFunc = queue_on_teleport or syn.queue_on_teleport or queueonteleport
    if queueFunc then
        local visitedStr = "{"
        for _, id in ipairs(_G.VisitedServers) do
            visitedStr = visitedStr .. '"' .. id .. '",'
        end
        visitedStr = visitedStr .. "}"
        queueFunc(string.format('_G.VisitedServers = %s; loadstring(game:HttpGet("%s"))()', visitedStr, github_raw_url))
    end
    
    TeleportService:TeleportToPlaceInstance(game.PlaceId, targetJobId, LocalPlayer)
end

-- التنقل الذكي بين السيرفرات بدون تكرار السيرفر الحالي
local function serverHop()
    statusLabel.Text = "🔄 جاري البحث عن سيرفر جديد لم تدرخله من قبل..."
    statusLabel.TextColor3 = Color3.fromRGB(0, 170, 255)
    
    task.spawn(function()
        local placeId = game.PlaceId
        local currentJobId = game.JobId
        local foundServer = nil
        local cursor = ""

        for page = 1, 3 do
            local url = "https://games.roproxy.com/v1/games/" .. placeId .. "/servers/Public?sortOrder=Desc&limit=100"
            if cursor ~= "" then
                url = url .. "&cursor=" .. cursor
            end

            local success, result = pcall(function()
                return HttpService:JSONDecode(game:HttpGet(url))
            end)

            if success and result and result.data then
                local validServers = {}
                for _, s in ipairs(result.data) do
                    if type(s) == "table" and s.id ~= currentJobId and s.playing < s.maxPlayers then
                        local visited = false
                        if _G.VisitedServers then
                            for _, vId in ipairs(_G.VisitedServers) do
                                if vId == s.id then
                                    visited = true
                                    break
                                end
                            end
                        end
                        if not visited then
                            table.insert(validServers, s.id)
                        end
                    end
                end

                if #validServers > 0 then
                    foundServer = validServers[math.random(1, #validServers)]
                    break
                end

                if result.nextPageCursor then
                    cursor = result.nextPageCursor
                else
                    break
                end
            else
                task.wait(1)
            end
        end

        if foundServer then
            executeTeleport(foundServer)
        else
            -- إذا فحص كل السيرفرات، يصفر القائمة ويبحث من جديد
            _G.VisitedServers = {game.JobId}
            statusLabel.Text = "⚠️ جاري إعادة محاولة البحث..."
            task.wait(1)
            serverHop()
        end
    end)
end

manualHopBtn.MouseButton1Click:Connect(serverHop)

-- فحص دقيق للحيوانات على الأرض فقط (استبعاد اللاعبين وقوائم الشراء ولوحة الصدارة)
local function check1BPetInServer()
    for _, obj in ipairs(Workspace:GetDescendants()) do
        -- التأكد أن الكائن ليس جزءاً من شخصية أي لاعب
        local isPlayer = false
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr.Character and obj:IsDescendantOf(plr.Character) then
                isPlayer = true
                break
            end
        end

        if not isPlayer then
            -- استبعاد شاشات الواجهة والقوائم وقوائم الشراء
            if not (obj:IsA("SurfaceGui") or obj:IsA("ScreenGui")) then
                -- 1. فحص أسماء مجسمات الحيوانات المترسبنة
                if obj:IsA("Model") or obj:IsA("BasePart") then
                    for _, petName in ipairs(HighTier1BPets) do
                        if string.find(string.lower(obj.Name), string.lower(petName)) then
                            return obj.Name
                        end
                    end
                end

                -- 2. فحص النص العائم فوق البيض/الحيوانات المترسبنة على الأرض فقط
                if obj:IsA("BillboardGui") and obj.Parent and obj.Parent.Name ~= "Head" then
                    for _, child in ipairs(obj:GetDescendants()) do
                        if child:IsA("TextLabel") or child:IsA("TextButton") then
                            local txt = child.Text
                            if string.find(txt, "B/s") or string.find(txt, "B") then
                                for num in string.gmatch(txt, "(%d+%.?%d*)B") do
                                    local val = tonumber(num)
                                    if val and val >= 1.0 then
                                        return "حيوان مترسبن (" .. txt .. ")"
                                    end
                                end
                            end
                        end
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

-- حساب التوقيت المتبقي لانتهاء دورة 5 دقائق
local function getTimeRemainingIn5MinCycle()
    local now = os.time()
    return 300 - (now % 300)
end

-- الحلقة الرئيسية المتزامنة مع الماب
task.spawn(function()
    while true do
        local timeLeft = getTimeRemainingIn5MinCycle()
        
        while timeLeft > 2 do
            timeLeft = getTimeRemainingIn5MinCycle()
            local mins = math.floor(timeLeft / 60)
            local secs = timeLeft % 60
            statusLabel.Text = string.format("⏳ باقي على رسبون الماب القادم:\n%02d:%02d", mins, secs)
            statusLabel.TextColor3 = Color3.fromRGB(255, 200, 50)
            task.wait(1)
        end

        statusLabel.Text = "⚡ رسبن الماب الآن! جاري فحص الحيوانات..."
        statusLabel.TextColor3 = Color3.fromRGB(0, 200, 255)
        task.wait(2.5) -- انتظار تحميل الكائنات الجديدة بالماب

        local found1BPet = check1BPetInServer()

        if found1BPet then
            statusLabel.Text = "🎉 تم العثور على حيوان 1B+!\n" .. found1BPet
            statusLabel.TextColor3 = Color3.fromRGB(0, 255, 100)
            break
        else
            statusLabel.Text = "❌ لم يترسبن حيوان 1B+."
            statusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
            showPrompt()
            break
        end
    end
end)
