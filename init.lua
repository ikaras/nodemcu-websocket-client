wifi.setmode(wifi.STATIONAP)
wifi.sta.config("<SSID>","<PASSWORD>")
wifi.sta.connect()

tmr.alarm(0, 3000, 1, function ()
  local ip = wifi.sta.getip()
  if ip then
    tmr.stop(0)
    print("IP: "..ip..", memory: "..node.heap())
    st = node.heap()

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

  end
end)
