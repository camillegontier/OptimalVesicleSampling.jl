abstract type OEDPolicy <: Timestep end

abstract type MyopicPolicy <: OEDPolicy end

struct Myopic{T1, T2} <: MyopicPolicy
    dts::T1
    target::T2
end

Myopic(dts) = Myopic(dts, _entropy)

_temp_simmodel(sim, ::Myopic) = deepcopy(sim.simmodel)

function (policy::MyopicPolicy)(sim::Simulation)
    M = 10
    dts = sim.tsteps.dts
    m_out = length(sim.simmodel.state.A1ind)
    idx = rand(1:m_out,M)
    A1_temp = sim.simmodel.state.A1ind[idx]
    τ1_temp = sim.simmodel.state.τ1ind[idx]
    A2_temp = sim.simmodel.state.A2ind[idx]
    τ2_temp = sim.simmodel.state.τ2ind[idx]
    results = zeros(length(dts))
    @showprogress for (i, dt) in enumerate(dts)
        e_temp = A1_temp.*(1 .- exp.(-dt./τ1_temp)) + A2_temp.*(1 .- exp.(-dt./τ2_temp))
        for e in e_temp
            obs = Observation(e,dt)
            temp_simmodel = _temp_simmodel(sim, policy)
            update!(temp_simmodel, obs, sim.filter, sim.gtmodel.σ)
            results[i] += policy.target(temp_simmodel.state)
        end
    end
    return dts[argmin(results)]
end

function (policy::MyopicPolicy)(sim::Experiment)
    M = 10
    dts = sim.tsteps.dts
    m_out = length(sim.simmodel.state.A1ind)
    idx = rand(1:m_out,M)
    A1_temp = sim.simmodel.state.A1ind[idx]
    τ1_temp = sim.simmodel.state.τ1ind[idx]
    A2_temp = sim.simmodel.state.A2ind[idx]
    τ2_temp = sim.simmodel.state.τ2ind[idx]
    results = zeros(length(dts))
    @showprogress for (i, dt) in enumerate(dts)
        e_temp = A1_temp.*(1 .- exp.(-dt./τ1_temp)) + A2_temp.*(1 .- exp.(-dt./τ2_temp))
        for e in e_temp
            obs = Observation(e,dt)
            temp_simmodel = _temp_simmodel(sim, policy)
            update!(temp_simmodel, obs, sim.filter, sim.gtmodel.σ)
            results[i] += policy.target(temp_simmodel.state)
        end
    end
    return dts[argmin(results)]
end


function _entropy(temp_state::GridModel)
    A1ind = Array(temp_state.A1ind)
    τ1ind = Array(temp_state.τ1ind)
    A2ind = Array(temp_state.A2ind)
    τ2ind = Array(temp_state.τ2ind)

    A1max = temp_state.A1rng[end]
    τ1max = temp_state.τ1rng[end]
    A2max = temp_state.A2rng[end]
    τ2max = temp_state.τ2rng[end]

    samples = [A1ind'./A1max ; τ1ind'./τ1max ; A2ind'./A2max ; τ2ind'./τ2max]
    method = LinearShrinkage(DiagonalUnequalVariance(), 0.5)
    Σ_est = cov(method, samples')
    return log(det(2*pi*ℯ*Σ_est))
end
