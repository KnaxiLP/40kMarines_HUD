local squads = {}

--[[
squads array -> squad array -> spieler 
spieler change color -> squad array -> alle squad spieler -> color change
]]
if SERVER then
util.AddNetworkString("updateplayersquadhud")
util.AddNetworkString("updateplayersquadmenu")
util.AddNetworkString("joinsquad_player")
util.AddNetworkString("leavesquad_player")
end

function updateplayersquadhud(company, ply, members, color, squadname, sendto)
    net.Start("updateplayersquadhud")

    if squads[squadname] and IsValid(squads[squadname].leader) then
        net.WritePlayer(squads[squadname].leader)
    else
        net.WritePlayer(NULL)
    end

    -- Vorsichtshalber prüfen
    net.WriteTable(members or {})
    net.WriteColor(color or Color(255,255,255))
    net.WriteString(squadname or "Unknown")
    
    net.Send(sendto)
    net.Start("updateplayersquadmenu")

    if squads[squadname] and IsValid(squads[squadname].leader) then
        net.WritePlayer(squads[squadname].leader)
    else
        net.WritePlayer(NULL)
    end

    -- Vorsichtshalber prüfen
    net.WriteTable(members or {})
    net.WriteColor(color or Color(255,255,255))
    net.WriteString(squadname or "Unknown")
    
    net.Send(sendto)
    print("Debug .. " .. company)
    if IsValid(company) or company == nil then
    -- Hilfe hier hier wierd irgendwie die folgenden prints net ausgelöst
        for k, v in pairs(squads) do
            companycc = company .. "_cc"
            print(companycc ..   k)
            if k == companycc then
                
            end
        end
    end
end

function joinsquad(ply, nsquadname, nnncompany)
    local squadname = nsquadname
    local ncompany = nnncompany

    if not squads[squadname] then
        squads[squadname] = {
            company = ncompany,
            leader = nil,
            members = {ply},
            color = Color(255, 255, 255)
        }
    else
        local alreadyMember = false
        for _, member in ipairs(squads[squadname].members) do
            if member == ply then
                alreadyMember = true
                break
            end
        end
        if not alreadyMember then
            table.insert(squads[squadname].members, ply)
        end
    end

    for _, member in ipairs(squads[squadname].members) do 
        updateplayersquadhud(
            squads[squadname].company,
            squads[squadname].leader,
            squads[squadname].members,
            squads[squadname].color,
            squadname,
            member
        )
    end
end

local function leavesquad(ply,  nsquadname, nnncompany )
    for i, member in ipairs(squads[nsquadname].members) do
        if member == ply then
            PrintTable(squads[nsquadname].members)
            print(i)
            table.remove(squads[nsquadname].members, i)
            updateplayersquadhud(
                nil,
                nil,
                {},
                nil,
                nil,
                ply
            )
        end 
    end
    for _, member in ipairs(squads[nsquadname].members) do 
        updateplayersquadhud(
            squads[nsquadname].company,
            squads[nsquadname].leader,
            squads[nsquadname].members,
            squads[nsquadname].color,
            nsquadname,
            member
        )
    end
end

if SERVER then
    net.Receive("leavesquad_player", function(len, ply)
        local squadname = net.ReadString()
        local company = net.ReadString()
        leavesquad(ply, squadname, company)
    end)
    net.Receive("joinsquad_player", function(len, ply)
        local squadname = net.ReadString()
        local company = net.ReadString()
        joinsquad(ply, squadname, company)
    end)

    net.Receive("updateleader", function()
        local bool = net.ReadBool()
        local ply = net.ReadPlayer()
        local squadname = net.ReadString()
        print(ply)
        if bool then
            squads[squadname].leader = ply
            for i, member in ipairs(squads[squadname].members) do
                print(member)
                if member == ply then
                    print(tostring(member) .. " 3")
                    table.remove(squads[squadname].members, i)
                end
            end
        else
            squads[squadname].leader = nil
            table.insert(squads[squadname].members, ply)
        end
        updateplayersquadhud(
            squads[squadname].company,
            squads[squadname].leader,
            squads[squadname].members,
            squads[squadname].color,
            squadname,
            ply
        )
        for _, member in ipairs(squads[squadname].members) do
            updateplayersquadhud(
                squads[squadname].company,
                squads[squadname].leader,
                squads[squadname].members,
                squads[squadname].color,
                squadname,
                member
            )
            
        end
    end)
end
concommand.Add("joinsquad",  joinsquad)
