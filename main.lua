repeat wait() until game.isLoaded
local UIS = game:GetService('UserInputService')
local OnRender = game:GetService('RunService').RenderStepped
local LP = game:GetService('Players').LocalPlayer
local WS = game:GetService('Workspace')
local CCAM = WS.CurrentCamera
local LPNAME = LP.Name
local LPDIS = LP.DisplayName or LPNAME
local XenoplonVersion = '0.0.1'

local Fluent = loadstring(game:HttpGet('https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua'))()
local SaveManager = loadstring(game:HttpGet('https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua'))()
local InterfaceManager = loadstring(game:HttpGet('https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua'))()

local Window = Fluent:CreateWindow({
    Title = 'XenoplonHub ' .. XenoplonVersion,
    SubTitle = 'by Fakqr',
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = false,
    Theme = 'Dark',
    MinimizeKey = Enum.KeyCode.LeftControl
})

local Tabs = {
    Main = Window:AddTab({ Title = 'Main', Icon = '' }),
    Settings = Window:AddTab({ Title = 'Settings', Icon = 'settings' })
}

local Options = Fluent.Options

local function GetChar()
    return LP.Character or LP.CharacterAdded:Wait()
end

local function GetRoot()
    local Root = GetChar():FindFirstChild('HumanoidRootPart')
    return Root
end

local function ToPos(x,y,z)
    local Root = GetChar():FindFirstChild('HumanoidRootPart')
    if Root~=nil then
        Root.CFrame = CFrame.new(x,y,z)
    end
end

local function CheckGame()
    local PlaceID = game.PlaceId
    local SupportedGames = {
        [7606564092] = 'Shrimp Game'
    }

    if SupportedGames[PlaceID] then
        return {
            ['Game'] = SupportedGames[PlaceID],
            ['SupportedGames'] = SupportedGames
        }
    else
        return nil
    end
end

do
    local CG = CheckGame()
    local SGame = CG['Game']
    local SupportedGames = CG['SupportedGames']

    local function getUI()
        if SGame==nil then return end

        if SGame==SupportedGames[7606564092] then
            local FlySpeed = 45
            local Nav = {Flying = false, Forward = false, Backward = false, Left = false, Right = false}

            Tabs.Main:AddParagraph({
                Title = 'Shrimp Game',
                Content = '🦐 Welcome to Shrimp Game: a survival competition inspired by the series Squid Game!'
            })

            Tabs.Main:AddButton({
                Title = 'Teleport to the end of Red-light Green-light',
                Description = 'Teleports you to the finish-line',
                Callback = function()
                    ToPos(154, 4, 710)
                end
            })

            local Fly = Tabs.Main:AddToggle('Fly', {Title = 'Fly', Default = false})

            Fly:OnChanged(function()
                Nav.Flying = Options.Fly.Value
                GetRoot().Anchored = Nav.Flying
            end)

            local C1 = UIS.InputBegan:Connect(function(Input)
                if Input.UserInputType == Enum.UserInputType.Keyboard then
                    if Input.KeyCode == Enum.KeyCode.E then
                        Options.Fly:SetValue(not Options.Fly.Value)
                    elseif Input.KeyCode == Enum.KeyCode.W then
                        Nav.Forward = true
                    elseif Input.KeyCode == Enum.KeyCode.S then
                        Nav.Backward = true
                    elseif Input.KeyCode == Enum.KeyCode.A then
                        Nav.Left = true
                    elseif Input.KeyCode == Enum.KeyCode.D then
                        Nav.Right = true
                    end
                end
            end)

            local C2 = UIS.InputEnded:Connect(function(Input)
                if Input.UserInputType == Enum.UserInputType.Keyboard then
                    if Input.KeyCode == Enum.KeyCode.W then
                        Nav.Forward = false
                    elseif Input.KeyCode == Enum.KeyCode.S then
                        Nav.Backward = false
                    elseif Input.KeyCode == Enum.KeyCode.A then
                        Nav.Left = false
                    elseif Input.KeyCode == Enum.KeyCode.D then
                        Nav.Right = false
                    end
                end
            end)

            local C3 = CCAM:GetPropertyChangedSignal('CFrame'):Connect(function()
                if Nav.Flying then
                    GetRoot().CFrame = CFrame.new(GetRoot().CFrame.Position, GetRoot().CFrame.Position + CCAM.CFrame.LookVector)
                end
            end)
            
            local C4 = OnRender:Connect(function(Delta)
                if Nav.Flying then
                    if Nav.Forward then
                        GetRoot().CFrame = GetRoot().CFrame + (CCAM.CFrame.LookVector * (Delta * FlySpeed))
                    end
                    if Nav.Backward then
                        GetRoot().CFrame = GetRoot().CFrame + (-CCAM.CFrame.LookVector * (Delta * FlySpeed))
                    end
                    if Nav.Left then
                        GetRoot().CFrame = GetRoot().CFrame + (-CCAM.CFrame.RightVector * (Delta * FlySpeed))
                    end
                    if Nav.Right then
                        GetRoot().CFrame = GetRoot().CFrame + (CCAM.CFrame.RightVector * (Delta * FlySpeed))
                    end
                end
            end)
        end
    end

    local GameMessage = 'null'

    if SGame~=nil then
        getUI()
        GameMessage = 'Loaded on'..SGame..'!'
    else
        SGame = 'Universal'
        GameMessage = 'Could not find a supported game using Universal mode.'
    end

    Fluent:Notify({
        Title = 'Xenoplon',
        Content = 'Welcome '..LPDIS..'\n\nLoaded on '..SGame,
        Duration = 8
    })
end

SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({})
InterfaceManager:SetFolder('XenoplonScriptHub')
SaveManager:SetFolder('XenoplonScriptHub/Universal')
InterfaceManager:BuildInterfaceSection(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)
Window:SelectTab(1)
SaveManager:LoadAutoloadConfig()
