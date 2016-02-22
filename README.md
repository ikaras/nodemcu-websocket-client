# WebSocket Client for NodeMCU and ESP8266 on Lua
Lightweight WebSocket Client, main class takes 12kb of heap, works stability

# Firmware modules dependencies
* bit
* crypto
* file
* net
* node
* tmr
* wifi

# How to start?
You can take my [firmware](https://github.com/ikaras/nodemcu-websocket-client/blob/master/firmwares/firmware-for-wsclient.bin) which I used for developing.

Set your SSID and PASSWORD in `ws_client/init.lua` and copy all files from the directory `ws_client`. All available configuration of client you can find in init.lua

# Example

```
    dofile("ws_client.lua")
    print("Loading ws sources takes "..(st - node.heap()).." bytes")

    -- configure ws client
    local ws_client = websocket.createClient()

    -- on established connection, after handshacking - good point to introduce your self
    ws_client.on_connected = function (client, data)
        print("Sending board metadata")
        client:send('{"NodeMCU": {"metadata": "bla-bla"}}')
    end

    -- you can ping server and process on pong
    ws_client.on_pong = function (client, data)
        print("PONG! data"..tostring(data))
    end

    -- receiving messages after connection
    ws_client.on_receive = function (client, data)
        print("RECEIVED, data "..tostring(data).."!")
        if data=="Go-go-go" then
            client:send('{"data": "value"}')
        end
    end

    -- catch event of closing - good point to reconnect
    ws_client.on_close = function (client, data)
        print("CLOSE, socket: "..tostring(client.socket)..", data "..tostring(data).."!")
        tmr.delay(5000000)      -- delay a little bit before reconnecting
        client:reconnect()
    end

    -- to start connection you need just to set full url, client take care about its parsing
    ws_client:connect("ws://some-host.com:7890/board_input")
```

# Special thanks
- *[Tim Caswell](https://github.com/creationix)* for his [websocket server](https://github.com/creationix/nodemcu-webide) - I used his code to encode and decode messages
- *[Gerhard Preuss](https://github.com/lipp)* for his [websockets for Lua](https://github.com/lipp/lua-websockets) - used his code for generating client unique key
