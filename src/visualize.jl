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
    p1 = histogram(A1idx,legend=false,xlabel = L"$A_1$ [-]", xlims = (A1rng[1],A1rng[end]),normed=true,
    ylabel=L"$p(A_1)$",xticks=[0.2,0.5,0.8])
    vline!([A1], linewidth = 3, linestyle =:dash)
    hist = fit(Histogram, A1idx)
    i = argmax(hist.weights)
    A1_MAP = hist.edges[1][i:i+1][1]
    vline!([A1_MAP], linewidth = 3, linestyle =:dot)

    p2 = histogram(τ1idx,legend=false,xlabel = L"$\tau_1$ [s]", xlims = (τ1rng[1],τ1rng[end]),normed=true,
    ylabel=L"$p(\tau_1)$",xticks=[0.06,0.18])
    vline!([τ1], linewidth = 3, linestyle =:dash)
    hist = fit(Histogram, τ1idx)
    i = argmax(hist.weights)
    τ1_MAP = hist.edges[1][i:i+1][1]
    vline!([τ1_MAP], linewidth = 3, linestyle =:dot)

    p4 = histogram(τ2idx,legend=false,xlabel = L"$\tau_2$ [s]", xlims = (τ2rng[1],τ2rng[end]),normed=true,
    ylabel=L"$p(\tau_2)$",xticks=[0,2,4,6])
    vline!([τ2], linewidth = 3, linestyle =:dash)
    hist = fit(Histogram, τ2idx)
    i = argmax(hist.weights)
    τ2_MAP = hist.edges[1][i:i+1][1]
    vline!([τ2_MAP], linewidth = 3, linestyle =:dot)


    σ = sim.gtmodel.σ
    t = LinRange(0, 6, 100)
    y = A1.*(1 .- exp.(-t./τ1)) + (1 .- A1).*(1 .- exp.(-t./τ2))
    d = plot(t,y.*100,xlabel = "Time [s]",label="Ground truth",legend=:bottomright,
    linewidth = 3, color = "orange", ylabel="Phasic EPSC [%]")
    y_MAP = A1_MAP.*(1 .- exp.(-t./τ1_MAP)) + (1 .- A1_MAP).*(1 .- exp.(-t./τ2_MAP))
    plot!(t,y_MAP.*100,xlabel = "Time [s]",label="MAP estimate",legend=:bottomright,
    linewidth = 3, color = "green", ylabel="Phasic EPSC [%]")
    dt = sim.times
    e = sim.epsps
    plot!(dt, e.*100, seriestype = :scatter,label="EPSCs",color="blue")

    p = plot(d, p1, p2, p4, layout = l,size=(600,300), dpi=300)

    display(p)

end
