LogPos = LogPos or {}
LogPos.Config = LogPos.Config or {}

LogPos.Config.Key = KEY_J -- Go to : https://wiki.facepunch.com/gmod/Enums/KEY <- checking the keys for gmod.
LogPos.Config.LogposPosition = 1 -- Choices : "TOP_LEFT" = 1 ; "BOTTOM_LEFT" = 2 ; "TOP_RIGHT" = 3 ; "BOTTOM_RIGHT" = 4
LogPos.Config.LogposSize = 180 -- The Size of the LogPos.
LogPos.Config.DestinationMessage = true -- Display a message on your screen, when you arrived in yout LogPos's destination. true or false
LogPos.Config.DestinationRadius = 300 -- The radius defined when a player arrives in the destination area

LogPos.Config.Notifications = false -- Choices : true, false
LogPos.Config.NotifDelay = 20 -- Delay between two notifications, in seconds. Restart after modifications.

LogPos.Config.StaffGroups = {"superadmin", "admin"} -- Groups allowed to open the admin panel.
LogPos.Config.CantOpenPanel = "You're not allowed." -- The message for the player who can't open the admin panel/