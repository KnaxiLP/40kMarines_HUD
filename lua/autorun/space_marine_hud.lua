
local hudoutline = Material("hud_outline.png")
local scan_crossair = Material("g23.png")
local scan_crossair_inner = Material("path4.png")
hook.Add("HUDPaint", "SpaceMarinePaint", function()
    local ply = LocalPlayer()
    --if ply:GetNWBool("SpaceMarineHUD", false) then
       
        local maxarmor = ply:GetMaxArmor()
        local armor =  ply:Armor()

        local armorbardings = armor/maxarmor
        local startarmorx = 948-274*armorbardings
        --surface.SetDrawColor(96,193,0,191.25)
        --surface.DrawRect(47,startarmorx,70,274*armorbardings)
        --urface.SetDrawColor(34,145,0,191.25)
        --surface.DrawOutlinedRect(47,674,70,274,5)
        surface.SetDrawColor(255,255,255)
        surface.SetMaterial(hudoutline)
        surface.DrawTexturedRect(1920/2 - 1920/2,0,1920,1080)
        surface.DrawRect(100,100,100,100)
        local hp = math.max(1, ply:Health()) -- Keine negativen HP-Werte
        local maxHp = ply:GetMaxHealth()
        local screenW, screenH = ScrW(), ScrH()
        if hp <= ply:GetMaxHealth()*0.25 then
            local alpha = math.abs(math.sin(CurTime() * 5)) * 255 
            surface.SetDrawColor(255,6,0,alpha)
            surface.DrawOutlinedRect(ScrW()/2-100,100,200,40,3)
            surface.SetTextPos(ScrW()/2-50,110)
            surface.SetTextColor(255,6,0,alpha)
            surface.DrawText("Low Vital Points")
            
        end
        local startX = 150
        local startY = screenH - 130
        local length = 300
        local speed = 1 + (100 - hp) * 0.02 -- Herzschlag wird schneller, wenn HP sinkt
        
        -- EKG Muster (normiert auf 0-1 Bereich)
        local ekgPattern = {
        -- Erster Schlag
        {0.0, 0}, {0.025, 2}, {0.05, -4}, {0.075, 8}, {0.1, -6}, {0.125, 3}, {0.15, 0},


        }
        
        -- Zeichnen der EKG-Kurve
            local lastX, lastY = startX, startY
        for i = 1, length do
            local t = ((CurTime() * speed) + i / length) % 1 -- Zyklusberechnung
            local height = 0
    
            -- EKG-Muster interpolieren
            for j = 1, #ekgPattern - 1 do
                local p1, p2 = ekgPattern[j], ekgPattern[j + 1]
                if t >= p1[1] and t <= p2[1] then
                    local progress = (t - p1[1]) / (p2[1] - p1[1])
                    height = Lerp(progress, p1[2], p2[2]) * 3 -- Verstärkung der Linie
                    break
                end
            end
            
            local newX, newY = startX + i, startY - height
            
            surface.SetDrawColor(255-(hp/maxHp)*255, 255*(hp/maxHp), 0)
            
            
            surface.DrawLine(lastX, lastY, newX, newY)
            lastX, lastY = newX, newY
        end
       
        
    --end
end)

















--          ---------------------------------------------------------------------------------------------------------
--          [                                           Rüstungs Anzeige                                            ]
--          ---------------------------------------------------------------------------------------------------------
local playerEntity, silhouetteEntity

local playerEntity = nil
local playerEntity2 = nil
local lastModel = nil

hook.Add("HUDPaint", "DrawHealthAndShieldBasedColoredPlayerModelOnHUD", function()
    local ply = LocalPlayer()
    if not IsValid(ply) then return end  

    local armor = ply:Armor()  
    local maxArmor = ply:GetMaxArmor()  
    local visibilityPercent = math.Clamp((armor / maxArmor), 0, 1)  

    local x, y = 0, 254  
    local width, height = 200 * 2.5, 400 * 2.5  

    local playerModel = ply:GetModel()

    -- Prüfe, ob das Model sich geändert hat oder noch nicht geladen wurde
    if lastModel ~= playerModel then
        if IsValid(playerEntity) then playerEntity:Remove() end
        if IsValid(playerEntity2) then playerEntity2:Remove() end

        playerEntity = ClientsideModel(playerModel)
        playerEntity2 = ClientsideModel(playerModel)

        if not IsValid(playerEntity) or not IsValid(playerEntity2) then
            playerEntity = nil
            playerEntity2 = nil
            return
        end

        playerEntity:SetNoDraw(true)
        playerEntity2:SetNoDraw(true)

        lastModel = playerModel
    end

    if not IsValid(playerEntity) or not IsValid(playerEntity2) then return end  

    cam.Start3D(Vector(100, 30, 50), Angle(0, 180, 0), 70, x, y, width, height)
    render.SuppressEngineLighting(true)

    playerEntity:SetPos(Vector(0, 0, 0))
    playerEntity:SetAngles(Angle(0, RealTime() * 30 % 360, 0))
    playerEntity2:SetPos(Vector(0, 0, 0))
    playerEntity2:SetAngles(Angle(0, RealTime() * 30 % 360, 0))

    local clipHeight = Lerp(visibilityPercent, 0, -72)
    local clipNormal = Vector(0, 0, -1)

    render.EnableClipping(true)
    render.PushCustomClipPlane(clipNormal, clipHeight)

    render.SetBlend(1)
    render.SetColorModulation(0.4, 0.8, 0)  
    render.MaterialOverride(Material("warhammermaterials/holoprojection"))
    playerEntity:DrawModel()
    render.PopCustomClipPlane()
    render.EnableClipping(false)

    render.SetBlend(0.2)
    render.SetColorModulation(0, 0, 0)
    render.MaterialOverride(Material("models/debug/debugwhite"))
    playerEntity2:DrawModel()

    render.MaterialOverride(nil)
    render.SetColorModulation(1, 1, 1)
    render.SetBlend(1)

    cam.End3D()

    render.SuppressEngineLighting(false)
end)

-- Aufräumen, wenn das Script neu geladen wird
hook.Add("ShutDown", "CleanupClientsideModels", function()
    if IsValid(playerEntity) then playerEntity:Remove() end
    if IsValid(playerEntity2) then playerEntity2:Remove() end
end)



















--          ---------------------------------------------------------------------------------------------------------
--          [                                           Scan Anzeige                                                ]
--          ---------------------------------------------------------------------------------------------------------
local scanArea = {
    xMin = ScrW() * 0.25, -- 25% von der linken Seite
    xMax = ScrW() * 0.75, -- 75% von der rechten Seite
    yMin = ScrH() * 0.25, -- 25% von oben
    yMax = ScrH() * 0.75  -- 75% von unten
}

local function IsValidEntity(ent)
    if not IsValid(ent) then return false end
    if ent:IsWeapon() or ent:IsPlayer() then return false end -- Waffen und Spieler ignorieren
    if ent:GetClass() == "gmod_hands" then return false end
    if ent:GetClass() == "physgun_beam" then return false end -- Hände ausblenden
    if ent:GetClass() == "class C_BaseFlex" then return false end -- Hände ausblenden
    return true
end

local function IsEntityInScanArea(ent)
    if not IsValidEntity(ent) then return false end

    local pos = ent:LocalToWorld(ent:OBBCenter()) -- Mittelpunkt des Entities
    local screenPos = pos:ToScreen() -- Weltposition zu Bildschirm umwandeln

    if not screenPos.visible then return false end
    local ply = LocalPlayer()
    if ply:GetPos():DistToSqr(ent:GetPos()) >= 100 * 10000 then return false end
    -- Prüfen, ob das Entity innerhalb des definierten Bereichs liegt
    return screenPos.x >= scanArea.xMin and screenPos.x <= scanArea.xMax
       and screenPos.y >= scanArea.yMin and screenPos.y <= scanArea.yMax
end
local entitiesoutlinetabel = {}
local scanenitys = {}
hook.Add("HUDPaint", "DrawEntitiesInArea", function()
    entitiesoutlinetabel = {}
    local x = 0
    local crossairX, crossairY = 0,0
    for _, ent in ipairs(ents.GetAll()) do
        
        if IsEntityInScanArea(ent) then
            local pos = ent:LocalToWorld(ent:OBBCenter()):ToScreen() -- Aktuelle Position
            crossairX = pos.x
            crossairY = pos.y
            x = x + 1
            draw.SimpleText(ent:GetClass() .. " | " .. x , "DermaDefault", pos.x, pos.y, color_white, TEXT_ALIGN_CENTER)
            DrawFill(ent, pos.x,pos.y)
            local disposition = ent:GetNWBool("SMS_disposition", 0)
            local haloColor

            if disposition == 0 then
                haloColor = Color(255, 251, 0)
            elseif disposition == 1 then
                haloColor = Color(0, 255, 0)
            elseif disposition == 2 then
                haloColor = Color(255, 0, 0)
            end

            
            table.insert(entitiesoutlinetabel,{ent = ent, color = haloColor})
            
        end
    end

    crossairscanner(crossairX, crossairY)
    
    
end)

hook.Add("PreDrawHalos", "DrawEntityOutlinesOnce", function()
    -- Gruppiere alle Entities nach Farbe (damit halo.Add nur pro Farbe aufgerufen wird)
    local colorGroups = {}

    for _, data in ipairs(entitiesoutlinetabel) do
        local ent = data.ent
        local color = data.color
        if IsValid(ent) then
            local key = tostring(color.r) .. "_" .. tostring(color.g) .. "_" .. tostring(color.b)

            colorGroups[key] = colorGroups[key] or {color = color, ents = {}}
            table.insert(colorGroups[key].ents, ent)
        end
    end

    -- Einmal pro Farbgruppe aufrufen
    for _, group in pairs(colorGroups) do
        halo.Add(group.ents, group.color, 1, 2, 10, true, true)
    end
end)


local entModels = {} -- Cache für Models & Health
function DrawFill(ent)
     
    local ply = LocalPlayer()
    if not IsValid(ply) or not IsValid(ent) then return end
    local visibilityPercent
    local health = ent:Health()
    local maxHealth = ent.GetMaxHealth and ent:GetMaxHealth() or 100
    if ent:GetNWFloat("SPaceMarine_ScanP", 0) < 1 then
        visibilityPercent = ent:GetNWFloat("SPaceMarine_ScanP", 0)
        ent:SetNWFloat("SPaceMarine_ScanP", ent:GetNWFloat("SPaceMarine_ScanP", 0)+0.01)
    else
        local visibilityPercent = ent:GetNWFloat("SPaceMarine_ScanP", 0)
        return
    end
    local modelPath = ent:GetModel()
    if not modelPath then return end

    -- Modell-Caching
    entModels = entModels or {}
    entModels[ent] = entModels[ent] or {}
    local data = entModels[ent]

    if data.modelPath ~= modelPath or not IsValid(data.model) or not IsValid(data.model2) then
        if IsValid(data.model) then data.model:Remove() end
        if IsValid(data.model2) then data.model2:Remove() end

        data.model = ClientsideModel(modelPath, RENDERGROUP_OPAQUE)
        data.model2 = ClientsideModel(modelPath, RENDERGROUP_OPAQUE)

        if not IsValid(data.model) or not IsValid(data.model2) then return end

        data.model:SetNoDraw(true)
        data.model2:SetNoDraw(true)
        data.modelPath = modelPath
    end

    local mdl = data.model
    local mdl2 = data.model2

    if not IsValid(mdl) or not IsValid(mdl2) then return end

    -- 3D-Position über dem Entity berechnen
    local entPos = ent:GetPos()
    local entAng = ent:GetAngles()
    local offset = Vector(0, 0, ent:OBBMaxs().z) -- über dem Entity
    local renderPos = entPos

    
    -- Rotation fürs Modell
    local ang = ent:GetAngles()

    mdl:SetPos(renderPos)
    mdl:SetAngles(ang)
    mdl:SetupBones()
    for i = 0, ent:GetBoneCount() - 1 do
        local mat = ent:GetBoneMatrix(i)
        if mat then
            mdl:SetBoneMatrix(i, mat)
        end
    end
    mdl2:SetPos(renderPos)
    mdl2:SetAngles(ang)
    local min, max = mdl:GetModelBounds()
    
    -- Berechnung der Höhe
    local height = max.z - min.z

    
    cam.Start3D(EyePos(), EyeAngles())
        render.SuppressEngineLighting(true)

        local clipHeight = Lerp(1 - visibilityPercent, -1*height , 0)
        local clipNormal = Vector(0, 0, -1)

        render.EnableClipping(true)
        render.PushCustomClipPlane(clipNormal, -1*entPos.z + clipHeight)

        render.SetBlend(1)
        if ent:GetNWBool("SMS_disposition", 0) == 0 then
            render.SetColorModulation(1, 1, 0, 0.486) -- Gelb
        elseif ent:GetNWBool("SMS_disposition", 0) == 1 then
            render.SetColorModulation(0, 1, 0, 0.486) -- Grün
        elseif ent:GetNWBool("SMS_disposition", 0) == 2 then
            render.SetColorModulation(1, 0, 0, 0.486) -- Rot
        end
        
        render.MaterialOverride(Material("warhammermaterials/holoprojection"))
        mdl:DrawModel()
        render.PopCustomClipPlane()
        render.EnableClipping(false)

        render.SetBlend(0.0)
        render.SetColorModulation(0, 0, 0)
        render.MaterialOverride(Material("models/debug/debugwhite"))
        mdl2:DrawModel()

        render.MaterialOverride(nil)
        render.SetColorModulation(1, 1, 1)
        render.SetBlend(1)
        render.SuppressEngineLighting(false)
    cam.End3D()
end

local crossair_x, crossair_y = 0, 0
function crossairscanner(crossairX, crossairY)

    crossairX, crossairY = crossairscanner_move(crossairX,crossairY)
    crossair_x, crossair_y = crossairX, crossairY
    surface.SetDrawColor(255,255,255)
    surface.SetMaterial(scan_crossair)
    surface.DrawTexturedRectRotated(crossairX, crossairY,170,170,0)--0+360*RealTime()*0.1
    surface.SetMaterial(scan_crossair_inner)
    surface.DrawTexturedRectRotated(crossairX, crossairY,54,54,0+360*RealTime()*0.25)
end


function crossairscanner_move(newcrossairX, newcrossairY)
    if newcrossairX == 0 or newcrossairY == 0 then
        
        newcrossairX = 200
        newcrossairY = 500
        return crossair_x+(newcrossairX-crossair_x)*0.1, crossair_y + (newcrossairY-crossair_y) * 0.1
    end
    if math.abs(newcrossairX-crossair_x) < 15 and math.abs(newcrossairY-crossair_y) < 15 then
        
        return newcrossairX, newcrossairY
    end
    return crossair_x+(newcrossairX-crossair_x)*0.1, crossair_y + (newcrossairY-crossair_y) * 0.1
end
























--          ---------------------------------------------------------------------------------------------------------
--          [                                           Context Menu Anzeige                                        ]
--          ---------------------------------------------------------------------------------------------------------




local function AddRowToCategory(panelList, labelText, control)
    local row = vgui.Create("DPanel")
    row:SetTall(24)
    row:Dock(TOP)
    row:DockMargin(0, 0, 0, 2)
    row.Paint = function() end -- Kein Hintergrund

    -- Label
    local label = vgui.Create("DLabel", row)
    label:SetText(labelText)
    label:SetDark(true)
    label:SetWide(150)
    label:Dock(LEFT)
    label:DockMargin(5, 0, 5, 0)
    label:SizeToContentsY()

    -- Control (z. B. Checkbox oder TextEntry)
    control:Dock(FILL)
    control:SetTall(20)
    row:Add(control)

    panelList:AddItem(row)
end

local function OpenCustomEntityMenu(ent)
    if not IsValid(ent) then return end

    local frame = vgui.Create("DFrame")
    frame:SetTitle("Entity [" .. ent:EntIndex() .. "] [" .. ent:GetClass() .. "]")
    frame:SetSize(400, 500)
    frame:Center()
    frame:MakePopup()

    local scroll = vgui.Create("DScrollPanel", frame)
    scroll:Dock(FILL)

    -- Kategorie: AI
    local catAI = vgui.Create("DCollapsibleCategory", scroll)
    catAI:SetLabel("AI")
    catAI:Dock(TOP)

    local listAI = vgui.Create("DPanelList", catAI)
    listAI:EnableHorizontal(false)
    listAI:EnableVerticalScrollbar(false)
    listAI:SetSpacing(0)
    listAI:Dock(TOP)
    catAI:SetContents(listAI)

    -- Zeilen für AI
    local cbEnableTurrets = vgui.Create("DCheckBoxLabel")
    cbEnableTurrets:SetText("")         -- Kein Text, weil links schon ein Label ist
    cbEnableTurrets:SetValue(true)
    cbEnableTurrets:SizeToContents()    -- Passt sich automatisch an
    AddRowToCategory(listAI, "EnableTurrets", cbEnableTurrets)


    local txtAITeam = vgui.Create("DTextEntry")
    txtAITeam:SetText("2")
    AddRowToCategory(listAI, "AITeam", txtAITeam)

    -- Kategorie: Allgemein
    local catGeneral = vgui.Create("DCollapsibleCategory", scroll)
    catGeneral:SetLabel("Allgemein")
    catGeneral:Dock(TOP)

    local listGeneral = vgui.Create("DPanelList", catGeneral)
    listGeneral:EnableHorizontal(false)
    listGeneral:EnableVerticalScrollbar(false)
    listGeneral:SetSpacing(0)
    listGeneral:Dock(TOP)
    catGeneral:SetContents(listGeneral)

    local txtHP = vgui.Create("DTextEntry")
    txtHP:SetText("100000")
    AddRowToCategory(listGeneral, "HP", txtHP)

    local disposition = vgui.Create("DNumSlider")
    disposition:SetMin(0)
    disposition:SetMax(2)
    disposition:SetValue(ent:GetNWFloat("SMS_disposition", -1))
    disposition:SetDecimals(0)
    AddRowToCategory(listGeneral, "Gesinnung", disposition)

    
    local function dispositionApplyValue(value)
        ent:SetNWFloat("SMS_disposition", value)
        --print("Debug 2" .. ent:GetNWFloat("SMS_disposition", -1).. "  " .. value)
    end
    disposition.OnValueChanged = function(self, value)
        local roundedValue = math.Round(value)
        --print(roundedValue)
        self:SetValue(roundedValue) -- Setze den Wert des Schiebereglers
        dispositionApplyValue(value)
        --print("Debug 1")
    end

    local scananimation = vgui.Create("DNumSlider")
    scananimation:SetMin(0)
    scananimation:SetMax(1)
    scananimation:SetValue(ent:GetNWFloat("SPaceMarine_ScanP", -1))
    scananimation:SetDecimals(0)
    AddRowToCategory(listGeneral, "Scan Animation Timer", scananimation)

    
    local function scananimationApplyValue(value)
        ent:SetNWFloat("SPaceMarine_ScanP", value)
        --print("Debug 2" .. ent:GetNWFloat("SMS_disposition", -1).. "  " .. value)
    end
    scananimation.OnValueChanged = function(self, value)
        local roundedValue = math.Round(value)
        --print(roundedValue)
        self:SetValue(roundedValue) -- Setze den Wert des Schiebereglers
        scananimationApplyValue(value)
        --print("Debug 1")
    end
end
properties.Add("custom_scanermenü", {
    MenuLabel = "Space Marine Scan Settings",
    Order = 10010, -- Je höher, desto weiter unten
    MenuIcon = "icon16/cog.png",

    Filter = function(self, ent, ply)
        -- Nur bei bestimmten Entities anzeigen, z.B. wenn Class passt
        return IsValid(ent)
    end,

    Action = function(self, ent)
        -- Menü öffnen
        OpenCustomEntityMenu(ent)
    end,

    Receive = function(self, length, ply)
        -- Netzwerklogik falls du brauchst
    end
})
