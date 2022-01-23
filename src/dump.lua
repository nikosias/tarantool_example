local function dump(tbl, idx)
    if(type(tbl) ~= 'table')then
        tbl = {tbl}
    end
    if(not idx)then
        idx=0
    end
    local res = {}
    for k,v in pairs(tbl) do
        local t = type(v)
        if(t == 'table') then
            print(string.format('%'..(idx*2)..'s %s = {', ' ', tostring(k)))
            dump(v, idx+1)
            print(string.format('%'..((idx+1)*2)..'s}',' '))
        else
            print(string.format('%'..(idx*2)..'s %s = %s', ' ',tostring(k), tostring(t == 'function' and 'function'
                or t == 'cdata' and 'cdata'
                or v)))
        end
    end
    return res
end

return function (...) return dump({...}) end