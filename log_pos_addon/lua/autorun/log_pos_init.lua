if SERVER then
    AddCSLuaFile("autorun/cl_log_pos.lua")
    AddCSLuaFile("autorun/sv_log_pos.lua")
    include("autorun/cl_log_pos.lua")
    include("autorun/sv_log_pos.lua")
elseif CLIENT then
    include("autorun/cl_log_pos.lua")
end
