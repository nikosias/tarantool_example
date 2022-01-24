local config = {
    logFile = 'tarantool.log',
    port    = 80,
    addr    = '*',
    rateLimiting = {
        rps = 20,
        maxDelay = 0.001,
        algoritm = 'window',  -- simple , window
        maxWindowRequest = 4,
    }
}
return config