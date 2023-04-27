local accessLevelColors = {}
accessLevelColors["admin"] = "1,0,0"
accessLevelColors["moderator"] = "0,0.5,0.18"
accessLevelColors["overseer"] = "0.1,0.1,0.75"
accessLevelColors["gm"] = "0.83,0.48,0.09"
accessLevelColors["observer"] = "0.5,0.5,0.5"

--LuaEventManager.triggerEvent("OnAddMessage", var1, this.getTabID())
---@param chatMessage ChatMessage
local function applyRoleToChatMessage(chatMessage, chatID)
    local author = chatMessage:getAuthor()
    if chatMessage and author then
        local player = getPlayerFromUsername(author)
        if player then
            local accessLevel = string.lower(player:getAccessLevel())
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