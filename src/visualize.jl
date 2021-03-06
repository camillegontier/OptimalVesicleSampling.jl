function plot_results(sim::Simulation)

    A1 = sim.gtmodel.A1
    τ1 = sim.gtmodel.τ1
    τ2 = sim.gtmodel.τ2

    A1idx = sim.simmodel.state.A1ind
    τ1idx = sim.simmodel.state.τ1ind
    τ2idx = sim.simmodel.state.τ2ind

    A1rng = sim.simmodel.state.A1rng
    τ1rng = sim.simmodel.state.τ1rng
    τ2rng = sim.simmodel.state.τ2rng

    l = @layout [
        a{0.5w} [grid(2,2)]
    ]
    p1 = histogram(A1idx,legend=false,xlabel = L"$A_1$", xlims = (A1rng[1],A1rng[end]))
    vline!([A1], linewidth = 3, linestyle =:dash)
    hist = fit(Histogram, A1idx)
    i = argmax(hist.weights)
    A1_MAP = hist.edges[1][i:i+1][1]
    vline!([A1_MAP], linewidth = 3, linestyle =:dash)

    p2 = histogram(τ1idx,legend=false,xlabel = L"$\tau_1$", xlims = (τ1rng[1],τ1rng[end]))
    vline!([τ1], linewidth = 3, linestyle =:dash)
    hist = fit(Histogram, τ1idx)
    i = argmax(hist.weights)
    τ1_MAP = hist.edges[1][i:i+1][1]
    vline!([τ1_MAP], linewidth = 3, linestyle =:dash)

    p4 = histogram(τ2idx,legend=false,xlabel = L"$\tau_2$", xlims = (τ2rng[1],τ2rng[end]))
    vline!([τ2], linewidth = 3, linestyle =:dash)
    hist = fit(Histogram, τ2idx)
    i = argmax(hist.weights)
    τ2_MAP = hist.edges[1][i:i+1][1]
    vline!([τ2_MAP], linewidth = 3, linestyle =:dash)


    σ = sim.gtmodel.σ
    t = LinRange(0, 6, 100)
    y = A1.*(1 .- exp.(-t./τ1)) + (1 .- A1).*(1 .- exp.(-t./τ2))
    d = plot(t,y,xlabel = "Time [s]",label="Ground truth",legend=:bottomright,
    linewidth = 3, color = "orange")
    y_MAP = A1_MAP.*(1 .- exp.(-t./τ1_MAP)) + (1 .- A1_MAP).*(1 .- exp.(-t./τ2_MAP))
    plot!(t,y_MAP,xlabel = "Time [s]",label="MAP estimate",legend=:bottomright,
    linewidth = 3, color = "green")
    dt = sim.times
    e = sim.epsps
    plot!(dt, e, seriestype = :scatter,label="EPSCs",color="blue")

    p = plot(d, p1, p2, p4, layout = l,size=(800,400), dpi=100)

    display(p)

end
