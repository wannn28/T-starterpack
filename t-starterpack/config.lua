-- config.lua
Config = {
    framework = 'qbcore',    -- Options: 'qbcore', 'esx'
    emote = 'clipboard',
    FuelResource = 'qb-fuel', -- qb-fuel, ps-fuel
    target = 'qb-target',    -- Options: 'qb-target', 'qtarget', 'ox_target', 'drawtext'
    locationped = vector4(-1032.32, -2735.09, 20.17, 109.65),
    locationvehicle = vector4(-1030.19, -2730.87, 20.14, 243.51),
    ped = 'a_m_m_hasjew_01',
    starterpackladies = true,
    starterpacks = {
         umum = { -- General Starter Pack
              item = {
                   ['cash'] = { amount = 500000 },
                   ['box_starterpack'] = { amount = 1 },
                   ['box_phone'] = { amount = 1 },
              },
              vehicles = {
                   ['gtr'] = {
                        label = "NISSAN GTR SPORTS", -- bisalah kasih uang kopi hihihi
                        model = "sultanrs"
                   },
              }
         },
         ladies = {
              item = {
                   ['cash'] = { amount = 1000000 },
                   ['box_starterpack'] = { amount = 1 },
                   ['box_phone'] = { amount = 1 },
              },
              vehicles = {
                   ['gtr'] = {
                        label = "NISSAN GTR SPORTS",
                        model = "sultanrs"
                   },
              }
         }
    }
}
