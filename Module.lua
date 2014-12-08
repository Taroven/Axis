local addon, ns = ...

local lower = string.lower
local pairs, ipairs = pairs, ipairs

ns.Modules = {}

function ns:RegisterModule(self, name, namespace, essential)
	local n = lower(name)
	if not self.Modules[n] then
		self.Modules[n] = namespace
		local t = self.Modules[n]
		t.Essential = essential
		self:ModuleEvent('RegisterModule', n)
	end
end

function ns:LoadModules()
	local profile = self.db.profile
	for i,m in pairs(self.Modules) do
		if  or m.Essential then
			if not(m.Enable) then m.Enable = function () end end
			if not(m.Disable) then m.Disable = function () end end
			self.modules[i]:Init()
			self.modules[i]:Enable()
			vars.modulesLoaded = true
		end
	end
end