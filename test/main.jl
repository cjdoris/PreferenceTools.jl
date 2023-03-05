@testitem "get_all" begin
    P = PreferencesTools
    pss = P.get_all()
    @test pss isa Dict{String,Any}
    @test all(ps->ps isa Dict{String,Any}, values(pss))
    gpss = P.get_all(_global=true)
    @test gpss isa Dict{String,Any}
    @test all(ps->ps isa Dict{String,Any}, values(gpss))
    ps = P.get_all("__example__")
    @test ps isa Dict{String,Any}
    gps = P.get_all("__example__"; _global=true)
    @test gps isa Dict{String,Any}
end

@testitem "add/rm" begin
    P = PreferencesTools
    io = IOBuffer()
    P.add("__example__"; foo=11, _io=io)
    str = String(take!(io))
    @test occursin("Writing", str)
    @test occursin(P._prefs_file(_global=false, _export=false), str)
    @test occursin("You may need to restart Julia", str)
    @test P.get_all("__example__")["foo"] === 11
    P.add("__example__"; foo=10, _global=true, _io=devnull)
    @test P.get_all("__example__")["foo"] === 10
    @test P.get_all("__example__"; _global=true)["foo"] === 10
    P.rm("__example__", "foo"; _global=true, _io=devnull)
    @test get(P.get_all("__example__"), "foo", 10) === 10
    @test get(P.get_all("__example__"; _global=true), "foo", nothing) === nothing
    P.rm("__example__", "foo", _io=devnull)
    @test get(P.get_all("__example__"), "foo", nothing) === nothing
    @test get(P.get_all("__example__"; _global=true), "foo", nothing) === nothing
end

@testitem "rm_all" begin
    P = PreferencesTools
    P.add("__example__"; foo=11, bar=true, _global=true, _io=devnull)
    P.add("__example__"; foo=10, bar=false, _io=devnull)
    @test P.get_all("__example__")["foo"] === 10
    @test P.get_all("__example__")["bar"] === false
    @test P.get_all("__example__"; _global=true)["foo"] in [10, 11]
    @test P.get_all("__example__"; _global=true)["bar"] in [true, false]
    P.rm_all("__example__", _io=devnull)
    @test get(P.get_all("__example__"), "foo", nothing) in [nothing, 11]
    @test get(P.get_all("__example__"), "bar", nothing) in [nothing, true]
    @test get(P.get_all("__example__"; _global=true), "foo", nothing) in [nothing, 11]
    @test get(P.get_all("__example__"; _global=true), "bar", nothing) in [nothing, true]
    P.rm_all("__example__", _io=devnull)
end

@testitem "status" begin
    P = PreferencesTools
    status = (args...; kw...) -> sprint(io -> P.status(args...; _io=io, kw...))
    P.add("__example__"; foo=11, bar=true, baz="hello", _global=true)
    for st in [status(; _global=true), status("__example__"; _global=true)]
        @test st isa String
        @test occursin("__example__", st)
        @test occursin("foo: 11", st)
        @test occursin("bar: true", st)
        @test occursin("baz: \"hello\"", st)
        P.add("__example__"; foo=12)
    end
    P.add("__example__"; foo=99)
    for st in [status(), status("__example__")]
        @test occursin("__example__", st)
        @test occursin("foo: 99", st)
        @test occursin("bar: true", st)
        @test occursin("baz: \"hello\"", st)
    end
    P.add("__example2__"; foo=12)
    @test occursin("__example__", status())
    @test occursin("__example2__", status())
    @test occursin("__example__", status("__example__"))
    @test occursin("__example2__", status("__example2__"))
    @test !occursin("__example__", status("__example2__"))
    @test !occursin("__example2__", status("__example__"))
    P.rm_all("__example__", _global=true)
    P.rm_all("__example__", _global=false)
    P.rm_all("__example2__", _global=true)
    P.rm_all("__example2__", _global=false)
end
