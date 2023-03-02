module PkgREPL

import ..PrefsUtils
import Pkg
import Markdown

### options

const all_opt = Pkg.REPLMode.OptionDeclaration([
    :name => "all",
    :short_name => "a",
    :api => :all => true,
])

### status

function status()
    PrefsUtils.status()
end
function status(name)
    PrefsUtils.status(name)
end

const status_help = Markdown.md"""
```
prefs st|status [pkg]
```

Show all the preferences, optionally for a particular package.
"""

const status_spec = Pkg.REPLMode.CommandSpec(
    name = "status",
    short_name = "st",
    api = status,
    help = status_help,
    description = "show all preferences",
    arg_count = 0 => 1,
)

### add

function add(args)
    pkg, args... = args
    prefs = map(args) do x
        '=' in x || error("preferences must be of the form key=value")
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
        Symbol(key) => value
    end
    PrefsUtils.set!(pkg; prefs...)
    PrefsUtils.status(pkg)
end

const add_help = Markdown.md"""
```
prefs add pkg key=value ...
```

Set preferences for a given package.
"""

const add_spec = Pkg.REPLMode.CommandSpec(
    name = "add",
    api = add,
    help = add_help,
    description = "set preferences",
    arg_count = 1 => Inf,
    should_splat = false,
)

### rm

function rm(args; all=false)
    pkg, keys... = args
    if all
        error("not implemented")
    end
    if !isempty(keys)
        PrefsUtils.delete!(pkg, keys...)
    end
    PrefsUtils.status(pkg)
end

const rm_help = Markdown.md"""
```
prefs rm|remove pkg key ...
prefs rm|remove pkg --all
```

Unset preferences for a given package.
"""

const rm_spec = Pkg.REPLMode.CommandSpec(
    name = "remove",
    short_name = "rm",
    api = rm,
    help = rm_help,
    description = "unset preferences",
    arg_count = 1 => Inf,
    should_splat = false,
    option_spec = [all_opt],
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
    Pkg.REPLMode.SPECS["prefs"] = SPECS
    # update the help with the new commands
    copy!(Pkg.REPLMode.help.content, Pkg.REPLMode.gen_help().content)
end

end
