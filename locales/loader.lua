-- locales/loader.lua
-- Config.Locale で選択した言語を Config.Text に展開する（en を基準に不足キーを補完）
local base = (Locales and Locales["en"]) or {}
local sel = (Locales and Locales[Config.Locale or "en"]) or {}
local text = {}
for k, v in pairs(base) do text[k] = v end
for k, v in pairs(sel) do text[k] = v end
Config.Text = text
