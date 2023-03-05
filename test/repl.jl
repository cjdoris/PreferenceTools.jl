@testitem "status" begin
    using Pkg
    P = PreferencesTools
    pkg"prefs st"
    pkg"prefs status"
end

@testitem "add/rm" begin
    using Pkg
    P = PreferencesTools
    pkg"prefs add __example__ t=true f=false i=12 r=3.4 n=nothing s=/some/path"
    ps = P.get_all()["__example__"]
    @test ps["t"] === true
    @test ps["f"] === false
    @test ps["i"] === 12
    @test ps["r"] === 3.4
    @test get(ps, "n", nothing) === nothing
    @test ps["s"] == "/some/path"
    pkg"prefs add __example__ t= f="
    ps = P.get_all()["__example__"]
    @test get(ps, "t", nothing) === nothing
    @test get(ps, "f", nothing) === nothing
    @test ps["i"] === 12
    @test ps["r"] === 3.4
    @test get(ps, "n", nothing) === nothing
    @test ps["s"] == "/some/path"
    pkg"prefs rm __example__ i r"
    ps = P.get_all()["__example__"]
    @test get(ps, "t", nothing) === nothing
    @test get(ps, "f", nothing) === nothing
    @test get(ps, "i", nothing) === nothing
    @test get(ps, "r", nothing) === nothing
    @test get(ps, "n", nothing) === nothing
    @test ps["s"] == "/some/path"
    pkg"prefs remove --all __example__"
    ps = P.get_all()["__example__"]
    @test get(ps, "t", nothing) === nothing
    @test get(ps, "f", nothing) === nothing
    @test get(ps, "i", nothing) === nothing
    @test get(ps, "r", nothing) === nothing
    @test get(ps, "n", nothing) === nothing
    @test get(ps, "r", nothing) === nothing
    @test get(ps, "s", nothing) === nothing
end
