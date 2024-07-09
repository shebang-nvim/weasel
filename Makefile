format:
	stylua -v --verify .

integration-test:
	LUA_PATH="$(shell luarocks path --lr-path --lua-version 5.1 --local);$(shell pwd)/?.lua" \
	LUA_CPATH="$(shell luarocks path --lr-cpath --lua-version 5.1 --local)" \
	busted --run=integration

test:
	LUA_PATH="$(shell luarocks path --lr-path --lua-version 5.1 --local)" \
	LUA_CPATH="$(shell luarocks path --lr-cpath --lua-version 5.1 --local)" \
	luarocks test --local --lua-version 5.1

build:
	LUA_PATH="$(shell luarocks path --lr-path --lua-version 5.1 --local)" \
	LUA_CPATH="$(shell luarocks path --lr-cpath --lua-version 5.1 --local)" \
	luarocks build --local --lua-version 5.1
