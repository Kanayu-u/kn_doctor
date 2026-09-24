-- 通知(kn_timer / kn_doctor / kn_policearmor 共通。直すときは 3 つとも直すこと)
-- Config.Notify.Style = 'kn' ならこのリソース同梱の画面、'ox' なら ox_lib の通知で出す。
local OX_POSITION = {
    ['top-right'] = 'top-right', ['top-left'] = 'top-left', ['top-center'] = 'top',
    ['bottom-right'] = 'bottom-right', ['bottom-left'] = 'bottom-left',
}

-- ntype: 'success' / 'error' / 'warning' / 'info'
function KnNotify(title, description, ntype)
    local cfg = Config.Notify or {}
    ntype = ntype or 'info'

    if cfg.Style == 'ox' and lib and lib.notify then
        lib.notify({
            title       = title,
            description = description,
            type        = ntype == 'info' and 'inform' or ntype,
            duration    = cfg.Duration,
            position    = OX_POSITION[cfg.Position],
        })
        return
    end

    SendNUIMessage({
        action      = 'kn:notify',
        title       = title,
        description = description,
        type        = ntype,
        duration    = cfg.Duration,
        position    = cfg.Position,
    })
end
