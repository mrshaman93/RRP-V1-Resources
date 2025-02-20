QBCore = exports['qb-core']:GetCoreObject()

local vehicle_sounds = {}
local PlayerJob = QBCore.Functions.GetPlayerData().job

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
  PlayerJob = QBCore.Functions.GetPlayerData().job
end)

RegisterNetEvent('QBCore:Client:OnJobUpdate', function(JobInfo)
  PlayerJob = JobInfo
end)

function StartListeningForControl(jobName)
	listen = true
	InputDisabled = false
	CreateThread(function()
		while listen do
			if IsControlJustReleased(0, 38) and not InputDisabled then -- E
				Openengine(jobName)
			end
			Wait(1)
		end
	end)
end

function Openengine(jobName)
  local ped = PlayerPedId()
  local vehicle = GetVehiclePedIsIn(ped)
  local plate = GetVehicleNumberPlateText(vehicle)
  local enginemenu = {}

  enginemenu[#enginemenu + 1] = {
    header = "Engine Swap - Plate: " .. plate,
    isMenuHeader = true
  }

  for _, v in pairs(Config.Swaps) do
    enginemenu[#enginemenu + 1] = {
      header = v.label,
	    txt = "$ ".. v.price,
      params = {
        isServer = true, 
        event = "an-engine:server:engine",
        args = {
          sound = v.soundname,
          price = v.price,
          job = jobName,
        }
      }
    }
  end

  enginemenu[#enginemenu + 1] = {
    header = "Close menu.",
    txt = "",
    params = {
      event = "qb-menu:closeMenu"
    }
  }

  exports['qb-menu']:openMenu(enginemenu)
end

CreateThread(function()
  for _, v in pairs(Config.engineLocations) do 
    QBCore.Functions.GetPlayerData(function(PlayerData)
      PlayerJob = PlayerData.job
      swapZone = CircleZone:Create(v["coords"], v["size"], { 
        name = v["text"], 
        heading = v["heading"], 
        debugPoly = v["debug"], 
        PlayerJob = v["authorizedJob"],
        useZ = true, 
      })
      swapZone:onPlayerInOut(function(isPointInside)
        if Config.Settings['Notify'] == "ps-ui" then
          if isPointInside then
            if Config.Settings['Job']['UseJob'] then
              if PlayerJob.name == v["authorizedJob"] then
                local playerPed = PlayerPedId()
                if IsPedSittingInAnyVehicle(playerPed) then
                  exports[Config.Settings['Notify']]:DisplayText(v["inVehicle"]) 
                  StartListeningForControl(v["authorizedJob"])
                else
                  exports[Config.Settings['Notify']]:DisplayText(v["outVehicle"]) 
                end
              else 
                QBCore.Functions.Notify("You are not qualified", "error")
              end
            else
              local playerPed = PlayerPedId()
              if IsPedSittingInAnyVehicle(playerPed) then
                exports[Config.Settings['Notify']]:DisplayText(v["inVehicle"]) 
                StartListeningForControl('mechanic')
              else
                exports[Config.Settings['Notify']]:DisplayText(v["outVehicle"]) 
              end
            end
          else
            exports[Config.Settings['Notify']]:HideText('hide')
            listen = false
          end
        else
          if isPointInside then
            if Config.Settings['Job']['UseJob'] then
              if PlayerJob.name == v["authorizedJob"] then
                local playerPed = PlayerPedId()
                if IsPedSittingInAnyVehicle(playerPed) then
                  exports[Config.Settings['Notify']]:DisplayText(v["inVehicle"]) 
                  StartListeningForControl(v["authorizedJob"])
                else
                  exports[Config.Settings['Notify']]:DisplayText(v["outVehicle"]) 
                end
              else 
                QBCore.Functions.Notify("You are not qualified", "error")
              end
            else
              local playerPed = PlayerPedId()
              if IsPedSittingInAnyVehicle(playerPed) then
                exports[Config.Settings['Notify']]:DisplayText(v["inVehicle"]) 
                StartListeningForControl('mechanic')
              else
                exports[Config.Settings['Notify']]:DisplayText(v["outVehicle"]) 
              end
            end
          else
            exports[Config.Settings['Notify']]:HideText('hide')
            listen = false
          end
        end
      end)
    end)
  end
end)

CreateThread(function()
    while true do
      local mycoords = GetEntityCoords(PlayerPedId())
      for _,v in pairs(GetGamePool('CVehicle')) do
          local veh = Entity(v).state
          if #(mycoords - GetEntityCoords(v, false)) < 100 and veh and veh.exhaust and veh.engine then
            local plate = GetVehicleNumberPlateText(v)
            if vehicle_sounds[plate] == nil then
              vehicle_sounds[plate] = {}
              vehicle_sounds[plate].exhaust = veh.exhaust
              vehicle_sounds[plate].plate = plate
              vehicle_sounds[plate].entity = v
              vehicle_sounds[plate].engine = veh.engine
            end
            vehicle_sounds[plate].exhaust = veh.exhaust
            if vehicle_sounds[plate] ~= nil and vehicle_sounds[plate].plate ~= nil and plate == vehicle_sounds[plate].plate and vehicle_sounds[plate].current ~= vehicle_sounds[plate].exhaust then
                ForceVehicleEngineAudio(v, vehicle_sounds[plate].exhaust)
                vehicle_sounds[plate].current = vehicle_sounds[plate].exhaust
            end
          elseif #(mycoords - GetEntityCoords(v, false)) > 100 and vehicle_sounds[plate] ~= nil and vehicle_sounds[plate].current ~= nil then
            vehicle_sounds[plate].current = nil
          end
      end
      for k,v in pairs(vehicle_sounds) do
        if not DoesEntityExist(v.entity) then
          vehicle_sounds[k] = nil
        end
      end
      Wait(2000)
    end
end)
