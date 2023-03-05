# PreferencesTools.jl

A friendlier way to set preferences in Julia.

Built on top of [Preferences.jl](https://github.com/JuliaPackaging/Preferences.jl), this
package provides new commands in the Pkg REPL for getting and setting preferences.

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

pkg> prefs rm Plots default_backend
Writing `C:\Users\chris\.julia\environments\plots\LocalPreferences.toml`
Plots
  No preferences.
You may need to restart Julia for preferences to take effect.
```
