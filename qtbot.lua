--[[
    qtbot.lua
    otouto plugin for the operation of @qtchan.

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
local bindings = require('otouto.bindings')
local HTTP = require('socket.http')
local JSON = require('dkjson')

local qtbot = {}

function qtbot.get_cat(thecatapi_key)
    local url = 'http://thecatapi.com/api/images/get?format=html&type=jpg&api_key=' .. thecatapi_key
    local str = HTTP.request(url)
    local image_url = str:match('<img src="(.-)">')
    local filename = '/tmp/cat-'..os.time()..'.jpg'
    return utilities.download_file(image_url, filename)
end

function qtbot.get_fact()
    local url = 'http://catfacts-api.appspot.com/api/facts'
    local jstr = HTTP.request(url)
    local data = JSON.decode(jstr)
    return data.facts[1]
end

function qtbot:cron(config)
    local now = os.date('%H')
    if self.database.last_cat ~= now then
        if bindings.sendPhoto(
            { chat_id = '@qtchan', caption = now == '00' and qtbot.get_fact() or nil },
            { photo = qtbot.get_cat(config.thecatapi_key) }
        ) then
            self.database.last_cat = now
        end
    end
end

return qtbot
