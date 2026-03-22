local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local CoreGui = game:GetService("CoreGui")


local ACCENT_COLOR = Color3.fromRGB(170, 85, 255)
local BG_COLOR = Color3.fromRGB(15, 15, 15)
local TOGGLE_KEY = Enum.KeyCode.M


local BUTTONS_URL = "https://raw.githubusercontent.com/MRX-Coders/MRXhub_Roblox_free/refs/heads/main/BTS.lua"


local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MRXDashboard"
ScreenGui.Parent = CoreGui
ScreenGui.IgnoreGuiInset = true

local Blur = Instance.new("BlurEffect")
Blur.Parent = Lighting
Blur.Size = 0
Blur.Enabled = false

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = BG_COLOR
MainFrame.BackgroundTransparency = 1
MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
MainFrame.Size = UDim2.new(0, 0, 0, 0)
MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
MainFrame.Visible = false

local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0, 15)
Corner.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Parent = MainFrame
Title.Text = "MRX HUB"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.BackgroundTransparency = 1
Title.Position = UDim2.new(0, 0, 0.05, 0)
Title.Size = UDim2.new(1, 0, 0, 60)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 40

local Gradient = Instance.new("UIGradient")
Gradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.new(1, 1, 1)),
    ColorSequenceKeypoint.new(1, ACCENT_COLOR)
})
Gradient.Parent = Title

local Container = Instance.new("ScrollingFrame")
Container.Parent = MainFrame
Container.BackgroundTransparency = 1
Container.Position = UDim2.new(0.1, 0, 0.25, 0)
Container.Size = UDim2.new(0.8, 0, 0.65, 0)
Container.ScrollBarThickness = 2
Container.CanvasSize = UDim2.new(0, 0, 2, 0)

local Grid = Instance.new("UIGridLayout")
Grid.Parent = Container
Grid.CellSize = UDim2.new(0, 220, 0, 80)
Grid.CellPadding = UDim2.new(0, 25, 0, 25)


local function AddButton(text, callback)
    local Btn = Instance.new("TextButton")
    Btn.Parent = Container
    Btn.Text = text
    Btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    Btn.TextColor3 = Color3.new(0.8, 0.8, 0.8)
    Btn.Font = Enum.Font.GothamSemibold
    Btn.TextSize = 16
    Btn.AutoButtonColor = false
    
    local BtnCorner = Instance.new("UICorner")
    BtnCorner.CornerRadius = UDim.new(0, 10)
    BtnCorner.Parent = Btn
    
    local Stroke = Instance.new("UIStroke")
    Stroke.Color = ACCENT_COLOR
    Stroke.Thickness = 0
    Stroke.Transparency = 0.5
    Stroke.Parent = Btn

    Btn.MouseEnter:Connect(function()
        TweenService:Create(Btn, TweenInfo.new(0.3), {BackgroundColor3 = Color3.fromRGB(45, 45, 45), TextColor3 = Color3.new(1,1,1)}):Play()
        TweenService:Create(Stroke, TweenInfo.new(0.3), {Thickness = 2}):Play()
    end)
    
    Btn.MouseLeave:Connect(function()
        TweenService:Create(Btn, TweenInfo.new(0.3), {BackgroundColor3 = Color3.fromRGB(30, 30, 30), TextColor3 = Color3.new(0.8, 0.8, 0.8)}):Play()
        TweenService:Create(Stroke, TweenInfo.new(0.3), {Thickness = 0}):Play()
    end)

    Btn.MouseButton1Click:Connect(callback)
end


local function LoadButtons()
    local success, response = pcall(function()
        return game:HttpGet(BUTTONS_URL)
    end)

    if success then
        local func, err = loadstring(response) 
        if func then
            local dataSuccess, buttonList = pcall(func) 
            if dataSuccess and type(buttonList) == "table" then
                for _, item in ipairs(buttonList) do
                    AddButton(item.Name, item.Callback)
                end
            else
                AddButton("Ошибка данных в BTS.lua", function() print("Ошибка в таблице") end)
            end
        else
            AddButton("Ошибка синтаксиса в BTS.lua", function() print(err) end)
        end
    else
        AddButton("Ошибка загрузки URL", function() print("Check URL") end)
    end
end

LoadButtons()


local isOpen = false
UserInputService.InputBegan:Connect(function(input, processed)
    if not processed and input.KeyCode == TOGGLE_KEY then
        isOpen = not isOpen
        
        if isOpen then
            Blur.Enabled = true
            MainFrame.Visible = true
            TweenService:Create(Blur, TweenInfo.new(0.5), {Size = 24}):Play()
            TweenService:Create(MainFrame, TweenInfo.new(0.5, Enum.EasingStyle.Back), {
                Size = UDim2.new(0.9, 0, 0.8, 0),
                BackgroundTransparency = 0.1
            }):Play()
        else
            TweenService:Create(Blur, TweenInfo.new(0.3), {Size = 0}):Play()
            TweenService:Create(MainFrame, TweenInfo.new(0.3), {
                Size = UDim2.new(0, 0, 0, 0),
                BackgroundTransparency = 1
            }):Play()
            task.wait(0.3)
            Blur.Enabled = false
            MainFrame.Visible = false
        end
    end
end)
