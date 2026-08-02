--!strict

local ContentTypes = require(script.Parent.ContentTypes)
local Result = require(script.Parent.Parent.types.Result)
local StableId = require(script.Parent.StableId)

type ActionDefinition = ContentTypes.ActionDefinition
type ContentSet = ContentTypes.ContentSet
type Definition = ContentTypes.Definition
type EquipmentSlotDefinition = ContentTypes.EquipmentSlotDefinition
type Failure = Result.Failure
type ItemDefinition = ContentTypes.ItemDefinition
type ModifierDefinition = ContentTypes.ModifierDefinition
type ProfessionDefinition = ContentTypes.ProfessionDefinition
type ToolDefinition = ContentTypes.ToolDefinition

export type Registry = {
	contentVersion: string,
	get: (id: string) -> Definition?,
	getItem: (id: string) -> ItemDefinition?,
	getEquipmentSlot: (id: string) -> EquipmentSlotDefinition?,
	getProfession: (id: string) -> ProfessionDefinition?,
	getTool: (id: string) -> ToolDefinition?,
	getAction: (id: string) -> ActionDefinition?,
	getModifier: (id: string) -> ModifierDefinition?,
	getActionModifiers: (actionId: string) -> { ModifierDefinition }?,
	getToolModifiers: (toolId: string) -> { ModifierDefinition }?,
	all: () -> { Definition },
}

export type CreateResult = {
	ok: true,
	value: Registry,
} | Failure

local ContentRegistry = {}
local SUPPORTED_SCHEMA_VERSION = 1

local function fail(code: string, detail: string): Failure
	return {
		ok = false,
		code = code,
		retryable = false,
		detail = detail,
	}
end

local function isFinite(value: number): boolean
	return value == value and math.abs(value) ~= math.huge
end

local function isPositiveInteger(value: number): boolean
	return isFinite(value) and value > 0 and value == math.floor(value)
end

local function isPositiveMultiplier(value: number): boolean
	return isFinite(value) and value > 0
end

local function validateCommon(definition: Definition, expectedNamespace: string): Failure?
	if not StableId.hasNamespace(definition.id, expectedNamespace) then
		return fail(
			"content.invalid_id",
			`Definition '{definition.id}' must use the '{expectedNamespace}' namespace`
		)
	end

	if definition.schemaVersion ~= SUPPORTED_SCHEMA_VERSION then
		return fail(
			"content.unsupported_schema_version",
			`Definition '{definition.id}' uses schema version {definition.schemaVersion}`
		)
	end

	if #definition.displayName == 0 then
		return fail(
			"content.invalid_display_name",
			`Definition '{definition.id}' has no display name`
		)
	end

	if
		not isFinite(definition.displayOrder)
		or definition.displayOrder < 0
		or definition.displayOrder ~= math.floor(definition.displayOrder)
	then
		return fail(
			"content.invalid_display_order",
			`Definition '{definition.id}' must have a non-negative integer display order`
		)
	end

	return nil
end

local function validateStableIdList(
	ownerId: string,
	values: { string },
	expectedNamespace: string,
	fieldName: string,
	requireValue: boolean
): Failure?
	if requireValue and #values == 0 then
		return fail(
			"content.empty_list",
			`Definition '{ownerId}' requires at least one {fieldName}`
		)
	end

	local seen: { [string]: boolean } = {}
	for _, value in values do
		if not StableId.hasNamespace(value, expectedNamespace) then
			return fail(
				"content.invalid_reference_id",
				`Definition '{ownerId}' has invalid {fieldName} '{value}'`
			)
		end

		if seen[value] then
			return fail(
				"content.duplicate_list_value",
				`Definition '{ownerId}' repeats {fieldName} '{value}'`
			)
		end
		seen[value] = true
	end

	return nil
end

local function copyStringList(values: { string }): { string }
	return table.freeze(table.clone(values))
end

local function copyDefinition(definition: Definition): Definition
	if definition.kind == "item" then
		local copy: ItemDefinition = {
			kind = definition.kind,
			id = definition.id,
			schemaVersion = definition.schemaVersion,
			displayName = definition.displayName,
			displayOrder = definition.displayOrder,
			tags = copyStringList(definition.tags),
			stackable = definition.stackable,
			equipmentSlotId = definition.equipmentSlotId,
		}
		return table.freeze(copy)
	elseif definition.kind == "equipment_slot" then
		local copy: EquipmentSlotDefinition = {
			kind = definition.kind,
			id = definition.id,
			schemaVersion = definition.schemaVersion,
			displayName = definition.displayName,
			displayOrder = definition.displayOrder,
			acceptedItemTags = copyStringList(definition.acceptedItemTags),
			deathLossEligible = definition.deathLossEligible,
		}
		return table.freeze(copy)
	elseif definition.kind == "profession" then
		local copy: ProfessionDefinition = {
			kind = definition.kind,
			id = definition.id,
			schemaVersion = definition.schemaVersion,
			displayName = definition.displayName,
			displayOrder = definition.displayOrder,
			curveId = definition.curveId,
			contentLevelCap = definition.contentLevelCap,
			xpMultiplier = definition.xpMultiplier,
		}
		return table.freeze(copy)
	elseif definition.kind == "tool" then
		local copy: ToolDefinition = {
			kind = definition.kind,
			id = definition.id,
			schemaVersion = definition.schemaVersion,
			displayName = definition.displayName,
			displayOrder = definition.displayOrder,
			professionId = definition.professionId,
			categoryId = definition.categoryId,
			requiredProfessionLevel = definition.requiredProfessionLevel,
			modifierIds = copyStringList(definition.modifierIds),
		}
		return table.freeze(copy)
	elseif definition.kind == "action" then
		local copy: ActionDefinition = {
			kind = definition.kind,
			id = definition.id,
			schemaVersion = definition.schemaVersion,
			displayName = definition.displayName,
			displayOrder = definition.displayOrder,
			baseDurationSeconds = definition.baseDurationSeconds,
			professionId = definition.professionId,
			requiredProfessionLevel = definition.requiredProfessionLevel,
			requiredToolId = definition.requiredToolId,
			professionXp = definition.professionXp,
			xpMultiplier = definition.xpMultiplier,
			outputItemId = definition.outputItemId,
			outputQuantity = definition.outputQuantity,
			modifierIds = copyStringList(definition.modifierIds),
		}
		return table.freeze(copy)
	else
		local copy: ModifierDefinition = {
			kind = definition.kind,
			id = definition.id,
			schemaVersion = definition.schemaVersion,
			displayName = definition.displayName,
			displayOrder = definition.displayOrder,
			target = definition.target,
			operation = definition.operation,
			value = definition.value,
			priority = definition.priority,
			dependencies = copyStringList(definition.dependencies),
		}
		return table.freeze(copy)
	end
end

local function definitionsSort(left: Definition, right: Definition): boolean
	if left.displayOrder == right.displayOrder then
		return left.id < right.id
	end
	return left.displayOrder < right.displayOrder
end

local function modifiersSort(left: ModifierDefinition, right: ModifierDefinition): boolean
	if left.priority == right.priority then
		return left.id < right.id
	end
	return left.priority < right.priority
end

function ContentRegistry.create(content: ContentSet): CreateResult
	if not StableId.isValid(content.contentVersion) then
		return fail(
			"content.invalid_content_version",
			`Content version '{content.contentVersion}' must be a stable namespaced ID`
		)
	end

	local definitionsById: { [string]: Definition } = {}
	local itemsById: { [string]: ItemDefinition } = {}
	local slotsById: { [string]: EquipmentSlotDefinition } = {}
	local professionsById: { [string]: ProfessionDefinition } = {}
	local toolsById: { [string]: ToolDefinition } = {}
	local actionsById: { [string]: ActionDefinition } = {}
	local modifiersById: { [string]: ModifierDefinition } = {}
	local orderedDefinitions: { Definition } = {}

	local function addDefinition(definition: Definition, expectedNamespace: string): Failure?
		local commonFailure = validateCommon(definition, expectedNamespace)
		if commonFailure ~= nil then
			return commonFailure
		end

		if definitionsById[definition.id] ~= nil then
			return fail("content.duplicate_id", `Duplicate definition ID '{definition.id}'`)
		end

		local copy = copyDefinition(definition)
		definitionsById[copy.id] = copy
		table.insert(orderedDefinitions, copy)
		return nil
	end

	for _, item in content.items do
		if item.kind ~= "item" then
			return fail("content.kind_mismatch", `Item '{item.id}' has kind '{item.kind}'`)
		end
		local validationFailure = addDefinition(item, "item")
		if validationFailure ~= nil then
			return validationFailure
		end

		local tagsFailure = validateStableIdList(item.id, item.tags, "item_tag", "tag", true)
		if tagsFailure ~= nil then
			return tagsFailure
		end

		if
			item.equipmentSlotId ~= nil
			and not StableId.hasNamespace(item.equipmentSlotId, "equipment_slot")
		then
			return fail(
				"content.invalid_reference_id",
				`Item '{item.id}' has invalid equipment slot ID '{item.equipmentSlotId}'`
			)
		end
		itemsById[item.id] = definitionsById[item.id] :: ItemDefinition
	end

	for _, slot in content.equipmentSlots do
		if slot.kind ~= "equipment_slot" then
			return fail(
				"content.kind_mismatch",
				`Equipment slot '{slot.id}' has kind '{slot.kind}'`
			)
		end
		local validationFailure = addDefinition(slot, "equipment_slot")
		if validationFailure ~= nil then
			return validationFailure
		end

		local tagsFailure = validateStableIdList(
			slot.id,
			slot.acceptedItemTags,
			"item_tag",
			"accepted item tag",
			true
		)
		if tagsFailure ~= nil then
			return tagsFailure
		end
		slotsById[slot.id] = definitionsById[slot.id] :: EquipmentSlotDefinition
	end

	for _, profession in content.professions do
		if profession.kind ~= "profession" then
			return fail(
				"content.kind_mismatch",
				`Profession '{profession.id}' has kind '{profession.kind}'`
			)
		end
		local validationFailure = addDefinition(profession, "profession")
		if validationFailure ~= nil then
			return validationFailure
		end

		if not StableId.hasNamespace(profession.curveId, "profession_curve") then
			return fail(
				"content.invalid_reference_id",
				`Profession '{profession.id}' has invalid curve ID '{profession.curveId}'`
			)
		end
		if not isPositiveInteger(profession.contentLevelCap) then
			return fail(
				"content.invalid_level_requirement",
				`Profession '{profession.id}' must have a positive integer content level cap`
			)
		end
		if not isPositiveMultiplier(profession.xpMultiplier) then
			return fail(
				"content.invalid_xp_multiplier",
				`Profession '{profession.id}' must have a positive finite XP multiplier`
			)
		end
		professionsById[profession.id] = definitionsById[profession.id] :: ProfessionDefinition
	end

	for _, tool in content.tools do
		if tool.kind ~= "tool" then
			return fail("content.kind_mismatch", `Tool '{tool.id}' has kind '{tool.kind}'`)
		end
		local validationFailure = addDefinition(tool, "tool")
		if validationFailure ~= nil then
			return validationFailure
		end

		if not StableId.hasNamespace(tool.professionId, "profession") then
			return fail(
				"content.invalid_reference_id",
				`Tool '{tool.id}' has invalid profession ID '{tool.professionId}'`
			)
		end
		if not StableId.hasNamespace(tool.categoryId, "tool_category") then
			return fail(
				"content.invalid_reference_id",
				`Tool '{tool.id}' has invalid category ID '{tool.categoryId}'`
			)
		end
		if not isPositiveInteger(tool.requiredProfessionLevel) then
			return fail(
				"content.invalid_level_requirement",
				`Tool '{tool.id}' must have a positive integer profession level requirement`
			)
		end
		local modifiersFailure =
			validateStableIdList(tool.id, tool.modifierIds, "modifier", "modifier ID", false)
		if modifiersFailure ~= nil then
			return modifiersFailure
		end
		toolsById[tool.id] = definitionsById[tool.id] :: ToolDefinition
	end

	for _, action in content.actions do
		if action.kind ~= "action" then
			return fail("content.kind_mismatch", `Action '{action.id}' has kind '{action.kind}'`)
		end
		local validationFailure = addDefinition(action, "action")
		if validationFailure ~= nil then
			return validationFailure
		end

		if not isFinite(action.baseDurationSeconds) or action.baseDurationSeconds <= 0 then
			return fail(
				"content.invalid_duration",
				`Action '{action.id}' must have a positive finite duration`
			)
		end
		if not isPositiveInteger(action.outputQuantity) then
			return fail(
				"content.invalid_quantity",
				`Action '{action.id}' must have a positive integer output quantity`
			)
		end
		if not StableId.hasNamespace(action.professionId, "profession") then
			return fail(
				"content.invalid_reference_id",
				`Action '{action.id}' has invalid profession ID '{action.professionId}'`
			)
		end
		if not isPositiveInteger(action.requiredProfessionLevel) then
			return fail(
				"content.invalid_level_requirement",
				`Action '{action.id}' must have a positive integer profession level requirement`
			)
		end
		if not StableId.hasNamespace(action.requiredToolId, "tool") then
			return fail(
				"content.invalid_reference_id",
				`Action '{action.id}' has invalid tool ID '{action.requiredToolId}'`
			)
		end
		if not isPositiveInteger(action.professionXp) then
			return fail(
				"content.invalid_profession_xp",
				`Action '{action.id}' must award positive integer profession XP`
			)
		end
		if not isPositiveMultiplier(action.xpMultiplier) then
			return fail(
				"content.invalid_xp_multiplier",
				`Action '{action.id}' must have a positive finite XP multiplier`
			)
		end
		if not StableId.hasNamespace(action.outputItemId, "item") then
			return fail(
				"content.invalid_reference_id",
				`Action '{action.id}' has invalid output item ID '{action.outputItemId}'`
			)
		end
		local modifiersFailure =
			validateStableIdList(action.id, action.modifierIds, "modifier", "modifier ID", false)
		if modifiersFailure ~= nil then
			return modifiersFailure
		end
		actionsById[action.id] = definitionsById[action.id] :: ActionDefinition
	end

	for _, modifier in content.modifiers do
		if modifier.kind ~= "modifier" then
			return fail(
				"content.kind_mismatch",
				`Modifier '{modifier.id}' has kind '{modifier.kind}'`
			)
		end
		local validationFailure = addDefinition(modifier, "modifier")
		if validationFailure ~= nil then
			return validationFailure
		end

		if
			modifier.target ~= "action_duration"
			and modifier.target ~= "output_quantity"
			and modifier.target ~= "profession_xp"
		then
			return fail(
				"content.invalid_modifier_target",
				`Modifier '{modifier.id}' has an invalid target`
			)
		end
		if modifier.operation ~= "add" and modifier.operation ~= "multiply" then
			return fail(
				"content.invalid_modifier_operation",
				`Modifier '{modifier.id}' has an invalid operation`
			)
		end
		if
			not isFinite(modifier.value)
			or (modifier.operation == "multiply" and modifier.value <= 0)
		then
			return fail(
				"content.invalid_modifier_value",
				`Modifier '{modifier.id}' has an invalid value`
			)
		end
		if
			not isFinite(modifier.priority)
			or modifier.priority < 0
			or modifier.priority ~= math.floor(modifier.priority)
		then
			return fail(
				"content.invalid_modifier_priority",
				`Modifier '{modifier.id}' must have a non-negative integer priority`
			)
		end
		local dependenciesFailure = validateStableIdList(
			modifier.id,
			modifier.dependencies,
			"modifier",
			"dependency",
			false
		)
		if dependenciesFailure ~= nil then
			return dependenciesFailure
		end
		modifiersById[modifier.id] = definitionsById[modifier.id] :: ModifierDefinition
	end

	for _, item in itemsById do
		if item.equipmentSlotId ~= nil then
			local slot = slotsById[item.equipmentSlotId]
			if slot == nil then
				return fail(
					"content.missing_reference",
					`Item '{item.id}' references missing slot '{item.equipmentSlotId}'`
				)
			end

			local acceptedTags: { [string]: boolean } = {}
			for _, tag in slot.acceptedItemTags do
				acceptedTags[tag] = true
			end
			local compatible = false
			for _, tag in item.tags do
				if acceptedTags[tag] then
					compatible = true
					break
				end
			end
			if not compatible then
				return fail(
					"content.incompatible_equipment_tags",
					`Item '{item.id}' has no tag accepted by slot '{slot.id}'`
				)
			end
		end
	end

	for _, tool in toolsById do
		local profession = professionsById[tool.professionId]
		if profession == nil then
			return fail(
				"content.missing_reference",
				`Tool '{tool.id}' references missing profession '{tool.professionId}'`
			)
		end
		if tool.requiredProfessionLevel > profession.contentLevelCap then
			return fail(
				"content.requirement_above_cap",
				`Tool '{tool.id}' requires level {tool.requiredProfessionLevel} above profession cap {profession.contentLevelCap}`
			)
		end
		for _, modifierId in tool.modifierIds do
			if modifiersById[modifierId] == nil then
				return fail(
					"content.missing_reference",
					`Tool '{tool.id}' references missing modifier '{modifierId}'`
				)
			end
		end
	end

	for _, action in actionsById do
		if itemsById[action.outputItemId] == nil then
			return fail(
				"content.missing_reference",
				`Action '{action.id}' references missing item '{action.outputItemId}'`
			)
		end
		local profession = professionsById[action.professionId]
		if profession == nil then
			return fail(
				"content.missing_reference",
				`Action '{action.id}' references missing profession '{action.professionId}'`
			)
		end
		if action.requiredProfessionLevel > profession.contentLevelCap then
			return fail(
				"content.requirement_above_cap",
				`Action '{action.id}' requires level {action.requiredProfessionLevel} above profession cap {profession.contentLevelCap}`
			)
		end
		local tool = toolsById[action.requiredToolId]
		if tool == nil then
			return fail(
				"content.missing_reference",
				`Action '{action.id}' references missing tool '{action.requiredToolId}'`
			)
		end
		if tool.professionId ~= action.professionId then
			return fail(
				"content.incompatible_tool_profession",
				`Action '{action.id}' and tool '{tool.id}' belong to different professions`
			)
		end
		for _, modifierId in action.modifierIds do
			if modifiersById[modifierId] == nil then
				return fail(
					"content.missing_reference",
					`Action '{action.id}' references missing modifier '{modifierId}'`
				)
			end
		end
	end

	for _, modifier in modifiersById do
		for _, dependencyId in modifier.dependencies do
			if modifiersById[dependencyId] == nil then
				return fail(
					"content.missing_reference",
					`Modifier '{modifier.id}' references missing dependency '{dependencyId}'`
				)
			end
		end
	end

	local visitState: { [string]: number } = {}
	local function visitModifier(modifierId: string): Failure?
		local state = visitState[modifierId]
		if state == 1 then
			return fail(
				"content.circular_modifier_reference",
				`Modifier dependency cycle includes '{modifierId}'`
			)
		elseif state == 2 then
			return nil
		end

		visitState[modifierId] = 1
		for _, dependencyId in modifiersById[modifierId].dependencies do
			local dependencyFailure = visitModifier(dependencyId)
			if dependencyFailure ~= nil then
				return dependencyFailure
			end
		end
		visitState[modifierId] = 2
		return nil
	end

	for modifierId in modifiersById do
		local cycleFailure = visitModifier(modifierId)
		if cycleFailure ~= nil then
			return cycleFailure
		end
	end

	table.sort(orderedDefinitions, definitionsSort)
	local frozenDefinitions = table.freeze(orderedDefinitions)

	local function resolveModifiers(modifierIds: { string }): { ModifierDefinition }
		local collected: { ModifierDefinition } = {}
		local included: { [string]: boolean } = {}
		local function collect(modifierId: string)
			if included[modifierId] then
				return
			end
			included[modifierId] = true
			local modifier = modifiersById[modifierId]
			for _, dependencyId in modifier.dependencies do
				collect(dependencyId)
			end
			table.insert(collected, modifier)
		end

		for _, modifierId in modifierIds do
			collect(modifierId)
		end
		table.sort(collected, modifiersSort)
		return table.freeze(collected)
	end

	local registry: Registry = {
		contentVersion = content.contentVersion,
		get = function(id: string): Definition?
			return definitionsById[id]
		end,
		getItem = function(id: string): ItemDefinition?
			return itemsById[id]
		end,
		getEquipmentSlot = function(id: string): EquipmentSlotDefinition?
			return slotsById[id]
		end,
		getProfession = function(id: string): ProfessionDefinition?
			return professionsById[id]
		end,
		getTool = function(id: string): ToolDefinition?
			return toolsById[id]
		end,
		getAction = function(id: string): ActionDefinition?
			return actionsById[id]
		end,
		getModifier = function(id: string): ModifierDefinition?
			return modifiersById[id]
		end,
		getActionModifiers = function(actionId: string): { ModifierDefinition }?
			local action = actionsById[actionId]
			if action == nil then
				return nil
			end
			return resolveModifiers(action.modifierIds)
		end,
		getToolModifiers = function(toolId: string): { ModifierDefinition }?
			local tool = toolsById[toolId]
			if tool == nil then
				return nil
			end
			return resolveModifiers(tool.modifierIds)
		end,
		all = function(): { Definition }
			return table.freeze(table.clone(frozenDefinitions))
		end,
	}

	return {
		ok = true,
		value = table.freeze(registry),
	}
end

return table.freeze(ContentRegistry)
