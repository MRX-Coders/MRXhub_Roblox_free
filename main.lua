local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- === НАСТРОЙКИ ТЕМЫ ===
local ACCENT_COLOR = Color3.fromRGB(138, 43, 226)
local ACCENT_COLOR_2 = Color3.fromRGB(0, 191, 255)
local BG_COLOR_DARK = Color3.fromRGB(5, 5, 15)
local BG_COLOR_LIGHT = Color3.fromRGB(20, 20, 40)
local TOGGLE_KEY = Enum.KeyCode.M
local PARTICLE_COUNT = 50

-- === URL ДЛЯ КНОПОК ===
local BUTTONS_URL = "https://raw.githubusercontent.com/MRX-Coders/MRXhub_Roblox_free/refs/heads/main/BTS.lua"

-- === СОЗДАНИЕ GUI ===
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MRXDashboard_Cosmic"
ScreenGui.Parent = CoreGui
ScreenGui.IgnoreGuiInset = true
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- === BLUR EFFECT ===
local Blur = Instance.new("BlurEffect")
Blur.Parent = Lighting
Blur.Size = 0
Blur.Enabled = false

-- === ГЛАВНЫЙ ФРЕЙМ ===
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = BG_COLOR_DARK
MainFrame.BackgroundTransparency = 1
MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
MainFrame.Size = UDim2.new(0, 0, 0, 0)
MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
MainFrame.Visible = false

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 20)
MainCorner.Parent = MainFrame

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = ACCENT_COLOR
MainStroke.Thickness = 0
MainStroke.Transparency = 0.7
MainStroke.Parent = MainFrame

-- === ГРАДИЕНТНЫЙ ФОН ===
local BackgroundGradient = Instance.new("UIGradient")
BackgroundGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, BG_COLOR_DARK),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(10, 10, 30)),
    ColorSequenceKeypoint.new(1, BG_COLOR_DARK)
})
BackgroundGradient.Rotation = 90
BackgroundGradient.Parent = MainFrame

-- === ЗАГОЛОВОК С АНИМАЦИЕЙ ===
local TitleContainer = Instance.new("Frame")
TitleContainer.Parent = MainFrame
TitleContainer.BackgroundTransparency = 1
TitleContainer.Position = UDim2.new(0, 0, 0.02, 0)
TitleContainer.Size = UDim2.new(1, 0, 0, 70)

local Title = Instance.new("TextLabel")
Title.Parent = TitleContainer
Title.Text = "✨ MRX COSMIC HUB ✨"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.BackgroundTransparency = 1
Title.Position = UDim2.new(0.5, 0, 0, 0)
Title.Size = UDim2.new(1, 0, 1, 0)
Title.AnchorPoint = Vector2.new(0.5, 0)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 42
Title.TextStrokeTransparency = 0

local TitleGradient = Instance.new("UIGradient")
TitleGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, ACCENT_COLOR_2),
    ColorSequenceKeypoint.new(0.5, ACCENT_COLOR),
    ColorSequenceKeypoint.new(1, ACCENT_COLOR_2)
})
TitleGradient.Rotation = 45
TitleGradient.Parent = Title

-- === ПОДСВЕТКА ЗАГОЛОВКА (ПУЛЬСАЦИЯ) ===
local TitleGlow = Instance.new("ImageLabel")
TitleGlow.Parent = TitleContainer
TitleGlow.BackgroundTransparency = 1
TitleGlow.Position = UDim2.new(0.5, 0, 0.5, 0)
TitleGlow.AnchorPoint = Vector2.new(0.5, 0.5)
TitleGlow.Size = UDim2.new(1.2, 0, 2, 0)
TitleGlow.Image = "rbxassetid://6431527199"
TitleGlow.ImageColor3 = ACCENT_COLOR
TitleGlow.ImageTransparency = 0.8
TitleGlow.ScaleType = Enum.ScaleType.Slice
TitleGlow.SliceCenter = Rect.new(24, 24, 276, 276)

-- === КОНТЕЙНЕР ДЛЯ КНОПОК ===
local Container = Instance.new("ScrollingFrame")
Container.Parent = MainFrame
Container.BackgroundTransparency = 1
Container.Position = UDim2.new(0.05, 0, 0.15, 0)
Container.Size = UDim2.new(0.9, 0, 0.75, 0)
Container.ScrollBarThickness = 4
Container.CanvasSize = UDim2.new(0, 0, 2, 0)
Container.AutomaticCanvasSize = Enum.AutomaticSize.Y
Container.ScrollBarImageColor3 = ACCENT_COLOR
Container.BottomImage = "rbxassetid://6431527199"
Container.TopImage = "rbxassetid://6431527199"
Container.MidImage = "rbxassetid://6431527199"

local ContainerCorner = Instance.new("UICorner")
ContainerCorner.CornerRadius = UDim.new(0, 15)
ContainerCorner.Parent = Container

local Grid = Instance.new("UIGridLayout")
Grid.Parent = Container
Grid.CellSize = UDim2.new(0, 250, 0, 90)
Grid.CellPadding = UDim2.new(0, 20, 0, 20)
Grid.HorizontalAlignment = Enum.HorizontalAlignment.Center
Grid.SortOrder = Enum.SortOrder.LayoutOrder

local ListPadding = Instance.new("UIListLayout")
ListPadding.Padding = UDim.new(0, 15)
ListPadding.HorizontalAlignment = Enum.HorizontalAlignment.Center
ListPadding.Parent = Container

-- === ЗВЕЗДНЫЙ ФОН (ЧАСТИЦЫ) ===
local StarsFolder = Instance.new("Frame")
StarsFolder.Name = "Stars"
StarsFolder.Parent = MainFrame
StarsFolder.BackgroundTransparency = 1
StarsFolder.Size = UDim2.new(1, 0, 1, 0)
StarsFolder.ClipsDescendants = true
StarsFolder.ZIndex = 0

local function CreateStar()
    local Star = Instance.new("ImageLabel")
    Star.Parent = StarsFolder
    Star.BackgroundTransparency = 1
    Star.Image = "rbxassetid://6431527199"
    Star.ImageColor3 = Color3.new(1, 1, 1)
    Star.Size = UDim2.new(0, math.random(3, 8), 0, math.random(3, 8))
    Star.Position = UDim2.new(math.random(), 0, math.random(), 0)
    Star.AnchorPoint = Vector2.new(0.5, 0.5)
    Star.ImageTransparency = math.random(0.3, 0.8)
    Star.ZIndex = 0
    
    -- Анимация мерцания
    local TweenInfo_table = TweenInfo.new(math.random(2, 5) / 2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true)
    local Tween = TweenService:Create(Star, TweenInfo_table, {
        ImageTransparency = math.random(0.1, 0.5),
        Size = UDim2.new(0, Star.Size.X.Offset * 1.2, 0, Star.Size.Y.Offset * 1.2)
    })
    Tween:Play()
    
    return Star
end

for i = 1, PARTICLE_COUNT do
    CreateStar()
end

-- === ДИНАМИЧЕСКАЯ ПОДСВЕТКА (СЛЕДУЕТ ЗА МЫШЬЮ) ===
local MouseGlow = Instance.new("ImageLabel")
MouseGlow.Parent = MainFrame
MouseGlow.BackgroundTransparency = 1
MouseGlow.Image = "rbxassetid://6431527199"
MouseGlow.ImageColor3 = ACCENT_COLOR
MouseGlow.ImageTransparency = 0.85
MouseGlow.Size = UDim2.new(0, 300, 0, 300)
MouseGlow.AnchorPoint = Vector2.new(0.5, 0.5)
MouseGlow.ZIndex = 1
MouseGlow.ScaleType = Enum.ScaleType.Slice
MouseGlow.SliceCenter = Rect.new(24, 24, 276, 276)

-- Обновление позиции подсветки за мышью
RunService.RenderStepped:Connect(function()
    if MainFrame.Visible and MainFrame.BackgroundTransparency < 0.5 then
        local MousePos = UserInputService:GetMouseLocation()
        local FramePos = MainFrame.AbsolutePosition
        local FrameSize = MainFrame.AbsoluteSize
        
        local RelativeX = (MousePos.X - FramePos.X) / FrameSize.X
        local RelativeY = (MousePos.Y - FramePos.Y) / FrameSize.Y
        
        MouseGlow.Position = UDim2.new(RelativeX, 0, RelativeY, 0)
    end
end)

-- === ФУНКЦИЯ СОЗДАНИЯ КНОПКИ ===
local ButtonIndex = 0

local function AddButton(text, callback)
    ButtonIndex = ButtonIndex + 1
    
    local Btn = Instance.new("TextButton")
    Btn.Parent = Container
    Btn.Name = "Btn_" .. text
    Btn.Text = text
    Btn.BackgroundColor3 = Color3.fromRGB(25, 25, 45)
    Btn.TextColor3 = Color3.new(0.9, 0.9, 0.9)
    Btn.Font = Enum.Font.GothamSemibold
    Btn.TextSize = 18
    Btn.AutoButtonColor = false
    Btn.LayoutOrder = ButtonIndex
    
    local BtnCorner = Instance.new("UICorner")
    BtnCorner.CornerRadius = UDim.new(0, 12)
    BtnCorner.Parent = Btn
    
    local BtnStroke = Instance.new("UIStroke")
    BtnStroke.Color = ACCENT_COLOR
    BtnStroke.Thickness = 1.5
    BtnStroke.Transparency = 0.6
    BtnStroke.Parent = Btn
    
    -- Градиент для кнопки
    local BtnGradient = Instance.new("UIGradient")
    BtnGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(25, 25, 45)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(35, 35, 60))
    })
    BtnGradient.Rotation = 45
    BtnGradient.Parent = Btn
    
    -- Иконка/индикатор
    local Indicator = Instance.new("Frame")
    Indicator.Parent = Btn
    Indicator.BackgroundColor3 = ACCENT_COLOR
    Indicator.Size = UDim2.new(0, 4, 0, 0)
    Indicator.Position = UDim2.new(0, 0, 0.5, 0)
    Indicator.AnchorPoint = Vector2.new(0, 0.5)
    Indicator.BorderSizePixel = 0
    
    local IndicatorCorner = Instance.new("UICorner")
    IndicatorCorner.CornerRadius = UDim.new(1, 0)
    IndicatorCorner.Parent = Indicator
    
    -- Анимация при наведении
    Btn.MouseEnter:Connect(function()
        TweenService:Create(Btn, TweenInfo.new(0.3, Enum.EasingStyle.Quart), {
            BackgroundColor3 = Color3.fromRGB(45, 45, 75)
        }):Play()
        TweenService:Create(BtnStroke, TweenInfo.new(0.3), {
            Thickness = 3,
            Color = ACCENT_COLOR_2,
            Transparency = 0.3
        }):Play()
        TweenService:Create(Indicator, TweenInfo.new(0.3), {
            Size = UDim2.new(0, 4, 0, Btn.AbsoluteSize.Y * 0.6)
        }):Play()
        
        -- Эффект свечения
        local GlowTemp = Instance.new("ImageLabel")
        GlowTemp.Parent = Btn
        GlowTemp.BackgroundTransparency = 1
        GlowTemp.Image = "rbxassetid://6431527199"
        GlowTemp.ImageColor3 = ACCENT_COLOR_2
        GlowTemp.ImageTransparency = 0.7
        GlowTemp.Size = UDim2.new(1.1, 0, 1.1, 0)
        GlowTemp.Position = UDim2.new(-0.05, 0, -0.05, 0)
        GlowTemp.AnchorPoint = Vector2.new(0.5, 0.5)
        GlowTemp.ZIndex = 10
        GlowTemp.ScaleType = Enum.ScaleType.Slice
        GlowTemp.SliceCenter = Rect.new(24, 24, 276, 276)
        
        TweenService:Create(GlowTemp, TweenInfo.new(0.3), {
            ImageTransparency = 0.5,
            Size = UDim2.new(1.15, 0, 1.15, 0)
        }):Play()
        
        task.spawn(function()
            while Btn and Btn.Parent and Btn:IsA("TextButton") do
                wait(0.1)
            end
            if GlowTemp and GlowTemp.Parent then
                GlowTemp:Destroy()
            end
        end)
    end)
    
    Btn.MouseLeave:Connect(function()
        TweenService:Create(Btn, TweenInfo.new(0.3, Enum.EasingStyle.Quart), {
            BackgroundColor3 = Color3.fromRGB(25, 25, 45)
        }):Play()
        TweenService:Create(BtnStroke, TweenInfo.new(0.3), {
            Thickness = 1.5,
            Color = ACCENT_COLOR,
            Transparency = 0.6
        }):Play()
        TweenService:Create(Indicator, TweenInfo.new(0.3), {
            Size = UDim2.new(0, 4, 0, 0)
        }):Play()
    end)

    Btn.MouseButton1Click:Connect(function()
        -- Анимация нажатия
        TweenService:Create(Btn, TweenInfo.new(0.1), {
            Size = UDim2.new(1, 0, 1, -4)
        }):Play()
        task.wait(0.1)
        TweenService:Create(Btn, TweenInfo.new(0.1), {
            Size = UDim2.new(1, 0, 1, 0)
        }):Play()
        
        -- Выполнение колбэка
        pcall(callback)
    end)
end

-- === ЗАГРУЗКА КНОПОК ===
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
                AddButton("❌ Ошибка данных в BTS.lua", function() print("Ошибка в таблице") end)
            end
        else
            AddButton("❌ Ошибка синтаксиса", function() print(err) end)
        end
    else
        AddButton("❌ Ошибка загрузки URL", function() print("Check URL") end)
    end
end

LoadButtons()

-- === АНИМАЦИЯ ОТКРЫТИЯ/ЗАКРЫТИЯ ===
local isOpen = false
local AnimPlaying = false

UserInputService.InputBegan:Connect(function(input, processed)
    if not processed and input.KeyCode == TOGGLE_KEY and not AnimPlaying then
        isOpen = not isOpen
        AnimPlaying = true
        
        if isOpen then
            Blur.Enabled = true
            MainFrame.Visible = true
            
            -- Плавное появление
            TweenService:Create(Blur, TweenInfo.new(0.6, Enum.EasingStyle.Quint), {Size = 35}):Play()
            TweenService:Create(MainFrame, TweenInfo.new(0.6, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                Size = UDim2.new(0.85, 0, 0.75, 0),
                BackgroundTransparency = 0.15
            }):Play()
            
            TweenService:Create(MainStroke, TweenInfo.new(0.6), {
                Thickness = 2,
                Transparency = 0.4
            }):Play()
            
            -- Анимация заголовка
            TweenService:Create(TitleGlow, TweenInfo.new(0.6), {
                ImageTransparency = 0.6,
                Size = UDim2.new(1.3, 0, 2.5, 0)
            }):Play()
            
            -- Пульсация заголовка
            task.spawn(function()
                while isOpen do
                    TweenService:Create(TitleGlow, TweenInfo.new(1.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {
                        ImageTransparency = 0.5 + math.random() * 0.2,
                        Size = UDim2.new(1.25 + math.random() * 0.1, 0, 2.3 + math.random() * 0.2, 0)
                    }):Play()
                    wait(1.5)
                end
            end)
        else
            TweenService:Create(Blur, TweenInfo.new(0.4, Enum.EasingStyle.Quint), {Size = 0}):Play()
            TweenService:Create(MainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Quint), {
                Size = UDim2.new(0, 0, 0, 0),
                BackgroundTransparency = 1
            }):Play()
            
            TweenService:Create(MainStroke, TweenInfo.new(0.4), {
                Thickness = 0,
                Transparency = 0.7
            }):Play()
            
            TweenService:Create(TitleGlow, TweenInfo.new(0.4), {
                ImageTransparency = 0.8,
                Size = UDim2.new(1.2, 0, 2, 0)
            }):Play()
            
            task.wait(0.4)
            Blur.Enabled = false
            MainFrame.Visible = false
        end
        
        task.wait(0.5)
        AnimPlaying = false
    end
end)

-- === ДОПОЛНИТЕЛЬНЫЕ ЭФФЕКТЫ ===
-- Динамическое изменение цвета акцента
task.spawn(function()
    local hue = 0
    while true do
        hue = (hue + 0.001) % 1
        local newColor = Color3.fromHSV(hue, 0.7, 1)
        -- Можно раскомментировать для радужного эффекта
        -- ACCENT_COLOR = newColor
        wait(0.03)
    end
end)

-- Информация о версии внизу
local VersionLabel = Instance.new("TextLabel")
VersionLabel.Parent = MainFrame
VersionLabel.Text = "v2.0 Cosmic Edition | Press M to toggle"
VersionLabel.TextColor3 = Color3.fromRGB(150, 150, 180)
VersionLabel.BackgroundTransparency = 1
VersionLabel.Position = UDim2.new(0.5, 0, 0.97, 0)
VersionLabel.Size = UDim2.new(1, 0, 0, 20)
VersionLabel.AnchorPoint = Vector2.new(0.5, 0.5)
VersionLabel.Font = Enum.Font.Gotham
VersionLabel.TextSize = 14
VersionLabel.TextTransparency = 0.5
