-- WePlay: Burner Booster -- Factorio 2.1
-- WHEN: respond to construction events.
-- WHAT: add a single stack of compatible fuel, capped by the amount setting.

local PRIORITY = { "coal", "wood", "solid-fuel", "rocket-fuel", "nuclear-fuel" }

-- Return true when this burner permits at least one of the item's fuel categories.
-- 2.1: both sides support multiple categories; burner categories are a lookup table.
local function accepts(burner, item)
  if not (item and item.fuel_value > 0 and item.fuel_categories) then return false end
  for _, category in pairs(item.fuel_categories) do
    if burner.fuel_categories[category] then return true end
  end
  return false
end

-- Choose a compatible item, prioritizing familiar vanilla fuels.
-- For modded-only categories, select the lowest energy-value fuel;
-- tie-break by name to make the result deterministic regardless of table order.
local function choose_fuel(burner)
  for _, name in ipairs(PRIORITY) do
    local item = prototypes.item[name]
    if accepts(burner, item) then return item end
  end

  local choice = nil
  for _, item in pairs(prototypes.item) do
    if accepts(burner, item) then
      if not choice or item.fuel_value < choice.fuel_value
         or (item.fuel_value == choice.fuel_value and item.name < choice.name) then
        choice = item
      end
    end
  end
  return choice
end

-- This is the reusable operation: it can handle furnaces, locomotives, etc.
local function fuel_new_entity(entity)
  if not (entity and entity.valid) then return end
  local burner = entity.burner
  if not (burner and burner.valid) then return end

  local inventory = burner.inventory
  if not (inventory and inventory.valid) then return end

  local item
  if settings.global["wp-starter-fuel-mode"].value == "automatic" then
    item = choose_fuel(burner)
  else
    item = prototypes.item[settings.global["wp-starter-fuel-type"].value]
    if not accepts(burner, item) then return end
  end
  if not item then return end

  local requested = settings.global["wp-starter-fuel-amount"].value
  -- 0 means 'one full stack', otherwise insert no more than requested.
  local amount = requested == 0 and item.stack_size or math.min(requested, item.stack_size)
  if amount > 0 then
    inventory.insert({name = item.name, count = amount})
  end
end

-- Factorio gives event handlers an event table. event.entity is the new entity.
local function on_built(event)
  fuel_new_entity(event.entity)
end

script.on_event({
  defines.events.on_built_entity,
  defines.events.on_robot_built_entity,
  defines.events.script_raised_built,
  defines.events.script_raised_revive,
  defines.events.on_space_platform_built_entity
}, on_built)

-- Intentionally no periodic refueling. Cloned entities are not refueled.
