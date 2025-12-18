Config = {}

-- 💰 修理費用
Config.RepairCost = 30000

-- 🧑‍🔧 メカニック系ジョブ（複数対応OK）
Config.MechanicJobs = { 'mechanic', 'mechanic2', 'staff' }

-- ⏱ 修理時間（ms）
Config.RepairDuration = 8000 -- 例：5秒

-- 🧭 修理台設置場所
Config.Stations = {
    {
        coords = vec3(-337.24, -135.74, 39.01),
        heading = 180.0,
        label = 'ベニーズ裏 修理台'
    },
    {
        coords = vec3(1178.5, 2639.1, 37.75),
        heading = 90.0,
        label = 'サンディ 修理台'
    },
    {
        coords = vec3(-358.5, -128.14, 38.70),
        heading = 250.0,
        label = 'LSカスタム前 修理台'
    },
}

-- 🧰 修理台オブジェクト
Config.ObjectModel = `gr_prop_gr_bench_02b`

-- 🔧 その他設定
Config.Radius = 5.0
Config.Debug = false
