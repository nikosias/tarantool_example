local config = {
    logFile = nil,--'tarantool.log',
    port    = 8080,
    addr    = '*',
    rateLimiting = {
        rps = 10,
        maxDelay = 0.1,
        algoritm = 'simple',  -- simple , window
    }
}
return config