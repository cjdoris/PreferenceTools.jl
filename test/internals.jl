@testitem "_project_file" begin
    P = PreferencesTools
    projs = filter(p->endswith(p, "Project.toml"), Base.load_path())
    proj = P._project_file(_global=false)
    @test endswith(proj, "Project.toml")
    @test proj == first(projs)
    proj = P._project_file(_global=true)
    @test endswith(proj, "Project.toml")
    @test proj == last(projs)
end

@testitem "_prefs_file" begin
    P = PreferencesTools
    # basic test
    file = P._prefs_file(_export=false, _global=false)
    @test basename(file) in ["LocalPreferences.toml", "JuliaLocalPreferences.toml"]
    @test dirname(file) == dirname(P._project_file(_global=false))
    # if JuliaLocalPreferences.toml does not exist, then the file should be LocalPreferences.toml
    rm(file)
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
