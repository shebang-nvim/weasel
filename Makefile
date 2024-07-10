BUSTED_HELPER ?= $(PWD)/spec/fixtures.lua
NVIM_BIN ?= nvim

format:
	stylua -v --verify .

integration-test:
	LUA_PATH="$(shell luarocks path --lr-path --lua-version 5.1 --local);$(shell pwd)/?.lua" \
	LUA_CPATH="$(shell luarocks path --lr-cpath --lua-version 5.1 --local)" \
	# nlua spec/init.lua --helper=$(BUSTED_HELPER) spec/integration
	busted --run=integration 
	# $(NVIM_BIN) --headless -u spec/init.lua -- \
	# --helper=$(BUSTED_HELPER) $(BUSTED_ARGS)

test:
	LUA_PATH="$(shell luarocks path --lr-path --lua-version 5.1 --local);$(shell pwd)/?.lua" \
	LUA_CPATH="$(shell luarocks path --lr-cpath --lua-version 5.1 --local)" \
	# luarocks test --local --lua-version 5.1
	busted --run=unit

test_async: 
	@echo Test with $(LUA_VERSION) ......
	LUA_PATH="$(shell luarocks path --lr-path --lua-version 5.1 --local);$(shell pwd)/?.lua" \
	LUA_CPATH="$(shell luarocks path --lr-cpath --lua-version 5.1 --local)" \
	lua spec/init.lua --helper=$(BUSTED_HELPER) $(BUSTED_ARGS)


build:
	LUA_PATH="$(shell luarocks path --lr-path --lua-version 5.1 --local)" \
	LUA_CPATH="$(shell luarocks path --lr-cpath --lua-version 5.1 --local)" \
	luarocks build --local --lua-version 5.1
