module PreferencesTools

import Pkg
import Preferences

function _in_global_env(f)
    proj = Pkg.project().path
    try
        Pkg.activate(; io=devnull)
        f()
    finally
        Pkg.activate(proj; io=devnull)
    end
end

function _project_file(; _global)
    ans = if _global
        _in_global_env() do 
            Pkg.project().path
        end
    else
        Pkg.project().path
    end
    endswith(ans, "Project.toml") || error("environment does not have a Project.toml: $ans")
    ans
end

function _prefs_file(; _global, _export)
    proj = _project_file(; _global)
    if !_export
        ans = joinpath(dirname(proj), "JuliaLocalPreferences.toml")
        if !isfile(ans)
            ans = joinpath(dirname(proj), "LocalPreferences.toml")
        end
    else
        ans = proj
    end
    ans
end

function add(pkg::String, args::Pair{String}...; _global::Bool=false, _export::Bool=false, _io::IO=stdout, _interactive::Bool=false, kw...)
    # find the project to modify
    proj = _prefs_file(; _global, _export)
    # get the preferences
    prefs = collect(Pair{String,Any}, args)
    for (key, value) in kw
        skey = String(key)
        startswith(skey, "_") && error("invalid keyword argument: $key")
        push!(prefs, eltype(prefs)(skey, value))
    end
    # set the preferences
    printstyled(_io, "Writing", color=:green, bold=true)
    println(_io, " `", proj, "`")
    Preferences.set_preferences!(proj, pkg, prefs...; force=true)
    if _interactive
        status(pkg; _io)
    end
    printstyled(_io, "You may need to restart Julia for preferences to take effect.", color=:yellow)
    println(_io)
    nothing
end

function rm(pkg::String, args::String...; kw...)
    add(pkg, map(x->x=>missing, args)...; kw...)
end

function rm_all(pkg::String; kw...)
    rm(pkg, keys(get_all(pkg))...; kw...)
end

function get_all(; _global::Bool=false)
    prefs = if _global
        _in_global_env() do 
            Base.get_preferences()
        end
    else
        Base.get_preferences()
    end
    Preferences.drop_clears(prefs)
end

function get_all(pkg::String; kw...)
    Base.get(Dict{String,Any}, get_all(; kw...), pkg)
end

function _status(io::IO, name, prefs)
    printstyled(io, name, bold=true)
    println(io)
    for (key, value) in prefs
        print(io, "  ", key, ": ")
        show(io, value)
        println(io)
    end
    if isempty(prefs)
        printstyled(io, "  No preferences.", color=:light_black)
        println(io)
    end
    nothing
end

function status(name::String; _io::IO=stdout, _global::Bool=false)
    prefs = get_all(name; _global)
    _status(_io, name, prefs)
end

function status(; _io::IO=stdout, _global::Bool=false)
    prefs = get_all(; _global)
    any = false
    for (name, prefs) in prefs
        if !isempty(prefs)
            any = true
            _status(_io, name, prefs)
        end
    end
    if !any
        printstyled(_io, "No preferences.", color=:light_black)
        println(_io)
    end
end

include("PkgREPL.jl")

end # module PreferencesTools
