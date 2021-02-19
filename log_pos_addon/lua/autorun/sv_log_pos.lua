local LogPos = {}
-- LogPos.AddIsland = {
--     ["IslandNameVar"] = {
--         name = "IslandNameVar",
--         pos = "Vector(LocalPlayer():GetPos())",
--         copyright = "Made by asklop."
--     },
-- }

-- for k,v in pairs(file.Find("logpos/*.json","DATA")) do
--     local result = util.JSONToTable(file.Read("logpos/"..LogPosSelectedIsland))
--     LogPosDestination = result["pos"]
-- end

if SERVER then

    util.AddNetworkString("LogPos_SendTableToServer")
    util.AddNetworkString("LogPos_DeleteAnIsland")
    util.AddNetworkString("LogPos_DeleteAllIslands")
    util.AddNetworkString("LogPos_GetIslands")
    util.AddNetworkString("LogPos_SendIslands")
    util.AddNetworkString("LogPos_GetIslandPos")
    util.AddNetworkString("LogPos_SendIslandPos")

    if not (file.Exists("logpos/logpos_config.txt", "DATA")) then
        file.CreateDir("logpos")
    end

    net.Receive("LogPos_DeleteAnIsland", function()

        local IslandNameVar = net.ReadString()
        file.Delete("logpos/" .. IslandNameVar .. ".json")

    end)

    net.Receive("LogPos_DeleteAllIslands", function()
        for k,v in pairs(file.Find("logpos/*.json","DATA")) do
            file.Delete("logpos/" .. v)
        end
    end)

    net.Receive("LogPos_SendTableToServer", function(len,ply)
        local TableReceived = net.ReadTable()
        local IslandNameReceived = net.ReadString()
        file.Write("logpos/".. IslandNameReceived ..".json", util.TableToJSON(TableReceived, true))
    end )

    local LogPosDestinationTbl
    local LogPosSelectedIslandPos
    local LogPosSelectedIsland
    local LogPosSelectedIslandText

    net.Receive("LogPos_GetIslands", function(len, ply)
        for k,v in pairs(file.Find("logpos/*.json","DATA")) do
            LogPosDestinationTbl = {
                [k] = v
            }
            net.Start("LogPos_SendIslands")
                net.WriteTable(LogPosDestinationTbl)
            net.Send(ply)
        end
    end)
    
    net.Receive("LogPos_GetIslandPos", function (len,ply)

        local LogPosSelectedIslandPos = net.ReadString()
        local result = util.JSONToTable(file.Read("logpos/"..LogPosSelectedIslandPos))
        LogPosSelectedIsland = result["pos"]
        LogPosSelectedIslandText = result["name"]

        net.Start("LogPos_SendIslandPos")
            net.WriteVector(LogPosSelectedIsland)
            net.WriteString(LogPosSelectedIslandText)
        net.Send(ply)
    end)

end