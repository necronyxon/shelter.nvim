---@class ShelterFullMode
---Full masking mode - replaces all characters with mask character
local Base = require("shelter.modes.base")

-- Lazy-loaded engine for cached mask access
local engine = nil
local function get_engine()
	if not engine then
		engine = require("shelter.masking.engine")
	end
	return engine
end

---@type ShelterModeDefinition
local definition = {
	name = "full",
	description = "Replace all characters with mask character",

	schema = {
		mask_char = {
			type = "string",
			default = "*",
			description = "Character used for masking",
		},
		preserve_length = {
			type = "boolean",
			default = true,
			description = "Whether to preserve original value length",
		},
		fixed_length = {
			type = "number",
			default = nil,
			min = 1,
			description = "Fixed output length (overrides preserve_length)",
		},
	},

	default_options = {
		mask_char = "*",
		preserve_length = true,
	},

	---@param self ShelterModeBase
	---@param ctx ShelterModeContext
	---@return string
	apply = function(self, ctx)
		-- Direct property access - options pre-resolved at config time
		local opts = self.options
		local mask_char = opts.mask_char
		local length = opts.fixed_length or #ctx.value

		-- Use cached mask strings to avoid repeated string.rep()
		return get_engine().get_cached_mask(mask_char, length)
	end,

	---@param options table
	---@return boolean, string?
	validate = function(options)
		if options.mask_char and #options.mask_char ~= 1 then
			return false, "mask_char must be a single character"
		end
		return true
	end,
}

---Create a new full mode instance
---@param options? table<string, any>
---@return ShelterModeBase
local function create(options)
	local mode = Base.new(definition)
	if options then
		mode:configure(options)
	end
	return mode
end

return {
	definition = definition,
	create = create,
}
