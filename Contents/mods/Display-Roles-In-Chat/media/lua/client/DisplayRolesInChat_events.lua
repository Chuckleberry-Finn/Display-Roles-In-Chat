local displayRole = require "DisplayRolesInChat"
Events.OnLoad.Add(displayRole.processSandBoxOptions)
if isServer() then Events.OnGameBoot.Add(displayRole.processSandBoxOptions) end