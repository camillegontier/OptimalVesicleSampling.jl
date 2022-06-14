struct ParticleFilter
    jittering_width::Float32
end

struct ParticleState{T1}
    state::T1
end

function ParticleState(
    m_out::Integer,
    A1rng, τ1rng, A2rng, τ2rng;
    device::Symbol = :gpu
)
    state = GridModel(
        m_out, A1rng, τ1rng, A2rng, τ2rng,
        device = device
    )
    return ParticleState(state)
end

function update!(
    simmodel::ParticleState,
    observation::Observation,
    filter::ParticleFilter,
    σ
)
    state = simmodel.state

    jitter!(state, filter.jittering_width)
    u = likelihood(state, observation, σ)
    resample!(state, u)
    return simmodel
end
