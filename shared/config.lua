--[[                                                --------------------------------->     FOR ASSISTANCE,SCRIPTS AND MORE JOIN OUR DISCORD (https://discord.gg/gbJ5SyBJBv) <---------------------------------                                                                                                                                                                                    
                                                                                                                                                                                                                                 
               AAA               NNNNNNNN        NNNNNNNN                 XXXXXXX       XXXXXXX   SSSSSSSSSSSSSSS TTTTTTTTTTTTTTTTTTTTTTTUUUUUUUU     UUUUUUUUDDDDDDDDDDDDD      IIIIIIIIII     OOOOOOOOO        SSSSSSSSSSSSSSS 
              A:::A              N:::::::N       N::::::N                 X:::::X       X:::::X SS:::::::::::::::ST:::::::::::::::::::::TU::::::U     U::::::UD::::::::::::DDD   I::::::::I   OO:::::::::OO    SS:::::::::::::::S
             A:::::A             N::::::::N      N::::::N                 X:::::X       X:::::XS:::::SSSSSS::::::ST:::::::::::::::::::::TU::::::U     U::::::UD:::::::::::::::DD I::::::::I OO:::::::::::::OO S:::::SSSSSS::::::S
            A:::::::A            N:::::::::N     N::::::N                 X::::::X     X::::::XS:::::S     SSSSSSST:::::TT:::::::TT:::::TUU:::::U     U:::::UUDDD:::::DDDDD:::::DII::::::IIO:::::::OOO:::::::OS:::::S     SSSSSSS
           A:::::::::A           N::::::::::N    N::::::N   ooooooooooo   XXX:::::X   X:::::XXXS:::::S            TTTTTT  T:::::T  TTTTTT U:::::U     U:::::U   D:::::D    D:::::D I::::I  O::::::O   O::::::OS:::::S            
          A:::::A:::::A          N:::::::::::N   N::::::N oo:::::::::::oo    X:::::X X:::::X   S:::::S                    T:::::T         U:::::D     D:::::U   D:::::D     D:::::DI::::I  O:::::O     O:::::OS:::::S            
         A:::::A A:::::A         N:::::::N::::N  N::::::No:::::::::::::::o    X:::::X:::::X     S::::SSSS                 T:::::T         U:::::D     D:::::U   D:::::D     D:::::DI::::I  O:::::O     O:::::O S::::SSSS         
        A:::::A   A:::::A        N::::::N N::::N N::::::No:::::ooooo:::::o     X:::::::::X       SS::::::SSSSS            T:::::T         U:::::D     D:::::U   D:::::D     D:::::DI::::I  O:::::O     O:::::O  SS::::::SSSSS    
       A:::::A     A:::::A       N::::::N  N::::N:::::::No::::o     o::::o     X:::::::::X         SSS::::::::SS          T:::::T         U:::::D     D:::::U   D:::::D     D:::::DI::::I  O:::::O     O:::::O    SSS::::::::SS  
      A:::::AAAAAAAAA:::::A      N::::::N   N:::::::::::No::::o     o::::o    X:::::X:::::X           SSSSSS::::S         T:::::T         U:::::D     D:::::U   D:::::D     D:::::DI::::I  O:::::O     O:::::O       SSSSSS::::S 
     A:::::::::::::::::::::A     N::::::N    N::::::::::No::::o     o::::o   X:::::X X:::::X               S:::::S        T:::::T         U:::::D     D:::::U   D:::::D     D:::::DI::::I  O:::::O     O:::::O            S:::::S
    A:::::AAAAAAAAAAAAA:::::A    N::::::N     N:::::::::No::::o     o::::oXXX:::::X   X:::::XXX            S:::::S        T:::::T         U::::::U   U::::::U   D:::::D    D:::::D I::::I  O::::::O   O::::::O            S:::::S
   A:::::A             A:::::A   N::::::N      N::::::::No:::::ooooo:::::oX::::::X     X::::::XSSSSSSS     S:::::S      TT:::::::TT       U:::::::UUU:::::::U DDD:::::DDDDD:::::DII::::::IIO:::::::OOO:::::::OSSSSSSS     S:::::S
  A:::::A               A:::::A  N::::::N       N:::::::No:::::::::::::::oX:::::X       X:::::XS::::::SSSSSS:::::S      T:::::::::T        UU:::::::::::::UU  D:::::::::::::::DD I::::::::I OO:::::::::::::OO S::::::SSSSSS:::::S
 A:::::A                 A:::::A N::::::N        N::::::N oo:::::::::::oo X:::::X       X:::::XS:::::::::::::::SS       T:::::::::T          UU:::::::::UU    D::::::::::::DDD   I::::::::I   OO:::::::::OO   S:::::::::::::::SS 
AAAAAAA                   AAAAAAANNNNNNNN         NNNNNNN   ooooooooooo   XXXXXXX       XXXXXXX SSSSSSSSSSSSSSS         TTTTTTTTTTT            UUUUUUUUU      DDDDDDDDDDDDD      IIIIIIIIII     OOOOOOOOO      SSSSSSSSSSSSSSS     

                                                 --------------------------------->     FOR ASSISTANCE,SCRIPTS AND MORE JOIN OUR DISCORD (https://discord.gg/gbJ5SyBJBv) <---------------------------------                                                                                                                                                                                                                                    
--]]
Config = {}
Config.Framework = 'auto' -- 'auto', 'esx', 'qbcore', 'qbox'
Config.Notify = 'ox' -- 'ox'
Config.ProgressBar = 'ox' -- 'ox'
Config.Menu = 'ox' -- 'ox'
Config.Target = 'ox' -- 'ox','qb'
Config.AlertDialog = 'ox' -- 'ox'
Config.Dispatch = 'ox' -- 'ox'
Config.Language = 'en' -- 'en'

Config.BlacklistJobs = {'police','ambulance'}
Config.UseZones = true -- Zone Bonus
Config.Debug = false -- Enable debug logs
Config.SellingDetails = true -- Details on Top Center

Config.Reputation = {
    Gain = 1, -- Reputation gained on successful sale
    Loss = 10, -- Reputation lost on refused sale
    Max = 100 -- Maximum reputation possible
}
Config.SaleChance = {
    baseSuccessRate = 0.5, -- Base success rate (50%) 
    reputationFactor = 0.005, -- How much each reputation point matters (0.5% per point)
    priceFactor = {
        min = 1.0, -- Multiplier at minimum price (100% of base)
        max = 0.25 -- Multiplier at maximum price (25% of base)
    }
}
Config.DispatchChance = {
    baseChance = 0.1, -- Base chance of alerting police (10%)
    reputationFactor = 0.001, -- How much each reputation point reduces chance (0.1% per point)
    priceFactor = 0.0009 -- How much price increases chance
}
Config.SaleSettings = {
    minDistanceFromPlayer = 50.0, -- Minimum spawn distance from player
    maxDistanceFromPlayer = 100.0, -- Maximum spawn distance from player
    interactionTimeout = 64, -- Seconds before sale opportunity expires
    saleAnimationTime = 5000, -- Milliseconds for sale animation
}
Config.NPCSettings = {
    walkDistance = 30.0, -- Distance NPCs will walk to player
    despawnTime = 60, -- Seconds before NPC despawns after interaction ends
    blipSprite = 480, -- Blip sprite ID for drug buyer
    blipColor = 1, -- Blip color
    blipScale = 0.8, -- Blip size
    models = { -- Models used for drug buyers
        'a_m_m_beach_01',
        'a_m_m_beach_02',
        'a_m_m_tramp_01',
        'a_m_y_downtown_01',
        'a_m_y_hipster_01',
        'a_m_y_skater_01',
        'a_m_y_stwhi_01'
    }
}

Config.Drugs = {
    oxy = {
        label = "oxy",
        minPrice = 100,
        maxPrice = 1000,
        DirtyMoney = false,
        prop = 'prop_meth_bag_01' -- Prop shown during sale
    },
    weed = {
        label = "Weed",
        minPrice = 50,
        maxPrice = 300,
        DirtyMoney = false,
        prop = 'prop_meth_bag_01'
    },
    meth = {
        label = "Meth",
        minPrice = 150,
        maxPrice = 1200,
        DirtyMoney = true,
        prop = 'prop_meth_bag_01'
    },
    heroin = {
        label = "Heroin",
        minPrice = 200,
        maxPrice = 1500,
        DirtyMoney = false,
        prop = 'prop_meth_bag_01'
    }
}

-- Drug Sale Zones (if Config.UseZones = true)
Config.Zones = {
    {
        name = "south_los_santos",
        coords = vector3(300.0, -2000.0, 20.0),
        radius = 300.0,
        multiplier = 2.0 -- Price multiplier in this zone (higher demand)
    },
    {
        name = "vinewood",
        coords = vector3(300.0, 400.0, 150.0),
        radius = 200.0,
        multiplier = 1.5 -- Rich people pay more
    },
    {
        name = "sandy_shores",
        coords = vector3(1800.0, 3800.0, 30.0),
        radius = 250.0,
        multiplier = 0.8 -- Lower prices in rural areas
    }
}