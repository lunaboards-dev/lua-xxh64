local xxh64 = require("xxh64")
local function ps(i)
	print(string.format("%x", i))
end

os.execute("printf qwertyuiopasdfghjklzxcvbnmQWERTYUIOPASDFGHJKLZXCVBNM | xxh64sum")
ps(xxh64.sum("qwertyuiopasdfghjklzxcvbnmQWERTYUIOPASDFGHJKLZXCVBNM"))
local s = xxh64.state(0)
--s:update()
ps(s:digest("qwertyuiopasdfghjklzxcvbnmQWERTYUIOPASDFGHJKLZXCVBNM"))
