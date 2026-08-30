local Framework   = nil
local OxInventory = false

CreateThread(function()
    Wait(0)
    if GetResourceState('qbx_core') == 'started' then
        Framework = 'QBX'
    elseif GetResourceState('es_extended') == 'started' then
        ESX = exports['es_extended']:getSharedObject()
        Framework = 'ESX'
    elseif GetResourceState('qb-core') == 'started' then
        QBCore = exports['qb-core']:GetCoreObject()
        Framework = 'QBCore'
    else
        Framework = 'Standalone'
    end
    OxInventory = GetResourceState('ox_inventory') == 'started'
    print(("^2[%s] ^7Framework: %s | ox_inventory: %s"):format(
        GetCurrentResourceName(), Framework, tostring(OxInventory)
    ))
end)

-- 公開関数: 出勤中の救急隊人数を取得
function GetEMSOnDutyCount()
    -- Framework が検出完了前に呼ばれた場合は 0 を返す（安全対策）
    if not Framework then return 0 end

    local count = 0
    if Framework == 'QBX' then
        local players = GetPlayers()
        for i = 1, #players do
            local player = exports.qbx_core:GetPlayer(tonumber(players[i]))
            if player and player.PlayerData.job.name == Config.EMS.JobName and player.PlayerData.job.onduty then
                count = count + 1
            end
        end
    elseif Framework == 'ESX' then
        local xPlayers = ESX.GetExtendedPlayers('job', Config.EMS.JobName)
        for _, xPlayer in ipairs(xPlayers) do
            if xPlayer.job and xPlayer.job.duty then
                count = count + 1
            end
        end
    elseif Framework == 'QBCore' then
        local players = QBCore.Functions.GetPlayers()
        for i = 1, #players do
            local player = QBCore.Functions.GetPlayer(players[i])
            if player and player.PlayerData.job.name == Config.EMS.JobName and player.PlayerData.job.onduty then
                count = count + 1
            end
        end
    end
    -- Standalone は常に 0（EMS制限なし）
    return count
end

-- 公開関数: 銀行から指定金額を引き落とす（成功: true / 残高不足: false）
-- 銀行残高は ox_inventory 使用時もフレームワーク側（qbx/qb/esx）が管理するため、
-- 常にフレームワーク API で引き落とす（ox_inventory の 'money' は現金アイテムであり銀行ではない）
function DeductBankMoney(playerSrc, amount)
    -- Framework が検出完了前に呼ばれた場合は失敗とする（安全対策）
    if not Framework then return false end

    if Framework == 'QBX' then
        local player = exports.qbx_core:GetPlayer(playerSrc)
        if not player then return false end
        if player.PlayerData.money['bank'] >= amount then
            return exports.qbx_core:RemoveMoney(playerSrc, 'bank', amount, 'kn_doctor: treatment fee')
        end
        return false
    elseif Framework == 'ESX' then
        local xPlayer = ESX.GetPlayerFromId(playerSrc)
        if not xPlayer then return false end
        --[[
          **口座の有無を確かめてから読む。** getAccount は該当口座が無いと nil を返すため、
          そのまま .money を読むとサーバー側で落ちる。
          また **ESX の removeAccountMoney は残高不足を検査しない**ので
          （内部の underflow 判定は金額が負のときしか働かない）、
          ここでの事前確認が唯一の防波堤になる。外さないこと。
        ]]
        local account = xPlayer.getAccount('bank')
        if account and (account.money or 0) >= amount then
            xPlayer.removeAccountMoney('bank', amount, 'kn_doctor: treatment fee')
            return true
        end
        return false
    elseif Framework == 'QBCore' then
        local player = QBCore.Functions.GetPlayer(playerSrc)
        if not player then return false end
        if player.PlayerData.money['bank'] >= amount then
            player.Functions.RemoveMoney('bank', amount)
            return true
        end
        return false
    end
    -- Standalone: 経済システムが無いため無料（常に成功扱い）
    return true
end

-- 公開関数: サーバー側から蘇生イベントを送信
-- 引数名を playerSrc に変更（グローバル source との混同を防止）
function TriggerRevive(playerSrc)
    if Framework == 'QBX' then
        TriggerClientEvent('hospital:client:Revive', playerSrc)
    elseif Framework == 'ESX' then
        TriggerClientEvent('esx_ambulancejob:revive', playerSrc)
    elseif Framework == 'QBCore' then
        TriggerClientEvent('hospital:client:Revive', playerSrc)
    else
        TriggerClientEvent('kn_doctor:client:standaloneRevive', playerSrc)
    end
end

function TriggerHeal(playerSrc)
    TriggerClientEvent('kn_doctor:client:doHeal', playerSrc)
end
function IsPlayerDead(playerSrc)
    if not Framework then return false end

    if Framework == 'QBX' then
        local player = exports.qbx_core:GetPlayer(playerSrc)
        return player and (player.PlayerData.metadata['isdead'] or player.PlayerData.metadata['inlaststand'])
    elseif Framework == 'ESX' then
        local ped = GetPlayerPed(playerSrc)
        return GetEntityHealth(ped) <= 0 or Entity(ped).state.isDead
    elseif Framework == 'QBCore' then
        local player = QBCore.Functions.GetPlayer(playerSrc)
        return player and (player.PlayerData.metadata['isdead'] or player.PlayerData.metadata['inlaststand'])
    end
    
    return GetEntityHealth(GetPlayerPed(playerSrc)) <= 0
end

AddEventHandler('playerJoining', function()
    local src = source
    CreateThread(function()
        Wait(1500)
        if Framework == 'Standalone' then
            TriggerClientEvent('kn_doctor:client:setStandalone', src, true)
        end
    end)
end)
