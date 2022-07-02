local holdingUp = false
local store = ""
local blipRobbery = nil
local RobSekarang = nil
local countLockpick = 0
local statusrob

ESX = nil

local Keys = {
	["ESC"] = 322, ["F1"] = 288, ["F2"] = 289, ["F3"] = 170, ["F5"] = 166, ["F6"] = 167, ["F7"] = 168, ["F8"] = 169, ["F9"] = 56, ["F10"] = 57,
	["~"] = 243, ["1"] = 157, ["2"] = 158, ["3"] = 160, ["4"] = 164, ["5"] = 165, ["6"] = 159, ["7"] = 161, ["8"] = 162, ["9"] = 163, ["-"] = 84, ["="] = 83, ["BACKSPACE"] = 177,
	["TAB"] = 37, ["Q"] = 44, ["W"] = 32, ["E"] = 38, ["R"] = 45, ["T"] = 245, ["Y"] = 246, ["U"] = 303, ["P"] = 199, ["["] = 39, ["]"] = 40, ["ENTER"] = 18,
	["CAPS"] = 137, ["A"] = 34, ["S"] = 8, ["D"] = 9, ["F"] = 23, ["G"] = 47, ["H"] = 74, ["K"] = 311, ["L"] = 182,
	["LEFTSHIFT"] = 21, ["Z"] = 20, ["X"] = 73, ["C"] = 26, ["V"] = 0, ["B"] = 29, ["N"] = 249, ["M"] = 244, [","] = 82, ["."] = 81,
	["LEFTCTRL"] = 36, ["LEFTALT"] = 19, ["SPACE"] = 22, ["RIGHTCTRL"] = 70,
	["HOME"] = 213, ["PAGEUP"] = 10, ["PAGEDOWN"] = 11, ["DELETE"] = 178,
	["LEFT"] = 174, ["RIGHT"] = 175, ["TOP"] = 27, ["DOWN"] = 173,
	["NENTER"] = 201, ["N4"] = 108, ["N5"] = 60, ["N6"] = 107, ["N+"] = 96, ["N-"] = 97, ["N7"] = 117, ["N8"] = 61, ["N9"] = 118
}

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end

	while ESX.GetPlayerData().job == nil do
		Citizen.Wait(100)
	end

	ESX.PlayerData = ESX.GetPlayerData()
end)

function drawTxt(x,y ,width,height,scale, text, r,g,b,a, outline)

    SetTextFont(4)

    SetTextProportional(0)

    SetTextScale(scale, scale)

    SetTextColour(r, g, b, a)

    SetTextDropShadow(0, 0, 0, 0,255)

    SetTextEdge(2, 0, 0, 0, 255)

    SetTextDropShadow()

    SetTextOutline()

    SetTextEntry("STRING")

    AddTextComponentString(text)

    DrawText(x - width/2, y - height/2 + 0.005)

end



RegisterNetEvent('esx_holdup:currentlyRobbing')

AddEventHandler('esx_holdup:currentlyRobbing', function(currentStore)

	holdingUp, store = true, currentStore

end)



RegisterNetEvent('esx_holdup:killBlip')

AddEventHandler('esx_holdup:killBlip', function()

	RemoveBlip(blipRobbery)

end)



RegisterNetEvent('esx_holdup:setBlip')

AddEventHandler('esx_holdup:setBlip', function(position)

	blipRobbery = AddBlipForCoord(position.x, position.y, position.z)



	SetBlipSprite(blipRobbery, 161)

	SetBlipScale(blipRobbery, 2.0)

	SetBlipColour(blipRobbery, 3)



	PulseBlip(blipRobbery)



	Citizen.Wait(2700000)

	RemoveBlip(blipRobbery)

end)



RegisterNetEvent('esx_holdup:tooFar')

AddEventHandler('esx_holdup:tooFar', function()

	holdingUp, store = false, ''

	ESX.ShowNotification(_U('robbery_cancelled'))

end)



RegisterNetEvent('esx_holdup:robberyComplete')

AddEventHandler('esx_holdup:robberyComplete', function(award)

	holdingUp, store = false, ''

	ESX.ShowNotification(_U('robbery_complete', award))

end)



RegisterNetEvent('esx_holdup:startTimer')

AddEventHandler('esx_holdup:startTimer', function()

	local timer = Stores[store].secondsRemaining



	Citizen.CreateThread(function()

		while timer > 0 and holdingUp do

			Citizen.Wait(1000)



			if timer > 0 then

				timer = timer - 1

			end

		end

	end)



	Citizen.CreateThread(function()

		while holdingUp do

			Citizen.Wait(0)

			drawTxt(0.89, 1.44, 1.0, 1.0, 0.6, _U('robbery_timer', timer), 255, 255, 255, 255)

		end

	end)

end)



Citizen.CreateThread(function()

	while true do

		Citizen.Wait(1)

		local playerPos = GetEntityCoords(PlayerPedId(), true)



		for k,v in pairs(Stores) do

			local storePos = v.position

			local distance = Vdist(playerPos.x, playerPos.y, playerPos.z, storePos.x, storePos.y, storePos.z)



			if distance < Config.Marker.DrawDistance then

				if not holdingUp then

					DrawMarker(Config.Marker.Type, storePos.x, storePos.y, storePos.z - 1, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, Config.Marker.x, Config.Marker.y, Config.Marker.z, Config.Marker.r, Config.Marker.g, Config.Marker.b, Config.Marker.a, false, false, 2, false, false, false, false)



					if distance < 0.5 then

						ESX.ShowHelpNotification(_U('press_to_rob', v.nameOfStore))



						if IsControlJustReleased(0, Keys['E']) then

							RobSekarang = k

							ESX.TriggerServerCallback('evan-robberywarung:lockpick', function(result)

								if result then

									TriggerEvent('evan-robberywarung:openhtml', 'robbery', storePos.x, storePos.y, storePos.z)
									exports['mythic_notify']:SendAlert('inform', 'Memulai...', 3000)

								else

									exports['mythic_notify']:SendAlert('error', 'Tidak memiliki lockpick!', 10000)

								end

							end, 'lockpick')

						end

					end

				end

			end

		end



		if holdingUp then

			local storePos = Stores[store].position

			if Vdist(playerPos.x, playerPos.y, playerPos.z, storePos.x, storePos.y, storePos.z) > Config.MaxJarakRampok then

				TriggerServerEvent('esx_holdup:tooFar', store)

			end

		end

	end

end)



local menuEnabled = false

local isLokcpicking = false



RegisterNetEvent('evan-robberywarung:openhtml')

AddEventHandler('evan-robberywarung:openhtml', function(status, x1, y1, z1)

	statusrob = status

	Citizen.Wait(500)

	if statusrob == 'robbery' then

	isLokcpicking = true

	SetNuiFocus( true, true )

    SendNUIMessage({showPlayerMenu = true})

	TriggerEvent('evan-robberywarung:animlockpick')

end)



RegisterNetEvent('evan-robberywarung:closehtml')

AddEventHandler('evan-robberywarung:closehtml', function()

	SetNuiFocus( false, false )

	isLokcpicking = false

end)



RegisterNetEvent('evan-robberywarung:triggerserver')

AddEventHandler('evan-robberywarung:triggerserver', function()

	TriggerServerEvent('esx_holdup:robberyStarted', RobSekarang)

end)



RegisterNetEvent('evan-robberywarung:animlockpick')

AddEventHandler('evan-robberywarung:animlockpick', function()

	local lPed = PlayerPedId()

    RequestAnimDict("veh@break_in@0h@p_m_one@")

    while not HasAnimDictLoaded("veh@break_in@0h@p_m_one@") do

        Citizen.Wait(0)

    end

    while isLokcpicking do

        if not IsEntityPlayingAnim(lPed, "veh@break_in@0h@p_m_one@", "low_force_entry_ds", 3) then

            TaskPlayAnim(lPed, "veh@break_in@0h@p_m_one@", "low_force_entry_ds", 1.0, 1.0, 1.0, 1, 0.0, 0, 0, 0)

            Citizen.Wait(1500)

            ClearPedTasks(PlayerPedId())

        end

        Citizen.Wait(1)

    end

end)



RegisterNetEvent('evan-robberywarung:closehtmlui')

AddEventHandler('evan-robberywarung:closehtmlui', function()

	SetNuiFocus(false, false)

	if isLokcpicking then 

		TriggerServerEvent('lockpick:removeitem')

	end

end)



RegisterCommand("cobarob", function()

	isLokcpicking = true

	SetNuiFocus( true, true )

    SendNUIMessage({

		showPlayerMenu = true

	})

	TriggerEvent('evan-robberywarung:animlockpick')

end)




RegisterCommand("closehtml", function()

	SetNuiFocus( false, false )

	isLokcpicking = false

end)



RegisterNUICallback('win', function(data, cb)

	isLokcpicking = false

	if statusrob == 'robbery' then

		TriggerEvent('evan-robberywarung:triggerserver')

	end



	SetNuiFocus( false, false )

	SendNUIMessage({showPlayerMenu = false})

	exports['mythic_notify']:SendAlert('success', 'Berhasil!', 10000)

	TriggerServerEvent('lockpick:removeitem')

  	cb('ok')

end)



RegisterNUICallback('lose', function(data, cb)

	isLokcpicking = false

	countLockpick = countLockpick + 1

	local random = math.random(1, 5)

	SetNuiFocus( false, false )

	SendNUIMessage({

		showPlayerMenu = false

	})

	exports['mythic_notify']:SendAlert('error', 'Gagal!', 10000)

	if random == 3 then 
		TriggerServerEvent('lockpick:removeitem')
	elseif countLockpick == 3 then 
		TriggerServerEvent('lockpick:removeitem')
		countLockpick = 0
	end
	cb('ok')
end)

RegisterNUICallback('close', function(data, cb)
	isLokcpicking = false
	ToggleActionMenu()
	cb('ok')
end)

RegisterNUICallback('closeButton', function(data, cb)
	isLokcpicking = false
	killTutorialMenu()
	cb('ok')
end)

function ToggleActionMenu()
	menuEnabled = not menuEnabled
	if ( menuEnabled ) then
		SetNuiFocus( true, true )
		SendNUIMessage({
			showPlayerMenu = true
		})
	else
		SetNuiFocus( false )
		SendNUIMessage({
			showPlayerMenu = false
		})
	end
end

function killTutorialMenu()
	SetNuiFocus( false, false )
	SendNUIMessage({
		showPlayerMenu = false
	})
	menuEnabled = false
end
