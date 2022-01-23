local config = {
    logFile = nil,--'tarantool.log',
    port    = 2020,
    addr    = '*',
    rateLimiting = {
        rps = 10,
        maxDelay = 0.1,
        algoritm = 'window',  -- simple , window
    }
}
return config