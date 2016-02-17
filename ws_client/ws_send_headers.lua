local socket = _G.do_input.socket
local host = _G.do_input.host
local path  = _G.do_input.path 
local add_header = _G.do_input.add_header

local mrandom = math.random
local toBase64 = crypto.toBase64
local pack_bytes = string.char
local band = bit.band
local rshift = bit.rshift
local hash = crypto.hash

local guid = "258EAFA5-E914-47DA-95CA-C5AB0DC85B11"

local write_int32 = function(v)
  return pack_bytes(
    band(rshift(v, 24), 0xFF),
    band(rshift(v, 16), 0xFF),
    band(rshift(v,  8), 0xFF),
    band(v, 0xFF)
  )
end

local generate_key = function()
  local r1 = mrandom(0,0xfffffff)
  local r2 = mrandom(0,0xfffffff)
  local r3 = mrandom(0,0xfffffff)
  local r4 = mrandom(0,0xfffffff)
  local key = write_int32(r1)..write_int32(r2)..write_int32(r3)..write_int32(r4)
  return toBase64(key)
end


local headers = ""

local sec_websocket_accept = function(sec_websocket_key)
  local a = sec_websocket_key..guid
  local sha1 = hash("sha1", a)
  assert((#sha1 % 2) == 0)
  return toBase64(sha1)
end


headers = headers.."GET "..path.." HTTP/1.1\r\n"
headers = headers.."Upgrade: WebSocket\r\n"
headers = headers.."Connection: Upgrade\r\n"
headers = headers.."Sec-WebSocket-Version: 7\r\n"
headers = headers.."Sec-Websocket-Key: "..sec_websocket_accept(generate_key()).."\r\n" --qRuMdykMYGEyIrjwimgOGL79D68=\r\n"
headers = headers.."Host: "..host.."\r\n"
headers = headers.."Origin: NodeMCUWebSocketClient\r\n"
headers = headers.."Nodeid: NodeMCU\r\n"

if #add_header > 0 then
    
end
headers = headers.."\r\n"

print("Handshaking headers: "..headers)

socket:send(headers)
