local squads = {}

--[[
squads array -> squad array -> spieler 
spieler change color -> squad array -> alle squad spieler -> color change
]]
if SERVER then
util.AddNetworkString("updateplayersquadhud")
util.AddNetworkString("updateplayersquadmenu")
end

function updateplayersquadhud(ply, members, color, squadname, sendto)
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
end

function joinsquad(ply, cmd, args)
    local squadname = args[1]
    local ncolor = args[2]

    if not squads[squadname] then
        squads[squadname] = {
            leader = nil,
            members = {ply},
            color = Color(247, 247, 247)
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
            squads[squadname].leader,
            squads[squadname].members,
            squads[squadname].color,
            squadname,
            member
        )
    end
end

if SERVER then
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
            squads[squadname].leader,
            squads[squadname].members,
            squads[squadname].color,
            squadname,
            ply
        )
        for _, member in ipairs(squads[squadname].members) do
            updateplayersquadhud(
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
