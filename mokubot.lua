--[[
    mokubot.lua
    otouto plugin for mokubot to return group listings based on data shared by
    oubot.

    Copyright 2016 topkecleon <drew@otou.to>
    This code is licensed under the GNU AGPLv3. See /LICENSE for details.
]]--

local utilities = require('otouto.utilities')

local mokubot = {}

function mokubot:init()
    mokubot.triggers = utilities.triggers(self.info.username, self.config.cmd_pat):t('groups', true).table
    mokubot.command = 'groups [query]'
end

function mokubot:action(msg)
    local gdat = utilities.load_data('../group_data.json')
    local chat_id_str = tostring(msg.chat.id)
    for _, group in ipairs(gdat) do
        if chat_id_str == group.id_str then
            return
        end
    end
    if #gdat == 0 then
        utilities.send_message(msg.chat.id, 'There are currently no listed groups.')
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
            utilities.send_message(msg.chat.id, output, true, nil, true)
            return
        end
    end
    local output = '*Groups:*\n'
    for _, group in ipairs(gdat) do
        if not group.unlisted then
            output = output .. '• [' .. utilities.md_escape(group.name) .. '](' .. group.link .. ')\n'
        end
    end
    utilities.send_message(msg.chat.id, output, true, nil, true)
end

 -- Basically administration.lua's /groups.
function mokubot:action(msg)
    local groups = utilities.load_data('../group_data.json')
    if groups[tostring(msg.chat.id)] then return end

    local input = utilities.input(msg.text)
    local group_list = {}
    local result_list = {}
    for _, group in pairs(groups) do
        if (not group.flags[1]) and group.link then -- no unlisted or unlinked groups
            local line = '• [' .. utilities.md_escape(group.name) .. '](' .. group.link .. ')'
            table.insert(group_list, line)
            if input and string.match(group.name:lower(), input:lower()) then
                table.insert(result_list, line)
            end
        end
    end
    local output
    if #result_list > 0 then
        table.sort(result_list)
        output = '*Groups matching* _' .. input:gsub('_', '_\\__') .. '_*:*\n' .. table.concat(result_list, '\n')
    elseif #group_list > 0 then
        table.sort(group_list)
        output = '*Groups:*\n' .. table.concat(group_list, '\n')
    else
        output = 'There are currently no listed groups.'
    end
    utilities.send_message(msg.chat.id, output, true, nil, true)
end

return mokubot
