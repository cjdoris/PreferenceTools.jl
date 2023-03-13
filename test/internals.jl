@testitem "_project_file" begin
    P = PreferenceTools
    projs = filter(p->endswith(p, "Project.toml"), Base.load_path())
    proj = P._project_file(_global=false)
    @test endswith(proj, "Project.toml")
    @test proj == first(projs)
    proj = P._project_file(_global=true)
    @test endswith(proj, "Project.toml")
    @test proj == last(projs)
end

@testitem "_prefs_file" begin
    P = PreferenceTools
    # basic test
    file = P._prefs_file(_export=false, _global=false)
    @test basename(file) in ["LocalPreferences.toml", "JuliaLocalPreferences.toml"]
    @test dirname(file) == dirname(P._project_file(_global=false))
    # if JuliaLocalPreferences.toml does not exist, then the file should be LocalPreferences.toml
    rm(file, force=true)
    file2 = P._prefs_file(_export=false, _global=false)
    @test dirname(file2) == dirname(file)
    @test basename(file2) == "LocalPreferences.toml"
    # if JuliaLocalPreferences.toml exists, this should be the file
    open(joinpath(dirname(file), "JuliaLocalPreferences.toml"), "w") do io
        nothing
    end
    file2 = P._prefs_file(_export=false, _global=false)
    @test dirname(file2) == dirname(file)
    @test basename(file2) == "JuliaLocalPreferences.toml"
    # test _global
    file = P._prefs_file(_export=false, _global=true)
    @test basename(file) in ["LocalPreferences.toml", "JuliaLocalPreferences.toml"]
    @test dirname(file) == dirname(P._project_file(_global=true))
    # test _export
    file = P._prefs_file(_export=true, _global=false)
    @test file == P._project_file(_global=false)
    file = P._prefs_file(_export=true, _global=true)
    @test file == P._project_file(_global=true)
end

@testitem "_parse_value" begin
    p = PreferenceTools.PkgREPL._parse_value
    @test p("nothing") === nothing
    @test p("true") === true
    @test p("false") === false
    @test p("0") === 0
    @test p("1") === 1
    @test p("-12") === -12
    @test p("1.2") === 1.2
    @test p("-3.4") === -3.4
    @test p("/some/path") === "/some/path"
    @test p("1,2,3") == [1, 2, 3]
    @test p("true,nothing,false,12,3.4,foo") == [true, nothing, false, 12, 3.4, "foo"]
    @test p("12,") == [12]
    @test p(",") == []
end

@testitem "completions" begin
    P = PreferenceTools
    using Pkg
    pkg"preference add -g __example__ foo=1 bar=2"
    cs = P.PkgREPL.complete_packages_and_prefs(Dict(:_global=>true), "")
    @test "__example__" in cs
    @test "foo" in cs
    @test "bar" in cs
    cs = P.PkgREPL.complete_packages_and_prefs(Dict(:_global=>true), "__ex")
    @test "__example__" in cs
    @test "foo" ∉ cs
    @test "bar" ∉ cs
    cs = P.PkgREPL.complete_packages_and_prefs(Dict(:_global=>true), "foo=")
    @test isempty(cs)
end
