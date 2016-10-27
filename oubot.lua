--[[
    oubot.lua
    otouto plugin for the uninteresting operation of oubot; ignoring spammers
    and preparing a group list for mokubot.

    Copyright 2016 topkecleon <drew@otou.to>
    This code is licensed under the GNU AGPLv3. See /LICENSE for details.
]]--

local drua = require('otouto.drua-tg')
local bindings = require('otouto.bindings')
local utilities = require('otouto.utilities')

local oubot = {}

function oubot:init()
    oubot.error = false
    oubot.triggers = { '' }
    oubot.last_restart = os.date('%d')
    utilities.save_data('../group_data.json', self.database.administration.groups)
    oubot.last_grouplisting = os.date('%H')
    oubot.ignore = {}
end

function oubot:cron()
    -- update mokubot's grouplist every hour
    if oubot.last_grouplisting ~= os.date('%H') then
        utilities.save_data('../group_data.json', self.database.administration.groups)
        oubot.last_grouplisting = os.date('%H')
    end
    -- clear ignore list every minute
    oubot.ignore = {}
end

 -- this all belongs to the ignore part
function oubot:action(msg)
    if msg.from.id == self.config.admin then
        return true
    elseif msg.chat.type == 'private' then
        oubot.ignore[msg.from.id] = (oubot.ignore[msg.from.id] or 0) + 1
        if oubot.ignore[msg.from.id] > 9 then
            local s = '%s [%s] has exceeded ten private messages within a minute.'
            s = s:format(
                utilities.build_name(msg.from.first_name, msg.from.last_name),
                msg.from.id
            )
            utilities.handle_exception(self, 'oubot_ignore:', s, self.config.log_chat)
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
