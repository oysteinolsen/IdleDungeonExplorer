--!strict

export type Config = {
	balanceVersion: string,
	globalProfessionXpMultiplier: number,
	testProfessionXpMultiplier: number,
}

local ProgressionBalance = {}

local DEFAULT: Config = table.freeze({
	balanceVersion = "balance.prototype_v1",
	globalProfessionXpMultiplier = 1,
	testProfessionXpMultiplier = 1,
})

ProgressionBalance.DEFAULT = DEFAULT

return table.freeze(ProgressionBalance)
