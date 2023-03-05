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
