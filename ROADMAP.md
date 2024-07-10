# ROADMAP

1. modules
   1. [ ] provider modules
      1. [ ] create a spec for a provider

## Modules

Responsibility: Modules are used to load code via `luarocks` or `git`.

- SRIs:
  - Resolving names to Lua modules
  - Loading modules
  - Registering modules
  - Configure modules

Modules have data for its own responsibility and specifications for
dynamically creating classes. Modules do not care about specs.

### Example: Providers

Providers are used to create clients from a specification.
