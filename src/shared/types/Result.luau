--!strict

export type Failure = {
	ok: false,
	code: string,
	retryable: boolean,
	detail: string?,
}

export type Result<T> = {
	ok: true,
	value: T,
} | Failure

return {}
