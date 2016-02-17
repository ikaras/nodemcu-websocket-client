local band = bit.band
local bor = bit.bor
local rshift = bit.rshift
local char = string.char

local payload = _G.do_input.payload
local opcode = _G.do_input.opcode

opcode = opcode or 2
assert(type(opcode) == "number", "opcode must be number")
assert(type(payload) == "string", "payload must be string")
local len = #payload
local head = char(
bor(0x80, opcode),
bor(len < 126 and len or len < 0x10000 and 126 or 127)
)
if len >= 0x10000 then
    head = head .. char(
        0,0,0,0, -- 32 bit length is plenty, assume zero for rest
        band(rshift(len, 24), 0xff),
        band(rshift(len, 16), 0xff),
        band(rshift(len, 8), 0xff),
        band(len, 0xff)
    )
elseif len >= 126 then
    head = head .. char(band(rshift(len, 8), 0xff), band(len, 0xff))
end
return head .. payload
