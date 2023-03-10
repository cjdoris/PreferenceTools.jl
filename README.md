# PreferenceTools.jl

[![Project Status: Active – The project has reached a stable, usable state and is being actively developed.](https://www.repostatus.org/badges/latest/active.svg)](https://www.repostatus.org/#active)
[![Test Status](https://github.com/cjdoris/PreferenceTools.jl/actions/workflows/tests.yml/badge.svg)](https://github.com/cjdoris/PreferenceTools.jl/actions/workflows/tests.yml)
[![Test Status (nightly)](https://github.com/cjdoris/PreferenceTools.jl/actions/workflows/tests-nightly.yml/badge.svg)](https://github.com/cjdoris/PreferenceTools.jl/actions/workflows/tests-nightly.yml)
[![Codecov](https://codecov.io/gh/cjdoris/PreferenceTools.jl/branch/main/graph/badge.svg?token=1flP5128hZ)](https://codecov.io/gh/cjdoris/PreferenceTools.jl)

A friendlier way to set preferences in Julia.

Built on top of [Preferences.jl](https://github.com/JuliaPackaging/Preferences.jl), this
package provides new commands in the Pkg REPL for getting and setting preferences.

In the following example, we find that Plots and PythonCall both have some preferences set
already and modify them.

```
julia> using PreferenceTools

julia> # press ] to enter the Pkg REPL

pkg> preference status
Plots
  default_backend: "unicodeplots"
PythonCall
  exe: "python"

pkg> preference add Plots default_backend=gr
Writing `.../example/LocalPreferences.toml`
Plots
  default_backend: "gr"
You may need to restart Julia for preferences to take effect.

pkg> preference rm --all PythonCall
Writing `.../example/LocalPreferences.toml`
PythonCall
  No preferences.
You may need to restart Julia for preferences to take effect.
```

## API

See the docstrings for more details (e.g. `pkg> help preference`).

### Commands
- `preference st|status [pkg]`
- `preference add pkg key=value ...`
- `preference rm|remove [-a|--all] pkg key ...`

### Functions
- `status(["pkg"])`
- `add("pkg"; key=value, ...)` or `add("pkg", "key"=>value, ...)`
- `rm("pkg", "key", ...)`
- `rm_all("pkg")`
- `get_all(["pkg"])`

### Flags
- `-g`/`--global`/`_global=true` works in the global environment instead of the current
  project. This sets default preferences for all projects.
- `-x`/`--export`/`_export=true` writes preferences to `Project.toml` instead of
  `LocalPreferences.toml`. Use this to set default preferences to be shared with others
  (e.g. defaults for your own package).
- `-s`/`--string` forces the values given to `preference add` to be interpreted as strings,
  instead of parsing them.
