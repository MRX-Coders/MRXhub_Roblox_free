--==============================================================================
-- COSMIC ULTIMATE GUI SYSTEM - EXTREME DETAIL EDITION
-- Language: Luau (Roblox)
-- Lines: 1300+
-- Features: Dynamic lighting, particle systems, advanced animations, 
--           modular components, sound effects, data persistence, and more!
--==============================================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local TextService = game:GetService("TextService")
local CollectionService = game:GetService("CollectionService")
local Debris = game:GetService("Debris")
local SoundService = game:GetService("SoundService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

--==============================================================================
-- CONFIGURATION TABLE
--==============================================================================
local Config = {
    Theme = {
        PrimaryColor = Color3.fromRGB(138, 43, 226),      -- BlueViolet
        SecondaryColor = Color3.fromRGB(0, 191, 255),     -- DeepSkyBlue
        AccentColor = Color3.fromRGB(255, 20, 147),       -- DeepPink
        BackgroundDark = Color3.fromRGB(10, 10, 30),
        BackgroundMedium = Color3.fromRGB(20, 20, 50),
        BackgroundLight = Color3.fromRGB(30, 30, 70),
        TextPrimary = Color3.fromRGB(255, 255, 255),
        TextSecondary = Color3.fromRGB(200, 200, 220),
        TextMuted = Color3.fromRGB(150, 150, 180),
        SuccessColor = Color3.fromRGB(0, 255, 127),
        WarningColor = Color3.fromRGB(255, 215, 0),
        ErrorColor = Color3.fromRGB(255, 69, 0),
        GlowIntensity = 0.8,
        ParticleDensity = 75,
        StarCount = 150,
        AnimationSpeed = 1.2,
        BlurAmount = 3,
        CornerRoundness = UDim.new(0.12, 0),
    },
    
    Window = {
        Size = UDim2.new(0, 900, 0, 650),
        Position = UDim2.new(0.5, -450, 0.5, -325),
        MinSize = Vector2.new(600, 400),
        MaxSize = Vector2.new(1400, 900),
        Draggable = true,
        Resizable = true,
        FadeInDuration = 1.5,
        FadeOutDuration = 0.8,
    },
    
    Effects = {
        EnableMouseGlow = true,
        MouseGlowRadius = 250,
        MouseGlowStrength = 0.6,
        EnableParallax = true,
        ParallaxStrength = 0.03,
        EnableChromaticAberration = false,
        EnableScanlines = true,
        ScanlineOpacity = 0.03,
        EnableVignette = true,
        VignetteStrength = 0.7,
        EnableNoise = true,
        NoiseOpacity = 0.02,
        EnableBloom = true,
        BloomThreshold = 0.8,
        BloomIntensity = 0.5,
    },
    
    Audio = {
        EnableSounds = true,
        HoverSoundId = "rbxassetid://604123456",
        ClickSoundId = "rbxassetid://604123789",
        OpenSoundId = "rbxassetid://604124012",
        CloseSoundId = "rbxassetid://604124345",
        Volume = 0.3,
    },
    
    Keybinds = {
        ToggleKey = Enum.KeyCode.M,
        CloseKey = Enum.KeyCode.Escape,
    },
}

--==============================================================================
-- UTILITY MODULE
--==============================================================================
local Utility = {}

function Utility.LerpColor(color1, color2, alpha)
    return Color3.new(
        color1.R + (color2.R - color1.R) * alpha,
        color1.G + (color2.G - color1.G) * alpha,
        color1.B + (color2.B - color1.B) * alpha
    )
end

function Utility.CreateTween(object, properties, duration, style, direction)
    local tweenInfo = TweenInfo.new(
        duration or 0.5,
        style or Enum.EasingStyle.Quint,
        direction or Enum.EasingDirection.Out,
        0,
        false,
        0
    )
    return TweenService:Create(object, tweenInfo, properties)
end

function Utility.Round(number, decimals)
    local multiplier = 10 ^ (decimals or 0)
    return math.floor(number * multiplier + 0.5) / multiplier
end

function Utility.GetDistance(pos1, pos2)
    return (pos1 - pos2).Magnitude
end

function Utility.RandomRange(min, max)
    return min + math.random() * (max - min)
end

function Utility.HexToColor(hex)
    hex = hex:gsub("#", "")
    return Color3.fromRGB(
        tonumber(hex:sub(1, 2), 16),
        tonumber(hex:sub(3, 4), 16),
        tonumber(hex:sub(5, 6), 16)
    )
end

function Utility.ColorToHex(color)
    return string.format("#%02X%02X%02X", 
        math.floor(color.R * 255),
        math.floor(color.G * 255),
        math.floor(color.B * 255)
    )
end

function Utility.DeepCopy(original)
    local copy = {}
    for key, value in next, original, nil do
        copy[Utility.DeepCopy(key)] = Utility.DeepCopy(value)
    end
    setmetatable(copy, Utility.DeepCopy(getmetatable(original)))
    return copy
end

function Utility.WaitForChildTyped(parent, childName, childType, timeout)
    local child = parent:WaitForChild(childName, timeout or 10)
    if child and child:IsA(childType) then
        return child
    end
    return nil
end

--==============================================================================
-- PARTICLE SYSTEM MANAGER
--==============================================================================
local ParticleSystem = {}
ParticleSystem.__index = ParticleSystem

function ParticleSystem.new(parent, config)
    local self = setmetatable({}, ParticleSystem)
    self.Parent = parent
    self.Config = config or {}
    self.Particles = {}
    self.Active = false
    self.Connection = nil
    
    self:Initialize()
    return self
end

function ParticleSystem:Initialize()
    self.Container = Instance.new("Folder")
    self.Container.Name = "ParticleContainer"
    self.Container.Parent = self.Parent
end

function ParticleSystem:CreateParticle(position, size, color, transparency, velocity)
    local particle = Instance.new("Frame")
    particle.Size = UDim2.new(0, size or 4, 0, size or 4)
    particle.Position = UDim2.new(0, position.X, 0, position.Y)
    particle.BackgroundColor3 = color or Config.Theme.SecondaryColor
    particle.BackgroundTransparency = transparency or 0.5
    particle.BorderSizePixel = 0
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(1, 0)
    corner.Parent = particle
    
    local glow = Instance.new("ImageLabel")
    glow.Size = UDim2.new(1, 20, 1, 20)
    glow.Position = UDim2.new(0, -10, 0, -10)
    glow.BackgroundTransparency = 1
    glow.Image = "rbxassetid://280055602"
    glow.ImageColor3 = particle.BackgroundColor3
    glow.ImageTransparency = 0.7
    glow.Parent = particle
    
    particle.Parent = self.Container
    
    return {
        Instance = particle,
        Velocity = velocity or Vector2.new(0, 0),
        Life = 1,
        MaxLife = 3,
        Size = size or 4,
    }
end

function ParticleSystem:Emit(count, position)
    for i = 1, count do
        local pos = position or Vector2.new(
            Utility.RandomRange(0, self.Parent.AbsoluteSize.X),
            Utility.RandomRange(0, self.Parent.AbsoluteSize.Y)
        )
        
        local vel = Vector2.new(
            Utility.RandomRange(-2, 2),
            Utility.RandomRange(-2, 2)
        )
        
        local size = Utility.RandomRange(2, 8)
        local color = Config.Theme.SecondaryColor
        
        if math.random() > 0.7 then
            color = Config.Theme.PrimaryColor
        elseif math.random() > 0.9 then
            color = Config.Theme.AccentColor
        end
        
        local particle = self:CreateParticle(pos, size, color, 0.5, vel)
        table.insert(self.Particles, particle)
    end
end

function ParticleSystem:Update(dt)
    for i = #self.Particles, 1, -1 do
        local particle = self.Particles[i]
        particle.Life = particle.Life - dt
        
        if particle.Life <= 0 then
            particle.Instance:Destroy()
            table.remove(self.Particles, i)
        else
            local alpha = particle.Life / particle.MaxLife
            particle.Instance.Position = particle.Instance.Position + 
                UDim2.new(0, particle.Velocity.X * dt * 60, 0, particle.Velocity.Y * dt * 60)
            particle.Instance.BackgroundTransparency = 1 - alpha
            particle.Instance.Size = UDim2.new(0, particle.Size * alpha, 0, particle.Size * alpha)
            
            local glow = particle.Instance:FindFirstChildWhichIsA("ImageLabel")
            if glow then
                glow.ImageTransparency = 1 - (alpha * 0.5)
            end
        end
    end
end

function ParticleSystem:Start()
    self.Active = true
    self.Connection = RunService.RenderStepped:Connect(function(dt)
        self:Update(dt)
    end)
end

function ParticleSystem:Stop()
    self.Active = false
    if self.Connection then
        self.Connection:Disconnect()
        self.Connection = nil
    end
end

function ParticleSystem:Clear()
    for _, particle in ipairs(self.Particles) do
        particle.Instance:Destroy()
    end
    self.Particles = {}
end

function ParticleSystem:Destroy()
    self:Stop()
    self:Clear()
    if self.Container then
        self.Container:Destroy()
    end
end

--==============================================================================
-- STAR FIELD BACKGROUND SYSTEM
--==============================================================================
local StarField = {}
StarField.__index = StarField

function StarField.new(parent, count)
    local self = setmetatable({}, StarField)
    self.Parent = parent
    self.StarCount = count or Config.Theme.StarCount
    self.Stars = {}
    self.Time = 0
    self.Active = false
    self.Connection = nil
    
    self:Generate()
    return self
end

function StarField:Generate()
    -- Clear existing stars
    for _, star in ipairs(self.Stars) do
        if star.Instance then
            star.Instance:Destroy()
        end
    end
    self.Stars = {}
    
    -- Generate new stars
    for i = 1, self.StarCount do
        local star = self:CreateStar()
        table.insert(self.Stars, star)
    end
end

function StarField:CreateStar()
    local size = Utility.RandomRange(1, 3)
    local x = Utility.RandomRange(0, self.Parent.AbsoluteSize.X)
    local y = Utility.RandomRange(0, self.Parent.AbsoluteSize.Y)
    local brightness = Utility.RandomRange(0.3, 1)
    local twinkleSpeed = Utility.RandomRange(0.5, 2)
    local twinkleOffset = math.random() * math.pi * 2
    
    local star = Instance.new("Frame")
    star.Size = UDim2.new(0, size, 0, size)
    star.Position = UDim2.new(0, x, 0, y)
    star.BackgroundColor3 = Color3.new(1, 1, 1)
    star.BackgroundTransparency = 1 - brightness
    star.BorderSizePixel = 0
    star.ZIndex = 1
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(1, 0)
    corner.Parent = star
    
    -- Add glow effect
    local glow = Instance.new("ImageLabel")
    glow.Size = UDim2.new(1, size * 4, 1, size * 4)
    glow.Position = UDim2.new(0, -size * 2, 0, -size * 2)
    glow.BackgroundTransparency = 1
    glow.Image = "rbxassetid://280055602"
    glow.ImageColor3 = Color3.new(1, 1, 1)
    glow.ImageTransparency = 0.6
    glow.ZIndex = 1
    glow.Parent = star
    
    star.Parent = self.Parent
    
    return {
        Instance = star,
        BaseBrightness = brightness,
        TwinkleSpeed = twinkleSpeed,
        TwinkleOffset = twinkleOffset,
        X = x,
        Y = y,
        Size = size,
    }
end

function StarField:Update(dt)
    self.Time = self.Time + dt
    
    for _, star in ipairs(self.Stars) do
        local twinkle = math.sin(self.Time * star.TwinkleSpeed + star.TwinkleOffset)
        local brightness = star.BaseBrightness * (0.7 + 0.3 * twinkle)
        
        star.Instance.BackgroundTransparency = 1 - brightness
        local glow = star.Instance:FindFirstChildWhichIsA("ImageLabel")
        if glow then
            glow.ImageTransparency = 1 - (brightness * 0.5)
        end
    end
end

function StarField:Resize()
    for _, star in ipairs(self.Stars) do
        star.X = Utility.RandomRange(0, self.Parent.AbsoluteSize.X)
        star.Y = Utility.RandomRange(0, self.Parent.AbsoluteSize.Y)
        star.Instance.Position = UDim2.new(0, star.X, 0, star.Y)
    end
end

function StarField:Start()
    self.Active = true
    self.Connection = RunService.RenderStepped:Connect(function(dt)
        self:Update(dt)
    end)
end

function StarField:Stop()
    self.Active = false
    if self.Connection then
        self.Connection:Disconnect()
        self.Connection = nil
    end
end

function StarField:Destroy()
    self:Stop()
    for _, star in ipairs(self.Stars) do
        if star.Instance then
            star.Instance:Destroy()
        end
    end
    self.Stars = {}
end

--==============================================================================
-- DYNAMIC LIGHTING SYSTEM
--==============================================================================
local DynamicLighting = {}
DynamicLighting.__index = DynamicLighting

function DynamicLighting.new(parent)
    local self = setmetatable({}, DynamicLighting)
    self.Parent = parent
    self.LightLayers = {}
    self.MousePosition = Vector2.new(0, 0)
    self.TargetPosition = Vector2.new(0, 0)
    self.Active = false
    self.Connection = nil
    
    self:Initialize()
    return self
end

function DynamicLighting:Initialize()
    -- Create gradient overlay
    self.GradientOverlay = Instance.new("Frame")
    self.GradientOverlay.Size = UDim2.new(1, 0, 1, 0)
    self.GradientOverlay.Position = UDim2.new(0, 0, 0, 0)
    self.GradientOverlay.BackgroundTransparency = 1
    self.GradientOverlay.ZIndex = 10
    
    -- Radial gradient for mouse glow
    self.MouseGlow = Instance.new("ImageLabel")
    self.MouseGlow.Size = UDim2.new(0, Config.Effects.MouseGlowRadius * 2, 0, Config.Effects.MouseGlowRadius * 2)
    self.MouseGlow.Position = UDim2.new(0, -Config.Effects.MouseGlowRadius, 0, -Config.Effects.MouseGlowRadius)
    self.MouseGlow.BackgroundTransparency = 1
    self.MouseGlow.Image = "rbxassetid://280055602"
    self.MouseGlow.ImageColor3 = Config.Theme.SecondaryColor
    self.MouseGlow.ImageTransparency = 0.7
    self.MouseGlow.ZIndex = 10
    self.MouseGlow.Parent = self.GradientOverlay
    
    -- Ambient light layer
    self.AmbientLayer = Instance.new("Frame")
    self.AmbientLayer.Size = UDim2.new(1, 0, 1, 0)
    self.AmbientLayer.Position = UDim2.new(0, 0, 0, 0)
    self.AmbientLayer.BackgroundColor3 = Config.Theme.PrimaryColor
    self.AmbientLayer.BackgroundTransparency = 0.95
    self.AmbientLayer.BorderSizePixel = 0
    self.AmbientLayer.ZIndex = 9
    self.AmbientLayer.Parent = self.GradientOverlay
    
    self.GradientOverlay.Parent = self.Parent
end

function DynamicLighting:SetMousePosition(position)
    self.TargetPosition = position
end

function DynamicLighting:Update(dt)
    -- Smooth follow
    local lerpSpeed = 10 * dt
    self.MousePosition = self.MousePosition + (self.TargetPosition - self.MousePosition) * lerpSpeed
    
    -- Update mouse glow position
    self.MouseGlow.Position = UDim2.new(
        0, self.MousePosition.X - Config.Effects.MouseGlowRadius,
        0, self.MousePosition.Y - Config.Effects.MouseGlowRadius
    )
    
    -- Pulsating ambient light
    local pulse = math.sin(os.clock() * 2) * 0.05 + 0.95
    self.AmbientLayer.BackgroundTransparency = pulse
end

function DynamicLighting:Start()
    self.Active = true
    self.Connection = RunService.RenderStepped:Connect(function(dt)
        self:Update(dt)
    end)
end

function DynamicLighting:Stop()
    self.Active = false
    if self.Connection then
        self.Connection:Disconnect()
        self.Connection = nil
    end
end

function DynamicLighting:Destroy()
    self:Stop()
    if self.GradientOverlay then
        self.GradientOverlay:Destroy()
    end
end

--==============================================================================
-- ADVANCED BUTTON COMPONENT
--==============================================================================
local AdvancedButton = {}
AdvancedButton.__index = AdvancedButton

function AdvancedButton.new(config)
    local self = setmetatable({}, AdvancedButton)
    self.Config = config or {}
    self.Button = nil
    self.Label = nil
    self.Icon = nil
    self.Glow = nil
    self.Border = nil
    self.Particles = nil
    self.Hovered = false
    self.Pressed = false
    self.Enabled = true
    self.Callback = nil
    self.HoverCallback = nil
    self.LeaveCallback = nil
    
    self:Create()
    return self
end

function AdvancedButton:Create()
    -- Main button frame
    self.Button = Instance.new("TextButton")
    self.Button.Size = self.Config.Size or UDim2.new(0, 200, 0, 50)
    self.Button.Position = self.Config.Position or UDim2.new(0, 0, 0, 0)
    self.Button.BackgroundColor3 = Config.Theme.BackgroundMedium
    self.Button.BackgroundTransparency = 0.2
    self.Button.BorderSizePixel = 0
    self.Button.Text = ""
    self.Button.AutoButtonColor = false
    self.Button.ClipsDescendants = true
    
    -- Rounded corners
    local corner = Instance.new("UICorner")
    corner.CornerRadius = Config.Theme.CornerRoundness
    corner.Parent = self.Button
    
    -- Border with gradient effect
    self.Border = Instance.new("Frame")
    self.Border.Size = UDim2.new(1, 0, 1, 0)
    self.Border.Position = UDim2.new(0, 0, 0, 0)
    self.Border.BackgroundTransparency = 1
    self.Border.BorderSizePixel = 0
    self.Border.ZIndex = 2
    self.Border.Parent = self.Button
    
    local borderCorner = Instance.new("UICorner")
    borderCorner.CornerRadius = Config.Theme.CornerRoundness
    borderCorner.Parent = self.Border
    
    -- Inner glow
    self.Glow = Instance.new("ImageLabel")
    self.Glow.Size = UDim2.new(1, 0, 1, 0)
    self.Glow.Position = UDim2.new(0, 0, 0, 0)
    self.Glow.BackgroundTransparency = 1
    self.Glow.Image = "rbxassetid://280055602"
    self.Glow.ImageColor3 = Config.Theme.SecondaryColor
    self.Glow.ImageTransparency = 0.8
    self.Glow.ScaleType = Enum.ScaleType.Slice
    self.Glow.SliceCenter = Rect.new(24, 24, 276, 276)
    self.Glow.ZIndex = 1
    self.Glow.Parent = self.Button
    
    -- Label
    self.Label = Instance.new("TextLabel")
    self.Label.Size = UDim2.new(1, -20, 1, 0)
    self.Label.Position = UDim2.new(0, 10, 0, 0)
    self.Label.BackgroundTransparency = 1
    self.Label.Text = self.Config.Text or "Button"
    self.Label.TextColor3 = Config.Theme.TextPrimary
    self.Label.TextSize = self.Config.TextSize or 16
    self.Label.Font = Enum.Font.GothamBold
    self.Label.TextXAlignment = self.Config.TextAlign or Enum.TextXAlignment.Left
    self.Label.ZIndex = 3
    self.Label.Parent = self.Button
    
    -- Icon (optional)
    if self.Config.Icon then
        self.Icon = Instance.new("ImageLabel")
        self.Icon.Size = UDim2.new(0, 20, 0, 20)
        self.Icon.Position = UDim2.new(0, 10, 0.5, -10)
        self.Icon.BackgroundTransparency = 1
        self.Icon.Image = self.Config.Icon
        self.Icon.ImageColor3 = Config.Theme.SecondaryColor
        self.Icon.ZIndex = 3
        self.Icon.Parent = self.Button
        
        -- Adjust label position if icon exists
        if self.Config.TextAlign == Enum.TextXAlignment.Left then
            self.Label.Position = UDim2.new(0, 40, 0, 0)
            self.Label.Size = UDim2.new(1, -50, 1, 0)
        end
    end
    
    -- Hover detection
    self.Button.MouseEnter:Connect(function()
        if not self.Enabled then return end
        self.Hovered = true
        self:OnHover()
        if self.HoverCallback then
            self.HoverCallback()
        end
        self:PlaySound("Hover")
    end)
    
    self.Button.MouseLeave:Connect(function()
        self.Hovered = false
        self:OnLeave()
        if self.LeaveCallback then
            self.LeaveCallback()
        end
    end)
    
    self.Button.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 and self.Enabled then
            self.Pressed = true
            self:OnPress()
        end
    end)
    
    self.Button.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 and self.Enabled then
            self.Pressed = false
            self:OnRelease()
            if self.Callback then
                self.Callback()
            end
        end
    end)
end

function AdvancedButton:OnHover()
    local tween = Utility.CreateTween(self.Glow, {
        ImageTransparency = 0.5,
        Size = UDim2.new(1, 10, 1, 10),
        Position = UDim2.new(0, -5, 0, -5)
    }, 0.3)
    tween:Play()
    
    local borderTween = Utility.CreateTween(self.Border, {
        BackgroundTransparency = 0.5
    }, 0.3)
    borderTween:Play()
    
    -- Emit particles on hover
    if self.Particles then
        self.Particles:Emit(5, Vector2.new(self.Button.AbsoluteSize.X / 2, self.Button.AbsoluteSize.Y / 2))
    end
end

function AdvancedButton:OnLeave()
    local tween = Utility.CreateTween(self.Glow, {
        ImageTransparency = 0.8,
        Size = UDim2.new(1, 0, 1, 0),
        Position = UDim2.new(0, 0, 0, 0)
    }, 0.3)
    tween:Play()
    
    local borderTween = Utility.CreateTween(self.Border, {
        BackgroundTransparency = 1
    }, 0.3)
    borderTween:Play()
end

function AdvancedButton:OnPress()
    local tween = Utility.CreateTween(self.Button, {
        BackgroundTransparency = 0.4
    }, 0.1)
    tween:Play()
end

function AdvancedButton:OnRelease()
    local tween = Utility.CreateTween(self.Button, {
        BackgroundTransparency = 0.2
    }, 0.2)
    tween:Play()
end

function AdvancedButton:PlaySound(soundType)
    if not Config.Audio.EnableSounds then return end
    
    local soundId = nil
    if soundType == "Hover" then
        soundId = Config.Audio.HoverSoundId
    elseif soundType == "Click" then
        soundId = Config.Audio.ClickSoundId
    end
    
    if soundId then
        local sound = Instance.new("Sound")
        sound.SoundId = soundId
        sound.Volume = Config.Audio.Volume
        sound.Parent = SoundService
        sound:Play()
        Debris:AddItem(sound, 2)
    end
end

function AdvancedButton:SetEnabled(enabled)
    self.Enabled = enabled
    self.Button.Interactable = enabled
    
    local targetTransparency = enabled and 0.2 or 0.7
    local tween = Utility.CreateTween(self.Button, {
        BackgroundTransparency = targetTransparency
    }, 0.3)
    tween:Play()
    
    self.Label.TextTransparency = enabled and 0 or 0.5
end

function AdvancedButton:SetText(text)
    self.Label.Text = text
end

function AdvancedButton:SetIcon(iconId)
    if not self.Icon then
        self.Icon = Instance.new("ImageLabel")
        self.Icon.Size = UDim2.new(0, 20, 0, 20)
        self.Icon.Position = UDim2.new(0, 10, 0.5, -10)
        self.Icon.BackgroundTransparency = 1
        self.Icon.ZIndex = 3
        self.Icon.Parent = self.Button
        
        if self.Config.TextAlign == Enum.TextXAlignment.Left then
            self.Label.Position = UDim2.new(0, 40, 0, 0)
            self.Label.Size = UDim2.new(1, -50, 1, 0)
        end
    end
    
    self.Icon.Image = iconId
end

function AdvancedButton:SetCallback(callback)
    self.Callback = callback
end

function AdvancedButton:SetHoverCallback(callback)
    self.HoverCallback = callback
end

function AdvancedButton:SetLeaveCallback(callback)
    self.LeaveCallback = callback
end

function AdvancedButton:GetButton()
    return self.Button
end

function AdvancedButton:Destroy()
    if self.Button then
        self.Button:Destroy()
    end
end

--==============================================================================
-- SLIDER COMPONENT
--==============================================================================
local Slider = {}
Slider.__index = Slider

function Slider.new(config)
    local self = setmetatable({}, Slider)
    self.Config = config or {}
    self.Slider = nil
    self.Track = nil
    self.Thumb = nil
    self.Fill = nil
    self.Label = nil
    self.ValueLabel = nil
    self.MinValue = config.MinValue or 0
    self.MaxValue = config.MaxValue or 100
    self.Value = config.Value or 50
    self.Callback = nil
    self.Dragging = false
    
    self:Create()
    return self
end

function Slider:Create()
    -- Main container
    self.Slider = Instance.new("Frame")
    self.Slider.Size = self.Config.Size or UDim2.new(1, 0, 0, 40)
    self.Slider.Position = self.Config.Position or UDim2.new(0, 0, 0, 0)
    self.Slider.BackgroundTransparency = 1
    self.Slider.ClipsDescendants = false
    
    -- Label
    self.Label = Instance.new("TextLabel")
    self.Label.Size = UDim2.new(0.5, -10, 0, 20)
    self.Label.Position = UDim2.new(0, 0, 0, 0)
    self.Label.BackgroundTransparency = 1
    self.Label.Text = self.Config.Text or "Slider"
    self.Label.TextColor3 = Config.Theme.TextSecondary
    self.Label.TextSize = 14
    self.Label.Font = Enum.Font.Gotham
    self.Label.TextXAlignment = Enum.TextXAlignment.Left
    self.Label.Parent = self.Slider
    
    -- Value label
    self.ValueLabel = Instance.new("TextLabel")
    self.ValueLabel.Size = UDim2.new(0.5, -10, 0, 20)
    self.ValueLabel.Position = UDim2.new(0.5, 5, 0, 0)
    self.ValueLabel.BackgroundTransparency = 1
    self.ValueLabel.Text = tostring(math.floor(self.Value))
    self.ValueLabel.TextColor3 = Config.Theme.SecondaryColor
    self.ValueLabel.TextSize = 14
    self.ValueLabel.Font = Enum.Font.GothamBold
    self.ValueLabel.TextXAlignment = Enum.TextXAlignment.Right
    self.ValueLabel.Parent = self.Slider
    
    -- Track
    self.Track = Instance.new("Frame")
    self.Track.Size = UDim2.new(1, 0, 0, 8)
    self.Track.Position = UDim2.new(0, 0, 0, 28)
    self.Track.BackgroundColor3 = Config.Theme.BackgroundLight
    self.Track.BorderSizePixel = 0
    self.Track.Parent = self.Slider
    
    local trackCorner = Instance.new("UICorner")
    trackCorner.CornerRadius = UDim.new(0.5, 0)
    trackCorner.Parent = self.Track
    
    -- Fill
    self.Fill = Instance.new("Frame")
    self.Fill.Size = UDim2.new((self.Value - self.MinValue) / (self.MaxValue - self.MinValue), 0, 1, 0)
    self.Fill.Position = UDim2.new(0, 0, 0, 0)
    self.Fill.BackgroundColor3 = Config.Theme.SecondaryColor
    self.Fill.BorderSizePixel = 0
    self.Fill.Parent = self.Track
    
    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(0.5, 0)
    fillCorner.Parent = self.Fill
    
    -- Thumb
    self.Thumb = Instance.new("Frame")
    self.Thumb.Size = UDim2.new(0, 16, 0, 16)
    self.Thumb.Position = UDim2.new((self.Value - self.MinValue) / (self.MaxValue - self.MinValue), -8, 0.5, -8)
    self.Thumb.BackgroundColor3 = Config.Theme.TextPrimary
    self.Thumb.BorderSizePixel = 0
    self.Thumb.ZIndex = 2
    self.Thumb.Parent = self.Track
    
    local thumbCorner = Instance.new("UICorner")
    thumbCorner.CornerRadius = UDim.new(1, 0)
    thumbCorner.Parent = self.Thumb
    
    local thumbGlow = Instance.new("ImageLabel")
    thumbGlow.Size = UDim2.new(1, 10, 1, 10)
    thumbGlow.Position = UDim2.new(0, -5, 0, -5)
    thumbGlow.BackgroundTransparency = 1
    thumbGlow.Image = "rbxassetid://280055602"
    thumbGlow.ImageColor3 = Config.Theme.SecondaryColor
    thumbGlow.ImageTransparency = 0.6
    thumbGlow.ZIndex = 1
    thumbGlow.Parent = self.Thumb
    
    -- Input handling
    local function updateValue(inputPosition)
        local relativePos = (inputPosition.X - self.Track.AbsolutePosition.X) / self.Track.AbsoluteSize.X
        relativePos = math.clamp(relativePos, 0, 1)
        self.Value = self.MinValue + relativePos * (self.MaxValue - self.MinValue)
        
        self.Fill.Size = UDim2.new(relativePos, 0, 1, 0)
        self.Thumb.Position = UDim2.new(relativePos, -8, 0.5, -8)
        self.ValueLabel.Text = tostring(math.floor(self.Value))
        
        if self.Callback then
            self.Callback(self.Value)
        end
    end
    
    self.Thumb.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            self.Dragging = true
        end
    end)
    
    self.Thumb.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            self.Dragging = false
        end
    end)
    
    self.Track.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            self.Dragging = true
            updateValue(input.Position)
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if self.Dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            updateValue(input.Position)
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            self.Dragging = false
        end
    end)
end

function Slider:SetCallback(callback)
    self.Callback = callback
end

function Slider:SetValue(value)
    value = math.clamp(value, self.MinValue, self.MaxValue)
    self.Value = value
    
    local relativePos = (value - self.MinValue) / (self.MaxValue - self.MinValue)
    self.Fill.Size = UDim2.new(relativePos, 0, 1, 0)
    self.Thumb.Position = UDim2.new(relativePos, -8, 0.5, -8)
    self.ValueLabel.Text = tostring(math.floor(value))
    
    if self.Callback then
        self.Callback(value)
    end
end

function Slider:GetValue()
    return self.Value
end

function Slider:GetSlider()
    return self.Slider
end

function Slider:Destroy()
    if self.Slider then
        self.Slider:Destroy()
    end
end

--==============================================================================
-- TOGGLE SWITCH COMPONENT
--==============================================================================
local ToggleSwitch = {}
ToggleSwitch.__index = ToggleSwitch

function ToggleSwitch.new(config)
    local self = setmetatable({}, ToggleSwitch)
    self.Config = config or {}
    self.Switch = nil
    self.Track = nil
    self.Thumb = nil
    self.Label = nil
    self.State = config.State or false
    self.Callback = nil
    
    self:Create()
    return self
end

function ToggleSwitch:Create()
    -- Main container
    self.Switch = Instance.new("TextButton")
    self.Switch.Size = self.Config.Size or UDim2.new(0, 200, 0, 40)
    self.Switch.Position = self.Config.Position or UDim2.new(0, 0, 0, 0)
    self.Switch.BackgroundColor3 = Config.Theme.BackgroundMedium
    self.Switch.BackgroundTransparency = 0.5
    self.Switch.BorderSizePixel = 0
    self.Switch.Text = ""
    self.Switch.AutoButtonColor = false
    
    local switchCorner = Instance.new("UICorner")
    switchCorner.CornerRadius = Config.Theme.CornerRoundness
    switchCorner.Parent = self.Switch
    
    -- Label
    self.Label = Instance.new("TextLabel")
    self.Label.Size = UDim2.new(0.6, -10, 1, 0)
    self.Label.Position = UDim2.new(0, 10, 0, 0)
    self.Label.BackgroundTransparency = 1
    self.Label.Text = self.Config.Text or "Toggle"
    self.Label.TextColor3 = Config.Theme.TextPrimary
    self.Label.TextSize = 14
    self.Label.Font = Enum.Font.Gotham
    self.Label.TextXAlignment = Enum.TextXAlignment.Left
    self.Label.Parent = self.Switch
    
    -- Track
    self.Track = Instance.new("Frame")
    self.Track.Size = UDim2.new(0, 50, 0, 24)
    self.Track.Position = UDim2.new(1, -60, 0.5, -12)
    self.Track.BackgroundColor3 = Config.Theme.BackgroundLight
    self.Track.BorderSizePixel = 0
    self.Track.Parent = self.Switch
    
    local trackCorner = Instance.new("UICorner")
    trackCorner.CornerRadius = UDim.new(1, 0)
    trackCorner.Parent = self.Track
    
    -- Thumb
    self.Thumb = Instance.new("Frame")
    self.Thumb.Size = UDim2.new(0, 20, 0, 20)
    self.Thumb.Position = self.State and UDim2.new(1, -22, 0.5, -10) or UDim2.new(0, 2, 0.5, -10)
    self.Thumb.BackgroundColor3 = self.State and Config.Theme.SecondaryColor or Config.Theme.TextMuted
    self.Thumb.BorderSizePixel = 0
    self.Thumb.Parent = self.Track
    
    local thumbCorner = Instance.new("UICorner")
    thumbCorner.CornerRadius = UDim.new(1, 0)
    thumbCorner.Parent = self.Thumb
    
    -- State change
    self.Switch.MouseButton1Click:Connect(function()
        self:SetState(not self.State)
        if self.Callback then
            self.Callback(self.State)
        end
    end)
end

function ToggleSwitch:SetState(state)
    self.State = state
    
    local targetPos = state and UDim2.new(1, -22, 0.5, -10) or UDim2.new(0, 2, 0.5, -10)
    local targetColor = state and Config.Theme.SecondaryColor or Config.Theme.TextMuted
    
    local tween = Utility.CreateTween(self.Thumb, {
        Position = targetPos,
        BackgroundColor3 = targetColor
    }, 0.3)
    tween:Play()
end

function ToggleSwitch:GetState()
    return self.State
end

function ToggleSwitch:SetCallback(callback)
    self.Callback = callback
end

function ToggleSwitch:GetSwitch()
    return self.Switch
end

function ToggleSwitch:Destroy()
    if self.Switch then
        self.Switch:Destroy()
    end
end

--==============================================================================
-- PROGRESS BAR COMPONENT
--==============================================================================
local ProgressBar = {}
ProgressBar.__index = ProgressBar

function ProgressBar.new(config)
    local self = setmetatable({}, ProgressBar)
    self.Config = config or {}
    self.Bar = nil
    self.Track = nil
    self.Fill = nil
    self.Label = nil
    self.Value = config.Value or 0
    self.MaxValue = config.MaxValue or 100
    
    self:Create()
    return self
end

function ProgressBar:Create()
    -- Main container
    self.Bar = Instance.new("Frame")
    self.Bar.Size = self.Config.Size or UDim2.new(1, 0, 0, 20)
    self.Bar.Position = self.Config.Position or UDim2.new(0, 0, 0, 0)
    self.Bar.BackgroundTransparency = 1
    
    -- Track
    self.Track = Instance.new("Frame")
    self.Track.Size = UDim2.new(1, 0, 1, 0)
    self.Track.Position = UDim2.new(0, 0, 0, 0)
    self.Track.BackgroundColor3 = Config.Theme.BackgroundLight
    self.Track.BorderSizePixel = 0
    self.Track.Parent = self.Bar
    
    local trackCorner = Instance.new("UICorner")
    trackCorner.CornerRadius = UDim.new(0.5, 0)
    trackCorner.Parent = self.Track
    
    -- Fill
    self.Fill = Instance.new("Frame")
    self.Fill.Size = UDim2.new(self.Value / self.MaxValue, 0, 1, 0)
    self.Fill.Position = UDim2.new(0, 0, 0, 0)
    self.Fill.BackgroundColor3 = Config.Theme.SecondaryColor
    self.Fill.BorderSizePixel = 0
    self.Fill.Parent = self.Track
    
    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(0.5, 0)
    fillCorner.Parent = self.Fill
    
    -- Gradient overlay on fill
    local fillGradient = Instance.new("UIGradient")
    fillGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Config.Theme.SecondaryColor),
        ColorSequenceKeypoint.new(1, Config.Theme.PrimaryColor)
    })
    fillGradient.Rotation = 90
    fillGradient.Parent = self.Fill
    
    -- Label
    self.Label = Instance.new("TextLabel")
    self.Label.Size = UDim2.new(1, 0, 1, 0)
    self.Label.Position = UDim2.new(0, 0, 0, 0)
    self.Label.BackgroundTransparency = 1
    self.Label.Text = math.floor((self.Value / self.MaxValue) * 100) .. "%"
    self.Label.TextColor3 = Config.Theme.TextPrimary
    self.Label.TextSize = 12
    self.Label.Font = Enum.Font.GothamBold
    self.Label.TextStrokeTransparency = 0.5
    self.Label.Parent = self.Bar
end

function ProgressBar:SetValue(value)
    self.Value = math.clamp(value, 0, self.MaxValue)
    local percentage = self.Value / self.MaxValue
    
    local tween = Utility.CreateTween(self.Fill, {
        Size = UDim2.new(percentage, 0, 1, 0)
    }, 0.5)
    tween:Play()
    
    self.Label.Text = math.floor(percentage * 100) .. "%"
end

function ProgressBar:GetValue()
    return self.Value
end

function ProgressBar:GetBar()
    return self.Bar
end

function ProgressBar:Destroy()
    if self.Bar then
        self.Bar:Destroy()
    end
end

--==============================================================================
-- TAB SYSTEM COMPONENT
--==============================================================================
local TabSystem = {}
TabSystem.__index = TabSystem

function TabSystem.new(config)
    local self = setmetatable({}, TabSystem)
    self.Config = config or {}
    self.Container = nil
    self.TabBar = nil
    self.ContentArea = nil
    self.Tabs = {}
    self.ActiveTab = nil
    
    self:Create()
    return self
end

function TabSystem:Create()
    -- Main container
    self.Container = Instance.new("Frame")
    self.Container.Size = self.Config.Size or UDim2.new(1, 0, 1, 0)
    self.Container.Position = self.Config.Position or UDim2.new(0, 0, 0, 0)
    self.Container.BackgroundColor3 = Config.Theme.BackgroundMedium
    self.Container.BackgroundTransparency = 0.5
    self.Container.BorderSizePixel = 0
    
    local containerCorner = Instance.new("UICorner")
    containerCorner.CornerRadius = Config.Theme.CornerRoundness
    containerCorner.Parent = self.Container
    
    -- Tab bar
    self.TabBar = Instance.new("Frame")
    self.TabBar.Size = UDim2.new(1, 0, 0, 40)
    self.TabBar.Position = UDim2.new(0, 0, 0, 0)
    self.TabBar.BackgroundColor3 = Config.Theme.BackgroundDark
    self.TabBar.BackgroundTransparency = 0.3
    self.TabBar.BorderSizePixel = 0
    self.TabBar.Parent = self.Container
    
    local tabBarCorner = Instance.new("UICorner")
    tabBarCorner.CornerRadius = UDim.new(Config.Theme.CornerRoundness.Scale, 0)
    tabBarCorner.Parent = self.TabBar
    
    -- Content area
    self.ContentArea = Instance.new("ScrollingFrame")
    self.ContentArea.Size = UDim2.new(1, 0, 1, -45)
    self.ContentArea.Position = UDim2.new(0, 0, 0, 45)
    self.ContentArea.BackgroundTransparency = 1
    self.ContentArea.BorderSizePixel = 0
    self.ContentArea.ScrollBarThickness = 4
    self.ContentArea.ScrollBarImageColor3 = Config.Theme.SecondaryColor
    self.ContentArea.AutomaticCanvasSize = Enum.AutomaticSize.Y
    self.ContentArea.CanvasSize = UDim2.new(0, 0, 0, 0)
    self.ContentArea.Parent = self.Container
    
    local contentLayout = Instance.new("UIListLayout")
    contentLayout.Padding = UDim.new(0, 10)
    contentLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    contentLayout.Parent = self.ContentArea
    
    local contentPadding = Instance.new("UIPadding")
    contentPadding.PaddingTop = UDim.new(0, 15)
    contentPadding.PaddingBottom = UDim.new(0, 15)
    contentPadding.PaddingLeft = UDim.new(0, 15)
    contentPadding.PaddingRight = UDim.new(0, 15)
    contentPadding.Parent = self.ContentArea
end

function TabSystem:AddTab(name, icon)
    local tabData = {
        Name = name,
        Icon = icon,
        Button = nil,
        Content = nil,
    }
    
    -- Create tab button
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(0, 120, 1, -8)
    button.Position = UDim2.new(0, 5 + (#self.Tabs * 125), 0, 4)
    button.BackgroundColor3 = Config.Theme.BackgroundMedium
    button.BackgroundTransparency = 0.5
    button.BorderSizePixel = 0
    button.Text = ""
    button.AutoButtonColor = false
    button.Parent = self.TabBar
    
    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = UDim.new(0.3, 0)
    buttonCorner.Parent = button
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -10, 1, 0)
    label.Position = UDim2.new(0, 5, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = name
    label.TextColor3 = Config.Theme.TextSecondary
    label.TextSize = 13
    label.Font = Enum.Font.GothamSemibold
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = button
    
    if icon then
        local iconLabel = Instance.new("ImageLabel")
        iconLabel.Size = UDim2.new(0, 16, 0, 16)
        iconLabel.Position = UDim2.new(0, 10, 0.5, -8)
        iconLabel.BackgroundTransparency = 1
        iconLabel.Image = icon
        iconLabel.ImageColor3 = Config.Theme.SecondaryColor
        iconLabel.Parent = button
        
        label.Position = UDim2.new(0, 35, 0, 0)
        label.Size = UDim2.new(1, -40, 1, 0)
    end
    
    -- Create content frame
    local content = Instance.new("Frame")
    content.Size = UDim2.new(1, -30, 0, 0)
    content.Position = UDim2.new(0, 15, 0, 0)
    content.BackgroundTransparency = 1
    content.Visible = false
    content.Parent = self.ContentArea
    
    local contentLayout = Instance.new("UIListLayout")
    contentLayout.Padding = UDim.new(0, 10)
    contentLayout.Parent = content
    
    tabData.Button = button
    tabData.Content = content
    
    -- Tab click handler
    button.MouseButton1Click:Connect(function()
        self:SelectTab(tabData)
    end)
    
    table.insert(self.Tabs, tabData)
    
    -- Select first tab automatically
    if #self.Tabs == 1 then
        self:SelectTab(tabData)
    end
    
    return content
end

function TabSystem:SelectTab(tabData)
    -- Hide all tabs
    for _, tab in ipairs(self.Tabs) do
        tab.Content.Visible = false
        tab.Button.BackgroundTransparency = 0.5
        tab.Button.BackgroundColor3 = Config.Theme.BackgroundMedium
    end
    
    -- Show selected tab
    tabData.Content.Visible = true
    tabData.Button.BackgroundTransparency = 0
    tabData.Button.BackgroundColor3 = Config.Theme.BackgroundLight
    
    self.ActiveTab = tabData
end

function TabSystem:GetContainer()
    return self.Container
end

function TabSystem:Destroy()
    if self.Container then
        self.Container:Destroy()
    end
end

--==============================================================================
-- NOTIFICATION SYSTEM
--==============================================================================
local NotificationSystem = {}
NotificationSystem.__index = NotificationSystem

function NotificationSystem.new(parent)
    local self = setmetatable({}, NotificationSystem)
    self.Parent = parent
    self.Notifications = {}
    self.Container = nil
    self.MaxNotifications = 5
    
    self:Initialize()
    return self
end

function NotificationSystem:Initialize()
    self.Container = Instance.new("Frame")
    self.Container.Size = UDim2.new(0, 350, 1, -20)
    self.Container.Position = UDim2.new(1, -370, 0, 10)
    self.Container.BackgroundTransparency = 1
    self.Container.ClipsDescendants = false
    self.Container.Parent = self.Parent
    
    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 10)
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = self.Container
end

function NotificationSystem:Show(title, message, notificationType, duration)
    notificationType = notificationType or "Info"
    duration = duration or 5
    
    local notification = Instance.new("Frame")
    notification.Size = UDim2.new(1, 0, 0, 80)
    notification.BackgroundTransparency = 1
    notification.ClipsDescendants = true
    notification.LayoutOrder = #self.Notifications + 1
    notification.Parent = self.Container
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0.4, 0)
    corner.Parent = notification
    
    local bg = Instance.new("Frame")
    bg.Size = UDim2.new(1, 0, 1, 0)
    bg.Position = UDim2.new(0, 0, 0, 0)
    bg.BackgroundColor3 = Config.Theme.BackgroundMedium
    bg.BackgroundTransparency = 0.1
    bg.BorderSizePixel = 0
    bg.Parent = notification
    
    local bgCorner = Instance.new("UICorner")
    bgCorner.CornerRadius = UDim.new(0.4, 0)
    bgCorner.Parent = bg
    
    -- Type indicator
    local indicatorColor = Config.Theme.SecondaryColor
    if notificationType == "Success" then
        indicatorColor = Config.Theme.SuccessColor
    elseif notificationType == "Warning" then
        indicatorColor = Config.Theme.WarningColor
    elseif notificationType == "Error" then
        indicatorColor = Config.Theme.ErrorColor
    end
    
    local indicator = Instance.new("Frame")
    indicator.Size = UDim2.new(0, 4, 1, -10)
    indicator.Position = UDim2.new(0, 5, 0, 5)
    indicator.BackgroundColor3 = indicatorColor
    indicator.BorderSizePixel = 0
    indicator.Parent = bg
    
    local indicatorCorner = Instance.new("UICorner")
    indicatorCorner.CornerRadius = UDim.new(1, 0)
    indicatorCorner.Parent = indicator
    
    -- Title
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, -20, 0, 20)
    titleLabel.Position = UDim2.new(0, 15, 0, 10)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = title
    titleLabel.TextColor3 = Config.Theme.TextPrimary
    titleLabel.TextSize = 14
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.TextTruncate = Enum.TextTruncate.AtEnd
    titleLabel.Parent = bg
    
    -- Message
    local messageLabel = Instance.new("TextLabel")
    messageLabel.Size = UDim2.new(1, -20, 0, 40)
    messageLabel.Position = UDim2.new(0, 15, 0, 35)
    messageLabel.BackgroundTransparency = 1
    messageLabel.Text = message
    messageLabel.TextColor3 = Config.Theme.TextSecondary
    messageLabel.TextSize = 12
    messageLabel.Font = Enum.Font.Gotham
    messageLabel.TextXAlignment = Enum.TextXAlignment.Left
    messageLabel.TextYAlignment = Enum.TextYAlignment.Top
    messageLabel.TextWrapped = true
    messageLabel.TextTruncate = Enum.TextTruncate.AtEnd
    messageLabel.Parent = bg
    
    -- Animate in
    notification.Position = UDim2.new(1, 0, 0, 0)
    local tweenIn = Utility.CreateTween(notification, {
        Position = UDim2.new(0, 0, 0, 0)
    }, 0.5, Enum.EasingStyle.Back)
    tweenIn:Play()
    
    table.insert(self.Notifications, {
        Instance = notification,
        Time = os.clock(),
        Duration = duration,
    })
    
    -- Auto remove
    delay(duration, function()
        self:RemoveNotification(notification)
    end)
    
    -- Cleanup old notifications
    while #self.Notifications > self.MaxNotifications do
        local oldest = table.remove(self.Notifications, 1)
        if oldest.Instance then
            self:RemoveNotification(oldest.Instance)
        end
    end
end

function NotificationSystem:RemoveNotification(notification)
    for i, notif in ipairs(self.Notifications) do
        if notif.Instance == notification then
            local tweenOut = Utility.CreateTween(notification, {
                Position = UDim2.new(1, 20, 0, 0),
                BackgroundTransparency = 1
            }, 0.3)
            tweenOut:Play()
            
            tweenOut.Completed:Connect(function()
                notification:Destroy()
            end)
            
            table.remove(self.Notifications, i)
            break
        end
    end
end

function NotificationSystem:ClearAll()
    for _, notif in ipairs(self.Notifications) do
        if notif.Instance then
            notif.Instance:Destroy()
        end
    end
    self.Notifications = {}
end

--==============================================================================
-- MAIN GUI CONTROLLER
--==============================================================================
local CosmicGUI = {}
CosmicGUI.__index = CosmicGUI

function CosmicGUI.new()
    local self = setmetatable({}, CosmicGUI)
    self.ScreenGui = nil
    self.MainFrame = nil
    self.TitleBar = nil
    self.ContentFrame = nil
    self.CloseButton = nil
    self.MinimizeButton = nil
    self.IsOpen = false
    self.IsDragging = false
    self.IsMinimized = false
    self.DragOffset = Vector2.new(0, 0)
    self.StarField = nil
    self.DynamicLighting = nil
    self.ParticleSystem = nil
    self.NotificationSystem = nil
    self.Components = {}
    
    self:Initialize()
    return self
end

function CosmicGUI:Initialize()
    -- Create ScreenGui
    self.ScreenGui = Instance.new("ScreenGui")
    self.ScreenGui.Name = "CosmicUltimateGUI"
    self.ScreenGui.ResetOnSpawn = false
    self.ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    self.ScreenGui.DisplayOrder = 100
    self.ScreenGui.Parent = PlayerGui
    
    -- Main frame
    self.MainFrame = Instance.new("Frame")
    self.MainFrame.Size = Config.Window.Size
    self.MainFrame.Position = Config.Window.Position
    self.MainFrame.BackgroundColor3 = Config.Theme.BackgroundDark
    self.MainFrame.BorderSizePixel = 0
    self.MainFrame.Visible = false
    self.MainFrame.ClipsDescendants = true
    self.MainFrame.Parent = self.ScreenGui
    
    local mainCorner = Instance.new("UICorner")
    mainCorner.CornerRadius = Config.Theme.CornerRoundness
    mainCorner.Parent = self.MainFrame
    
    local mainShadow = Instance.new("ImageLabel")
    mainShadow.Size = UDim2.new(1, 40, 1, 40)
    mainShadow.Position = UDim2.new(0, -20, 0, -20)
    mainShadow.BackgroundTransparency = 1
    mainShadow.Image = "rbxassetid://280055602"
    mainShadow.ImageColor3 = Color3.new(0, 0, 0)
    mainShadow.ImageTransparency = 0.7
    mainShadow.ScaleType = Enum.ScaleType.Slice
    mainShadow.SliceCenter = Rect.new(24, 24, 276, 276)
    mainShadow.ZIndex = 0
    mainShadow.Parent = self.MainFrame
    
    -- Initialize effects
    self.StarField = StarField.new(self.MainFrame, Config.Theme.StarCount)
    self.DynamicLighting = DynamicLighting.new(self.MainFrame)
    self.ParticleSystem = ParticleSystem.new(self.MainFrame)
    self.NotificationSystem = NotificationSystem.new(self.ScreenGui)
    
    -- Start effects
    self.StarField:Start()
    self.DynamicLighting:Start()
    self.ParticleSystem:Start()
    
    -- Title bar
    self.TitleBar = Instance.new("Frame")
    self.TitleBar.Size = UDim2.new(1, 0, 0, 50)
    self.TitleBar.Position = UDim2.new(0, 0, 0, 0)
    self.TitleBar.BackgroundColor3 = Config.Theme.BackgroundDark
    self.TitleBar.BackgroundTransparency = 0.5
    self.TitleBar.BorderSizePixel = 0
    self.TitleBar.Parent = self.MainFrame
    
    local titleCorner = Instance.new("UICorner")
    titleCorner.CornerRadius = UDim.new(Config.Theme.CornerRoundness.Scale, 0)
    titleCorner.Parent = self.TitleBar
    
    -- Title gradient overlay
    local titleGradient = Instance.new("Frame")
    titleGradient.Size = UDim2.new(1, 0, 1, 0)
    titleGradient.Position = UDim2.new(0, 0, 0, 0)
    titleGradient.BackgroundTransparency = 1
    titleGradient.Parent = self.TitleBar
    
    local gradientTitle = Instance.new("UIGradient")
    gradientTitle.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Config.Theme.PrimaryColor),
        ColorSequenceKeypoint.new(0.5, Config.Theme.SecondaryColor),
        ColorSequenceKeypoint.new(1, Config.Theme.AccentColor)
    })
    gradientTitle.Rotation = 90
    gradientTitle.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.9),
        NumberSequenceKeypoint.new(1, 0.9)
    })
    gradientTitle.Parent = titleGradient
    
    -- Title label
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, -120, 1, 0)
    titleLabel.Position = UDim2.new(0, 15, 0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = "🌌 COSMIC ULTIMATE GUI"
    titleLabel.TextColor3 = Config.Theme.TextPrimary
    titleLabel.TextSize = 18
    titleLabel.Font = Enum.Font.GothamBlack
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.TextStrokeTransparency = 0.3
    titleLabel.Parent = self.TitleBar
    
    -- Animated title glow
    local titleGlow = Instance.new("ImageLabel")
    titleGlow.Size = UDim2.new(1, 0, 1, 0)
    titleGlow.Position = UDim2.new(0, 0, 0, 0)
    titleGlow.BackgroundTransparency = 1
    titleGlow.Image = "rbxassetid://280055602"
    titleGlow.ImageColor3 = Config.Theme.SecondaryColor
    titleGlow.ImageTransparency = 0.85
    titleGlow.ScaleType = Enum.ScaleType.Slice
    titleGlow.SliceCenter = Rect.new(24, 24, 276, 276)
    titleGlow.ZIndex = 1
    titleGlow.Parent = self.TitleBar
    
    -- Control buttons container
    local controlsFrame = Instance.new("Frame")
    controlsFrame.Size = UDim2.new(0, 100, 0, 30)
    controlsFrame.Position = UDim2.new(1, -110, 0, 10)
    controlsFrame.BackgroundTransparency = 1
    controlsFrame.Parent = self.TitleBar
    
    -- Minimize button
    self.MinimizeButton = Instance.new("TextButton")
    self.MinimizeButton.Size = UDim2.new(0, 30, 0, 30)
    self.MinimizeButton.Position = UDim2.new(0, 0, 0, 0)
    self.MinimizeButton.BackgroundColor3 = Config.Theme.BackgroundMedium
    self.MinimizeButton.BackgroundTransparency = 0.3
    self.MinimizeButton.BorderSizePixel = 0
    self.MinimizeButton.Text = "−"
    self.MinimizeButton.TextColor3 = Config.Theme.TextPrimary
    self.MinimizeButton.TextSize = 20
    self.MinimizeButton.Font = Enum.Font.GothamBold
    self.MinimizeButton.AutoButtonColor = false
    self.MinimizeButton.Parent = controlsFrame
    
    local minimizeCorner = Instance.new("UICorner")
    minimizeCorner.CornerRadius = UDim.new(0.5, 0)
    minimizeCorner.Parent = self.MinimizeButton
    
    self.MinimizeButton.MouseButton1Click:Connect(function()
        self:ToggleMinimize()
    end)
    
    -- Close button
    self.CloseButton = Instance.new("TextButton")
    self.CloseButton.Size = UDim2.new(0, 30, 0, 30)
    self.CloseButton.Position = UDim2.new(0, 40, 0, 0)
    self.CloseButton.BackgroundColor3 = Config.Theme.ErrorColor
    self.CloseButton.BackgroundTransparency = 0.3
    self.CloseButton.BorderSizePixel = 0
    self.CloseButton.Text = "×"
    self.CloseButton.TextColor3 = Config.Theme.TextPrimary
    self.CloseButton.TextSize = 20
    self.CloseButton.Font = Enum.Font.GothamBold
    self.CloseButton.AutoButtonColor = false
    self.CloseButton.Parent = controlsFrame
    
    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0.5, 0)
    closeCorner.Parent = self.CloseButton
    
    self.CloseButton.MouseButton1Click:Connect(function()
        self:Close()
    end)
    
    -- Drag functionality
    self.TitleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 and Config.Window.Draggable then
            self.IsDragging = true
            self.DragOffset = input.Position - Vector2.new(self.MainFrame.AbsolutePosition.X, self.MainFrame.AbsolutePosition.Y)
        end
    end)
    
    self.TitleBar.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            self.IsDragging = false
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if self.IsDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local newPosition = input.Position - self.DragOffset
            self.MainFrame.Position = UDim2.new(
                0, newPosition.X,
                0, newPosition.Y
            )
        end
    end)
    
    -- Mouse tracking for dynamic lighting
    self.MainFrame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            local mousePos = input.Position
            self.DynamicLighting:SetMousePosition(Vector2.new(mousePos.X - self.MainFrame.AbsolutePosition.X, mousePos.Y - self.MainFrame.AbsolutePosition.Y))
        end
    end)
    
    -- Content frame
    self.ContentFrame = Instance.new("ScrollingFrame")
    self.ContentFrame.Size = UDim2.new(1, 0, 1, -55)
    self.ContentFrame.Position = UDim2.new(0, 0, 0, 55)
    self.ContentFrame.BackgroundTransparency = 1
    self.ContentFrame.BorderSizePixel = 0
    self.ContentFrame.ScrollBarThickness = 5
    self.ContentFrame.ScrollBarImageColor3 = Config.Theme.SecondaryColor
    self.ContentFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
    self.ContentFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    self.ContentFrame.Parent = self.MainFrame
    
    local contentLayout = Instance.new("UIListLayout")
    contentLayout.Padding = UDim.new(0, 15)
    contentLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    contentLayout.Parent = self.ContentFrame
    
    local contentPadding = Instance.new("UIPadding")
    contentPadding.PaddingTop = UDim.new(0, 15)
    contentPadding.PaddingBottom = UDim.new(0, 15)
    contentPadding.PaddingLeft = UDim.new(0, 15)
    contentPadding.PaddingRight = UDim.new(0, 15)
    contentPadding.Parent = self.ContentFrame
    
    -- Setup keybinds
    self:SetupKeybinds()
    
    print("🌌 Cosmic Ultimate GUI Initialized Successfully!")
end

function CosmicGUI:SetupKeybinds()
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        
        if input.KeyCode == Config.Keybinds.ToggleKey then
            self:Toggle()
        elseif input.KeyCode == Config.Keybinds.CloseKey and self.IsOpen then
            self:Close()
        end
    end)
end

function CosmicGUI:Toggle()
    if self.IsOpen then
        self:Close()
    else
        self:Open()
    end
end

function CosmicGUI:Open()
    if self.IsOpen then return end
    
    self.IsOpen = true
    self.MainFrame.Visible = true
    
    -- Play open sound
    if Config.Audio.EnableSounds then
        local sound = Instance.new("Sound")
        sound.SoundId = Config.Audio.OpenSoundId
        sound.Volume = Config.Audio.Volume
        sound.Parent = SoundService
        sound:Play()
        Debris:AddItem(sound, 2)
    end
    
    -- Fade in animation
    self.MainFrame.BackgroundTransparency = 1
    local tween = Utility.CreateTween(self.MainFrame, {
        BackgroundTransparency = 0
    }, Config.Window.FadeInDuration, Enum.EasingStyle.Quint)
    tween:Play()
    
    -- Show notification
    self.NotificationSystem:Show("Welcome Back!", "Cosmic Ultimate GUI has been loaded successfully.", "Success", 3)
end

function CosmicGUI:Close()
    if not self.IsOpen then return end
    
    self.IsOpen = false
    
    -- Play close sound
    if Config.Audio.EnableSounds then
        local sound = Instance.new("Sound")
        sound.SoundId = Config.Audio.CloseSoundId
        sound.Volume = Config.Audio.Volume
        sound.Parent = SoundService
        sound:Play()
        Debris:AddItem(sound, 2)
    end
    
    -- Fade out animation
    local tween = Utility.CreateTween(self.MainFrame, {
        BackgroundTransparency = 1
    }, Config.Window.FadeOutDuration, Enum.EasingStyle.Quint)
    tween:Play()
    
    tween.Completed:Connect(function()
        self.MainFrame.Visible = false
    end)
end

function CosmicGUI:ToggleMinimize()
    self.IsMinimized = not self.IsMinimized
    
    if self.IsMinimized then
        local tween = Utility.CreateTween(self.MainFrame, {
            Size = UDim2.new(0, 300, 0, 50)
        }, 0.5, Enum.EasingStyle.Quint)
        tween:Play()
        
        self.ContentFrame.Visible = false
    else
        local tween = Utility.CreateTween(self.MainFrame, {
            Size = Config.Window.Size
        }, 0.5, Enum.EasingStyle.Quint)
        tween:Play()
        
        delay(0.3, function()
            self.ContentFrame.Visible = true
        end)
    end
end

function CosmicGUI:ShowNotification(title, message, notificationType, duration)
    self.NotificationSystem:Show(title, message, notificationType, duration)
end

function CosmicGUI:AddButton(config)
    local button = AdvancedButton.new(config)
    local buttonInstance = button:GetButton()
    buttonInstance.Parent = self.ContentFrame
    
    table.insert(self.Components, button)
    return button
end

function CosmicGUI:AddSlider(config)
    local slider = Slider.new(config)
    local sliderInstance = slider:GetSlider()
    sliderInstance.Parent = self.ContentFrame
    
    table.insert(self.Components, slider)
    return slider
end

function CosmicGUI:AddToggle(config)
    local toggle = ToggleSwitch.new(config)
    local toggleInstance = toggle:GetSwitch()
    toggleInstance.Parent = self.ContentFrame
    
    table.insert(self.Components, toggle)
    return toggle
end

function CosmicGUI:AddProgressBar(config)
    local progressBar = ProgressBar.new(config)
    local barInstance = progressBar:GetBar()
    barInstance.Parent = self.ContentFrame
    
    table.insert(self.Components, progressBar)
    return progressBar
end

function CosmicGUI:AddTabSystem(config)
    local tabSystem = TabSystem.new(config)
    local container = tabSystem:GetContainer()
    container.Parent = self.ContentFrame
    
    table.insert(self.Components, tabSystem)
    return tabSystem
end

function CosmicGUI:Destroy()
    -- Stop all effects
    if self.StarField then self.StarField:Destroy() end
    if self.DynamicLighting then self.DynamicLighting:Destroy() end
    if self.ParticleSystem then self.ParticleSystem:Destroy() end
    if self.NotificationSystem then self.NotificationSystem:ClearAll() end
    
    -- Destroy components
    for _, component in ipairs(self.Components) do
        if component.Destroy then
            component:Destroy()
        end
    end
    self.Components = {}
    
    -- Destroy ScreenGui
    if self.ScreenGui then
        self.ScreenGui:Destroy()
    end
    
    print("🌌 Cosmic Ultimate GUI Destroyed")
end

--==============================================================================
-- DEMO CONTENT BUILDER
--==============================================================================
local function BuildDemoContent(gui)
    -- Header section
    local headerFrame = Instance.new("Frame")
    headerFrame.Size = UDim2.new(1, -30, 0, 120)
    headerFrame.BackgroundTransparency = 1
    headerFrame.Parent = gui.ContentFrame
    
    local headerLayout = Instance.new("UIListLayout")
    headerLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    headerLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    headerLayout.Parent = headerFrame
    
    local headerTitle = Instance.new("TextLabel")
    headerTitle.Size = UDim2.new(1, 0, 0, 40)
    headerTitle.BackgroundTransparency = 1
    headerTitle.Text = "✨ Welcome to Cosmic Ultimate GUI ✨"
    headerTitle.TextColor3 = Config.Theme.TextPrimary
    headerTitle.TextSize = 24
    headerTitle.Font = Enum.Font.GothamBlack
    headerTitle.TextStrokeTransparency = 0.5
    headerTitle.Parent = headerFrame
    
    local headerSubtitle = Instance.new("TextLabel")
    headerSubtitle.Size = UDim2.new(1, 0, 0, 30)
    headerSubtitle.BackgroundTransparency = 1
    headerSubtitle.Text = "The most advanced GUI system in Luau"
    headerSubtitle.TextColor3 = Config.Theme.SecondaryColor
    headerSubtitle.TextSize = 16
    headerSubtitle.Font = Enum.Font.GothamBold
    headerSubtitle.Parent = headerFrame
    
    local headerDesc = Instance.new("TextLabel")
    headerDesc.Size = UDim2.new(1, 0, 0, 40)
    headerDesc.BackgroundTransparency = 1
    headerDesc.Text = "Press M to toggle • ESC to close • Experience the future of UI design"
    headerDesc.TextColor3 = Config.Theme.TextSecondary
    headerDesc.TextSize = 13
    headerDesc.Font = Enum.Font.Gotham
    headerDesc.TextWrapped = true
    headerDesc.Parent = headerFrame
    
    -- Tab System
    local tabSystem = gui:AddTabSystem({
        Size = UDim2.new(1, -30, 0, 450),
    })
    
    -- Home Tab
    local homeTab = tabSystem:AddTab("Home", "rbxassetid://123456789")
    
    local welcomeCard = Instance.new("Frame")
    welcomeCard.Size = UDim2.new(1, 0, 0, 150)
    welcomeCard.BackgroundColor3 = Config.Theme.BackgroundMedium
    welcomeCard.BackgroundTransparency = 0.5
    welcomeCard.BorderSizePixel = 0
    welcomeCard.Parent = homeTab
    
    local cardCorner = Instance.new("UICorner")
    cardCorner.CornerRadius = Config.Theme.CornerRoundness
    cardCorner.Parent = welcomeCard
    
    local cardTitle = Instance.new("TextLabel")
    cardTitle.Size = UDim2.new(1, -20, 0, 30)
    cardTitle.Position = UDim2.new(0, 15, 0, 15)
    cardTitle.BackgroundTransparency = 1
    cardTitle.Text = "🚀 Quick Start"
    cardTitle.TextColor3 = Config.Theme.TextPrimary
    cardTitle.TextSize = 18
    cardTitle.Font = Enum.Font.GothamBold
    cardTitle.TextXAlignment = Enum.TextXAlignment.Left
    cardTitle.Parent = welcomeCard
    
    local cardDesc = Instance.new("TextLabel")
    cardDesc.Size = UDim2.new(1, -30, 0, 80)
    cardDesc.Position = UDim2.new(0, 15, 0, 50)
    cardDesc.BackgroundTransparency = 1
    cardDesc.Text = "This is the Cosmic Ultimate GUI system featuring dynamic lighting, particle effects, smooth animations, and a modern cosmic theme. Explore the tabs to see all available components!"
    cardDesc.TextColor3 = Config.Theme.TextSecondary
    cardDesc.TextSize = 13
    cardDesc.Font = Enum.Font.Gotham
    cardDesc.TextWrapped = true
    cardDesc.TextXAlignment = Enum.TextXAlignment.Left
    cardDesc.TextYAlignment = Enum.TextYAlignment.Top
    cardDesc.Parent = welcomeCard
    
    -- Features grid
    local featuresFrame = Instance.new("Frame")
    featuresFrame.Size = UDim2.new(1, 0, 0, 200)
    featuresFrame.BackgroundTransparency = 1
    featuresFrame.Parent = homeTab
    
    local featuresLayout = Instance.new("UIGridLayout")
    featuresLayout.CellSize = UDim2.new(0.5, -10, 0, 90)
    featuresLayout.Padding = UDim.new(0, 10)
    featuresLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    featuresLayout.Parent = featuresFrame
    
    local featureNames = {"Dynamic Lighting", "Particle Systems", "Smooth Animations", "Custom Themes"}
    local featureIcons = {"⚡", "✨", "🎬", "🎨"}
    
    for i, name in ipairs(featureNames) do
        local featureCard = Instance.new("Frame")
        featureCard.BackgroundColor3 = Config.Theme.BackgroundLight
        featureCard.BackgroundTransparency = 0.6
        featureCard.BorderSizePixel = 0
        featureCard.Parent = featuresFrame
        
        local featureCorner = Instance.new("UICorner")
        featureCorner.CornerRadius = Config.Theme.CornerRoundness
        featureCorner.Parent = featureCard
        
        local featureIcon = Instance.new("TextLabel")
        featureIcon.Size = UDim2.new(0, 40, 0, 40)
        featureIcon.Position = UDim2.new(0, 10, 0, 5)
        featureIcon.BackgroundTransparency = 1
        featureIcon.Text = featureIcons[i]
        featureIcon.TextSize = 24
        featureIcon.Font = Enum.Font.GothamBold
        featureIcon.Parent = featureCard
        
        local featureLabel = Instance.new("TextLabel")
        featureLabel.Size = UDim2.new(1, -60, 0, 30)
        featureLabel.Position = UDim2.new(0, 55, 0, 15)
        featureLabel.BackgroundTransparency = 1
        featureLabel.Text = name
        featureLabel.TextColor3 = Config.Theme.TextPrimary
        featureLabel.TextSize = 14
        featureLabel.Font = Enum.Font.GothamBold
        featureLabel.TextXAlignment = Enum.TextXAlignment.Left
        featureLabel.Parent = featureCard
    end
    
    -- Settings Tab
    local settingsTab = tabSystem:AddTab("Settings", "rbxassetid://987654321")
    
    gui:AddToggle({
        Text = "Enable Dynamic Lighting",
        State = Config.Effects.EnableMouseGlow,
    }):SetCallback(function(state)
        Config.Effects.EnableMouseGlow = state
        gui:ShowNotification("Settings Updated", "Dynamic lighting " .. (state and "enabled" or "disabled"), "Info")
    end)
    
    gui:AddToggle({
        Text = "Enable Particle Effects",
        State = true,
    }):SetCallback(function(state)
        if state then
            gui.ParticleSystem:Start()
        else
            gui.ParticleSystem:Stop()
        end
        gui:ShowNotification("Settings Updated", "Particle effects " .. (state and "enabled" or "disabled"), "Info")
    end)
    
    gui:AddToggle({
        Text = "Enable Sound Effects",
        State = Config.Audio.EnableSounds,
    }):SetCallback(function(state)
        Config.Audio.EnableSounds = state
        gui:ShowNotification("Settings Updated", "Sound effects " .. (state and "enabled" or "disabled"), "Info")
    end)
    
    gui:AddSlider({
        Text = "Mouse Glow Radius",
        MinValue = 100,
        MaxValue = 500,
        Value = Config.Effects.MouseGlowRadius,
    }):SetCallback(function(value)
        Config.Effects.MouseGlowRadius = value
    end)
    
    gui:AddSlider({
        Text = "Animation Speed",
        MinValue = 0.5,
        MaxValue = 3,
        Value = Config.Theme.AnimationSpeed,
    }):SetCallback(function(value)
        Config.Theme.AnimationSpeed = value
    end)
    
    gui:AddSlider({
        Text = "Star Count",
        MinValue = 50,
        MaxValue = 300,
        Value = Config.Theme.StarCount,
    }):SetCallback(function(value)
        Config.Theme.StarCount = math.floor(value)
        gui.StarField.StarCount = math.floor(value)
        gui.StarField:Generate()
    end)
    
    -- Components Tab
    local componentsTab = tabSystem:AddTab("Components", "rbxassetid://456789123")
    
    gui:AddButton({
        Text = "Primary Action",
        Size = UDim2.new(1, 0, 0, 50),
        Icon = "rbxassetid://123456789",
    }):SetCallback(function()
        gui:ShowNotification("Button Clicked", "Primary action button was pressed!", "Success")
    end)
    
    gui:AddButton({
        Text = "Secondary Action",
        Size = UDim2.new(1, 0, 0, 50),
    }):SetCallback(function()
        gui:ShowNotification("Button Clicked", "Secondary action button was pressed!", "Info")
    end)
    
    gui:AddButton({
        Text = "Warning Action",
        Size = UDim2.new(1, 0, 0, 50),
    }):SetCallback(function()
        gui:ShowNotification("Warning!", "This action may have consequences.", "Warning", 5)
    end)
    
    local progressExample = gui:AddProgressBar({
        Size = UDim2.new(1, 0, 0, 25),
        Value = 75,
    })
    
    -- Animate progress bar
    spawn(function()
        while gui.IsOpen do
            for i = 0, 100, 5 do
                if not gui.IsOpen then break end
                progressExample:SetValue(i)
                wait(0.2)
            end
            for i = 100, 0, -5 do
                if not gui.IsOpen then break end
                progressExample:SetValue(i)
                wait(0.2)
            end
        end
    end)
    
    -- About Tab
    local aboutTab = tabSystem:AddTab("About", "rbxassetid://789123456")
    
    local aboutCard = Instance.new("Frame")
    aboutCard.Size = UDim2.new(1, 0, 0, 300)
    aboutCard.BackgroundColor3 = Config.Theme.BackgroundMedium
    aboutCard.BackgroundTransparency = 0.5
    aboutCard.BorderSizePixel = 0
    aboutCard.Parent = aboutTab
    
    local aboutCorner = Instance.new("UICorner")
    aboutCorner.CornerRadius = Config.Theme.CornerRoundness
    aboutCorner.Parent = aboutCard
    
    local aboutTitle = Instance.new("TextLabel")
    aboutTitle.Size = UDim2.new(1, -20, 0, 40)
    aboutTitle.Position = UDim2.new(0, 15, 0, 15)
    aboutTitle.BackgroundTransparency = 1
    aboutTitle.Text = "📖 About Cosmic Ultimate GUI"
    aboutTitle.TextColor3 = Config.Theme.TextPrimary
    aboutTitle.TextSize = 20
    aboutTitle.Font = Enum.Font.GothamBlack
    aboutTitle.TextXAlignment = Enum.TextXAlignment.Left
    aboutTitle.Parent = aboutCard
    
    local aboutText = Instance.new("TextLabel")
    aboutText.Size = UDim2.new(1, -30, 0, 240)
    aboutText.Position = UDim2.new(0, 15, 0, 60)
    aboutText.BackgroundTransparency = 1
    aboutText.Text = [[Cosmic Ultimate GUI is a premium GUI system built entirely in Luau for Roblox.

Features Include:
• Dynamic mouse-following lighting effects
• Animated starfield background with twinkling stars
• Particle emission systems
• Smooth tween-based animations
• Modular component architecture
• Customizable themes and colors
• Sound effect integration
• Notification system
• Tabbed interface
• Draggable and resizable windows
• Toggle switches, sliders, buttons, progress bars
• Responsive design
• Performance optimized

Created with passion for the Roblox community.
Enjoy the cosmic experience! 🌌]]
    aboutText.TextColor3 = Config.Theme.TextSecondary
    aboutText.TextSize = 13
    aboutText.Font = Enum.Font.Gotham
    aboutText.TextWrapped = true
    aboutText.TextXAlignment = Enum.TextXAlignment.Left
    aboutText.TextYAlignment = Enum.TextYAlignment.Top
    aboutText.Parent = aboutCard
    
    -- Stats display
    local statsFrame = Instance.new("Frame")
    statsFrame.Size = UDim2.new(1, 0, 0, 100)
    statsFrame.BackgroundTransparency = 1
    statsFrame.Parent = aboutTab
    
    local statsLayout = Instance.new("UIGridLayout")
    statsLayout.CellSize = UDim2.new(0.33, -10, 0, 80)
    statsLayout.Padding = UDim.new(0, 10)
    statsLayout.Parent = statsFrame
    
    local stats = {
        {Label = "Lines of Code", Value = "1300+"},
        {Label = "Components", Value = "8"},
        {Label = "Effects", Value = "12+"},
    }
    
    for _, stat in ipairs(stats) do
        local statCard = Instance.new("Frame")
        statCard.BackgroundColor3 = Config.Theme.BackgroundLight
        statCard.BackgroundTransparency = 0.6
        statCard.BorderSizePixel = 0
        statCard.Parent = statsFrame
        
        local statCorner = Instance.new("UICorner")
        statCorner.CornerRadius = Config.Theme.CornerRoundness
        statCorner.Parent = statCard
        
        local statValue = Instance.new("TextLabel")
        statValue.Size = UDim2.new(1, 0, 0, 35)
        statValue.Position = UDim2.new(0, 0, 0, 5)
        statValue.BackgroundTransparency = 1
        statValue.Text = stat.Value
        statValue.TextColor3 = Config.Theme.SecondaryColor
        statValue.TextSize = 22
        statValue.Font = Enum.Font.GothamBlack
        statValue.Parent = statCard
        
        local statLabel = Instance.new("TextLabel")
        statLabel.Size = UDim2.new(1, 0, 0, 25)
        statLabel.Position = UDim2.new(0, 0, 0, 40)
        statLabel.BackgroundTransparency = 1
        statLabel.Text = stat.Label
        statLabel.TextColor3 = Config.Theme.TextSecondary
        statLabel.TextSize = 12
        statLabel.Font = Enum.Font.Gotham
        statLabel.Parent = statCard
    end
end

--==============================================================================
-- INITIALIZATION
--==============================================================================
local function Initialize()
    -- Wait for player to load
    LocalPlayer.CharacterAdded:Wait()
    
    -- Create GUI instance
    local gui = CosmicGUI.new()
    
    -- Build demo content
    BuildDemoContent(gui)
    
    -- Auto-open on start (optional)
    wait(1)
    gui:Open()
    
    -- Return gui instance for external access
    return gui
end

-- Start the GUI system
local CosmicUltimateGUI = Initialize()

-- Export for external use
_G.CosmicGUI = CosmicUltimateGUI

print("🌌✨ Cosmic Ultimate GUI System Loaded Successfully! ✨🌌")
print("📊 Total Lines: 1300+")
print("🎨 Features: Dynamic Lighting, Particles, Stars, Animations, Sounds, Notifications")
print("⌨️ Controls: M = Toggle, ESC = Close")
