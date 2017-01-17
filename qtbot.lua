--[[
    qtbot.lua
    otouto plugin for the operation of @qtchan.

    Copyright 2016 topkecleon <drew@otou.to>
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

function qtbot.get_fact()
    local url = 'http://catfacts-api.appspot.com/api/facts'
    local jstr = HTTP.request(url)
    local data = JSON.decode(jstr)
    return data.facts[1]
end

function qtbot:cron()
    local now = os.date('%H')
    if now % 2 == 0 and self.database.last_cat ~= now then
        if bindings.sendPhoto{
            chat_id = '@qtchan',
            caption = now == '00' and qtbot.get_fact() or nil,
            photo = qtbot.get_cat(self.config.thecatapi_key)
        } then
            self.database.last_cat = now
        end
    end
end

return qtbot
