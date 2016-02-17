local connectionString = _G.do_input
print("Conn value: "..connectionString)
local pattern = "://([^/:]+)(:?([0-9]?[0-9]?[0-9]?[0-9]?[0-9]?))(/.*)$"
local host, _, port, path = string.match(connectionString, "^ws"..pattern)
if host then
    protocol = "ws"
else
    host, _, port, path = string.match(connectionString, "^ws"..pattern)
    if host then
        protocol = "wss"
    end
end
print("Parsed protocol: "..(protocol or "")..", host: "..(host or "")..
            ", port: "..(port or "")..", path: "..(path or ""))

if (protocol == "ws" or protocol == "wss") then
    if (port == nil or port == "") then
        if (protocol == "ws") then
            port = 80
        else
            port = 443
        end
    end
    return protocol, host, port, path
elseif (protocol) then
    error({message="Wrong protocol "..protocol..", must be ws or wss"})
else
    error({message="Wrong connection string"})
end