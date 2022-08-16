struct Experiment{T1, T2, T3, T4, T5, T6}
    gtmodel::T1
    filter::T2
    simmodel::T3
    tsteps::T4
    times::T5
    epsps::T6
end

function filter_update!(sim::Experiment, obs)
    return update!(sim.simmodel, obs, sim.filter, sim.gtmodel.σ)
end

function Experiment(
    σ,
    A1rng, τ1rng, τ2rng,
    m_out, width,
    timestep::Timestep = RandomTimestep(Exponential(0.121)),
    device::Symbol = :cpu
)
    gtmodel = ScalarGroundTruthModel(σ)
    filter = ParticleFilter(width)
    simmodel = ParticleState(
                m_out,
                A1rng, τ1rng, τ2rng,
                device = device
             )
    times = zeros(0)
    epsps = zeros(0)
    return Experiment(gtmodel, filter, simmodel, timestep, times, epsps)
end

function propagate!(sim::Experiment, obs)
    filter_update!(sim, obs)
    push!(sim.times, obs.dt)
    push!(sim.epsps, obs.EPSP)
    return sim
end

function run_experiment!(
    sim::Experiment,
    times,epsps;
    plot_each_timestep::Bool = false
)
    T = length(times)
    for i in 1:T
        propagate!(sim,Observation(epsps[i],times[i]))
        if plot_each_timestep
            plot_results(sim)
        end
    end
    dt = sim.tsteps(sim)
    print("Next optimal dt = ",dt)
    print("\n")
    return dt
end
