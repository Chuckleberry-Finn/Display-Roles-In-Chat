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


    local AssignRoles = SandboxVars.DisplayRolesInChat.AssignRoles
    for usernameRole in string.gmatch(AssignRoles, "([^;]+)") do
        local usernames,role = string.match(usernameRole, "(.*):(.*)")

        for username in string.gmatch(usernames, "([^,]+)") do
            assignedSpecialRoles[username] = role
        end
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


---@param message ChatMessage
local function getRoleForMessage(message)
    local author = message:getAuthor()
    if author then
        local player = getPlayerFromUsername(author)
        if player then

            local accessLevel = assignedSpecialRoles[player:getUsername()] or string.lower(player:getAccessLevel())
            if accessLevelColors[accessLevel] then
                ---@type Color
                local chatBaseColor = message:getTextColor()
                local oldRGB = "1,1,1"
                if chatBaseColor then
                    oldRGB = chatBaseColor:getR()..","..chatBaseColor:getG()..","..chatBaseColor:getB()
                end
                return (" <RGB:"..accessLevelColors[accessLevel].."> � "..string.upper(accessLevel).." �� <RGB:"..oldRGB.."> ")
            end
        end
    end
end


local _metaMethodOverwrite = {}

_metaMethodOverwrite.getTextWithPrefix = function(original_fn)
    return function(self, ...)
        local originalReturn = original_fn(self, ...)
        local role = getRoleForMessage(self) or ""
        return role..originalReturn
    end
end

function _metaMethodOverwrite.apply(class, methodName)
    local metatable = __classmetatables[class]
    local metatable__index = metatable.__index
    local originalMethod = metatable__index[methodName]
    metatable__index[methodName] = _metaMethodOverwrite[methodName](originalMethod)
end
_metaMethodOverwrite.apply(zombie.chat.ChatMessage.class, "getTextWithPrefix")