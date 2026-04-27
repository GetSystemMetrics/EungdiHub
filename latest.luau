if game.PlaceId ~= 13342303743 and game.PlaceId ~= 7862839080 then error("승리재단이 아닙니다."); end;

local G = getgenv and getgenv() or _G;

-------------------------==Service==-------------------------
local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))();
local Players = game:GetService("Players");
local lplr = Players.LocalPlayer;
local ReplicatedStorage = game:GetService("ReplicatedStorage");
local CAS = game:GetService("ContextActionService");
local Workspace = game:GetService("Workspace");
local Maps = Workspace:FindFirstChild("Maps") or Workspace;
local Spawns = Maps:FindFirstChild("Spawns") or Maps;
local Models = Maps:FindFirstChild("Models") or Maps;
-------------------------------------------------------------

---------------------------==ACS==---------------------------
local evts = ReplicatedStorage.ACS_Engine.Events;
local ACS_0 = G.ACS_0 or evts.AcessId:InvokeServer(lplr.UserId, lplr.Name);
G.ACS_0 = ACS_0;
-------------------------------------------------------------

-------------------------==HDADMIN==-------------------------
local HDGUI = lplr.PlayerGui:FindFirstChild("HDAdminGUIs");
local HDREP = ReplicatedStorage:WaitForChild("HDAdminClient");
local signals = HDREP.Signals;
local success, main = pcall(signals.RetrieveData.InvokeServer, signals.RetrieveData);
if not success then main = "fucked"; end;
-------------------------------------------------------------

------------------------==Variaveis==------------------------
local kexclude, conns, ck, threads = {}, {}, {}, {};
local ACS, Place, phconn;
local Theme = "Darker";
local Version = "4.5523";
-------------------------------------------------------------

---------------------------==GUI==---------------------------
pcall(function()
    local placeInfo = game:GetService("MarketplaceService"):GetProductInfoAsync(game.PlaceId);
    Place = placeInfo.Name;
end);

local Window = Fluent:CreateWindow({
    Title = "EUNGDI HUB "..Version,
    SubTitle = "by Roh Moo Hyun",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = false,
    Theme = Theme,
    MinimizeKey = Enum.KeyCode.LeftControl
});

local GUI = Fluent.GUI;
GUI.Name = "Eungdi"..math.random(100, 999);
Window.TitleBar.MinButton.Frame.MouseButton1Click:Connect(function()
    CAS:BindAction(
        "Eungdi_Unminimize",
        function(act, input, inputobj)
            if input == Enum.UserInputState.Begin then
                CAS:UnbindAction("Eungdi_Unminimize")
                Window:Minimize()
            end
        end,
        true
    )
    CAS:SetTitle("Eungdi_Unminimize", "GUI")
    CAS:SetPosition("Eungdi_Unminimize", UDim2.new(.65, 0, .65, 0))
end)

local function notify(Content, SubContent, Duration)
	Fluent:Notify({Title="EUNGDI HUB", Content=Content, SubContent=SubContent, Duration=Duration})
end
-------------------------------------------------------------

-------------------------==Freecam==-------------------------
local camera = Workspace.CurrentCamera;
local RS  = game:GetService("RunService");
local UIS = game:GetService("UserInputService");
local StarterGui = game:GetService("StarterGui");
local Spring = loadstring(game:HttpGet("https://raw.githubusercontent.com/Roblox/Core-Scripts/refs/heads/master/CoreScriptsRoot/Modules/Server/FreeCamera/Spring.lua"))();
local Maid = loadstring(game:HttpGet("https://raw.githubusercontent.com/Roblox/Core-Scripts/refs/heads/master/CoreScriptsRoot/Modules/Server/FreeCamera/Maid.lua"))();
local WasGuiVisible = {};
function ToggleGui(on)
    if not on then
        WasGuiVisible["PointsNotificationsActive"] = StarterGui:GetCore("PointsNotificationsActive");
        WasGuiVisible["BadgesNotificationsActive"] = StarterGui:GetCore("BadgesNotificationsActive");
        WasGuiVisible["Health"] = StarterGui:GetCoreGuiEnabled(Enum.CoreGuiType.Health);
        WasGuiVisible["Backpack"] = StarterGui:GetCoreGuiEnabled(Enum.CoreGuiType.Backpack);
        WasGuiVisible["PlayerList"] = StarterGui:GetCoreGuiEnabled(Enum.CoreGuiType.PlayerList);
        WasGuiVisible["Chat"] = StarterGui:GetCoreGuiEnabled(Enum.CoreGuiType.Chat);
    end;
    local function GuiOn(name)
        if on == false then
            return false;
        end
        if WasGuiVisible[name] ~= nil then
            return WasGuiVisible[name];
        end
        return true;
    end;
    StarterGui:SetCore("PointsNotificationsActive", GuiOn("PointsNotificationsActive"));
    StarterGui:SetCore("BadgesNotificationsActive", GuiOn("BadgesNotificationsActive"));
    StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Health, GuiOn("Health"));
    StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, GuiOn("Backpack"));
    StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, GuiOn("PlayerList"));
    StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Chat, GuiOn("Chat"));
end;

local DEF_FOV = 70;
local NM_ZOOM = math.tan(DEF_FOV * math.pi/360);
local LVEL_GAIN = Vector3.new(1, 0.75, 1);
local RVEL_GAIN = Vector2.new(0.85, 1)/128;
local FVEL_GAIN = -330;
local DEADZONE = 0.125;
local FOCUS_OFFSET = CFrame.new(0, 0, -16);
local DIRECTION_LEFT = 1;
local DIRECTION_RIGHT = 2;
local DIRECTION_FORWARD = 3;
local DIRECTION_BACKWARD = 4;
local DIRECTION_UP = 5;
local DIRECTION_DOWN = 6;
local KEY_MAPPINGS = {
    [DIRECTION_LEFT] = {Enum.KeyCode.A, Enum.KeyCode.H},
    [DIRECTION_RIGHT] = {Enum.KeyCode.D, Enum.KeyCode.K},
    [DIRECTION_FORWARD] = {Enum.KeyCode.W, Enum.KeyCode.U},
    [DIRECTION_BACKWARD] = {Enum.KeyCode.S, Enum.KeyCode.J},
    [DIRECTION_UP] = {Enum.KeyCode.E, Enum.KeyCode.I},
    [DIRECTION_DOWN] = {Enum.KeyCode.Q, Enum.KeyCode.Y},
};

local screenGuis = {};
local freeCamEnabled = false;
local stateRot = Vector2.new();
local panDeltaGamepad = Vector2.new();
local panDeltaMouse = Vector2.new();
local velSpring = Spring.new(7/9, 1/3, 1, Vector3.new());
local rotSpring = Spring.new(7/9, 1/3, 1, Vector2.new());
local fovSpring = Spring.new(2,   1/3, 1, 0);
local gp_x  = 0;
local gp_z  = 0;
local gp_l1 = 0;
local gp_r1 = 0;
local rate_fov = 0;
local SpeedModifier = 1;
local UpdateFreecam;

local function Clamp(x, min, max)
    return x < min and min or x > max and max or x;
end;
local function GetChar()
    local character = lplr.Character;
    if character then
        return character:FindFirstChildOfClass("Humanoid"), character:FindFirstChild("HumanoidRootPart");
    end;
end;
local function InputCurve(x)
    local s = math.abs(x);
    if s > DEADZONE then
        s = 0.255000975*(2^(2.299113817*s) - 1);
        return x > 0 and (s > 1 and 1 or s) or (s > 1 and -1 or -s);
    end;
    return 0;
end;
local function ProcessInput(input, processed)
    local userInputType = input.UserInputType;
    if userInputType == Enum.UserInputType.Gamepad1 then
        local keycode = input.KeyCode;
        if keycode == Enum.KeyCode.Thumbstick2 then
            local pos = input.Position;
            panDeltaGamepad = Vector2.new(InputCurve(pos.y), InputCurve(-pos.x))*7;
        elseif keycode == Enum.KeyCode.Thumbstick1 then
            local pos = input.Position;
            gp_x = InputCurve(pos.x);
            gp_z = InputCurve(-pos.y);
        elseif keycode == Enum.KeyCode.ButtonL2 then
            gp_l1 = input.Position.z;
        elseif keycode == Enum.KeyCode.ButtonR2 then
            gp_r1 = input.Position.z;
        end;
    elseif userInputType == Enum.UserInputType.MouseWheel then
        rate_fov = input.Position.Z;
    end;
end;
local function IsDirectionDown(direction)
    for i = 1, #KEY_MAPPINGS[direction] do
        if UIS:IsKeyDown(KEY_MAPPINGS[direction][i]) then
            return true;
        end;
    end;
    return false;
end;
local function Panned(input, processed)
    if not processed and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Delta;
        panDeltaMouse = Vector2.new(-delta.y, -delta.x);
    end;
end;
local function EnterFreecam()
    ToggleGui(false);
    UIS.MouseIconEnabled = false;
    GUI.Enabled = false;
    Maid:Mark(UIS.InputBegan:Connect(function(input, processed)
        if input.UserInputType == Enum.UserInputType.MouseButton2 then
            UIS.MouseBehavior = Enum.MouseBehavior.LockCurrentPosition;
            local conn = UIS.InputChanged:Connect(Panned);
            repeat
                input = UIS.InputEnded:wait();
            until input.UserInputType == Enum.UserInputType.MouseButton2 or not freeCamEnabled;
            panDeltaMouse = Vector2.new();
            panDeltaGamepad = Vector2.new();
            conn:Disconnect();
            if freeCamEnabled then
                UIS.MouseBehavior = Enum.MouseBehavior.Default;
            end;
        elseif input.KeyCode == Enum.KeyCode.LeftShift or input.KeyCode == Enum.KeyCode.RightShift then
            SpeedModifier = 0.5;
        end;
    end));

    Maid:Mark(UIS.InputEnded:Connect(function(input, processed)
        if input.KeyCode == Enum.KeyCode.LeftShift or input.KeyCode == Enum.KeyCode.RightShift then
            SpeedModifier = 1;
        end;
    end));

    camera.CameraType = Enum.CameraType.Scriptable;

    local hum, hrp = GetChar();
    if hrp then
        hrp.Anchored = true;
    end;
    if hum then
        hum.WalkSpeed = 0;
        Maid:Mark(hum.Jumping:Connect(function(active)
            if active then
                hum.Jumping = false;
            end;
        end));
    end;

    velSpring.t, velSpring.v, velSpring.x = Vector3.new(), Vector3.new(), Vector3.new();
    rotSpring.t, rotSpring.v, rotSpring.x = Vector2.new(), Vector2.new(), Vector2.new();
    fovSpring.t, fovSpring.v, fovSpring.x = camera.FieldOfView, 0, camera.FieldOfView;

    local camCFrame = camera.CFrame;
    local lookVector = camCFrame.lookVector.unit;

    stateRot = Vector2.new(
        math.asin(lookVector.y),
        math.atan2(-lookVector.z, lookVector.x) - math.pi/2
    );
    panDeltaMouse = Vector2.new();

    local playerGui = lplr:WaitForChild("PlayerGui");
    for _, obj in next, playerGui:GetChildren() do
        if obj:IsA("ScreenGui") and obj.Enabled then
            obj.Enabled = false;
            screenGuis[obj] = true;
        end;
    end;
    RS:BindToRenderStep("Freecam", Enum.RenderPriority.Camera.Value, UpdateFreecam);
    freeCamEnabled = true;
end;

local function ExitFreecam()
    freeCamEnabled = false;
    UIS.MouseIconEnabled = true;
    UIS.MouseBehavior = Enum.MouseBehavior.Default;
    Maid:Sweep();
    RS:UnbindFromRenderStep("Freecam");
    local hum, hrp = GetChar();
    if hum then
        hum.WalkSpeed = 16;
    end;
    if hrp then
        hrp.Anchored = false;
    end;
    camera.FieldOfView = DEF_FOV;
    camera.CameraType = Enum.CameraType.Custom;
    for obj in next, screenGuis do
        obj.Enabled = true;
    end;
    screenGuis = {};
    ToggleGui(true);
    GUI.Enabled = true;
end;
local fcconn = {};
-------------------------------------------------------------

---------------------==GlobalVariaveis==---------------------
G.PinghackPower = 2;
G.PinghackEnabled = false;
-------------------------------------------------------------

local function disconn(connlist)
    for i, conn in next, connlist do
        if conn then
            conn:Disconnect();
            connlist[i] = nil;
        end;
    end;
end;

GUI.Destroying:Once(function()
    disconn(fcconn);
    disconn(conns);
    disconn(ck);
    phconn:Disconnect();
    phconn = nil;
    CAS:UnbindAction("Eungdi_PinghackToggle");
    for _, thread in threads do
        task.cancel(thread);
    end;
end);

phconn = RS.RenderStepped:Connect(function()
    if not G.PinghackEnabled or not G.PinghackPower then return; end;

    for i = 1, tonumber(G.PinghackPower) do
        if not G.PinghackEnabled or not lplr.Character or not lplr.Character:FindFirstChildOfClass("Tool") or not lplr.Character:FindFirstChildOfClass("Tool"):FindFirstChild("ACS_Settings") then break; end;

        pcall(evts.ServerBullet.FireServer, evts.ServerBullet,
            Vector3.new(0, 2009, 0),
            Vector3.new(0, -1, 0),
            {
                WalkMult = 1,
                RainbowMode = true,
                Tracer = true,
                BulletFlare = true,
                BulletDrop = 0,
                MuzzleVelocity = 2009523
            },
            {
                MuzzleVelocity = 1
            },
            ACS_0
        );
        -- local gunname = ReplicatedStorage.ACS_Engine.GunModels:FindFirstChildOfClass("Model").Name
        -- local guntool = game:FindFirstChild(gunname, true)
        -- pcall(evts.Equip.FireServer, evts.Equip, guntool, 1, require(guntool.ACS_Settings), require(guntool.ACS_Animations), ACS_0, 777, "니엄마")
        -- OhShit saebu added cooltime to equip ohhhhhShit
        -- evts.Drag only affects client :<
    end;
end);

local function kill(hums)
    if hums and #hums > 0 then
        local gun = lplr:FindFirstChild("ACS_Settings" , true);
        if not gun then
            local chaos = Spawns["Chaos - 반란군 스폰"];
            local temp = chaos.CFrame;
            local humroot = lplr.Character.HumanoidRootPart;
            chaos.CFrame = humroot.CFrame;
            task.wait(.1);
            humroot.CFrame = CFrame.new(humroot.CFrame.X, humroot.CFrame.Y+1, humroot.CFrame.Z);
            chaos.CFrame = temp;
            temp = humroot.CFrame;
            lplr.Character.Head:Destroy();
            task.wait(Players.RespawnTime+1);
            lplr.Character.HumanoidRootPart.CFrame = temp;
            gun = lplr:FindFirstChild("ACS_Settings" , true);
        end;
        gun = gun.Parent;
        local zoomlevel = (camera.Focus.Position - camera.CFrame.Position).Magnitude;
        local zooms = { lplr.CameraMinZoomDistance, lplr.CameraMaxZoomDistance };
        lplr.Character:FindFirstChildOfClass("Humanoid"):EquipTool(gun);
        for _, hum in next, hums do
            if not hum then continue; end;
            pcall(evts.Damage.InvokeServer,
                evts.Damage,
                gun,
                hum,
                0,
                1,
                require(gun.ACS_Settings),
                {
                    camRecoilMod = {
                        RecoilTilt = 1,
                        RecoilUp = 1,
                        RecoilLeft = 1,
                        RecoilRight = 1,
                    },
                    gunRecoilMod = {
                        RecoilUp = 1,
                        RecoilTilt = 1,
                        RecoilLeft = 1,
                        RecoilRight = 1,
                    },
                    ZoomValue = 70,
                    Zoom2Value = 70,
                    AimRM = 1,
                    SpreadRM = 1,
                    DamageMod = math.huge,
                    minDamageMod = math.huge,
                    MinRecoilPower = 1,
                    MaxRecoilPower = 1,
                    RecoilPowerStepAmount = 1,
                    MinSpread = 1,
                    MaxSpread = 1,
                    AimInaccuracyStepAmount = 1,
                    AimInaccuracyDecrease = 1,
                    WalkMult = 1,
                    adsTime = 1,
                    MuzzleVelocity = 1,
                },
                nil,
                nil,
                ACS_0..'-'..tostring(lplr.UserId),
                ACS_0,
                "내엄마는죽었고,노무현곁에계십니다",
                "핵작작만들어"
            );
			notify("킬 성공", "good signal", 3);
        end;
        lplr.Character:FindFirstChildOfClass("Humanoid"):UnequipTools();
        lplr.CameraMinZoomDistance = zoomlevel;
        lplr.CameraMaxZoomDistance = zoomlevel;
        lplr.CameraMinZoomDistance = zooms[1];
        lplr.CameraMaxZoomDistance = zooms[2];
    end;
end;

local Current = Window:AddTab({ Title = "Current", Icon = "scan" })

Current:AddSection("게임")

Current:AddParagraph({
    Title = "Running in",
    Content = Place
})

local _, rankinfo = pcall(function()
    if main == "fucked" then return end
    return main.pdata.Rank .. (main.pdata.SaveRank and (", PermRanked by " .. Players:GetNameFromUserIdAsync(main.pdata.PermRankedBy)) or "")
end)

local rankpara = Current:AddParagraph({
    Title = "Rank",
    Content = rankinfo or "Fucked"
})

local rankReceiver = function()
    while task.wait(5) do
        local success
        success, main = pcall(signals.RetrieveData.InvokeServer, signals.RetrieveData)
        if not success then main = "fucked" end
        local _, rankinfo = pcall(function()
            if main == "fucked" then return end
            return main.pdata.Rank .. (main.pdata.SaveRank and (", PermRanked by " .. Players:GetNameFromUserIdAsync(main.pdata.PermRankedBy)) or "")
        end)
        rankpara:SetDesc(rankinfo or "Fucked")
    end
end

table.insert(threads, task.spawn(rankReceiver))

local WF = Window:AddTab({ Title = "승리재단", Icon = "locate" })

WF:AddSection("서버 테러")

local Slider = WF:AddSlider("PinghackPower", {
    Title = "핑핵 파워",
    Description = "핑 파워를 조절합니다.",
    Default = 2,
    Min = 1,
    Max = 100,
    Rounding = 1
})

Slider:OnChanged(function(Value)
    G.PinghackPower = Value
end)

WF:AddToggle("Pinghack", {
    Title = "핑핵",
    Description = "G키를 눌러 핑핵을 실행합니다.",
    Default = false,
    Callback = function(state)
        if state then
            CAS:BindAction(
                "Eungdi_PinghackToggle",
                function(act, input, inputobj)
                    if input == Enum.UserInputState.Begin then
                        if not G.PinghackEnabled then
                            local gun = lplr:FindFirstChild("ACS_Settings", true)
                            if not gun then
                                local chaos = Spawns["Chaos - 반란군 스폰"]
                                local temp = chaos.CFrame
                                local humroot = lplr.Character.HumanoidRootPart
                                chaos.CFrame = humroot.CFrame
                                task.wait(.1)
                                humroot.CFrame = CFrame.new(humroot.CFrame.X, humroot.CFrame.Y+1, humroot.CFrame.Z)
                                chaos.CFrame = temp
                                temp = humroot.CFrame
                                lplr.Character.Head:Destroy()
                                task.wait(Players.RespawnTime+1)
                                lplr.Character.HumanoidRootPart.CFrame = temp
                            end
                        end
                        G.PinghackEnabled = not G.PinghackEnabled
						notify("Pinghack: "..tostring(G.PinghackEnabled), "good signal", 3);
                    end
                end,
                true,
                Enum.KeyCode.G
            )
            CAS:SetTitle("Eungdi_PinghackToggle", "핑핵")
            CAS:SetPosition("Eungdi_PinghackToggle", UDim2.new(.7, 0, .6, 0))
        else
            CAS:UnbindAction("Eungdi_PinghackToggle")
            G.PinghackEnabled = false
        end
    end
})

WF:AddInput("ACS_KillExclude", {
    Title = "킬올 제외",
    Description = "유저를 킬올 대상자에서 제외합니다.",
    Default = "",
    Placeholder = "PlozPain",
    Numeric = false,
    Finished = true,
    Callback = function(Value)
        if Value == "" then return end
        if Players:FindFirstChild(Value) then
            if kexclude[Value] then
                kexclude[Value] = nil
                notify(Value.." 제거되었습니다.", "good signal", 3)
            else
                kexclude[Value] = true
                notify(Value.." 추가되었습니다.", "good signal", 3)
            end
        else
            notify("닉네임이 정확한지 확인해 주세요.", "bad signal", 5)
        end
    end
})

WF:AddButton({
    Title = "킬올",
    Description = "모든 유저를 죽입니다.",
    Callback = function()
        local tokill = {}
        for _, plr in next, Players:GetPlayers() do
            if kexclude[plr.Name] then continue end
            if plr.Team ~= lplr.Team then
                table.insert(tokill, plr.Character:FindFirstChildOfClass("Humanoid"))
            end
        end
        kill(tokill)
    end
})

WF:AddButton({
    Title = "킬올(몹)",
    Description = "모든 몹을 죽입니다.",
    Callback = function()
        local plrs, tokill = {}, {}
        for _, plr in next, Players:GetPlayers() do
            if plr.Character then
                table.insert(plrs, plr.Character)
            end
        end

        for _, obj in next, Workspace:GetDescendants() do
            local hum = obj:FindFirstChildOfClass("Humanoid")
            if hum and not table.find(plrs, obj) then
                table.insert(tokill, hum)
            end
        end
        kill(tokill)
    end
})

WF:AddToggle("ACS_Clickkill", {
    Title = "클릭 킬",
    Description = "클릭으로 유저를 죽입니다.",
    Default = false,
    Callback = function(state)
        if state then
            conns[2] = lplr:GetMouse().Button1Down:Connect(function()
                local target = lplr:GetMouse().Target
                if not target then return end

                local chr = target.Parent
                local plr = Players:GetPlayerFromCharacter(chr) or Players:GetPlayerFromCharacter(chr.Parent)
                if plr and plr.Team and plr.Team ~= lplr.Team then
                    kill({plr.Character:FindFirstChildOfClass("Humanoid")})
                end
            end)
        else
            if conns[2] then
                conns[2]:Disconnect()
                conns[2] = nil
            end
        end
    end
})

WF:AddToggle("ACS_Clickkill(Mob)", {
    Title = "클릭 킬(몹)",
    Description = "클릭으로 몹을 죽입니다.",
    Default = false,
    Callback = function(state)
        if state then
            conns[3] = lplr:GetMouse().Button1Down:Connect(function()
                local target = lplr:GetMouse().Target
                if not target then return end

                local chr = target.Parent
                local plr = Players:GetPlayerFromCharacter(chr) or Players:GetPlayerFromCharacter(chr.Parent)
                if not plr then
                    local hum = chr:FindFirstChildOfClass("Humanoid") or chr.Parent:FindFirstChildOfClass("Humanoid")
                    if hum then
                        kill({hum})
                    end
                end
            end)
        else
            if conns[3] then
                conns[3]:Disconnect()
                conns[3] = nil
            end
        end
    end
})

WF:AddInput("ACS_Namekill", {
    Title = "닉네임 킬",
    Description = "닉네임으로 유저를 죽입니다.",
    Default = "",
    Placeholder = "GRTAgdgdgf",
    Numeric = false,
    Finished = true,
    Callback = function(Value)
        if Value == "" then return end
        local plr = Players:FindFirstChild(Value)
        if plr then
            kill({plr.Character:FindFirstChildOfClass("Humanoid")})
        else
            notify("닉네임이 정확한지 확인해 주세요.", "bad signal", 5)
        end
    end
})

WF:AddSection("기능")

WF:AddToggle("RemoveCountdowns", {
    Title = "카운트 제거",
    Description = "카운트를 제거합니다.",
    Default = false,
    Callback = function(state)
        if state then
            for _, hint in next, HDGUI.MessageContainer.Hints:GetChildren() do
                if hint:FindFirstChild("Desc") and tonumber(hint.Desc.Text) then hint:Destroy() end
            end
            for _, message in next, HDGUI.MessageContainer.Messages:GetChildren() do
                if message:FindFirstChild("Title") and message.Title.Text == "Countdown" then message:Destroy() end
            end
            ck = {HDGUI.MessageContainer.Hints.ChildAdded:Connect(function(hint)
                task.wait()
                if hint:FindFirstChild("Desc") and tonumber(hint.Desc.Text) then hint:Destroy() end
            end), HDGUI.MessageContainer.Messages.ChildAdded:Connect(function(message)
                if message:FindFirstChild("Title") and message.Title.Text == "Countdown" then message:Destroy() end
            end)}
        else
            if ck then
                for i, conn in next, ck do
                    conn:Disconnect()
                    ck[i] = nil
                end
            end
        end
    end
})

WF:AddToggle("RemoveBlur", {
    Title = "블루어 제거",
    Description = "흐림 효과를 제거합니다.",
    Callback = function(state)
        if state then
            conns[4] = game:GetService("RunService").Heartbeat:Connect(function()
                camera.Blur.Size = 0
            end)
        else
            if conns[4] then
                conns[4]:Disconnect()
                conns[4] = nil
            end
        end
    end
})

WF:AddToggle("ForceUnmute", {
    Title = "강제 언뮤트",
    Description = "채팅창을 활성화시킵니다.",
    Callback = function(state)
        if state then
            conns[5] = game:GetService("RunService").Heartbeat:Connect(function()
                game:GetService("StarterGui"):SetCoreGuiEnabled(Enum.CoreGuiType.Chat, true)
            end)
        else
            if conns[5] then
                conns[5]:Disconnect()
                conns[5] = nil
            end
        end
    end
})

WF:AddButton({
    Title = "HD 복구",
    Description = "HD가 없다면 복구합니다.",
    Callback = function()
        if not Workspace:FindFirstChild("HDAdminWorkspaceFolder") then
            local workspaceFolder = Instance.new("Folder")
            workspaceFolder.Name = "HDAdminWorkspaceFolder"
            workspaceFolder.Parent = Workspace
        end
    end
})

WF:AddInput("RequestCommand", {
    Title = "명령 요청",
    Description = "명령 실행을 요청합니다.",
    Default = "",
    Placeholder = (main ~= "fucked" and main.pdata and main.pdata.Prefix or ':').."re",
    Numeric = false,
    Finished = true,
    Callback = function(Value)
        if Value == "" then return end
        if main == "fucked" then return end
        local commandToRequest = Value
        local firstChar = string.sub(commandToRequest,1,1)
        if firstChar ~= main.settings.UniversalPrefix and firstChar ~= main.pdata.Prefix then
            commandToRequest = main.pdata.Prefix..commandToRequest
        end
        local endChar = string.sub(commandToRequest,-1)
        if endChar == " " then
            commandToRequest = string.sub(commandToRequest,1,-1)
        end
        signals.RequestCommand:InvokeServer(commandToRequest)
    end
})

WF:AddToggle("OutrankAutoLeave", {
    Title = "어머멋언랭회피",
    Description = "슈퍼어드민 이상의 랭크를 소유하고 있을 때, 자신보다 높은 사람이 입장하면 강제퇴장합니다.",
    Default = true,
    Callback = function(state)
        if state then
            if main ~= "fucked" and main.pdata.Rank >= 4.5 then
                local serverRankInfo = signals.RetrieveServerRanks:InvokeServer()
                for _, playerRankInfo in next, serverRankInfo do
                    local plr = playerRankInfo.Player
					if lplr:IsFriendsWith(plr.UserId) then return end
                    local rankId = playerRankInfo.RankId
                    if tonumber(rankId) > main.pdata.Rank then
                        lplr:Kick("[응디허브] 랭크 "..rankId.." "..plr.Name.."이 접속했습니다.")
                    end
                end
            end
            conns[6] = Players.PlayerAdded:Connect(function()
                if main == "fucked" or main.pdata.Rank < 4.5 then return end
                local serverRankInfo = signals.RetrieveServerRanks:InvokeServer()
                for _, playerRankInfo in next, serverRankInfo do
                    local plr = playerRankInfo.Player
					if lplr:IsFriendsWith(plr.UserId) then return end
                    local rankId = playerRankInfo.RankId
                    if tonumber(rankId) > main.pdata.Rank then
                        lplr:Kick("[응디허브] 랭크 "..rankId.." "..plr.Name.."이 접속했습니다.")
                    end
                end
            end)
        else
            if conns[6] then
                conns[6]:Disconnect()
                conns[6] = nil
            end
        end
    end
})

WF:AddButton({
    Title = "알람",
    Description = "알람을 토글합니다.",
    Callback = function()
        local prox = Models["Red Alarm"].Button2.Main.ProximityPrompt
        local hrp = (lplr.Character or lplr.CharacterAdded:Wait()).HumanoidRootPart
        local origin = hrp.CFrame
        hrp.CFrame = prox.Parent.CFrame
        prox.RequiresLineOfSight = false
        prox.HoldDuration = 0
        task.wait(.1)
        fireproximityprompt(prox)
        hrp.CFrame = origin
    end
})

WF:AddButton({
    Title = "재접",
    Description = "이 서버로 재접속합니다.",
    Callback = function()
        game:GetService("TeleportService"):Teleport(game.PlaceId, lplr)
    end
})

local Standard = Window:AddTab({ Title = "Standard", Icon = "loader" })

Standard:AddSection("스탠다드")

Standard:AddInput("Loadstring", {
    Title = "로드스트링",
    Description = "문자열을 컴파일한 후 실행합니다.",
    Default = "",
    Placeholder = "print(\"Hello, World\");",
    Numeric = false,
    Finished = true,
    Callback = function(Value)
        if Value == "" then return end
        pcall(loadstring(Value))
    end
})

Standard:AddToggle("Freecam", {
    Title = "프리캠",
    Description = "프리캠을 활성화시킵니다.",
    Callback = function(state)
        if state then
            fcconn[1] = UIS.InputChanged:Connect(ProcessInput)
            fcconn[2] = UIS.InputEnded:Connect(ProcessInput)
            fcconn[3] = UIS.InputBegan:Connect(ProcessInput)
            do
                local dt = 1/60
                fcconn[4] = RS.RenderStepped:Connect(function(_dt)
                    dt = _dt
                end)

                function UpdateFreecam()
                    local camCFrame = camera.CFrame

                    local kx = (IsDirectionDown(DIRECTION_RIGHT) and 1 or 0) - (IsDirectionDown(DIRECTION_LEFT) and 1 or 0)
                    local ky = (IsDirectionDown(DIRECTION_UP) and 1 or 0) - (IsDirectionDown(DIRECTION_DOWN) and 1 or 0)
                    local kz = (IsDirectionDown(DIRECTION_BACKWARD) and 1 or 0) - (IsDirectionDown(DIRECTION_FORWARD) and 1 or 0)
                    local km = (kx * kx) + (ky * ky) + (kz * kz)
                    if km > 1e-15 then
                        km = ((UIS:IsKeyDown(Enum.KeyCode.LeftShift) or UIS:IsKeyDown(Enum.KeyCode.RightShift)) and 1/4 or 1)/math.sqrt(km)
                        kx = kx * km
                        ky = ky * km
                        kz = kz * km
                    end

                    local dx = kx + gp_x
                    local dy = ky + gp_r1 - gp_l1
                    local dz = kz + gp_z

                    velSpring.t = Vector3.new(dx, dy, dz) * SpeedModifier
                    rotSpring.t = panDeltaMouse + panDeltaGamepad
                    fovSpring.t = Clamp(fovSpring.t + dt * rate_fov*FVEL_GAIN, 5, 120)

                    local fov  = fovSpring:Update(dt)
                    local dPos = velSpring:Update(dt) * LVEL_GAIN
                    local dRot = rotSpring:Update(dt) * (RVEL_GAIN * math.tan(fov * math.pi/360) * NM_ZOOM)

                    rate_fov = 0
                    panDeltaMouse = Vector2.new()

                    stateRot = stateRot + dRot
                    stateRot = Vector2.new(Clamp(stateRot.x, -3/2, 3/2), stateRot.y)

                    local c = CFrame.new(camCFrame.Position) * CFrame.Angles(0, stateRot.y, 0) * CFrame.Angles(stateRot.x, 0, 0) * CFrame.new(dPos)

                    camera.CFrame = c
                    camera.Focus = c*FOCUS_OFFSET
                    camera.FieldOfView = fov
                end
            end

            fcconn[5] = UIS.InputBegan:Connect(function(input, processed)
                if not processed then
                    if input.KeyCode == Enum.KeyCode.P then
                        if UIS:IsKeyDown(Enum.KeyCode.LeftShift) then
                            if freeCamEnabled then
                                ExitFreecam()
                            else
                                EnterFreecam()
                            end
                        end
                    end
                end
            end)
        else
            for i, conn in next, fcconn do
                if conn then
                    conn:Disconnect()
                    fcconn[i] = nil
                end
            end
        end
    end
})

notify("응디 허브가 정상적으로 실행됨", "good signal", 5)
