local xxh64 = require("xxh64")
local xxh32 = require("xxh32")
local function ps(i)
	print(string.format("%x", i))
end

print(":: xxh64\n")
os.execute("printf qwertyuiopasdfghjklzxcvbnmQWERTYUIOPASDFGHJKLZXCVBNM | xxh64sum")
ps(xxh64.sum("qwertyuiopasdfghjklzxcvbnmQWERTYUIOPASDFGHJKLZXCVBNM"))
local s = xxh64.state(0)
--s:update()
ps(s:digest("qwertyuiopasdfghjklzxcvbnmQWERTYUIOPASDFGHJKLZXCVBNM"))

print("\n:: xxh32\n")
os.execute("printf qwertyuiopasdfghjklzxcvbnmQWERTYUIOPASDFGHJKLZXCVBNM | xxh32sum")
ps(xxh32.sum("qwertyuiopasdfghjklzxcvbnmQWERTYUIOPASDFGHJKLZXCVBNM"))
local s2 = xxh32.state(0)
--s:update()
ps(s2:digest("qwertyuiopasdfghjklzxcvbnmQWERTYUIOPASDFGHJKLZXCVBNM"))
