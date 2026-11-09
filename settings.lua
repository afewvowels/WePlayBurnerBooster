-- WePlay: Burner Booster -- 2.1 settings
-- This file runs during the settings stage, NOT while playing.
data:extend({
  {
    type = "string-setting",
    name = "wp-starter-fuel-mode",
    setting_type = "runtime-global",
    default_value = "automatic",
    allowed_values = {"automatic", "manual"},
    order = "a"
  },
  {
    type = "string-setting",
    name = "wp-starter-fuel-type",
    setting_type = "runtime-global",
    default_value = "coal",
    allowed_values = {"wood", "coal", "solid-fuel", "rocket-fuel", "nuclear-fuel"},
    order = "b"
  },
  {
    type = "int-setting",
    name = "wp-starter-fuel-amount",
    setting_type = "runtime-global",
    default_value = 1,
    minimum_value = 0,
    maximum_value = 1000,
    order = "c"
  }
})
