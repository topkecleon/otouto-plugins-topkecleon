--[[
    weeabot.lua
    otouto plugin for weeaboo functions of mokubot, such as inserting random
    weebery in the OU Anime & Manga group, and responding to "tadaima".

    Copyright 2016 topkecleon <drew@otou.to>

    This program is free software; you can redistribute it and/or modify it
    under the terms of the GNU Affero General Public License version 3 as
    published by the Free Software Foundation.

    This program is distributed in the hope that it will be useful, but WITHOUT
    ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
    FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Affero General Public License
    for more details.

    You should have received a copy of the GNU Affero General Public License
    along with this program; if not, write to the Free Software Foundation,
    Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.
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

function weeabot:action(msg, config)
    for response, triggers in pairs(weeabot.greetings) do
        for _, trigger in ipairs(triggers) do
            if msg.text_lower:match(trigger) then
                local name
                local userdata = self.database.userdata[tostring(msg.from.id)]
                if userdata and userdata.nickname then
                    name = userdata.nickname
                else
                    name = utilities.build_name(msg.from.first_name, msg.from.last_name)
                end
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
