local config = {
    logFile = 'tarantool.log',
    port    = 2020,
    addr    = '*',
    rateLimiting = {
        rps = 200,
        maxDelay = 0.001,
        algoritm = 'window',  -- simple , window
        maxWindowRequest = 40,
    }
}
return config