# PreferencesTools.jl

[![Project Status: Active – The project has reached a stable, usable state and is being actively developed.](https://www.repostatus.org/badges/latest/active.svg)](https://www.repostatus.org/#active)
[![Test Status](https://github.com/cjdoris/PreferencesTools.jl/actions/workflows/tests.yml/badge.svg)](https://github.com/cjdoris/PreferencesTools.jl/actions/workflows/tests.yml)
[![Codecov](https://codecov.io/gh/cjdoris/PreferencesTools.jl/branch/main/graph/badge.svg?token=1flP5128hZ)](https://codecov.io/gh/cjdoris/PreferencesTools.jl)

A friendlier way to set preferences in Julia.

Built on top of [Preferences.jl](https://github.com/JuliaPackaging/Preferences.jl), this
package provides new commands in the Pkg REPL for getting and setting preferences.

In the following example, we find that Plots and PythonCall both have some preferences set
already and modify them.

```
julia> using PreferencesTools

julia> # press ] to enter the Pkg REPL

pkg> prefs st
Plots
  default_backend: "unicodeplots"
PythonCall
  exe: "python"

pkg> prefs add Plots default_backend=gr
Writing `.../example/LocalPreferences.toml`
Plots
  default_backend: "gr"
You may need to restart Julia for preferences to take effect.

pkg> prefs rm --all PythonCall
Writing `.../example/LocalPreferences.toml`
PythonCall
  No preferences.
You may need to restart Julia for preferences to take effect.
```

## API

See the docstrings for more details (e.g. `pkg> help prefs`).

### Commands
- `prefs st [-g|--global] [pkg]`
- `prefs add [-g|--global] [-x|--export] pkg key=value ...`
- `prefs rm [-g|--global] [-x|--export] [-a|--all] pkg key ...`

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
