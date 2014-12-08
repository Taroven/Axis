local addon, ns = ...
_G[addon] = ns

LibStub("AceAddon-3.0"):NewAddon(ns, addon, "AceConsole-3.0", "AceEvent-3.0", "AceBucket-3.0")

local pairs, ipairs = pairs, ipairs
local unpack = unpack or table.unpack
local type = type

local t = {
	OnInitialize = function (self)
		self.Initialized = true
	end,

	OnEnable = function (self)
		self.Enabled = true
		self:Show()

		for k,v in pairs(self.Events) do
			local event = type(v) == 'string' and v or k
			self:RegisterEvent(event, 'OnEvent')
		end
		for k,v in pairs(self.Messages) do
			local event = type(v) == 'string' and v or k
			self:RegisterMessage(event)
		end

		for _,info in ipairs(self.BucketEvents) do
			self:RegisterBucketEvent(unpack(info))
		end
		for _,info in ipairs(self.BucketMessages) do
			self:RegisterBucketMessage(unpack(info))
		end

		for name, frame in pairs(self.Frames) do
			self:EnableScript('OnUpdate', true, name)
			self:EnableScript('OnEvent', true, name)
		end
	end,

	OnDisable = function (self)
		self.Enabled = false
		self:Hide()
		for name, frame in pairs(self.Frames) do
			self:EnableScript('OnUpdate', false, name)
			self:EnableScript('OnEvent', false, name)
		end
	end,

	OnEvent = function (self, event, ...)
		local f = self[event]
		if f then
			return f(self, ...)
		end
	end,

	EnableScript = function (self, script, enable, frame)
		local f = self.Frames[frame or 'Main']
		local func = (f == self.Frames.Main) and self[script] or frame[script]
		f:SetScript(script, enable and func)
	end,

	Show = function (self, frame)
		return self.Frames[frame or 'Main']:Show()
	end,

	Hide = function (self, frame)
		return self.Frames[frame or 'Main']:Hide()
	end,
}

-- Return a barebones template
function ns:Template(module, name)
	local module = module or {}
	if name then
		module.Name = name
		module.Prefix = name .. '_'
	end

	module.Frames = { Main = CreateFrame('Frame', name and (module.Prefix .. 'Primary'), module == ns and UIParent or 'Axis_Primary') }

	module.Events = {}
	module.Messages = {}
	module.BucketEvents = {}
	module.BucketMessages = {}

	for k,v in pairs(t) do
		module[k] = v
	end

	return module
end

-- Use our own template to get going
ns:Template(ns, 'Axis')

function ns:OnInitialize()
	self:RegisterChatCommand("axis", "SlashHandler")
	self.db = LibStub("AceDB-3.0"):New("AxisDB")
end

function ns:SlashHandler(input)

end

local prefix = ns.Prefix -- avoid a table lookup
function ns:OnEvent(event, ...)
	local f = self[event]
	if f then f(self, ...) end
	return ns:SendMessage(prefix .. event, ...)
end
