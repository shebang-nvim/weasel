local assert = assert
---@cast assert -function,+weasel.luassert

local helper = require "spec.helper"
local is_callable = vim.is_callable

---@type table<string,weasel.configuration.user>
local configs = {}

configs["empty"] = {
  lazy_loading = false,
  load = {
    provider = {},
  },
}
configs["with_provider_datamuse"] = {
  lazy_loading = false,
  load = {
    provider = {
      ["core.datamuse"] = {
        config = {},
      },
    },
  },
}

describe("weasel #integration", function()
  after_each(function()
    helper.unload_weasel()
  end)

  describe("public API", function()
    describe("when calling require('weasel')", function()
      it("exports setup()", function()
        local weasel = require "weasel"
        assert(weasel)
        assert.Function(weasel.setup)
      end)

      it("does not initialize the logger", function()
        local weasel = require "weasel"
        assert(weasel)
        assert.Function(weasel.setup)

        local log = require "weasel.core.log"
        assert.no.Function(log.debug)
      end)
    end)
    describe("weasel.setup()", function()
      it("initializes the logger", function()
        require("weasel").setup()
        local log = require "weasel.core.log"
        assert.Function(log.debug)
      end)

      describe("without config", function()
        it("exports the API with defaults", function()
          local weasel = require("weasel").setup()
          assert(weasel)
          assert.Table(weasel.config)
          assert.Table(weasel.config.user_config)
          assert.Table(weasel.config.user_config.load)
          assert.Table(weasel.config.user_config.load.provider)
          assert.Table(weasel.config.user_config.load.provider["core.generic"])
        end)
      end)

      describe("with config", function()
        it("exports the API with defaults", function()
          local weasel = require("weasel").setup(configs["with_provider_datamuse"])
          assert(weasel)
          assert.Table(weasel.config)
          assert.Table(weasel.config.user_config)
          assert.Table(weasel.config.user_config.load)
          assert.Table(weasel.config.user_config.load.provider)
          assert.Table(weasel.config.user_config.load.provider["core.generic"])
          assert.Table(weasel.config.user_config.load.provider["core.datamuse"])
        end)
      end)
    end)

    describe("weasel.client", function()
      it("exports a callable", function()
        local weasel = require("weasel").setup()
        assert(is_callable(weasel.client), "expect weasel.client to be a callable")
      end)

      describe("weasel.client(provider)", function()
        it("returns the client", function()
          local weasel = require("weasel").setup()
          -- assert(weasel)
          local client = weasel.client "core.datamuse"
          vim.print("test>>>>>>>>>>>>>", client)
          -- assert.Table(weasel.client)
          -- assert(is_callable(weasel.client), "expect weasel.client to be a callable")
          -- vim.print(weasel)
        end)
      end)
    end)
  end)

  if false then
    ---TODO: mock modules and test module loading logic
    describe("loading provider core.datamuse", function()
      local weasel

      local modules
      before_each(function()
        weasel = require "weasel"
        assert(weasel)

        weasel.setup(configs["with_provider_datamuse"])
        weasel.loader(true)

        modules = require "weasel.core.modules"
      end)

      it("core.modules.is_module_loaded() returns true", function()
        assert(modules.is_module_loaded("core.datamuse", "provider"))
      end)

      it("core.modules.get_module('core.datamuse', 'provider') returns the module's public API", function()
        local api = modules.get_module("core.datamuse", "provider")

        assert.String(api.version)
        assert.Function(api.word_sounds_like)
      end)

      it("core.modules.get_module_config('core.datamuse', 'provider') returns the module's config", function()
        local config = modules.get_module_config("core.datamuse", "provider")
        -- vim.print(config)

        assert.equal("datamuse", config.name)
        assert.Table(config.services)
        assert.Table(config.services.sounds_like)
        assert.Table(config.services.sounds_like.endpoint)
        assert.equal("https://api.datamuse.com/words", config.services.sounds_like.endpoint.url)
      end)
    end)

    describe("library loading", function()
      it("loads an empty config", function()
        local weasel = require "weasel"
        weasel.setup(configs["empty"])
        if not weasel.is_loaded() then
          weasel.loader(true)
        end

        assert(weasel)
      end)

      it("loads provider datamuse", function()
        local weasel = require "weasel"
        weasel.setup(configs["with_provider_datamuse"])
        if not weasel.is_loaded() then
          weasel.loader(true)
        end
        assert(weasel)

        local config = require "weasel.core.config"
        assert.Table(config.user_config.load.provider)
        assert.Table(config.user_config.load.provider["core.datamuse"])

        local modules = require "weasel.core.modules"
        assert.Table(modules.loaded_modules.provider["core.datamuse"])
        assert.equal(1, modules.loaded_modules_count)
      end)
    end)
  end
end)
