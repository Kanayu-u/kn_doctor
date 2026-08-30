local OxTarget     = GetResourceState('ox_target') == 'started'
local isStandalone = false

-- ターゲットシステムの有無を返す
function HasTargetSystem()
    return OxTarget
end

-- サーバーから Standalone フラグを受け取った際に設定
function SetStandaloneMode(value)
    isStandalone = value
end

-- クライアントサイドでの蘇生実行（Standalone 専用・二重蘇生防止）
function PerformRevive()
    if not isStandalone then return end
    local playerPed = cache.ped
    -- ped が無効な場合はスキップ
    if not playerPed or playerPed == 0 then return end
    if IsEntityDead(playerPed) then
        local coords = GetEntityCoords(playerPed)
        NetworkResurrectLocalPlayer(coords.x, coords.y, coords.z, GetEntityHeading(playerPed), true, false)
        SetEntityHealth(playerPed, GetEntityMaxHealth(playerPed))
        ClearPedBloodDamage(playerPed)
    end
end

-- クライアントサイドでの回復実行（全フレームワーク共通）
function PerformHeal()
    local playerPed = cache.ped
    -- ped が無効な場合はスキップ
    if not playerPed or playerPed == 0 then return end
    SetEntityHealth(playerPed, GetEntityMaxHealth(playerPed))
    ClearPedBloodDamage(playerPed)
end

-- 汎用通知（引数名を ntype にして Lua 標準関数 type() との衝突を回避）
function Notify(text, ntype)
    lib.notify({
        title       = 'Doctor',
        description = text,
        type        = ntype or 'inform',
    })
end


-- Standalone: サーバーから蘇生イベントを受信
RegisterNetEvent('kn_doctor:client:standaloneRevive', function()
    PerformRevive()
end)

-- 全フレームワーク共通: サーバーからヒールイベントを受信
RegisterNetEvent('kn_doctor:client:doHeal', function()
    PerformHeal()
end)

-- Standalone フラグをサーバーから受信して設定
RegisterNetEvent('kn_doctor:client:setStandalone', function(value)
    SetStandaloneMode(value)
end)
