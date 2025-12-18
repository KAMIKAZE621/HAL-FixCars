local spawnedStations = {}

CreateThread(function()
    for _, v in pairs(Config.Stations) do
        -- 工具台設置
        local model = Config.ObjectModel
        RequestModel(model)
        while not HasModelLoaded(model) do Wait(10) end

        local obj = CreateObject(model, v.coords.x, v.coords.y, v.coords.z - 1.0, false, false, false)
        SetEntityHeading(obj, v.heading or 0.0)
        FreezeEntityPosition(obj, true)
        SetEntityInvincible(obj, true)
        SetEntityAsMissionEntity(obj, true, true)
        table.insert(spawnedStations, obj)

        -- ox_target 登録
        exports.ox_target:addLocalEntity(obj, {
            {
                name = 'HA;_repairstation_' .. (v.label or 'repair'),
                label = ('%s ($%d)'):format(v.label or '修理台', Config.RepairCost),
                icon = 'fa-solid fa-wrench',
                distance = Config.Radius,
                onSelect = function()
                    local ped = PlayerPedId()
                    local veh = GetVehiclePedIsIn(ped, false)
                    if veh == 0 then
                        lib.notify({
                            title = 'エラー',
                            description = '車に乗っていません。',
                            type = 'error'
                        })
                        return
                    end

                    local engine = GetVehicleEngineHealth(veh)
                    local body = GetVehicleBodyHealth(veh)
                    if engine >= 999.0 and body >= 999.0 then
                        lib.notify({
                            title = '修理不要',
                            description = '車両はすでに完全な状態です。',
                            type = 'inform'
                        })
                        return
                    end

                    -- 🧾 支払い選択メニュー
                    local menu = {
                        {
                            title = '💵 現金で支払う',
                            description = ('修理費: $%d\n修理時間: %.1f秒'):format(Config.RepairCost, Config.RepairDuration / 1000),
                            icon = 'fa-solid fa-money-bill',
                            onSelect = function()
                                TriggerServerEvent('HA;_repairstation:attemptRepair', 'cash')
                            end
                        },
                        {
                            title = '🏦 銀行で支払う',
                            description = ('修理費: $%d\n修理時間: %.1f秒'):format(Config.RepairCost, Config.RepairDuration / 1000),
                            icon = 'fa-solid fa-building-columns',
                            onSelect = function()
                                TriggerServerEvent('HA;_repairstation:attemptRepair', 'bank')
                            end
                        },
                        {
                            title = 'キャンセル',
                            icon = 'fa-solid fa-xmark',
                            onSelect = function()
                                lib.notify({
                                    title = 'キャンセル',
                                    description = '修理を中止しました。',
                                    type = 'inform'
                                })
                            end
                        }
                    }

                    lib.registerContext({
                        id = 'HA;_repair_menu_' .. (v.label or ''),
                        title = '🔧 修理台メニュー',
                        options = menu
                    })
                    lib.showContext('HA;_repair_menu_' .. (v.label or ''))
                end
            }
        })
    end
end)

-- 🚗 修理処理
RegisterNetEvent('HA;_repairstation:fixVehicle', function()
    local ped = PlayerPedId()
    local veh = GetVehiclePedIsIn(ped, false)

    if veh ~= 0 then
        -- エンジン停止 & 固定
        SetVehicleEngineOn(veh, false, true, true)
        FreezeEntityPosition(veh, true)
        SetVehicleUndriveable(veh, true)

        lib.progressBar({
            duration = Config.RepairDuration,
            label = '修理中...',
            useWhileDead = false,
            canCancel = false,
            disable = { move = false, combat = true },
        })

        -- 修理完了
        SetVehicleFixed(veh)
        SetVehicleDirtLevel(veh, 0.0)
        SetVehicleEngineHealth(veh, 1000.0)
        SetVehicleBodyHealth(veh, 1000.0)
        SetVehiclePetrolTankHealth(veh, 1000.0)

        -- 固定解除 & 自動再始動
        FreezeEntityPosition(veh, false)
        SetVehicleUndriveable(veh, false)
        SetVehicleEngineOn(veh, true, true, false)

        lib.notify({
            title = '修理完了',
            description = ('修理が完了しました！（所要 %.1f 秒）'):format(Config.RepairDuration / 1000),
            type = 'success'
        })
    end
end)
