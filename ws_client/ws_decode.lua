local band = bit.band
local bor = bit.bor
local lshift = bit.lshift
local byte = string.byte
local sub = string.sub
local applyMask = crypto.mask

local chunk = _G.do_input

if #chunk < 2 then return end
local second = byte(chunk, 2)
local len = band(second, 0x7f)
local offset
if len == 126 then
if #chunk < 4 then return end
len = bor(
  lshift(byte(chunk, 3), 8),
  byte(chunk, 4))
offset = 4
elseif len == 127 then
if #chunk < 10 then return end
len = bor(
  -- Ignore lengths longer than 32bit
  lshift(byte(chunk, 7), 24),
  lshift(byte(chunk, 8), 16),
  lshift(byte(chunk, 9), 8),
  byte(chunk, 10))
offset = 10
else
offset = 2
end
local mask = band(second, 0x80) > 0
if mask then
offset = offset + 4
end
if #chunk < offset + len then return end

local first = byte(chunk, 1)
local payload = sub(chunk, offset + 1, offset + len)
assert(#payload == len, "Length mismatch")
if mask then
payload = applyMask(payload, sub(chunk, offset - 3, offset))
end
local extra = sub(chunk, offset + len + 1)
local opcode = band(first, 0xf)
return extra, payload, opcode

