if CLIENT then
    include("autorun/log_pos_config.lua")

    local function W(s)
        return ScrW() / 1920 * s
    end

    local function H(s)
        return ScrH() / 1080 * s
    end

    local LogPosVector
    local LogPosDestination
    local LogPosSelectedIsland
    local LogPosSelectedIslandPos
    local LogPosDestinationTbl = LogPosDestinationTbl or {}
    local LogPosDestinationReceived
    local LogPos = LogPos or {}
    local LogPosMain = Material("log_pos/LogPos_Main.png", "smooth clamp")
    local LogPosNeedle = Material("log_pos/LogPos_Needle.png", "smooth clamp")
    local HudShouldDraw = false
    local LogPosW
    local LogPosH
    local LogPosSizeX, LogPosSizeY = tonumber(LogPos.Config.LogposSize)
    local IslandNameVar
    local NumThink = 0

    sound.Add( {
        name = "DestinationReached",
        channel = CHAN_STATIC,
        volume = 0.9,
        level = 80,
        pitch = {95, 110},
        sound = "log_pos/LogPos_Destination.wav"
    } )

    hook.Add("PlayerButtonDown", "LogPos_ButtonToDrawHUD", function(ply, button)
        if IsFirstTimePredicted() then
            if (button == LogPos.Config.Key) then
                if LogPos.Config.LogposPosition == 1 then
                    LogPosW, LogPosH = W(100), H(50)
                elseif LogPos.Config.LogposPosition == 2 then
                    LogPosW, LogPosH = W(100), H(750)
                elseif LogPos.Config.LogposPosition == 3 then
                    LogPosW, LogPosH = W(1550), H(50)
                elseif LogPos.Config.LogposPosition == 4 then
                    LogPosW, LogPosH = W(1550), H(750)
                end

                if HudShouldDraw == false then
                    HudShouldDraw = true

                    hook.Add("HUDPaint", "LogPos_DrawHUD", function()
                        surface.SetDrawColor(255, 255, 255)
                        surface.SetMaterial(LogPosMain)
                        surface.DrawTexturedRect(LogPosW, LogPosH, W(LogPos.Config.LogposSize), H(LogPos.Config.LogposSize))
                        surface.SetMaterial(LogPosNeedle)
                        surface.DrawTexturedRectRotated(LogPosW + W(LogPos.Config.LogposSize) / 2, LogPosH + H(LogPos.Config.LogposSize) / 2, W(LogPos.Config.LogposSize) / 7.2, H(LogPos.Config.LogposSize) / 2, LogPosVector.y )
                    end)
                elseif HudShouldDraw == true then
                    HudShouldDraw = false
                    hook.Remove("HUDPaint", "LogPos_DrawHUD")
                end
            end
        end
    end)

    if LogPos.Config.Notifications == true then
        timer.Create("LogPos_Notifications", LogPos.Config.NotifDelay, 0, function()
            notification.AddLegacy("Press " .. input.GetKeyName(LogPos.Config.Key) .. " to display your LogPos.", 3, 5)
            notification.AddLegacy("Type 'open_logpos_menu' in your console to open the LogPos menu.", 3, 5)
        end)
    else
        timer.Remove("LogPos_Notifications")
    end

    
    function LogPos.Notification(sentence, type, delay)
        notification.AddLegacy( sentence, type, delay )
    end

    function LogPos.DestinationReached()

        local NotifyPanel = vgui.Create("DNotify")
        NotifyPanel:SetPos((ScrW() / 3.2), H(150))
        NotifyPanel:SetSize(W(600), H(200))

        local Panel = vgui.Create("DPanel", NotifyPanel)
        Panel:Dock(FILL)
        Panel.Paint = function(self,w,h)
            draw.RoundedBox(15, W(150), H(87), w - 150, h - 80, Color(40, 39, 39))
            draw.SimpleText("Welcome to :", "Trebuchet24", w - 260, h - 80, Color(255, 255, 255))
            draw.SimpleText(LogPosSelectedIsland, "DermaLarge", w - 200, h - 50, Color(255, 255, 255), TEXT_ALIGN_CENTER)

            surface.SetDrawColor(255, 255, 255)
            surface.SetMaterial(Material("log_pos/mugiwara.png"))
            surface.DrawTexturedRect(W(96), H(25), W(150), H(150))

        end

        LocalPlayer():EmitSound("DestinationReached")

        NotifyPanel:AddItem(Panel)
    end

    LogPos.AdminButs = {
        [1] = {
            name = "Add an island",
            use = function()
                -- Define the table for saving an island :
                LogPos.TableToSend = {
                    name = IslandNameVar,
                    pos = Vector(LocalPlayer():GetPos()),
                    copyright = "Made by asklop."
                }
                -- Send informations to the server :
                net.Start("LogPos_SendTableToServer")
                    net.WriteTable(LogPos.TableToSend)
                    net.WriteString(IslandNameVar)
                net.SendToServer()

                LogPos.Notification("Island added to the data.", 0, 4)
            end
        },
        [2] = {
            name = "Remove an island",
            use = function() 

                net.Start("LogPos_DeleteAnIsland")
                    net.WriteString(IslandNameVar)
                net.SendToServer()

                LogPos.Notification("Island removed from data.", 0, 4)
            end
        },
        [3] = {
            name = "Remove all islands",
            use = function() 
                net.Start("LogPos_DeleteAllIslands")
                net.SendToServer()

                LogPos.Notification("Islands removed from data.", 0, 4)
            end
        },
        [4] = {
            name = "Tutorial",
            use = function() end
        }
    }

    
    function LogPos.RequestTbl()
        net.Start("LogPos_GetIslands")
        net.SendToServer()

        net.Receive("LogPos_SendIslands", function()
            LogPosDestinationReceived = net.ReadTable()
            for k,v in pairs(LogPosDestinationReceived) do
                table.insert(LogPosDestinationTbl, v)
            end
        end )

    end

    function LogPos.AdminPanel()

        LogPos.RequestTbl()

        timer.Simple(2, function()

            if table.HasValue(LogPos.Config.StaffGroups, LocalPlayer():GetUserGroup()) then
                local frame = vgui.Create("DFrame")
                frame:SetSize(W(750), H(500))
                frame:Center()
                frame:SetTitle("")
                frame:ShowCloseButton(false)
                frame:MakePopup()

                frame.Paint = function(self, w, h)
                    draw.RoundedBox(18, 0, 0, w, h - W(444), Color(75, 73, 73))
                    draw.SimpleText("LogPos Admin Menu:", "DermaLarge", W(15), H(9), Color(255, 255, 255))
                end

                local closebutton = vgui.Create("DButton", frame)
                closebutton:SetSize(W(56), H(56))
                closebutton:SetPos(W(694), H(0))
                closebutton:SetTextColor(Color(255, 255, 255))
                closebutton:SetFont("DermaLarge")
                closebutton:SetText("X")

                closebutton.Paint = function(self, w, h)
                    draw.RoundedBox(18, 0, 0, w, h, Color(75, 73, 73))

                    if (closebutton:IsHovered()) then
                        draw.RoundedBox(18, 0, 0, w, h, Color(40, 39, 39))
                    end
                end

                closebutton.DoClick = function()
                    frame:Remove()
                    if !(table.IsEmpty(LogPosDestinationTbl)) then
                        table.Empty(LogPosDestinationTbl)
                    end
                end

                local panel = vgui.Create("DPanel", frame)
                panel:SetPos(W(0), H(66))
                panel:SetSize(frame:GetWide(), H(400))
                panel:SlideDown(1)

                panel.Paint = function(self, w, h)
                    draw.RoundedBox(18, 0, 0, w, h, Color(40, 39, 39))
                    draw.RoundedBox(5, W(215), H(77), w - W(749), h - W(150), Color(75, 73, 73))
                end

                local IslandEntry = vgui.Create("DTextEntry", panel)
                IslandEntry:SetSize(W(415), H(75))
                IslandEntry:SetPos(W(275), H(75))
                IslandEntry:SetTextColor(color_white)
                IslandEntry:SetFont("DermaLarge")
                IslandEntry:SetPlaceholderText("The name of the island.")
                IslandEntry:SetUpdateOnType(true)

                IslandEntry.Paint = function(self, w, h)
                    draw.RoundedBox(8, 0, 0, w, h, Color(75, 73, 73))
                    self:DrawTextEntryText(Color(255, 255, 255), Color(255, 255, 255), Color(255, 255, 255))
                end

                IslandEntry.OnValueChange = function(self, value)
                    IslandNameVar = self:GetValue()
                end

                for k, v in pairs(LogPos.AdminButs) do
                    local but = vgui.Create("DButton", panel)
                    but:SetPos(W(29), H(-7) + (W(70) * k))
                    but:SetSize(W(160), H(65))
                    but:SetFont("HudHintTextLarge")
                    but:SetTextColor(color_white)
                    but:SetText(v.name)

                    but.Paint = function(self, w, h)
                        draw.RoundedBox(5, 0, 0, w, h, Color(75, 73, 73))

                        if (but:IsHovered()) then
                            draw.RoundedBox(5, 0, 0, w, h, Color(65, 63, 63))
                        end
                    end

                    but.DoClick = v.use
                end

                local IslandsPanel = vgui.Create("DPanel",panel)
                IslandsPanel:SetPos(W(275), H(160))
                IslandsPanel:SetSize(W(415), H(185))
                IslandsPanel.Paint = function() end

                local Scroll = vgui.Create("DScrollPanel", IslandsPanel)
                Scroll:Dock(FILL)

                local sbar = Scroll:GetVBar()
                function sbar:Paint(w, h)
                    draw.RoundedBox(0, 0, 0, w - 10, h, Color(0, 0, 0, 100))
                end
                function sbar.btnUp:Paint(w, h)
                    draw.RoundedBox(31, 0, 0, w - 10, h, Color(75, 73, 73))
                end
                function sbar.btnDown:Paint(w, h)
                    draw.RoundedBox(31, 0, 0, w - 10, h, Color(75, 73, 73))
                end
                function sbar.btnGrip:Paint(w, h)
                    draw.RoundedBox(50, 0, 0, w - 10, h, Color(75, 73, 73))
                end

                local IslandsList = vgui.Create("DIconLayout", Scroll)
                IslandsList:Dock(FILL)
                IslandsList:SetSpaceX(5)
                IslandsList:SetSpaceY(5)

                for k,v in pairs(LogPosDestinationTbl) do
                    local IslandsButtons = IslandsList:Add("DButton")
                    IslandsButtons:SetSize(W(125), H(50))
                    IslandsButtons:SetTextColor(color_white)
                    IslandsButtons:SetFont("CloseCaption_Normal")
                    IslandsButtons:SetText(string.Implode("", string.Split(v, ".json")))
                    IslandsButtons.Paint = function(self,w,h)
                        draw.RoundedBox(5, 0, 0, w, h, Color(75, 73, 73))
                    end
                    IslandsButtons.DoClick = function ()
                        IslandNameVar = string.Implode("", string.Split(v, ".json"))
                    end

                end

            else
                LocalPlayer():ChatPrint(LogPos.Config.CantOpenPanel)
            end
        end )
    end

    net.Receive("LogPos_SendIslandPos", function ()
        LogPosDestination = net.ReadVector()
        LogPosSelectedIsland = net.ReadString()
    end)

    LogPos.PlayerBut = {
        [1] = {
            name = "Add to LogPos",
            use = function() 
                net.Start("LogPos_GetIslandPos")
                    net.WriteString(LogPosSelectedIslandPos)
                net.SendToServer()

                if LogPos.Config.DestinationMessage == true then
                    hook.Add("Think", "LogPos_ArriveToDestination", function()
                        for k, v in pairs(ents.FindInSphere(LogPosDestination, LogPos.Config.DestinationRadius)) do 
                            if v == LocalPlayer() then
                                hook.Remove("Think", "LogPos_ArriveToDestination")
                                LogPos.DestinationReached()
                            end
                        end
                    end )
                end
                LogPos.Notification("New destination added to the LogPos.", 0, 4)
            end
        },
        [2] = {
            name = "Remove from LogPos",
            use = function() 
                LogPosDestination = Vector(0, 0, 0)
                LogPos.Notification("Destination removed from the LogPos.", 0, 4)
                hook.Remove("Think", "LogPos_ArriveToDestination")
            end
        },
        [3] = {
            name = "Tutorial",
            use = function() end
        }
    }

    function LogPos.PlayerPanel()

        LogPos.RequestTbl()

        timer.Simple(2, function()

            local frame = vgui.Create("DFrame")
            frame:SetSize(W(750), H(500))
            frame:Center()
            frame:SetTitle("")
            frame:ShowCloseButton(false)
            frame:MakePopup()

            frame.Paint = function(self, w, h)
                draw.RoundedBox(18, 0, 0, w, h - W(444), Color(75, 73, 73))
                draw.SimpleText("LogPos Player Menu:", "DermaLarge", W(15), H(9), Color(255, 255, 255))
            end

            local closebutton = vgui.Create("DButton", frame)
            closebutton:SetSize(W(56), H(56))
            closebutton:SetPos(W(694), H(0))
            closebutton:SetTextColor(Color(255, 255, 255))
            closebutton:SetFont("DermaLarge")
            closebutton:SetText("X")

            closebutton.Paint = function(self, w, h)
                draw.RoundedBox(18, 0, 0, w, h, Color(75, 73, 73))

                if (closebutton:IsHovered()) then
                    draw.RoundedBox(18, 0, 0, w, h, Color(40, 39, 39))
                end
            end

            closebutton.DoClick = function()
                frame:Remove()
                if !(table.IsEmpty(LogPosDestinationTbl)) then
                    table.Empty(LogPosDestinationTbl)
                end
            end

            local panel = vgui.Create("DPanel", frame)
            panel:SetPos(W(0), H(66))
            panel:SetSize(frame:GetWide(), H(400))
            panel:SlideDown(1)

            panel.Paint = function(self, w, h)
                draw.RoundedBox(18, 0, 0, w, h, Color(40, 39, 39))
                draw.RoundedBox(5, W(215), H(77), w - W(749), h - W(150), Color(75, 73, 73))
            end

            for k, v in pairs(LogPos.PlayerBut) do
                local but = vgui.Create("DButton", panel)
                but:SetPos(W(29), H(27) + (W(70) * k))
                but:SetSize(W(160), H(65))
                but:SetFont("HudHintTextLarge")
                but:SetTextColor(color_white)
                but:SetText(v.name)

                but.Paint = function(self, w, h)
                    draw.RoundedBox(5, 0, 0, w, h, Color(75, 73, 73))

                    if (but:IsHovered()) then
                        draw.RoundedBox(5, 0, 0, w, h, Color(65, 63, 63))
                    end
                end

                but.DoClick = v.use
            end

            local IslandsPanel = vgui.Create("DPanel",panel)
            IslandsPanel:SetPos(W(275), H(75))
            IslandsPanel:SetSize(W(415), H(250))
            IslandsPanel.Paint = function() end

            local Scroll = vgui.Create("DScrollPanel", IslandsPanel)
            Scroll:Dock(FILL)

            local sbar = Scroll:GetVBar()
            function sbar:Paint(w, h)
                draw.RoundedBox(0, 0, 0, w - 10, h, Color(0, 0, 0, 100))
            end
            function sbar.btnUp:Paint(w, h)
                draw.RoundedBox(31, 0, 0, w - 10, h, Color(75, 73, 73))
            end
            function sbar.btnDown:Paint(w, h)
                draw.RoundedBox(31, 0, 0, w - 10, h, Color(75, 73, 73))
            end
            function sbar.btnGrip:Paint(w, h)
                draw.RoundedBox(50, 0, 0, w - 10, h, Color(75, 73, 73))
            end

            local IslandsList = vgui.Create("DIconLayout", Scroll)
            IslandsList:Dock(FILL)
            IslandsList:SetSpaceX(5)
            IslandsList:SetSpaceY(5)

            for k,v in pairs(LogPosDestinationTbl) do
                local IslandsButtons = IslandsList:Add("DButton")
                IslandsButtons:SetSize(W(125), H(50))
                IslandsButtons:SetTextColor(color_white)
                IslandsButtons:SetFont("CloseCaption_Normal")
                IslandsButtons:SetText(string.Implode("", string.Split(v, ".json")))
                IslandsButtons.Paint = function(self,w,h)
                    draw.RoundedBox(5, 0, 0, w, h, Color(75, 73, 73))

                    if (IslandsButtons:IsHovered()) then
                        draw.RoundedBox(5, 0, 0, w, h, Color(65, 63, 63))
                    end
                end
                IslandsButtons.DoClick = function()
                    LogPosSelectedIslandPos = v
                end

            end
        end )
    end

    if LogPosDestination == nil then
        LogPosDestination = Vector(0, 0, 0)
    end

    hook.Add("Think", "LogPos_UpdateLogPosVector", function()
        LogPosVector = (LogPosDestination - LocalPlayer():GetPos()):Angle() - LocalPlayer():GetAngles()
    end)

    concommand.Add("open_logpos_admin_menu", LogPos.AdminPanel)
    concommand.Add("open_logpos_menu", LogPos.PlayerPanel)
end