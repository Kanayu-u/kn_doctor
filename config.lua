Config = {}

-- 救急隊のジョブ設定
Config.EMS = {
    JobName   = 'ambulance',  -- ジョブ名（サーバーに合わせて要変更）
    MaxOnDuty = 1,      -- 出勤中のEMSがこの人数以上いる場合にNPCの使用を拒否する
                        -- 例: 1 → EMSが1人以上出勤中なら拒否（0人の時のみ使用可）
                        -- 例: 0 → EMSの人数に関わらず、常時NPCドクターを利用可能（チェック無効）
}

-- 料金設定 (銀行口座から消費)
Config.Prices = {
    Revive = 300000,      -- 蘇生時の料金
    Heal   = 100000,      -- 回復時の料金
}

-- クールダウン設定（連打防止）
Config.Cooldown = 30   -- 再利用までの待機時間（秒）

-- 3Dテキスト表示設定
Config.Enable3DText = true -- 頭上に文字を表示するかどうか
Config.DrawDistance = 5.0  -- 名前が表示される距離

-- ドクターNPCの設定（複数追加可能）
Config.Doctors = {
    {
        Coords   = vector4(37.75, -362.57, 40.84, 250.28), -- 座標とヘディング (x, y, z, h)
        Model    = 's_m_m_doctor_01',                  -- NPCのモデル名
        Label    = '本署 デビット',                          -- ターゲット・メニューに表示する文字
        Distance = 20.0,                               -- NPCをスポーンさせる距離（Distance Culling）
    },
    -- 追加する場合はここにコピー&ペースト
    {
        Coords   = vector4(1813.78, 3664.16, 34.19, 300.56),
        Model    = 's_m_m_doctor_01',
        Label    = '砂漠署 アンドリュー',
        Distance = 20.0,
    },
    {
        Coords   = vector4(-448.27, 6017.5, 27.58, 224.38),
        Model    = 's_m_m_doctor_01',
        Label    = '北署 マイケル',
        Distance = 20.0,
    },
}

-- 言語設定: 'ja' / 'en'（表示テキストは locales/ 内のファイルで編集可能）
Config.Locale = 'ja'
