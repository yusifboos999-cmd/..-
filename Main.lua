local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")

-- إزالة الواجهة القديمة إذا كانت موجودة مسبقاً لتجنب التكرار
if CoreGui:FindFirstChild("ServerHopGUI") then
    CoreGui.ServerHopGUI:Destroy()
end

-- إنشاء الواجهة الأساسية
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ServerHopGUI"
ScreenGui.Parent = CoreGui

local MainMenu = Instance.new("Frame")
MainMenu.Name = "MainMenu"
MainMenu.Parent = ScreenGui
MainMenu.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MainMenu.Position = UDim2.new(0.5, -100, 0.2, 0) -- موضع علوي بالمنتصف لتجنب أزرار التحكم
MainMenu.Size = UDim2.new(0, 200, 0, 150)
MainMenu.Active = true

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 10)
UICorner.Parent = MainMenu

local Title = Instance.new("TextLabel")
Title.Name = "Title"
Title.Parent = MainMenu
Title.BackgroundTransparency = 1
Title.Size = UDim2.new(1, 0, 0, 40)
Title.Font = Enum.Font.GothamBold
Title.Text = "Main Menu"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 20

local ChangeServerBtn = Instance.new("TextButton")
ChangeServerBtn.Name = "ChangeServer"
ChangeServerBtn.Parent = MainMenu
ChangeServerBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 215)
ChangeServerBtn.Position = UDim2.new(0.1, 0, 0.45, 0)
ChangeServerBtn.Size = UDim2.new(0.8, 0, 0, 45)
ChangeServerBtn.Font = Enum.Font.GothamBold
ChangeServerBtn.Text = "change server"
ChangeServerBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ChangeServerBtn.TextSize = 18

local BtnCorner = Instance.new("UICorner")
BtnCorner.CornerRadius = UDim.new(0, 8)
BtnCorner.Parent = ChangeServerBtn

-- نظام سحب الواجهة (مخصص للتوافق مع لمس الجوال)
local dragging
local dragInput
local dragStart
local startPos

MainMenu.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainMenu.Position
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

MainMenu.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        MainMenu.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- برمجة زر تغيير السيرفر
ChangeServerBtn.MouseButton1Click:Connect(function()
    ChangeServerBtn.Text = "Searching..."
    local PlaceId = game.PlaceId
    
    -- جلب قائمة السيرفرات وترتيبها من الأقل للأكثر
    local success, result = pcall(function()
        return game:HttpGet("https://games.roblox.com/v1/games/"..PlaceId.."/servers/Public?sortOrder=Asc&limit=100")
    end)

    if success then
        local data = HttpService:JSONDecode(result)
        local found = false
        
        if data and data.data then
            for _, server in ipairs(data.data) do
                -- التأكد من أن السيرفر يحتوي على 1 أو 0 لاعب وليس السيرفر الحالي
                if server.playing <= 1 and server.id ~= game.JobId then
                    ChangeServerBtn.Text = "Teleporting..."
                    found = true
                    TeleportService:TeleportToPlaceInstance(PlaceId, server.id, Players.LocalPlayer)
                    break
                end
            end
        end
        
        if not found then
            ChangeServerBtn.Text = "No Server Found"
            task.wait(2)
            ChangeServerBtn.Text = "change server"
        end
    else
        ChangeServerBtn.Text = "Error! Try Again"
        task.wait(2)
        ChangeServerBtn.Text = "change server"
    end
end)
