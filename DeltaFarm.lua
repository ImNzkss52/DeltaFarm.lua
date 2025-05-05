-- Delta Island Auto Farm (Toggle: F)
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local UIS = game:GetService("UserInputService")

-- Настройки
local Settings = {
    TargetNPC = "Pirate", -- Имя NPC (Pirate, Elite Pirate, Boss)
    AttackKey = "X", -- Клавиша атаки
    ToggleKey = Enum.KeyCode.F, -- Клавиша вкл/выкл
    AttackRange = 20, -- Дистанция атаки
    FarmEnabled = false -- Старт выключен
}

-- Основные переменные
local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")

-- Поиск NPC
local function FindNearestNPC()
    local closestNPC, closestDistance = nil, math.huge
    
    for _, npc in ipairs(Workspace.Enemies:GetChildren()) do
        if npc:FindFirstChild("Humanoid") and npc:FindFirstChild("HumanoidRootPart") and npc.Humanoid.Health > 0 then
            if string.find(npc.Name, Settings.TargetNPC) then
                local distance = (HumanoidRootPart.Position - npc.HumanoidRootPart.Position).Magnitude
                if distance < closestDistance then
                    closestNPC, closestDistance = npc, distance
                end
            end
        end
    end
    
    return closestNPC
end

-- Атака NPC
local function Attack(target)
    if target then
        HumanoidRootPart.CFrame = target.HumanoidRootPart.CFrame * CFrame.new(0, 0, Settings.AttackRange)
        game:GetService("VirtualInputManager"):SendKeyEvent(true, Settings.AttackKey, false, game)
        task.wait(0.2)
        game:GetService("VirtualInputManager"):SendKeyEvent(false, Settings.AttackKey, false, game)
    end
end

-- Анти-AFK
local VirtualUser = game:GetService("VirtualUser")
Player.Idled:Connect(function()
    VirtualUser:CaptureController()
    VirtualUser:ClickButton2(Vector2.new())
end)

-- Переключение скрипта
UIS.InputBegan:Connect(function(input, gameProcessed)
    if input.KeyCode == Settings.ToggleKey and not gameProcessed then
        Settings.FarmEnabled = not Settings.FarmEnabled
        print(string.format("AutoFarm: %s", Settings.FarmEnabled and "ON" or "OFF"))
    end
end)

-- Главный цикл
while task.wait() do
    if Settings.FarmEnabled then
        local target = FindNearestNPC()
        if target then
            Attack(target)
        end
    end
end
