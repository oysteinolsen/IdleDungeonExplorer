--!strict

local SUCCESS_SENTINEL = table.concat({ "IDLE_DUNGEON", "_EXPLORER_TESTS_OK" })

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DevPackages = ReplicatedStorage:FindFirstChild("DevPackages")
assert(DevPackages, "DevPackages is missing from the test place")

local Tests = ReplicatedStorage:FindFirstChild("Tests")
assert(Tests, "Tests is missing from the test place")

local JestModule = DevPackages:FindFirstChild("Jest")
assert(JestModule, "Jest is missing from DevPackages")

local Jest = require(JestModule)
local status, result = Jest.runCLI(Tests, {
	ci = true,
	verbose = true,
}, { Tests }):awaitStatus()

if status == "Rejected" then
	error(`Jest rejected the test run: {tostring(result)}`)
end

if status ~= "Resolved" then
	error(`Jest returned an unexpected promise status: {tostring(status)}`)
end

if result.results.numFailedTestSuites > 0 or result.results.numFailedTests > 0 then
	error("Jest completed with one or more failing tests")
end

print(SUCCESS_SENTINEL)
