local displayRole = {}

displayRole.accessLevelColors = {}
displayRole.accessLevelColors["admin"] = "1,0,0"
displayRole.accessLevelColors["moderator"] = "0,0.5,0.18"
displayRole.accessLevelColors["overseer"] = "0.1,0.1,0.75"
displayRole.accessLevelColors["gm"] = "0.83,0.48,0.09"
displayRole.accessLevelColors["observer"] = "0.5,0.5,0.5"

displayRole.assignedSpecialRoles = {}

function displayRole.processSandBoxOptions()

    local sandboxOptions = getSandboxOptions()
    if not sandboxOptions then return end

    ---@type SandboxOptions.SandboxOption
    local SpecialRolesOption = sandboxOptions:getOptionByName("DisplayRolesInChat.SpecialRoles")
    local SpecialRoles = SpecialRolesOption and SpecialRolesOption:getValue()
    if SpecialRoles then
        for roleColor in string.gmatch(SpecialRoles, "([^;]+)") do
            local role,color = string.match(roleColor, "(.*):(.*)")
            displayRole.accessLevelColors[role] = color
        end
    end

    ---@type SandboxOptions.SandboxOption
    local AssignRolesOption = sandboxOptions:getOptionByName("DisplayRolesInChat.AssignRoles")
    local AssignRoles = AssignRolesOption and AssignRolesOption:getValue()
    if AssignRoles then
        for usernameRole in string.gmatch(AssignRoles, "([^;]+)") do
            local usernames,role = string.match(usernameRole, "(.*):(.*)")

            for username in string.gmatch(usernames, "([^,]+)") do
                displayRole.assignedSpecialRoles[username] = role
            end
        end
    end

end


require "ISUI/AdminPanel/ISServerSandboxOptionsUI"
local destroy = ISServerSandboxOptionsUI.destroy
function ISServerSandboxOptionsUI:destroy()
    displayRole.processSandBoxOptions()
    destroy(self)
end


---@param message ChatMessage
function displayRole.getRoleForMessage(message)
    local author = message:getAuthor()
    if author then

        local username, accessLevel
        local onlineUsers = getOnlinePlayers()
        for i=0, onlineUsers:size()-1 do
            local player = onlineUsers:get(i)
            local pUsername = player:getUsername()
            if pUsername == author then
                username = player:getUsername()
                accessLevel = player:getAccessLevel()
                break
            end
        end

        if username or accessLevel then
            accessLevel = displayRole.assignedSpecialRoles[username] or string.lower(accessLevel)
            if displayRole.accessLevelColors[accessLevel] then
                ---@type Color
                local chatBaseColor = message:getTextColor()
                local oldRGB = "1,1,1"
                if chatBaseColor then
                    oldRGB = chatBaseColor:getR()..","..chatBaseColor:getG()..","..chatBaseColor:getB()
                end
                return (" <RGB:"..displayRole.accessLevelColors[accessLevel].."> � "..string.upper(accessLevel).." �� <RGB:"..oldRGB.."> ")
            end
        end
    end
end


displayRole._metaMethodOverwrite = {}
displayRole._metaMethodOverwrite.getTextWithPrefix = function(original_fn)
    return function(self, ...)
        local originalReturn = original_fn(self, ...)
        local role = displayRole.getRoleForMessage(self) or ""
        return role..originalReturn
    end
end
function displayRole._metaMethodOverwrite.apply(class, methodName)
    local metatable = __classmetatables[class]
    local metatable__index = metatable.__index
    local originalMethod = metatable__index[methodName]
    metatable__index[methodName] = displayRole._metaMethodOverwrite[methodName](originalMethod)
end
displayRole._metaMethodOverwrite.apply(zombie.chat.ChatMessage.class, "getTextWithPrefix")

return displayRole