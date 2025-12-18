local QBCore = exports['qb-core']:GetCoreObject()

-- 複数メカニックジョブ対応チェック
local function isMechanicOnline()
    for _, id in pairs(QBCore.Functions.GetPlayers()) do
        local xPlayer = QBCore.Functions.GetPlayer(id)
        if xPlayer then
            for _, job in ipairs(Config.MechanicJobs) do
                if xPlayer.PlayerData.job.name == job then
                    return true
                end
            end
        end
    end
    return false
end

-- 修理イベント（支払い方法付き）
RegisterNetEvent('HA;_repairstation:attemptRepair', function(payType)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    if isMechanicOnline() then
        TriggerClientEvent('ox_lib:notify', src, {
            title = '修理不可',
            description = 'メカニックがオンライン中のため修理台は使用できません。',
            type = 'error'
        })
        return
    end

    local label = payType == 'bank' and '銀行口座' or '現金'
    local balance = Player.Functions.GetMoney(payType)

    if balance >= Config.RepairCost then
        Player.Functions.RemoveMoney(payType, Config.RepairCost, 'repair-station')
        TriggerClientEvent('HA;_repairstation:fixVehicle', src)
        TriggerClientEvent('ox_lib:notify', src, {
            title = '修理開始',
            description = string.format('$%d を%sから支払いました。', Config.RepairCost, label),
            type = 'inform'
        })
    else
        TriggerClientEvent('ox_lib:notify', src, {
            title = '支払い失敗',
            description = string.format('%sの残高が不足しています。($%d 必要)', label, Config.RepairCost),
            type = 'error'
        })
    end
end)
