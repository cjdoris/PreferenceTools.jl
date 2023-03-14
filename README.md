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

This package is mainly intended for interactive use. Packages (or any other code
programatically accessing preferences) should normally use
[Preferences.jl](https://github.com/JuliaPackaging/Preferences.jl)
directly.

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

## More REPL examples

You can set booleans, integers and floating point numbers.
```
pkg> preference add Example bool=true int=34 float=99.9
Writing `.../example/LocalPreferences.toml`
Example
  bool: true
  float: 99.9
  int: 34
You may need to restart Julia for preferences to take effect.
```

You can unset a preference by passing an empty value. This is equivalent to using the `rm`
command.
```
pkg> preference add Example bool=
Writing `.../example/LocalPreferences.toml`
Example
  float: 99.9
  int: 34
You may need to restart Julia for preferences to take effect.
```

Preferences can be set in your global environment (e.g. `~/.julia/environments/v1.8`) with
the `-g` flag. Preferences are inherited up the load path, meaning that local preferences
take precedence - see how the `float` preference does not change because it already has a
local value.
```
pkg> preference add -g Example bool=false float=0.0
Writing `.../example/LocalPreferences.toml`
Example
  bool: false
  float: 99.9
  int: 34
You may need to restart Julia for preferences to take effect.
```

In this case, unsetting the `bool` preference in the local environment has no effect,
because it has a default value from the global environment. To force the preference to be
removed in the local environment, you can pass the `nothing` value (or remove it from the
global environment).
```
pkg> preference add Example bool=
Writing `.../example/LocalPreferences.toml`
Example
  bool: false
  float: 99.9
  int: 34
You may need to restart Julia for preferences to take effect.

pkg> preference add Example bool=nothing
Writing `.../example/LocalPreferences.toml`
Example
  float: 99.9
  int: 34
You may need to restart Julia for preferences to take effect.
```

A value containing `,` is interpreted as a list. Blank entries are ignored, so `,` itself
is an empty list and `foo,` is a list with one value.
```
pkg> preference add Example list=foo,bar,baz one=1, empty=,
Writing `.../example/LocalPreferences.toml`
Example
  empty: Union{}[]
  float: 99.9
  int: 34
  list: ["foo", "bar", "baz"]
  one: [1]
You may need to restart Julia for preferences to take effect.
```

You can append to a list with `+=` and remove items with `-=`.
```
pkg> preference add Example list+=hello
Writing `.../example/LocalPreferences.toml`
Example
  empty: Union{}[]
  float: 99.9
  int: 34
  list: ["foo", "bar", "baz", "hello"]
  one: [1]
You may need to restart Julia for preferences to take effect.

pkg> preference add Example list-=bar,baz
Writing `.../example/LocalPreferences.toml`
Example
  empty: Union{}[]
  float: 99.9
  int: 34
  list: ["foo", "hello"]
  one: [1]
You may need to restart Julia for preferences to take effect.
```
