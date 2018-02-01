 -- This plugin imports @oubot's group list and provides it on command.

local utilities = require('otouto.utilities')

local P = {}

function P:init()
    P.triggers = utilities.triggers(self.info.username, self.config.cmd_pat)
        :t('groups', true):t('listgroups', true).table
    P.command = 'groups [query]'
    P:cron()
end

function P:cron()
    if P.last_import ~= os.date('%H') then
        P.group_list = utilities.load_data('../group_list.json')
        P.last_import = os.date('%H')
    end
end

function P:action(msg)
    -- Ignore administrated groups.
    if P.group_list[tostring(msg.chat.id)] then return end

    -- The rest is basically copy-pasted from listgroups.lua.
    local input = utilities.input_from_msg(msg)

    local results = {}
    local listed_groups = {}

    for _, group in pairs(P.group_list) do
        if not group.flags.private then
            local link = string.format('<a href="%s">%s</a>',
                group.link,
                utilities.html_escape(group.name)
            )
            table.insert(listed_groups, link)

            if input and group.name:lower():match(input) then
                table.insert(results, link)
            end
        end
    end

    local output

    if input then
        if #results == 0 then
            output = self.config.errors.results
        else
            output = string.format(
                '<b>Groups matching</b> <i>%s</i><b>:</b>\n• %s',
                utilities.html_escape(input),
                table.concat(results, '\n• ')
            )
        end
    else
        output = '<b>Groups:</b>\n• ' .. table.concat(listed_groups, '\n• ')
    end

    utilities.send_reply(msg, output, 'html')
end

return P
