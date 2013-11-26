local garage = require 'garage'

module('garageFactory', package.seeall)

function _M.newGarage()
	local g = garage:new()
end