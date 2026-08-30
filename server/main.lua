-- クールダウン管理テーブル（key: source, value: 最後の使用時刻（os.time））
local cooldowns = {}

-- 救急隊人数チェック・料金引き落とし・処理トリガーを行うコールバック
lib.callback.register('kn_doctor:server:processPayment', function(source, treatmentType)

    -- クールダウンチェック（30秒制限）
    local now = os.time()
    local lastUsed = cooldowns[source]
    if lastUsed then
        local elapsed = now - lastUsed
        local remaining = Config.Cooldown - elapsed
        if remaining > 0 then
            return false, 'cooldown', remaining
        end
    end

    -- EMS出勤数チェック
    local emsCount = GetEMSOnDutyCount()
    if Config.EMS.MaxOnDuty > 0 and emsCount >= Config.EMS.MaxOnDuty then
        return false, 'busy', 0
    end

    -- プレイヤーの状態（死亡・ダウン）を自動判別
    local isDead = IsPlayerDead(source)
    local amount = isDead and Config.Prices.Revive or Config.Prices.Heal

    -- 銀行から引き落とし
    local success = DeductBankMoney(source, amount)
    if not success then
        return false, 'no_money', 0
    end

    -- 引き落とし成功 → クールダウンを記録してから処理をトリガー
    cooldowns[source] = now

    -- 監査ログ（金銭処理）
    print(('[kn_doctor] Payment: charged $%d to %s (ID:%d) for %s'):format(
        amount, GetPlayerName(source) or 'unknown', source, isDead and 'revive' or 'heal'))

    if isDead then
        TriggerRevive(source) -- 蘇生を実行 (bridge.lua)
    else
        TriggerHeal(source)   -- 回復を実行 (bridge.lua)
    end

    return true, 'success', 0
end)

-- プレイヤー切断時にクールダウンデータを解放（メモリリーク防止）
AddEventHandler('playerDropped', function()
    local src = source -- source をローカルにキャプチャして安全に参照
    cooldowns[src] = nil
end)
