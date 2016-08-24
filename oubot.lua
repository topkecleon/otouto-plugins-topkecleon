--[[
    oubot.lua
    otouto plugin for the uninteresting operation of oubot; ignoring spammers,
    preparing a group list for mokubot, and restarting oubot, mokubot, and tg
    every day.

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

local drua = require('otouto.drua-tg')
local bindings = require('otouto.bindings')
local utilities = require('otouto.utilities')

local oubot = {}

function oubot:grouplisting()
    local list = {}
    for _, chat_id_str in ipairs(self.database.administration.activity) do
        local group = self.database.administration.groups[chat_id_str]
        table.insert(list, {
            name = group.name,
            link = group.link,
            id_str = chat_id_str,
            -- unlisted status is sent for the sole purpose of mokubot not
            -- sending grouplists to groups where oubot exists
            unlisted = not not group.flags[1]
        })
    end
    utilities.save_data('../group_data.json', list)
end

function oubot:init(config)
    oubot.error = false
    oubot.triggers = { '' }
    oubot.last_restart = os.date('%d')
    oubot.grouplisting(self)
    oubot.last_grouplisting = os.date('%H')
    oubot.ignore = {}
end

function oubot:cron()
    -- autorestart every day
    if os.date('%d') ~= oubot.last_restart then
        -- tell mokubot to restart
        drua.message(117099167, '/halt')
        -- restart tg
        drua.send('quit')
        -- restart self
        self.is_started = false
    end
    -- update mokubot's grouplist every hour
    if oubot.last_grouplisting ~= os.date('%H') then
        oubot.grouplisting(self)
        oubot.last_grouplisting = os.date('%H')
    end
    -- clear ignore list every minute
    oubot.ignore = {}
end

 -- this all belongs to the ignore part
function oubot:action(msg, config)
    if msg.from.id == config.admin then
        return true
    elseif msg.chat.type == 'private' then
        oubot.ignore[msg.from.id] = (oubot.ignore[msg.from.id] or 0) + 1
        if oubot.ignore[msg.from.id] > 9 then
            local s = '%s [%s] has exceeded ten private messages within a minute.'
            s = s:format(
                utilities.build_name(msg.from.first_name, msg.from.last_name),
                msg.from.id
            )
            utilities.handle_exception(self, 'oubot_ignore:', s, config.log_chat)
            return
        elseif oubot.ignore[msg.from.id] > 4 then
            return
        end
    elseif not self.database.administration.groups[tostring(msg.chat.id)] then
        bindings.leaveChat{ chat_id = msg.chat.id }
        return
    end
    return true
end

return oubot
