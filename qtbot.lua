--[[
    qtbot.lua
    otouto plugin for the operation of @qtchan.

    Copyright 2018 topkecleon <drew@otou.to>
    This code is licensed under the GNU AGPLv3. See /LICENSE for details.
]]--

local bindings = require('otouto.bindings')
local HTTP = require('socket.http')
local JSON = require('dkjson')

local qtbot = {}

function qtbot.get_cat(thecatapi_key)
    local url = 'http://thecatapi.com/api/images/get?format=html&type=jpg&api_key=' .. thecatapi_key
    local str = HTTP.request(url)
    local image_url = str:match('<img src="(.-)">')
    return image_url
end

function qtbot:cron()
    local now = os.date('%H')
    if self.database.last_cat ~= now and now % 4 == 0 then
        if bindings.sendPhoto{
            chat_id = '@qtchan',
            photo = qtbot.get_cat(self.config.thecatapi_key)
        } then
            self.database.last_cat = now
        end
    end
end

return qtbot
