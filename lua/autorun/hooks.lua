
local function ToggleMenu()
    if IsValid(FunkMenu) then
        FunkMenu:Remove() -- Menü schließen, wenn es schon existiert
        gui.EnableScreenClicker(false)
        return
    end

    FunkMenu = vgui.Create("DPanel")
    FunkMenu:SetSize(500, 200)
    FunkMenu:Center()
    FunkMenu:SetPos(ScrW()-ScrW()/7-197, 115)
    FunkMenu:SetMouseInputEnabled(true)
    FunkMenu:SetKeyboardInputEnabled(true)
    gui.EnableScreenClicker(true)
    FunkMenu.Paint = function() end -- Kein Hintergrund

    -- Beispiel: Unsichtbarer Button
    for key, value in ipairs(config.funks) do
        print(value)
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
        if ply:GetNWBool("SpaceMarineHUD", false) then
            surface.SetDrawColor(34,145,0,191.25)
            surface.DrawOutlinedRect(ScrW()-ScrW()/7, 100,158,30,5)
            surface.DrawOutlinedRect(ScrW()-ScrW()/7, 100+25,158,30,5)
            surface.DrawOutlinedRect(ScrW()-ScrW()/7-(210-158), 100+50,210,40,5)
        end
    end)
end