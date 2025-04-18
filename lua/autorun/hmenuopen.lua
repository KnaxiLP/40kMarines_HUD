local leader
local members
local color
local squad

if SERVER then
    util.AddNetworkString("updateleader")
end
net.Receive("updateplayersquadmenu", function()
    print("[CLIENT] Received updateplayersquadmenu!")
    local nleader = net.ReadPlayer()
    local nmembers = net.ReadTable()
    local ncolor = net.ReadColor()
    local nsquad = net.ReadString()
    print(tostring(leader) .. " dddd")
    print(members)
    print(ncolor)
    leader = nleader
    members = nmembers
    color = ncolor
    squad = nsquad
    print( squad .. nsquad)
end)
local function ToggleMenu()
    if IsValid(HMenu) then
        HMenu:Remove() -- Menü schließen, wenn es schon existiert
        gui.EnableScreenClicker(false)
        return
    end
    local ply = LocalPlayer()
    HMenu = vgui.Create('DPanel')
    HMenu:SetSize(ScrW(), ScrH())
    HMenu:SetPos(0, 0)
    HMenu:SetMouseInputEnabled(true)
    HMenu:SetKeyboardInputEnabled(true)
    gui.EnableScreenClicker(true)

    HMenu.Paint = function()
        
    end
    local FunkMenu = vgui.Create("DPanel", HMenu)
    FunkMenu:SetSize(500, 200)
    FunkMenu:Center()
    FunkMenu:SetPos(ScrW()-ScrW()/7-197, 115)

    FunkMenu.Paint = function() end -- Kein Hintergrund

    -- Beispiel: Unsichtbarer Button
    for key, value in ipairs(config.funks) do
        --print(value)
    end
    local btn = vgui.Create("DButton", FunkMenu)
    btn:SetSize(210, 50)
    btn:Center()
    btn:SetText("Drück mich!")
    btn:SetColor(Color(255, 255, 255))
    btn.Paint = function(self, w, h) 
        surface.SetDrawColor(34,145,0,191.25)
        surface.DrawOutlinedRect(0,0,w,h,5)
    end -- Kein Hintergrund
    btn.DoClick = function()
        
    end
    local squadsystemmenu = vgui.Create('DPanel', HMenu)
    squadsystemmenu:SetSize(250, 325)
    squadsystemmenu:SetPos(100, 60)
    squadsystemmenu.Paint = function(self, w, h)
        surface.SetDrawColor(0,0,0,253)
        surface.DrawRect(0,0,w,h)
    end
    local SC_icon = vgui.Create('DButton', squadsystemmenu)
    SC_icon:SetSize(230, 50)
    SC_icon:SetText('Change Icon')
    SC_icon:SetColor(Color(255,255,255))
    SC_icon:SetPos(10, 25)
    SC_icon.Paint = function(self, w, h)
        surface.SetDrawColor(35,35,35)
        surface.DrawRect(0,0,w,h)
        if self:IsHovered() then
            surface.SetDrawColor(23,197,0)
            surface.DrawOutlinedRect(0,0,w,h,2)
        else
            surface.SetDrawColor(14,116,0)
            surface.DrawOutlinedRect(0,0,w,h,2)
        end
    end
    SC_icon.DoClick = function()
        SC_icon:Hide()
        
        local SC_icon1 = vgui.Create('DButton', squadsystemmenu)
        SC_icon1:SetSize(230, 37.5)
        SC_icon1:SetText('Squadlead')
        SC_icon1:SetPos(10, 25)
        SC_icon1:SetColor(Color(255,255,255))
        SC_icon1:SetIcon("icon6.png")
        SC_icon1.Paint = function(self, w, h)
            if not IsValid(leader) then
                surface.SetDrawColor(35,35,35)
                surface.DrawRect(0,0,w,h)
                if self:IsHovered() then
                    surface.SetDrawColor(23,197,0)
                    surface.DrawOutlinedRect(0,0,w,h,2)
                else
                    surface.SetDrawColor(14,116,0)
                    surface.DrawOutlinedRect(0,0,w,h,2)
                end
            else
                surface.SetDrawColor(12,12,12)
                surface.DrawRect(0,0,w,h)
                surface.SetDrawColor(5,41,0)
                surface.DrawOutlinedRect(0,0,w,h,2)

            end
        end
        local SC_icon2 = vgui.Create('DButton', squadsystemmenu)
        SC_icon2:SetSize(230, 37.5)
        SC_icon2:SetText('2ND in Command')
        SC_icon2:SetPos(10, 25 + 10 * 1 + 37.5 * 1)
        SC_icon2:SetColor(Color(255,255,255))
        SC_icon2:SetIcon("icon1.png")
        SC_icon2.Paint = function(self, w, h)
            surface.SetDrawColor(35,35,35)
            surface.DrawRect(0,0,w,h)
            if self:IsHovered() then
                surface.SetDrawColor(23,197,0)
                surface.DrawOutlinedRect(0,0,w,h,2)
            else
                surface.SetDrawColor(14,116,0)
                surface.DrawOutlinedRect(0,0,w,h,2)
            end
        end

        local SC_icon4 = vgui.Create('DButton', squadsystemmenu)
        SC_icon4:SetSize(230, 37.5)
        SC_icon4:SetText('VIP')
        SC_icon4:SetPos(10, 25 + 10 * 2 + 37.5 * 2)
        SC_icon4:SetColor(Color(255,255,255))
        SC_icon4:SetIcon("icon4.png")
        SC_icon4.Paint = function(self, w, h)
            surface.SetDrawColor(35,35,35)
            surface.DrawRect(0,0,w,h)
            if self:IsHovered() then
                surface.SetDrawColor(23,197,0)
                surface.DrawOutlinedRect(0,0,w,h,2)
            else
                surface.SetDrawColor(14,116,0)
                surface.DrawOutlinedRect(0,0,w,h,2)
            end
        end
        local SC_icon5 = vgui.Create('DButton', squadsystemmenu)
        SC_icon5:SetSize(230, 37.5)
        SC_icon5:SetText('Techniker')
        SC_icon5:SetPos(10, 25 + 10 * 3 + 37.5 * 3)
        SC_icon5:SetColor(Color(255,255,255))
        SC_icon5:SetIcon("icon5.png")
        SC_icon5.Paint = function(self, w, h)
            surface.SetDrawColor(35,35,35)
            surface.DrawRect(0,0,w,h)
            if self:IsHovered() then
                surface.SetDrawColor(23,197,0)
                surface.DrawOutlinedRect(0,0,w,h,2)
            else
                surface.SetDrawColor(14,116,0)
                surface.DrawOutlinedRect(0,0,w,h,2)
            end
        end
        local SC_icon6 = vgui.Create('DButton', squadsystemmenu)
        SC_icon6:SetSize(230, 37.5)
        SC_icon6:SetText('Medic')
        SC_icon6:SetPos(10, 25 + 10 * 4 + 37.5 * 4)
        SC_icon6:SetColor(Color(255,255,255))
        SC_icon6:SetIcon("icon2.png")
        SC_icon6.Paint = function(self, w, h)
            surface.SetDrawColor(35,35,35)
            surface.DrawRect(0,0,w,h)
            if self:IsHovered() then
                surface.SetDrawColor(23,197,0)
                surface.DrawOutlinedRect(0,0,w,h,2)
            else
                surface.SetDrawColor(14,116,0)
                surface.DrawOutlinedRect(0,0,w,h,2)
            end
        end
        local SC_icon7 = vgui.Create('DButton', squadsystemmenu)
        SC_icon7:SetSize(230, 37.5)
        SC_icon7:SetText('Member')
        SC_icon7:SetPos(10, 25 + 10 * 5 + 37.5 * 5)
        SC_icon7:SetColor(Color(255,255,255))
        SC_icon7:SetIcon("icon7.png")
        SC_icon7.Paint = function(self, w, h)
            surface.SetDrawColor(35,35,35)
            surface.DrawRect(0,0,w,h)
            if self:IsHovered() then
                surface.SetDrawColor(23,197,0)
                surface.DrawOutlinedRect(0,0,w,h,2)
            else
                surface.SetDrawColor(14,116,0)
                surface.DrawOutlinedRect(0,0,w,h,2)
            end
        end
        local function reset()
            SC_icon1:Remove()
            SC_icon2:Remove()
            SC_icon4:Remove()
            SC_icon5:Remove()
            SC_icon6:Remove()
            SC_icon7:Remove()
            SC_icon:Show()
        end
        local function soleader()
            if ply == leader then
            net.Start("updateleader")
            net.WriteBool(false)
            net.WritePlayer(ply)
            net.WriteString(squad)
            net.SendToServer()
            end
        end
        if not IsValid(leader) then
            SC_icon1.DoClick = function()
                print(squad)
                print(ply)
                ply:SetNW2String("SqSy_icon", "icon6.png")
                print(ply)
                net.Start("updateleader")
                net.WriteBool(true)
                net.WritePlayer(ply)
                net.WriteString(squad)
                net.SendToServer()
                reset()
            end
        end
        SC_icon2.DoClick = function()
            ply:SetNW2String("SqSy_icon", "icon1.png")
            soleader()
            reset()
        end
        SC_icon4.DoClick = function()
            ply:SetNW2String("SqSy_icon", "icon4.png")
            soleader()
            reset()
        end
        SC_icon5.DoClick = function()
            ply:SetNW2String("SqSy_icon", "icon5.png")
            soleader()
            reset()
        end
        SC_icon6.DoClick = function()
            ply:SetNW2String("SqSy_icon", "icon2.png")
            soleader()
            reset()
        end
        SC_icon7.DoClick = function()
            ply:SetNW2String("SqSy_icon", "")
            soleader()
            reset()
        end
    end
end

if CLIENT then
    hook.Add("Think", "ToggleMenuOnH", function()
        if input.IsKeyDown(KEY_H) and not FunkMenuPressed then
            FunkMenuPressed = true
            ToggleMenu()
        elseif not input.IsKeyDown(KEY_H) then
            FunkMenuPressed = false
        end
    end)

    hook.Add("HUDPaint", "DrawFunkHUD", function()
        local ply = LocalPlayer()
        if ply:GetNW2Bool("SpaceMarineHUD", false) then
            surface.SetDrawColor(34,145,0,191.25)
            surface.DrawOutlinedRect(ScrW()-ScrW()/7, 100,158,30,5)
            surface.DrawOutlinedRect(ScrW()-ScrW()/7, 100+25,158,30,5)
            surface.DrawOutlinedRect(ScrW()-ScrW()/7-(210-158), 100+50,210,40,5)
        end
    end)
end

