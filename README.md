# PreferencesTools.jl

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
Writing `C:\Users\chris\.julia\environments\plots\LocalPreferences.toml`
Plots
  default_backend: "gr"
You may need to restart Julia for preferences to take effect.

pkg> prefs rm --all PythonCall
Writing `C:\Users\chris\.julia\environments\plots\LocalPreferences.toml`
PythonCall
  No preferences.
You may need to restart Julia for preferences to take effect.
```

## Commands and functions

The REPL commands all have corresponding functions.

### status

```
julia> PreferencesTools.status(["pkg"])

pkg> prefs st [pkg]
```

Show all the preferences currently set, optionally restricted to a particular package.

### add

```
julia> PreferencesTools.add("pkg", "key"=value, ...)

pkg> prefs add pkg key=value ...
```

Add one or more preferences for a package.

In the REPL, the value is one of the following
- blank to set the key back to its default (e.g. `x=`)
- `nothing` to force the key to its default if there is an inherited non-default value (e.g. `x=nothing`)
- a boolean, integer or float literal (e.g. `x=true`, `x=12`, `x=2.3`)
- otherwise the value is set as a string (e.g. `x=foo`)

### remove

```
julia> PreferencesTools.rm("pkg", "key", ...)

pkg> prefs rm pkg key ...
```

Remove preferences from a package.

### remove all

```
julia> PreferencesTools.rm_all("pkg")

pkg> prefs rm --all pkg
```

Remove all preferences from a package.

### get all

```
julia> PreferencesTools.get_all()

julia> PreferencesTools.get_all("pkg")
```

Return all preferences as a dictionary of dictionaries, mapping package names to preference
names to preference values.

## Flags and keyword arguments

### `-x` / `--export` / `_export=true`

Preferences are normally written to `LocalPreferences.toml`, which is not intended to be
shared with others. This flag writes them to `Project.toml` instead, and so can be used
to share preferences.

### `-g` / `--global` / `_global=true`

The commands in this package ordinarily work on the current active project. As a
convenience, this flag can be used to set preferences in your global environment
(e.g. `~/.julia/environments/v1.8`).

This is used to set default preferences for all projects. Preferences are merged up the load
path so local preferences over-ride global preferences.
