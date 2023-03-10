@testitem "status" begin
    using Pkg
    P = PreferenceTools
    pkg"preference st"
    pkg"preference status"
end

@testitem "add/rm" begin
    using Pkg
    P = PreferenceTools
    pkg"preference add __example__ t=true f=false i=12 r=3.4 n=nothing s=/some/path"
    ps = P.get_all()["__example__"]
    @test ps["t"] === true
    @test ps["f"] === false
    @test ps["i"] === 12
    @test ps["r"] === 3.4
    @test get(ps, "n", nothing) === nothing
    @test ps["s"] == "/some/path"
    pkg"preference add -s __example__ t=true f=false"
    ps = P.get_all()["__example__"]
    @test ps["t"] === "true"
    @test ps["f"] === "false"
    @test ps["i"] === 12
    @test ps["r"] === 3.4
    @test get(ps, "n", nothing) === nothing
    @test ps["s"] == "/some/path"
    pkg"preference add __example__ t= f="
    ps = P.get_all()["__example__"]
    @test get(ps, "t", nothing) === nothing
    @test get(ps, "f", nothing) === nothing
    @test ps["i"] === 12
    @test ps["r"] === 3.4
    @test get(ps, "n", nothing) === nothing
    @test ps["s"] == "/some/path"
    pkg"preference rm __example__ i r"
    ps = P.get_all()["__example__"]
    @test get(ps, "t", nothing) === nothing
    @test get(ps, "f", nothing) === nothing
    @test get(ps, "i", nothing) === nothing
    @test get(ps, "r", nothing) === nothing
    @test get(ps, "n", nothing) === nothing
    @test ps["s"] == "/some/path"
    pkg"preference remove --all __example__"
    ps = P.get_all()["__example__"]
    @test get(ps, "t", nothing) === nothing
    @test get(ps, "f", nothing) === nothing
    @test get(ps, "i", nothing) === nothing
    @test get(ps, "r", nothing) === nothing
    @test get(ps, "n", nothing) === nothing
    @test get(ps, "r", nothing) === nothing
    @test get(ps, "s", nothing) === nothing
end

@testitem "list" begin
    using Pkg
    P = PreferenceTools
    pkg"preference add __example__ x=a,b"
    ps = P.get_all()["__example__"]
    @test ps["x"] == ["a", "b"]
    pkg"preference add __example__ x+=c,d x-=a,c x+=a,b"
    ps = P.get_all()["__example__"]
    @test ps["x"] == ["b", "d", "a", "b"]
    pkg"preference add __example__ x+=e x-=b"
    ps = P.get_all()["__example__"]
    @test ps["x"] == ["d", "a", "e"]
end

@testitem "bad" begin
    using Pkg
    @test_throws Exception pkg"preference add __example__ foo"
    @test_throws Exception pkg"preference add __example__=12 x=99"
    @test_throws Exception pkg"preference rm __example__=12"
    @test_throws Exception pkg"preference rm __example__ x=12"
end
