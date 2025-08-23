local leader
local members
local color
local squad
local FunkConfig = include("config/config.lua") 

-- Aktive Auswahl-Tabelle
local AktiveFunkKanaele = {
    F1 = nil,
    F2 = nil,
    F3 = nil
}
local UnmutedFunkKanaele = {}

-- Funktion bei Aktivierung
local function OnFunkAktiviert(funkName, kategorie)
    
    local ply = LocalPlayer()
    ply.aktivefunkkanaele = ply.aktivefunkkanaele or {nil, nil, nil}
    AktiveFunkKanaele[kategorie] = funkName
    print("Aktiviert: [" .. kategorie .. "] = " .. funkName)
    local index
    if kategorie == "F1" then
        index = 1
    elseif kategorie == "F2" then
        index = 2
    elseif kategorie == "F3" then
        index = 3
    end
    
    print(ply.aktivefunkkanaele[index] == funkName)
    print(ply.aktivefunkkanaele[index])
    print(funkName)
    if ply.aktivefunkkanaele[index] == funkName then
        ply.aktivefunkkanaele[index] = "N/A"
    else
        ply.aktivefunkkanaele[index] = funkName
        print(ply.aktivefunkkanaele[index])
    end
    if index == 1 then
        if ply.aktivefunkkanaele[index] == "N/A" then
            for key, value in pairs(FunkConfig.Kanaele) do
                if key == funkName then
                    net.Start("leavesquad_player")
                        net.WriteString(funkName)
                        net.WriteString(value.Company)            
                    net.SendToServer()
                end 
            end
        else
            for key, value in pairs(FunkConfig.Kanaele) do
                if key == funkName then
                    net.Start("joinsquad_player")
                        net.WriteString(funkName)
                        net.WriteString(value.Company)            
                    net.SendToServer()
                end 
            end
        end
        
    end
    -- Optional: An den Server senden
    -- net.Start("FunkSystem_SetAktiv")
    -- net.WriteString(kategorie)
    -- net.WriteString(funkName)
    -- net.SendToServer()
end



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

local function funkmenue(Hmenu)
    local checkboxGroups = {
        F1 = {},
        F2 = {},
        F3 = {}
    }
    local funkmenupanal = vgui.Create('DPanel', Hmenu)
    funkmenupanal:SetSize(250, 400)
    funkmenupanal:SetPos(ScrW()-400, 130)
    funkmenupanal.Paint = function(self, w, h)
        surface.SetDrawColor(0,0,0,253)
        surface.DrawRect(0,0,w,h)
    end
    xc = 5
    yc = 5
    wc = 240
    hc = 50
    for key, value in pairs(FunkConfig.Kanaele) do
        local funk = vgui.Create('DPanel', funkmenupanal)
        funk:SetSize(wc, hc)
        funk:SetPos(xc, yc)
        yc = yc + hc + 5
        funk.Paint = function(self, w, h)
            surface.SetDrawColor(35,35,35)
            surface.DrawRect(0,0,w,h)
            surface.SetDrawColor(14,116,0)
            surface.DrawOutlinedRect(0, 0, w, h,2)
            draw.SimpleText(key, "HudSelectionText", 5, 10, Color(255,255,255),TEXT_ALIGN_LEFT,TEXT_ALIGN_CENTER)
        end

        local function CreateFunkCheckbox(category, offsetX)
            local cb = vgui.Create("DCheckBox", funk)
            cb:SetPos(offsetX, 23)
            cb:SetSize(25, 20)
            cb.FunkName = key
            cb.Kategorie = category
            cb.Paint = function(self, w, h)
                if not self:GetChecked() then
                    surface.SetDrawColor(255,255,255)
                    surface.DrawOutlinedRect(0,0,w,h,2)
                else
                    surface.SetDrawColor(23,197,0)
                    surface.DrawOutlinedRect(0,0,w,h,2)
                end
                draw.SimpleText(category, "HudSelectionText", w/2,h/2,Color(255,255,255), TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
            end
            -- Checkbox-Verhalten
            cb.OnChange = function(s, val)
                
                if val then
                    for _, other in pairs(checkboxGroups[category]) do
                        if other ~= s then
                            other:SetChecked(false)
                        end
                    end
    
                    -- Aktive speichern
                    OnFunkAktiviert(s.FunkName, s.Kategorie)
                    local ply = LocalPlayer()
                    
                else
                    OnFunkAktiviert(s.FunkName, s.Kategorie)
                end
            end
            if AktiveFunkKanaele[category] == key then
                cb:SetChecked(true)
            end
            -- Zur Gruppentabelle hinzufügen
            table.insert(checkboxGroups[category], cb)
        end
    
        -- Checkboxen für F1, F2, F3 (du kannst die X-Positionen anpassen)
        CreateFunkCheckbox("F1", 100)
        CreateFunkCheckbox("F2", 130)
        CreateFunkCheckbox("F3", 160)
        
        local mutebox = vgui.Create('DCheckBox', funk)
        mutebox:SetPos(190, 23)
        mutebox:SetSize(40,20)
        mutebox.Paint = function(self, w, h)
            if not self:GetChecked() then
                surface.SetDrawColor(23,197,0)
                surface.DrawOutlinedRect(0,0,w,h,2)

            else
                surface.SetDrawColor(255,255,255)
                surface.DrawOutlinedRect(0,0,w,h,2)
            end
            draw.SimpleText("Mute", "HudSelectionText", w/2,h/2,Color(255,255,255), TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
        end
        mutebox.OnChange = function(s, val)
            if val then
                -- Duplikate vermeiden
                local found = false
                for _, v in ipairs(UnmutedFunkKanaele) do
                    if v == key then found = true break end
                end
                if not found then
                    table.insert(UnmutedFunkKanaele, key)
                end
            else
                -- Entferne alle Vorkommen
                for i = #UnmutedFunkKanaele, 1, -1 do
                    if UnmutedFunkKanaele[i] == key then
                        table.remove(UnmutedFunkKanaele, i)
                    end
                end
            end
        end
        for k, v in pairs(UnmutedFunkKanaele) do
            if v == key then
                mutebox:SetChecked(true)
            end
        end
    end
 
end

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
    funkmenue(HMenu)
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
end

