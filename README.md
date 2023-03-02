# PreferencesTools.jl

A friendlier way to set preferences in Julia.

Bulit on top of [Preferences.jl](https://github.com/JuliaPackaging/Preferences.jl), this
package provides new commands in the Pkg REPL for getting and setting preferences:

```
pkg> prefs st
...

pkg> prefs add SomePackage foo=true bar=/some/path
...

pkg> prefs rm SomePackage foo bar
...
```
