module PkgREPL

import ..PreferenceTools
import Pkg
import Markdown

### options

const all_opt = Pkg.REPLMode.OptionDeclaration([
    :name => "all",
    :short_name => "a",
    :api => :_all => true,
])

const global_opt = Pkg.REPLMode.OptionDeclaration([
    :name => "global",
    :short_name => "g",
    :api => :_global => true,
])

const export_opt = Pkg.REPLMode.OptionDeclaration([
    :name => "export",
    :short_name => "x",
    :api => :_export => true,
])

### status

function status(args...; _global=false)
    PreferenceTools.status(args...; _global)
end

const status_help = Markdown.md"""
```
preference st|status [-g|--global] [pkg]
```

Show all the preferences, optionally for a particular package.

The `-g` flag shows preferences in the global environment.
"""

const status_spec = Pkg.REPLMode.CommandSpec(
    name = "status",
    short_name = "st",
    api = status,
    help = status_help,
    description = "show all preferences",
    arg_count = 0 => 1,
    option_spec = [global_opt],
)

### add

function add(pkg, args...; _global=false, _export=false)
    preference = map(args) do x
        '=' in x || Pkg.Types.pkgerror("preferences must be of the form key=value")
        key, value = split(x, '=', limit=2)
        if value == "nothing"
            value = nothing
        elseif value == ""
            value = missing
        elseif value == "true"
            value = true
        elseif value == "false"
            value = false
        elseif (v = tryparse(Int, value)) !== nothing
            value = v
        elseif (v = tryparse(Float64, value)) !== nothing
            value = v
        end
        String(key) => value
    end
    PreferenceTools.add(pkg, preference...; _global, _export, _interactive=true)
end

const add_help = Markdown.md"""
```
preference add [-g|--global] [-x|--export] pkg key=value ...
```

Set preferences for a given package.

The `value` can be one of:
- blank to set the preference back to its default (e.g. `x=`)
- `nothing` to force it back to its default, over-riding any global preferences (e.g. `x=nothing`)
- a boolean, integer or float liters (e.g. `x=true`, `x=12`, `x=3.4`)
- anything else is a string (e.g. `x=/some/path`)

The `-g` flag sets the preferences in the global environment.

The `-x` flag exports the preferences to Project.toml.
"""

const add_spec = Pkg.REPLMode.CommandSpec(
    name = "add",
    api = add,
    help = add_help,
    description = "set preferences",
    arg_count = 1 => Inf,
    option_spec = [global_opt, export_opt],
)

### rm

function rm(pkg, keys...; _all=false, _global=false, _export=false)
    if _all
        PreferenceTools.rm_all(pkg; _global, _export, _interactive=true)
    elseif !isempty(keys)
        PreferenceTools.rm(pkg, keys...; _global, _export, _interactive=true)
    end
end

const rm_help = Markdown.md"""
```
preference rm|remove [-g|--global] [-x|--export] [-a|--all] pkg [key ...]
```

Unset preferences for a given package.

The `-a` flag removes all preferences.

The `-g` flag removes preferences from the global environment.

The `-x` flag exports the preferences to Project.toml.
"""

const rm_spec = Pkg.REPLMode.CommandSpec(
    name = "remove",
    short_name = "rm",
    api = rm,
    help = rm_help,
    description = "unset preferences",
    arg_count = 1 => Inf,
    option_spec = [all_opt, global_opt, export_opt],
)

### all specs

const SPECS = Dict(
    "status" => status_spec,
    "st" => status_spec,
    "add" => add_spec,
    "remove" => rm_spec,
    "rm" => rm_spec,
)

function __init__()
    # add the commands to the REPL
    Pkg.REPLMode.SPECS["preference"] = SPECS
    # update the help with the new commands
    copy!(Pkg.REPLMode.help.content, Pkg.REPLMode.gen_help().content)
end

end
