do
local websocket = {}
_G.websocket = websocket

function websocket.createClient()
    local client = {
        socket = nil,

        connection_string = nil,
        timeout = 0,

        add_headers = {},
        on_receive = nil,       -- on_receive(client, data)
        on_close = nil,         -- on_close(client, last_message)
        on_connected = nil,     -- on_close(client, received_headers)
        on_pong = nil,          -- on_close(client, ping_message)
        buffer = "",

        isConnected = function(self)
            return self.socket ~= nil
        end,
        
        send = function (self, data, opcode)
            opcode = opcode or 2
            print("[client] Sending data: "..data.."\r\n")
            local params = {
                payload = data,
                opcode = opcode,
            }
            local encoded_data = self:make("encode", params)
            self.socket:send(encoded_data)
        end,

        receive = function (self, chunk)
            local extra, payload, opcode = self:make("decode", chunk)
            print("[client] Received opcode="..tostring(opcode)..", payload="..tostring(payload)..", extra="..tostring(extra))
            print("[client] Free memory: "..tostring(node.heap()))
            if not opcode then
                print("[client] Not found opcode")
            elseif opcode == 0x0 then
                print("[client] Not full frame")
                self.buffer = self.buffer .. payload
                return
            else
                if payload == nil then
                    payload = ""
                end
                payload = self.buffer..payload
                self.buffer = ""
            end
            
            if opcode == 9 then         -- ping
                print("[client] Received PING from the server")
                self:send("Pong", 0xA)
                return
            elseif opcode == 0xA then       -- pong
                print("[client] Received PONG from the server")
                if self.on_pong then
                    self.on_pong(self, payload)
                end
                return
            elseif opcode == 0x8 then       -- close
                print("[client] Received CLOSE from the server")
                self:close()
                return
            end

            if self.on_receive then
                self.on_receive(self, payload)
            end
        end,

        ping = function (self)
            print("[client] Send PING to the server")
            self:send("Ping", 0x9)
        end,

        sendHandshake = function (self, host, path)
            print("[client] Handshaking")
            local params = {
                socket = self.socket,
                host = host,
                path = path,
                add_header = self.add_headers
            }
            self:make("send_headers", params)
        end,

        readHandshake = function (self, result)
            print("[client] Read handshake: "..result)
            self.socket:on("receive", function(s, data) self:receive(data) end)
            if self.on_connected then
                print("[client] Connected!")
                self.on_connected(self, result)
            end
        end,

        make = function (self, file, input)
            _G.do_input = input
            return dofile("ws_"..file..".lua")
        end,

        connect = function (self, connection_string, timeout)
            print("[client] Connect to "..connection_string)
            local protocol, host, port, path = self:make("parse_url", connection_string)

            timeout = timeout or 5
            self.socket = net.createConnection(net.TCP, timeout)
            self.timeout = timeout
            self.connection_string = connection_string
            
            self.socket:on("connection", function(sck) self:sendHandshake(host, path) end)
            self.socket:on("receive", function (sk, c) self:readHandshake(c) end)
            self.socket:on("reconnection", function(sck) print("\r\nRECONNECTING\r\n") end)
            self.socket:on("disconnection", function (sk, c) self:close() end)

            print("[client] Connect with host "..host.." and port "..port)
            self.socket:connect(tonumber(port), host)
        end,

        reconnect = function (self)
            if not self.connection_string then
                error({message="Not found connection string to reconnect"})
            else
                print("Reconnecting...")
                self:connect(self.connection_string, self.timeout)
            end
        end,

        close = function (self)
            print("[client] Close connectin")
            if self.socket then
                self.socket:close()
            end
            self.socket = nil
            if self.on_close then
                self.on_close(self, payload)
            end
        end
    }
    return client
end

end
