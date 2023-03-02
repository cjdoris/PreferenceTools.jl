module PreferencesTools

import Pkg
import Preferences

function _get_uuid(m::Module)
    Preferences.get_uuid(m)
end

function _get_uuid(p::Base.PkgId)
    p.uuid
end

function _get_uuid(u::Base.UUID)
    u
end

function _get_uuid(n::String)
    proj = Pkg.project()
    if proj.name == n
        return proj.uuid
    end
    if haskey(proj.dependencies, n)
        return proj.dependencies[n]
    end
    for (uuid, dep) in Pkg.dependencies()
        if dep.name == n
            return uuid
        end
    end
    error("cannot find a package called $n in the current environment")
end

function set!(pkg; _force=true, _export=false, kw...)
    uuid = _get_uuid(pkg)
    prefs = [String(k) => v for (k, v) in kw]
    Preferences.set_preferences!(uuid, prefs...; force=_force, export_prefs=_export)
    nothing
end

function delete!(pkg, names::Union{String,Symbol}...; _force=true, _export=false, kw...)
    uuid = _get_uuid(pkg)
    names = map(String, names)
    Preferences.delete_preferences!(uuid, names...; force=_force, export_prefs=_export)
    nothing
end

function get(pkg, name::Union{Symbol,String}, default=nothing)
    uuid = _get_uuid(pkg)
    name = String(name)
    Preferences.load_preference(uuid, name, default)
end

function get_all(pkg)
    uuid = _get_uuid(pkg)
    Preferences.drop_clears(Base.get_preferences(uuid))
end

function get_all()
    Preferences.drop_clears(Base.get_preferences())
end

function _status(io::IO, name, prefs)
    printstyled(io, name, bold=true)
    any = false
    for (key, value) in prefs
        any = true
        println(io)
        print(io, "  ", key, ": ")
        show(io, value)
    end
    if !any
        println(io)
        printstyled(io, "  No preferences.", color=:light_black)
    end
    nothing
end

function status(name; io=stdout)
    prefs = get_all(name)
    _status(io, name, prefs)
end

function status(; io=stdout)
    prefs = get_all()
    any = false
    for (name, prefs) in prefs
        if !isempty(prefs)
            any && println(io)
            any = true
            _status(io, name, prefs)
        end
    end
    if !any
        printstyled(io, "No preferences.", color=:light_black)
    end
end

include("PkgREPL.jl")

end # module PreferencesTools
