--!strict

export type Config = {
	balanceVersion: string,
	baseBankCapacity: number,
	baseBankSlotCostGold: number,
	bankSlotCostIncrementGold: number,
	maximumBankCapacity: number,
}

local EconomyBalance = {}

EconomyBalance.DEFAULT = table.freeze({
	balanceVersion = "economy_balance.v1",
	baseBankCapacity = 40,
	baseBankSlotCostGold = 200,
	bankSlotCostIncrementGold = 50,
	maximumBankCapacity = 200,
}) :: Config

function EconomyBalance.bankSlotCost(config: Config, currentCapacity: number): number?
	if currentCapacity >= config.maximumBankCapacity then
		return nil
	end
	local purchasedSlots = math.max(0, currentCapacity - config.baseBankCapacity)
	return config.baseBankSlotCostGold + purchasedSlots * config.bankSlotCostIncrementGold
end

return table.freeze(EconomyBalance)
