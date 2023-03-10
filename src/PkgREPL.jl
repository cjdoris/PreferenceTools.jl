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

const string_opt = Pkg.REPLMode.OptionDeclaration([
    :name => "string",
    :short_name => "s",
    :api => :_string => true,
])

function complete_packages(options, partial)
    _global = get(options, :_global, false)
    ans = String[]
    cur_proj = Pkg.project().path
    try
        if _global
            Pkg.activate(io=devnull)
        end
        for proj in Base.load_path()
            Pkg.activate(proj, io=devnull)
            for (dep, _) in Pkg.project().dependencies
                if startswith(dep, partial)
                    push!(ans, dep)
                end
            end
        end
    finally
        Pkg.activate(cur_proj, io=devnull)
    end
    for (pkg, _) in PreferenceTools.get_all(; _global)
        if startswith(pkg, partial)
            push!(ans, pkg)
        end
    end
    sort!(unique!(ans))
end

function complete_prefs(options, partial)
    _global = get(options, :global, false)
    ans = String[]
    if '=' ∉ partial
        for (_, prefs) in PreferenceTools.get_all(; _global)
            for (pref, _) in prefs
                if startswith(pref, partial)
                    push!(ans, pref)
                end
            end
        end
    end
    sort!(unique!(ans))
end

function complete_packages_and_prefs(options, partial)
    sort!(unique!(vcat(complete_packages(options, partial), complete_prefs(options, partial))))
end

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
    completions = complete_packages,
)

### add

function _parse_value(str)
    str = String(strip(str))
    if ',' in str
        return Any[_parse_value(x) for x in split(str, ',') if !isempty(strip(x))]
    elseif str == "nothing"
        return nothing
    elseif str == "true"
        return true
    elseif str == "false"
        return false
    elseif (v = tryparse(Int, str)) !== nothing
        return v
    elseif (v = tryparse(Float64, str)) !== nothing
        return v
    else
        return str
    end
end

function _check_pkg(pkg)
    if '=' in pkg
        Pkg.Types.pkgerror("invalid package name: $pkg")
    end
end

function _check_key(key)
    if '=' in key
        Pkg.Types.pkgerror("invalid preference name: $key")
    end
end

function add(pkg, args...; _global=false, _export=false, _string=false)
    _check_pkg(pkg)
    oldprefs = PreferenceTools.get_all(pkg; _global)
    preference = map(args) do x
        '=' in x || Pkg.Types.pkgerror("preferences must be of the form key=value")
        key, value = split(x, '=', limit=2)
        _check_key(key)
        if !_string
            if value == ""
                value = missing
            else
                value = _parse_value(value)
            end
        end
        if endswith(key, "+") || endswith(key, "-")
            op = key[end]
            key = key[1:prevind(key,end)]
            oldvalue = get(oldprefs, key, [])
            oldvalue isa AbstractVector || Pkg.Types.pkgerror("existing value for `$key` is not a list")
            if !isa(value, AbstractVector)
                value = [value]
            end
            if op == '+'
                value = vcat(oldvalue, value)
            else
                @assert op == '-'
                value = filter(∉(value), oldvalue)
            end
        end
        oldprefs[key] = value
        String(key) => value
    end
    PreferenceTools.add(pkg, preference...; _global, _export, _interactive=true)
end

const add_help = Markdown.md"""
```
preference add [-g|--global] [-x|--export] [-s|--string] pkg key=value ...
```

Set preferences for a given package.

The `value` can be one of:
- blank to set the preference back to its default (e.g. `x=`)
- `nothing` to force it back to its default, over-riding any global preferences (e.g. `x=nothing`)
- a boolean, integer or float literal (e.g. `x=true`, `x=12`, `x=3.4`)
- a comma-separated list of values (e.g. `x=foo,bar`; `x=foo,` for a singleton; `x=,` for an empty list)
- anything else is a string (e.g. `x=/some/path`)

You can also modify existing values:
- `key+=value` appends the given value (or values) to the list at `key`
- `key-=value` removes the given value (or values) from the list at `key`

The `-s` flag treats all values as strings.

The `-g` flag sets the preferences in the global environment.

The `-x` flag exports the preferences to Project.toml.
"""

const add_spec = Pkg.REPLMode.CommandSpec(
    name = "add",
    api = add,
    help = add_help,
    description = "set preferences",
    arg_count = 1 => Inf,
    option_spec = [global_opt, export_opt, string_opt],
    completions = complete_packages_and_prefs,
)

### rm

function rm(pkg, keys...; _all=false, _global=false, _export=false)
    _check_pkg(pkg)
    foreach(_check_key, keys)
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
    completions = complete_packages_and_prefs,
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
