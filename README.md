# lua-xxh64
Pure Lua xxHash64

## API

```lua
local xxh64 = require("xxh64")

-- xxh64.sum(input:string[, seed:integer]):integer
xxh64.sum("qwertyuiopasdfghjklzxcvbnmQWERTYUIOPASDFGHJKLZXCVBNM") -- -6187071714215514155

-- xxh64.state([seed:integer]):table
local state = xxh64.state()

-- state:digest([input:string]):integer
state:digest("qwertyuiopasdfghjklzxcvbnmQWERTYUIOPASDFGHJKLZXCVBNM") -- -6187071714215514155

-- state:reset([seed:integer])
state:reset(0xdeadbeef)

-- state:update(input:string)
state:update("qwertyuiopasdfghjklzxcvbnmQWERTYUIOPASDFGHJKLZXCVBNM")
state:digest() -- 7051555553238361330
```
