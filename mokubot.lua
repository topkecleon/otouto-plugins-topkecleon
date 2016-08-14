--[[
    mokubot.lua
    otouto plugin for mokubot to return group listings based on data shared by
    oubot.

    Copyright 2016 topkecleon <drew@otou.to>

    This program is free software; you can redistribute it and/or modify it
    under the terms of the GNU Affero General Public License version 3 as
    published by the Free Software Foundation.

    This program is distributed in the hope that it will be useful, but WITHOUT
    ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
    FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Affero General Public License
    for more details.
]]--

local utilities = require('otouto.utilities')

local mokubot = {}

function mokubot:init(config)
    mokubot.triggers = utilities.triggers(self.info.username, config.cmd_pat):t('groups', true).table
    mokubot.command = 'groups [query]'
end

function mokubot:action(msg, config)
    local gdat = utilities.load_data('../group_data.json')
    local chat_id_str = tostring(msg.chat.id)
    for _, group in ipairs(gdat) do
        if chat_id_str == group.id_str then
            return
        end
    end
    if #gdat == 0 then
        utilities.send_message(self, msg.chat.id, 'There are currently no listed groups.')
        return
    end
    local input = utilities.input(msg.text)
    if input then
        local output = ''
        for _, group in ipairs(gdat) do
            if string.match(group.name:lower(), input:lower()) and not group.unlisted then
                output = output .. '• [' .. utilities.md_escape(group.name) .. '](' .. group.link .. ')\n'
            end
        end
        if output ~= '' then
            output = '*Groups matching* _' .. utilities.md_escape(input) .. '_ *:*\n' .. output
            utilities.send_message(self, msg.chat.id, output, true, nil, true)
            return
        end
    end
    local output = '*Groups:*\n'
    for _, group in ipairs(gdat) do
        if not group.unlisted then
            output = output .. '• [' .. utilities.md_escape(group.name) .. '](' .. group.link .. ')\n'
        end
    end
    utilities.send_message(self, msg.chat.id, output, true, nil, true)
end

return mokubot
