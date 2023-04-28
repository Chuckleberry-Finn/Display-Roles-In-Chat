local accessLevelColors = {}
accessLevelColors["admin"] = "1,0,0"
accessLevelColors["moderator"] = "0,0.5,0.18"
accessLevelColors["overseer"] = "0.1,0.1,0.75"
accessLevelColors["gm"] = "0.83,0.48,0.09"
accessLevelColors["observer"] = "0.5,0.5,0.5"

local assignedSpecialRoles = {}

local function processSandBoxOptions()
    local SpecialRoles = SandboxVars.DisplayRolesInChat.SpecialRoles
    for roleColor in string.gmatch(SpecialRoles, "([^;]+)") do
        local role,color = string.match(roleColor, "(.*):(.*)")
        accessLevelColors[role] = color
    end

    print("ROLES:")
    for k,v in pairs(accessLevelColors) do
        print(k, v)
    end

    local AssignRoles = SandboxVars.DisplayRolesInChat.AssignRoles
    for usernameRole in string.gmatch(AssignRoles, "([^;]+)") do
        local username,role = string.match(usernameRole, "(.*):(.*)")
        assignedSpecialRoles[username] = role
    end

    print("ASSIGNED:")
    for k,v in pairs(assignedSpecialRoles) do
        print(k, v)
    end
end
Events.OnLoad.Add(processSandBoxOptions)
if isServer() then Events.OnGameBoot.Add(processSandBoxOptions) end


require "ISUI/AdminPanel/ISServerSandboxOptionsUI"
local destroy = ISServerSandboxOptionsUI.destroy
function ISServerSandboxOptionsUI:destroy()
    processSandBoxOptions()
    destroy(self)
end


--LuaEventManager.triggerEvent("OnAddMessage", var1, this.getTabID())
---@param chatMessage ChatMessage
local function applyRoleToChatMessage(chatMessage, chatID)
    local author = chatMessage:getAuthor()
    if chatMessage and author then
        local player = getPlayerFromUsername(author)
        if player then

            local accessLevel = assignedSpecialRoles[player:getUsername()] or string.lower(player:getAccessLevel())
            if accessLevelColors[accessLevel] then
                ---@type Color
                local chatBaseColor = chatMessage:getTextColor()
                local oldRGB = "1,1,1"
                if chatBaseColor then
                    oldRGB = chatBaseColor:getR()..","..chatBaseColor:getG()..","..chatBaseColor:getB()
                end
                chatMessage:setAuthor(" <RGB:"..accessLevelColors[accessLevel].."> � "..string.upper(accessLevel).." �� <RGB:"..oldRGB.."> "..author)
            end
        end
    end
end
Events.OnAddMessage.Add(applyRoleToChatMessage)