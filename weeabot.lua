--[[
    weeabot.lua
    otouto plugin for weeaboo functions of mokubot, such as inserting random
    weebery in the OU Anime & Manga group, and responding to "tadaima".

    Copyright 2016 topkecleon <drew@otou.to>
    This code is licensed under the GNU AGPLv3. See /LICENSE for details.
]]--

local utilities = require('otouto.utilities')

local weeabot = {
    error = false,
    triggers = { '' },
    responses = {
        'uguu~',
        'desu',
        'nya',
        'nyoro~n',
        'sugoi',
        'kawaii',
        'omedetou',
        'shine',
        'b-baka',
        'masshuruumu'
    },
    greetings = {
        ['Okaeri, #NAME!'] = { '^tadaima%p*$' },
        ['Welcome back, #NAME!'] = {
            '^i\'?m home$',
            '^i\'?m back$'
        }
    }
}

function weeabot:action(msg)
    for response, triggers in pairs(weeabot.greetings) do
        for _, trigger in ipairs(triggers) do
            if msg.text_lower:match(trigger) then
                local name = (self.database.userdata.nick and self.database.userdata.nick[tostring(msg.from.id)]) or utilities.build_name(msg.from.first_name, msg.from.last_name)
                utilities.send_message(msg.chat.id, response:gsub('#NAME', name))
                return
            end
        end
    end
    if msg.chat.id == -1001000134061 and math.random(200) == 1 then
        utilities.send_message(msg.chat.id, weeabot.responses[math.random(#weeabot.responses)])
    end
    return true
end

return weeabot
