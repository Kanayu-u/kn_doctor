local spawnedPeds   = {}
local textUIVisible = false
local isProcessing  = false

-- 3Dテキストの描画関数 (kn_teleport と完全に共通化)
local function DrawText3D(coords, text)
    local onScreen, _x, _y = GetScreenCoordFromWorldCoord(coords.x, coords.y, coords.z + 1.0)
    if onScreen then
        SetTextScale(0.35, 0.35)
        SetTextFont(0)
        SetTextProportional(1)
        SetTextColour(255, 255, 255, 215)
        SetTextEntry("STRING")
        SetTextCentre(1)
        AddTextComponentSubstringPlayerName(text)
        DrawText(_x, _y)
    end
end

-- ox_lib の初期化完了を待ってからポイントを登録
CreateThread(function()
    Wait(0)

    for i, data in ipairs(Config.Doctors) do
        local point = lib.points.new({
            coords   = vec3(data.Coords.x, data.Coords.y, data.Coords.z),
            distance = data.Distance or 30.0,
        })

        -- 範囲内に入った時: NPC をスポーン
        function point:onEnter()
            CreateThread(function()
                local modelHash = lib.requestModel(data.Model, 5000)
                if not modelHash then return end

                local x, y, z = data.Coords.x, data.Coords.y, data.Coords.z
                RequestCollisionAtCoord(x, y, z)
                local timeout = GetGameTimer() + 2000
                local foundGround, groundZ = false, z
                while GetGameTimer() < timeout do
                    foundGround, groundZ = GetGroundZFor_3dCoord(x, y, z + 1.0, false)
                    if foundGround then break end
                    Wait(100)
                end
                local spawnZ = foundGround and groundZ or z

                local ped = CreatePed(
                    4,
                    GetHashKey(data.Model),
                    x, y, spawnZ, data.Coords.w,
                    false,
                    true
                )
                
                if not ped or ped == 0 then return end
                
                SetEntityAsMissionEntity(ped, true, true)
                SetEntityVisible(ped, true, 0)
                SetPedDefaultComponentVariation(ped)
                
                Wait(0)
                FreezeEntityPosition(ped, true)
                SetEntityInvincible(ped, true)
                SetBlockingOfNonTemporaryEvents(ped, true)

                SetPedCanRagdoll(ped, false)
                SetPedConfigFlag(ped, 17, true)
                SetPedCanBeTargetted(ped, false)
                SetPedMaxHealth(ped, 99999)
                SetEntityHealth(ped, 99999)
                SetPedDiesWhenInjured(ped, false)
                ClearPedBloodDamage(ped)
                ResetPedVisibleDamage(ped)
                SetEntityCanBeDamaged(ped, false)

                spawnedPeds[i] = ped

                if HasTargetSystem() then
                    exports.ox_target:addLocalEntity(ped, {
                        {
                            name     = ('doctor_interact_%d'):format(i),
                            icon     = 'fa-solid fa-user-md',
                            label    = data.Label,
                            distance = 2.5,
                            onSelect = function()
                                OpenDoctorMenu()
                            end,
                        }
                    })
                end
            end)
        end

        -- 範囲外に出た時: NPC を削除
        function point:onExit()
            if textUIVisible then
                lib.hideTextUI()
                textUIVisible = false
            end

            if spawnedPeds[i] and DoesEntityExist(spawnedPeds[i]) then
                if HasTargetSystem() then
                    exports.ox_target:removeLocalEntity(spawnedPeds[i], ('doctor_interact_%d'):format(i))
                end
                SetEntityAsMissionEntity(spawnedPeds[i], false, true)
                DeleteEntity(spawnedPeds[i])
                spawnedPeds[i] = nil
            end
        end

        -- NPC 付近にいる時: 描画とキー入力待ち
        function point:nearby()
            -- 3Dテキストの表示 (kn_teleport と完全に共通化)
            if Config.Enable3DText and self.currentDistance < (Config.DrawDistance or 8.0) then
                DrawText3D(data.Coords, data.Label)
            end

            -- 5.0m 以内で TextUI を表示
            if self.currentDistance < 5.0 then
                if not textUIVisible then
                    lib.showTextUI(Config.Text.Interact, { position = 'left-center' })
                    textUIVisible = true
                end
                if IsControlJustPressed(0, 38) then -- [E] キー
                    OpenDoctorMenu()
                end
            else
                if textUIVisible then
                    lib.hideTextUI()
                    textUIVisible = false
                end
            end
        end
    end
end)

-- ドクターメニューを表示
function OpenDoctorMenu()
    if isProcessing then return end

    local playerPed = cache.ped
    if not playerPed or playerPed == 0 then return end

    local options = {}

    -- 蘇生と治療を1つの項目に統合（自動判別）
    table.insert(options, {
        title       = Config.Text.MenuTreat,
        description = Config.Text.MenuDesc:format(Config.Prices.Heal, Config.Prices.Revive),
        icon        = 'fa-solid fa-staff-aesculapius',
        onSelect    = function()
            RequestTreatment('medical')
        end,
    })

    table.insert(options, {
        title    = Config.Text.MenuCancel,
        icon     = 'fa-solid fa-xmark',
        onSelect = function() end,
    })

    lib.registerContext({
        id      = 'doctor_menu',
        title   = Config.Text.MenuTitle,
        options = options,
    })
    lib.showContext('doctor_menu')
end

-- サーバーへ治療リクエストを送信
function RequestTreatment(treatmentType)
    if isProcessing then return end
    isProcessing = true

    local success, response, remaining = lib.callback.await(
        'kn_doctor:server:processPayment', false, treatmentType
    )

    if success then
        Notify(Config.Text.Success, 'success')
    else
        if response == 'cooldown' then
            local secs = math.floor(remaining or 0)
            Notify(Config.Text.Cooldown:format(secs), 'error')
        elseif response == 'busy' then
            Notify(Config.Text.Busy, 'error')
        elseif response == 'no_money' then
            Notify(Config.Text.NoMoney, 'error')
        else
            Notify(Config.Text.Failed, 'error')
        end
    end

    isProcessing = false
end

-- リソース停止時のクリーンアップ
AddEventHandler('onResourceStop', function(resourceName)
    if resourceName ~= GetCurrentResourceName() then return end

    if textUIVisible then
        lib.hideTextUI()
        textUIVisible = false
    end
    for _, ped in pairs(spawnedPeds) do
        if DoesEntityExist(ped) then
            SetEntityAsMissionEntity(ped, false, true)
            DeleteEntity(ped)
        end
    end
end)
