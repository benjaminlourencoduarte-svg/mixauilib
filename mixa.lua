--// Roblox UI Library with Theme + Images + Notifications (fixed & complete) //--

local UILibrary = {};

-- Default theme
local Theme = {
    Background = Color3.fromRGB(20, 20, 20),
    Topbar = Color3.fromRGB(10, 10, 10),
    TabBar = Color3.fromRGB(15, 15, 15),
    Button = Color3.fromRGB(40, 40, 40),
    Accent = Color3.fromRGB(60, 60, 60),
    TextColor = Color3.fromRGB(255, 255, 255)
};

local AllUIElements = {
    Windows = {},
    Tabs = {},
    Buttons = {},
    Labels = {},
    Frames = {},
    Images = {}
};

-- Draggable utility
local function makeDraggable(frame, dragHandle)
    local dragging, dragInput, startPos, startInputPos
    dragHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            startPos = frame.Position
            startInputPos = input.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    dragHandle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)
    game:GetService("UserInputService").InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - startInputPos
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

-- Theme updater
local function applyTheme()
    for _, frame in ipairs(AllUIElements.Frames) do
        if not frame or not frame.Parent then
            -- skip destroyed elements
        else
            if frame.Name == "MainFrame" then
                frame.BackgroundColor3 = Theme.Background
            elseif frame.Name == "TopBar" then
                frame.BackgroundColor3 = Theme.Topbar
            elseif frame.Name == "TabBar" then
                frame.BackgroundColor3 = Theme.TabBar
            else
                -- generic frames (separators, notification frames, etc.)
                if frame:IsA("Frame") and frame.BackgroundTransparency < 1 then
                    frame.BackgroundColor3 = Theme.Accent
                end
            end
        end
    end

    for _, button in ipairs(AllUIElements.Buttons) do
        if button and button.Parent and button:IsA("TextButton") then
            button.BackgroundColor3 = Theme.Button
            button.TextColor3 = Theme.TextColor
        end
    end

    for _, label in ipairs(AllUIElements.Labels) do
        if label and label.Parent and (label:IsA("TextLabel") or label:IsA("TextButton")) then
            label.TextColor3 = Theme.TextColor
        end
    end

    for _, tab in ipairs(AllUIElements.Tabs) do
        if tab.Button and tab.Button.Parent and tab.Button:IsA("TextButton") then
            tab.Button.BackgroundColor3 = Theme.Button
            tab.Button.TextColor3 = Theme.TextColor
        end
    end

    for _, img in ipairs(AllUIElements.Images) do
        if img and img.Parent and img:IsA("ImageLabel") then
            -- keep image visuals; ensure background blends
            img.BackgroundTransparency = 1
        end
    end
end

-- Notification helper (internal)
local function getNotificationContainer()
    local ScreenGui = game:GetService("CoreGui"):FindFirstChild("UILibrary")
    if not ScreenGui then
        ScreenGui = Instance.new("ScreenGui")
        ScreenGui.Name = "UILibrary"
        ScreenGui.Parent = game:GetService("CoreGui")
    end

    local Container = ScreenGui:FindFirstChild("NotificationContainer")
    if not Container then
        Container = Instance.new("Frame")
        Container.Name = "NotificationContainer"
        Container.Size = UDim2.new(0, 300, 1, -50)
        Container.Position = UDim2.new(1, -310, 0, 50)
        Container.AnchorPoint = Vector2.new(0, 0)
        Container.BackgroundTransparency = 1
        Container.Parent = ScreenGui

        local Layout = Instance.new("UIListLayout")
        Layout.SortOrder = Enum.SortOrder.LayoutOrder
        Layout.Padding = UDim.new(0, 6)
        Layout.VerticalAlignment = Enum.VerticalAlignment.Top
        Layout.Parent = Container
    end

    return Container
end

-- Notification system
function UILibrary:Notify(message, duration, type)
    duration = duration or 3
    type = type or "default" -- "default", "success", "error", "warning"

    local Container = getNotificationContainer()

    local NotifyFrame = Instance.new("Frame")
    NotifyFrame.Size = UDim2.new(1, 0, 0, 40)
    NotifyFrame.BackgroundColor3 = Theme.Button
    NotifyFrame.BorderSizePixel = 0
    NotifyFrame.Parent = Container
    NotifyFrame.Name = "Notification"

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 6)
    Corner.Parent = NotifyFrame

    -- Accent strip
    local AccentStrip = Instance.new("Frame")
    AccentStrip.Size = UDim2.new(0, 6, 1, 0)
    AccentStrip.Position = UDim2.new(0, 0, 0, 0)
    AccentStrip.BorderSizePixel = 0
    AccentStrip.Parent = NotifyFrame

    if type == "success" then
        AccentStrip.BackgroundColor3 = Color3.fromRGB(76, 175, 80)
    elseif type == "error" then
        AccentStrip.BackgroundColor3 = Color3.fromRGB(244, 67, 54)
    elseif type == "warning" then
        AccentStrip.BackgroundColor3 = Color3.fromRGB(255, 193, 7)
    else
        AccentStrip.BackgroundColor3 = Theme.Accent
    end

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -16, 1, 0)
    Label.Position = UDim2.new(0, 10, 0, 0)
    Label.BackgroundTransparency = 1
    Label.TextColor3 = Theme.TextColor
    Label.Font = Enum.Font.Gotham
    Label.TextSize = 14
    Label.Text = message or ""
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = NotifyFrame

    -- Fade in
    NotifyFrame.BackgroundTransparency = 1
    Label.TextTransparency = 1
    AccentStrip.BackgroundTransparency = 1
    local TweenService = game:GetService("TweenService")
    TweenService:Create(NotifyFrame, TweenInfo.new(0.25), {BackgroundTransparency = 0}):Play()
    TweenService:Create(Label, TweenInfo.new(0.25), {TextTransparency = 0}):Play()
    TweenService:Create(AccentStrip, TweenInfo.new(0.25), {BackgroundTransparency = 0}):Play()

    -- Auto-remove
    task.delay(duration, function()
        if NotifyFrame and NotifyFrame.Parent then
            local t1 = TweenService:Create(NotifyFrame, TweenInfo.new(0.25), {BackgroundTransparency = 1})
            local t2 = TweenService:Create(Label, TweenInfo.new(0.25), {TextTransparency = 1})
            local t3 = TweenService:Create(AccentStrip, TweenInfo.new(0.25), {BackgroundTransparency = 1})
            t1:Play(); t2:Play(); t3:Play()
            t1.Completed:Wait()
            if NotifyFrame and NotifyFrame.Parent then
                NotifyFrame:Destroy()
            end
        end
    end)
end

-- Create window
function UILibrary:CreateWindow(title)
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "UILibrary"
    ScreenGui.Parent = game:GetService("CoreGui")

    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 450, 0, 300)
    MainFrame.Position = UDim2.new(0.3, 0, 0.3, 0)
    MainFrame.BackgroundColor3 = Theme.Background
    MainFrame.Active = true
    MainFrame.Parent = ScreenGui
    MainFrame.Name = "MainFrame"
    table.insert(AllUIElements.Frames, MainFrame)

    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 10)
    UICorner.Parent = MainFrame

    local TopBar = Instance.new("Frame")
    TopBar.Size = UDim2.new(1, 0, 0, 30)
    TopBar.BackgroundColor3 = Theme.Topbar
    TopBar.BorderSizePixel = 0
    TopBar.Parent = MainFrame
    TopBar.Name = "TopBar"
    table.insert(AllUIElements.Frames, TopBar)

    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, -10, 1, 0)
    Title.Position = UDim2.new(0, 10, 0, 0)
    Title.BackgroundTransparency = 1
    Title.Text = title or "Window"
    Title.Font = Enum.Font.GothamSemibold
    Title.TextColor3 = Theme.TextColor
    Title.TextSize = 14
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Parent = TopBar
    table.insert(AllUIElements.Labels, Title)

    makeDraggable(MainFrame, TopBar)

    local TabBar = Instance.new("Frame")
    TabBar.Size = UDim2.new(1, 0, 0, 30)
    TabBar.Position = UDim2.new(0, 0, 0, 30)
    TabBar.BackgroundColor3 = Theme.TabBar
    TabBar.BorderSizePixel = 0
    TabBar.Parent = MainFrame
    TabBar.Name = "TabBar"
    table.insert(AllUIElements.Frames, TabBar)

    local TabList = Instance.new("UIListLayout")
    TabList.FillDirection = Enum.FillDirection.Horizontal
    TabList.HorizontalAlignment = Enum.HorizontalAlignment.Left
    TabList.SortOrder = Enum.SortOrder.LayoutOrder
    TabList.Padding = UDim.new(0, 5)
    TabList.Parent = TabBar

    local TabContainer = Instance.new("Frame")
    TabContainer.Size = UDim2.new(1, 0, 1, -60)
    TabContainer.Position = UDim2.new(0, 0, 0, 60)
    TabContainer.BackgroundTransparency = 1
    TabContainer.Parent = MainFrame

    local window = {}
    local tabs = {}

    function window:Tab(tabname)
        local TabButton = Instance.new("TextButton")
        TabButton.Size = UDim2.new(0, 100, 1, 0)
        TabButton.BackgroundColor3 = Theme.Button
        TabButton.TextColor3 = Theme.TextColor
        TabButton.Font = Enum.Font.Gotham
        TabButton.TextSize = 13
        TabButton.Text = tabname or "Tab"
        TabButton.Parent = TabBar

        local Corner = Instance.new("UICorner")
        Corner.CornerRadius = UDim.new(0, 6)
        Corner.Parent = TabButton

        local TabFrame = Instance.new("ScrollingFrame")
        TabFrame.Size = UDim2.new(1, -10, 1, 0)
        TabFrame.Position = UDim2.new(0, 5, 0, 0)
        TabFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
        TabFrame.ScrollBarThickness = 4
        TabFrame.BackgroundTransparency = 1
        TabFrame.Visible = false
        TabFrame.Parent = TabContainer

        local UIListLayout = Instance.new("UIListLayout")
        UIListLayout.Padding = UDim.new(0, 6)
        UIListLayout.Parent = TabFrame

        -- Auto-update canvas size when content changes
        UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            local size = UIListLayout.AbsoluteContentSize
            TabFrame.CanvasSize = UDim2.new(0, 0, 0, size.Y + 10)
        end)

        local UIPadding = Instance.new("UIPadding")
        UIPadding.PaddingTop = UDim.new(0, 10)
        UIPadding.PaddingLeft = UDim.new(0, 10)
        UIPadding.Parent = TabFrame

        local tab = {}

        -- Button
        function tab:Button(name, func)
            local Button = Instance.new("TextButton")
            Button.Size = UDim2.new(0, 400, 0, 30)
            Button.BackgroundColor3 = Theme.Button
            Button.TextColor3 = Theme.TextColor
            Button.Font = Enum.Font.Gotham
            Button.TextSize = 14
            Button.Text = name or "Button"
            Button.Parent = TabFrame

            local Corner = Instance.new("UICorner")
            Corner.CornerRadius = UDim.new(0, 6)
            Corner.Parent = Button

            table.insert(AllUIElements.Buttons, Button)

            if func then
                Button.MouseButton1Click:Connect(function()
                    pcall(func)
                end)
            end
        end

        -- Label
        function tab:Label(text)
            local Label = Instance.new("TextLabel")
            Label.Size = UDim2.new(0, 400, 0, 30)
            Label.BackgroundTransparency = 1
            Label.TextColor3 = Theme.TextColor
            Label.Font = Enum.Font.Gotham
            Label.TextSize = 14
            Label.Text = text or "Label"
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.Parent = TabFrame

            table.insert(AllUIElements.Labels, Label)
        end

        -- Separator
        function tab:Separator()
            local Sep = Instance.new("Frame")
            Sep.Size = UDim2.new(0, 400, 0, 2)
            Sep.BackgroundColor3 = Theme.Accent
            Sep.BorderSizePixel = 0
            Sep.Parent = TabFrame

            local Corner = Instance.new("UICorner")
            Corner.CornerRadius = UDim.new(0, 2)
            Corner.Parent = Sep

            table.insert(AllUIElements.Frames, Sep)
        end

        -- Image (supports getcustomasset and rbxassetid) - mixed mode (replace/add)
        function tab:Image(assetPathOrId, size, scaleType, onClick, mode)
            mode = mode or "replace" -- "replace" or "add"
            size = size or UDim2.new(0, 400, 0, 200)
            scaleType = scaleType or Enum.ScaleType.Fit

            -- Helper to resolve image string
            local function resolveImage(src)
                if typeof(src) == "number" then
                    return "rbxassetid://" .. tostring(src)
                elseif typeof(src) == "string" then
                    if src:match("^rbxassetid://") or src:match("^rbxasset://") or src:match("^https?://") then
                        return src
                    end
                    local success, result = pcall(function() return getcustomasset(src) end)
                    if success and result then
                        return result
                    end
                    local num = tonumber(src)
                    if num then
                        return "rbxassetid://" .. tostring(num)
                    end
                end
                return ""
            end

            local resolved = resolveImage(assetPathOrId)

            if mode == "replace" then
                -- If we already created an image for this tab, update it
                if self._ImageInstance and self._ImageInstance.Parent and self._ImageInstance:IsA("ImageLabel") then
                    self._ImageInstance.Size = size
                    self._ImageInstance.ScaleType = scaleType
                    self._ImageInstance.Image = resolved
                    -- update or create click button once
                    if onClick then
                        if not self._ImageBtn or not self._ImageBtn.Parent then
                            local Btn = Instance.new("ImageButton")
                            Btn.Size = UDim2.new(1, 0, 1, 0)
                            Btn.BackgroundTransparency = 1
                            Btn.Image = ""
                            Btn.Parent = self._ImageInstance
                            Btn.MouseButton1Click:Connect(function() pcall(onClick) end)
                            self._ImageBtn = Btn
                        else
                            -- reconnect callback without duplicating overlay buttons
                            -- destroy previous connections by replacing the button
                            self._ImageBtn:Destroy()
                            local Btn = Instance.new("ImageButton")
                            Btn.Size = UDim2.new(1, 0, 1, 0)
                            Btn.BackgroundTransparency = 1
                            Btn.Image = ""
                            Btn.Parent = self._ImageInstance
                            Btn.MouseButton1Click:Connect(function() pcall(onClick) end)
                            self._ImageBtn = Btn
                        end
                    else
                        if self._ImageBtn and self._ImageBtn.Parent then
                            self._ImageBtn:Destroy()
                            self._ImageBtn = nil
                        end
                    end
                    return self._ImageInstance
                end

                -- No existing image: clear any ImageLabels in the frame to avoid hidden stacking
                for _, child in ipairs(TabFrame:GetChildren()) do
                    if child:IsA("ImageLabel") then
                        child:Destroy()
                    end
                end
            end

            -- Create new ImageLabel (for mode == "add" or fresh replace)
            local Image = Instance.new("ImageLabel")
            Image.Size = size
            Image.BackgroundTransparency = 1
            Image.ScaleType = scaleType
            Image.Image = resolved
            Image.Parent = TabFrame

            -- Optional click handler: create a single ImageButton overlay
            if onClick then
                local Btn = Instance.new("ImageButton")
                Btn.Size = UDim2.new(1, 0, 1, 0)
                Btn.BackgroundTransparency = 1
                Btn.Image = ""
                Btn.Parent = Image
                Btn.MouseButton1Click:Connect(function()
                    pcall(onClick)
                end)
                if mode == "replace" then
                    self._ImageBtn = Btn
                end
            end

            table.insert(AllUIElements.Images, Image)

            if mode == "replace" then
                self._ImageInstance = Image
            end

            return Image
        end

        table.insert(tabs, {Button = TabButton, Frame = TabFrame})
        table.insert(AllUIElements.Tabs, {Button = TabButton, Frame = TabFrame})

        TabButton.MouseButton1Click:Connect(function()
            for _, t in ipairs(tabs) do
                t.Frame.Visible = false
                if t.Button and t.Button.Parent then
                    t.Button.BackgroundColor3 = Theme.Button
                end
            end
            TabFrame.Visible = true
            TabButton.BackgroundColor3 = Theme.Accent
        end)

        if #tabs == 1 then
            TabFrame.Visible = true
            TabButton.BackgroundColor3 = Theme.Accent
        end

        return tab
    end

    return window
end

-- Set Theme Function
function UILibrary:SetTheme(themeTable)
    for key, value in pairs(themeTable) do
        if Theme[key] ~= nil and typeof(value) == "Color3" then
            Theme[key] = value
        end
    end
    applyTheme()
end

-- Convenience: expose Notify on library root too
function UILibrary.Notify(...) return UILibrary:Notify(...) end
function UILibrary.SetTheme(...) return UILibrary:SetTheme(...) end

return UILibrary
