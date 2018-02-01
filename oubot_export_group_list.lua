 -- This plugin exports the group list so that @mokubot can use it.

local utilities = require('otouto.utilities')

local P = {}

function P:init()
    if P.last_export ~= os.date('%H') then
        utilities.save_data('../group_list.json', self.database.administration.groups)
        P.last_export = os.date('%H')
    end
end

P.cron = P.init

return P
