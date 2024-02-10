local prime1, prime2, prime3, prime4, prime5 = 0x9E3779B1, 0x85EBCA77, 0xC2B2AE3D, 0x27D4EB2F, 0x165667B1
local mask32 = 0xFFFFFFFF

local function rotl32(x, r)
	x = x & mask32
	return (((x) << (r)) | ((x) >> (32 - (r)))) & mask32
end

local function round(acc, input)
	acc = acc + (input * prime2)
	acc = acc & mask32
	acc = rotl32(acc, 13)
	acc = acc * prime1
	acc = acc & mask32
	return acc
end

local function avalanche(hash)
	hash = hash & mask32
	hash = hash ~ (hash >> 15)
	hash = hash * prime2
	hash = hash & mask32
	hash = hash ~ (hash >> 13)
	hash = hash * prime3
	hash = hash & mask32
	hash = hash ~ (hash >> 16)
	return hash
end

local function xxh32_finalize(hash, str)
	local len = #str & 15
	local pos, bits = 1, 0
	while len >= 4 do
		bits, pos = string.unpack("I", str, pos)
		hash = hash + (bits * prime3)
		hash = hash & mask32
		hash = rotl32(hash, 17) * prime4
		len = len - 4
	end
	while len > 0 do
		hash = hash + (str:byte(pos) * prime5)
		hash = hash & mask32
		hash = rotl32(hash, 11) * prime1
		pos = pos + 1
		len = len - 1
	end
	return avalanche(hash)
end

local function xxh32_endian_align(str, seed)
	seed = seed or 0
	local len = #str
	local h32 = 0
	local bits, pos = 0, 1
	if len >= 16 then
		local v1 = seed + prime1 + prime2
		local v2 = seed + prime2
		local v3 = seed
		local v4 = seed - prime1

		v1 = v1 & mask32
		v2 = v2 & mask32
		v3 = v3 & mask32
		v4 = v4 & mask32

		local limit = len - 15
		repeat
			bits, pos = string.unpack("<I", str, pos)
			v1 = round(v1, bits)
			bits, pos = string.unpack("<I", str, pos)
			v2 = round(v2, bits)
			bits, pos = string.unpack("<I", str, pos)
			v3 = round(v3, bits)
			bits, pos = string.unpack("<I", str, pos)
			v4 = round(v4, bits)
			--print(str:sub(pos))
		until #str - pos + 1 < 16

		h32 = rotl32(v1, 1) + rotl32(v2, 7) + rotl32(v3, 12) + rotl32(v4, 18)
	else
		h32 = seed + prime5
	end
	h32 = h32 + len
	h32 = h32 & mask32

	return xxh32_finalize(h32, str:sub(pos))
end

local state = {}

local function mask(st)
	st.v1 = st.v1 & mask32
	st.v2 = st.v2 & mask32
	st.v3 = st.v3 & mask32
	st.v4 = st.v4 & mask32
end

function state:reset(seed)
	seed = seed or 0
	self.v1 = seed + prime1 + prime2
	self.v2 = seed + prime2
	self.v3 = seed + 0
	self.v4 = seed - prime1
	mask(self)
end

function state:update(input)
	if #input == 0 then return end
	if #input + #self.buffer < 16 then
		self.size = self.size + #input
		self.buffer = self.buffer .. input
		return
	end
	self.size = self.size + #input
	input = self.buffer .. input
	local data_len = #input - (#input & 15)
	self.buffer = input:sub(data_len+1)
	local data = input:sub(1, data_len)

	local bits, pos = 0, 1
	repeat
		bits, pos = string.unpack("<I", input, pos)
		self.v1 = round(self.v1, bits)
		bits, pos = string.unpack("<I", input, pos)
		self.v2 = round(self.v2, bits)
		bits, pos = string.unpack("<I", input, pos)
		self.v3 = round(self.v3, bits)
		bits, pos = string.unpack("<I", input, pos)
		self.v4 = round(self.v4, bits)
	until #data - pos + 1 < 16
end

function state:digest(input)
	if input then
		self:update(input)
	end

	local h32 = 0
	if self.size >= 16 then
		h32 = rotl32(self.v1, 1) + rotl32(self.v2, 7) +
			  rotl32(self.v3, 12) + rotl32(self.v4, 18)
	else
		h32 = self.v3 + prime5
		h32 = h32 & mask32
	end

	h32 = h32 + self.size
	h32 = h32 & mask32

	return xxh32_finalize(h32, self.buffer)
end

local function create_state(seed)
	local s = {
		v1 = 0,
		v2 = 0,
		v3 = 0,
		v4 = 0,
		buffer = "",
		size = 0
	}
	setmetatable(s, {__index=state})
	s:reset(seed)
	return s
end

return {
	state = create_state,
	sum = function(str, seed)
		return xxh32_endian_align(str, seed or 0)
	end
}