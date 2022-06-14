struct Simulation{T1, T2, T3, T4, T5, T6}
    gtmodel::T1
    filter::T2
    simmodel::T3
    tsteps::T4
    times::T5
    epsps::T6
end

function filter_update!(sim::Simulation, obs)
    return update!(sim.simmodel, obs, sim.filter, sim.gtmodel.σ)
end

function Simulation(
    A1, τ1, A2, τ2, σ,
    A1rng, τ1rng, A2rng, τ2rng,
    m_out, width;
    timestep::Timestep = RandomTimestep(Exponential(0.121)),
    device::Symbol = :gpu
)
    gtmodel = ScalarGroundTruthModel(A1, τ1, A2, τ2, σ)
    filter = ParticleFilter(width)
    simmodel = ParticleState(
                m_out,
                A1rng, τ1rng, A2rng, τ2rng,
                device = device
             )
    times = zeros(0)
    epsps = zeros(0)
    return Simulation(gtmodel, filter, simmodel, timestep, times, epsps)
end

(ts::Timestep)(::Simulation) = ts()

function propagate!(sim::Simulation)
    dt = sim.tsteps(sim)
    propagate!(sim, dt)
end

function propagate!(sim::Simulation, dt)
    obs = emit(sim, dt)
    filter_update!(sim, obs)
    push!(sim.times, dt)
    push!(sim.epsps, obs.EPSP)
    return sim
end

function run_simulation!(
    sim::Simulation;
    T::Integer,
    plot_each_timestep::Bool = false
)
    for i in 1:T
        propagate!(sim)
        if plot_each_timestep
            plot_results(sim)
        end
    end
end
