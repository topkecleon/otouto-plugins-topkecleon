--[[
    mokubot_google_translate.lua
    google_translate.lua, but only in configured groups.

    Uses config.lang for the output language, unless specified.

    Copyright 2017 topkecleon <drew@otou.to>
    This code is licensed under the GNU AGPLv3. See /LICENSE for details.
]]--

local mgt = require('otouto.plugins.google_translate')

mgt.init_ = mgt.init
mgt.action_ = mgt.action

function mgt:init()
    -- self.config.mgt is an array of group IDs where this plugin is available.
    -- mgt.groups is a set of group ID strings.
    mgt.groups = {}
    for _, id in pairs(self.config.mgt) do
        mgt.groups[tostring(id)] = true
    end
    mgt.init_(self)
end

function mgt:action(msg)
    if not mgt.groups[tostring(msg.chat.id)] then return true end
    return mgt.action_(self, msg)
end

return mgt
