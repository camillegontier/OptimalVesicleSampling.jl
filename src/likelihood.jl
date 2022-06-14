gauss(x, μ, σ) = exp(-((x-μ)/σ)^2/2)

function likelihood(state::GridModel, obs::Observation, σ)
    A1 = state.A1ind
    τ1 = state.τ1ind
    A2 = state.A2ind
    τ2 = state.τ2ind
    δ = obs.dt

    μ = A1.*(1 .- exp.(-δ./τ1)) + A2.*(1 .- exp.(-δ./τ2))

    v = gauss.(obs.EPSP, μ, σ)
    v = v./sum(v)

    return v
end
