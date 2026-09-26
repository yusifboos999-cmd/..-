ChangeServerBtn.MouseButton1Click:Connect(function()
    ChangeServerBtn.Text = "Searching..."
    local PlaceId = game.PlaceId
    
    local success, result = pcall(function()
        return game:HttpGet("https://games.roblox.com/v1/games/"..PlaceId.."/servers/Public?sortOrder=Asc&limit=100")
    end)

    if success then
        local data = HttpService:JSONDecode(result)
        local availableServers = {}
        
        if data and data.data then
            for _, server in ipairs(data.data) do
                -- التأكد من أن السيرفر فيه لاعب واحد أو أقل، وليس السيرفر الحالي، وغير ممتلئ
                if server.playing <= 1 and server.id ~= game.JobId and (server.maxPlayers and server.playing < server.maxPlayers) then
                    table.insert(availableServers, server.id)
                end
            end
        end
        
        if #availableServers > 0 then
            ChangeServerBtn.Text = "Teleporting..."
            -- اختيار سيرفر عشوائي من القائمة لتفادي السيرفرات المزدحمة
            local randomServerId = availableServers[math.random(1, #availableServers)]
            TeleportService:TeleportToPlaceInstance(PlaceId, randomServerId, Players.LocalPlayer)
        else
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
