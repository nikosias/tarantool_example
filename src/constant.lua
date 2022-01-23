local constant = {
    entrys = {
        post       = 'post', 
        put        = 'put',
        get        = 'get',  
        delete     = 'delete',
        base       = 'base',
        randomtime = 'randomtime'
    },
    logTypesEntry = {
        error = 'error',
        info  = 'info',
        debug = 'debug',
    },
    algoritm = {
        simple = 'testRPSSimple',
        window = 'testRPSwindow'

    }

}
constant.logTypes = {
    [constant.logTypesEntry.error] = 'log_messageError',
    [constant.logTypesEntry.info]  = 'log_messageInfo',
    [constant.logTypesEntry.debug] = 'log_messageDebug',
}
return constant