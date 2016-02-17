dofile("ws_client.lua")
local ws_client = websocket.createClient()
ws_client.on_connected = function (client, data) 
    print("Sending board metadata")
    client:send('{"NodeMCU": {"tempr": { "T": 1, "U": "*C"}}}')
end    
ws_client.on_pong = function (client, data) 
    print("PONG! data"..tostring(data))
end    
ws_client.on_receive = function (client, data) 
    print("RECEIVED, data "..tostring(data).."!")
    if data=="Go-go-go" then
        client:send('{"tempr": "25"}')
    end
end    
ws_client.on_close = function (client, data) 
    print("CLOSE, socket: "..tostring(client.socket)..", data "..tostring(data).."!")
    tmr.delay(5000)
    --client:connect("ws://192.168.0.77:7890/input")
end    
ws_client:connect("ws://192.168.0.77:7890/input")
return ws_client