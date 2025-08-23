if SERVER then
util.AddNetworkString("updateaktivfunkTS")
util.AddNetworkString("updateaktivfunkBC")
end
if SERVER then
    net.Receive("updateaktivfunkTS", function()
        local ply = net.ReadPlayer()
        local funk = net.ReadInt(4)
        local color = net.ReadColor()
        net.Start("updateaktivfunkBC")
        net.WriteInt(funk,4)
        net.WriteColor(color)
        net.Send(ply)
    end)
end
if CLIENT then
function updatecolor(funk, color, ply)
    net.Start("updateaktivfunkTS")
    net.WritePlayer(ply)
    net.WriteInt(funk, 4)
    net.WriteColor(color)
    -- das send macht fehler ich will es zum HUD code rübdersenden
    net.SendToServer()

end
function switchfromaktivfunks(ply, switchto)
    if switchto == "f1" then
        if ply.aktivefunk == 1 then
            ply.aktivefunk = 0
            updatecolor(1, Color(255,255,255), ply)
        else
            updatecolor(2, Color(255,255,255), ply)
            updatecolor(3, Color(255,255,255), ply)
            ply.aktivefunk = 1
            updatecolor(1, Color(0,255,0), ply)
        end
    elseif switchto == "f2" then
        if ply.aktivefunk == 2 then
            ply.aktivefunk = 0
            updatecolor(2, Color(255,255,255), ply)
        else
            updatecolor(1, Color(255,255,255), ply)
            updatecolor(3, Color(255,255,255), ply)
            ply.aktivefunk = 2
            updatecolor(2, Color(0,255,0), ply)
        end
    elseif switchto == "f3" then
        if ply.aktivefunk == 3 then
            ply.aktivefunk = 0
            updatecolor(3, Color(255,255,255), ply)
        else
            updatecolor(1, Color(255,255,255), ply)
            updatecolor(2, Color(255,255,255), ply)
            ply.aktivefunk = 3
            updatecolor(3, Color(0,255,0), ply)
        end
    end
end
end





--[[

if CLIENT then
    hook.Add("PlayerButtonDown", "Funksystembuttons", function()
        local ply = LocalPlayer()
        if input.IsKeyDown(KEY_F1) then
            print("Debugg")
            switchfromaktivfunks(ply,"f1")
        elseif input.IsKeyDown(KEY_F2) then
            switchfromaktivfunks(ply,"f2")
        elseif input.IsKeyDown(KEY_F3) then
            switchfromaktivfunks(ply,"f3")
        end
    end)
end ]]
if CLIENT then
    local keyPressed = {
        f1 = false,
        f2 = false,
        f3 = false
    }

    hook.Add("Think", "ToggleFunkKeys", function()
        local ply = LocalPlayer()

        -- Taste F1
        if input.IsKeyDown(KEY_F1) then
            if not keyPressed.f1 then
                switchfromaktivfunks(ply, "f1")
                keyPressed.f1 = true
            end
        else
            keyPressed.f1 = false
        end

        -- Taste F2
        if input.IsKeyDown(KEY_F2) then
            if not keyPressed.f2 then
                switchfromaktivfunks(ply, "f2")
                keyPressed.f2 = true
            end
        else
            keyPressed.f2 = false
        end

        -- Taste F3
        if input.IsKeyDown(KEY_F3) then
            if not keyPressed.f3 then
                switchfromaktivfunks(ply, "f3")
                keyPressed.f3 = true
            end
        else
            keyPressed.f3 = false
        end
    end)
end
