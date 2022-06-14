function jitter!(state::GridModel, width)

    jitter!(state.A1ind, state.A1rng[1], state.A1rng[end])
    jitter!(state.τ1ind, state.τ1rng[1], state.τ1rng[end])
    jitter!(state.A2ind, state.A2rng[1], state.A2rng[end])
    jitter!(state.τ2ind, state.τ2rng[1], state.τ2rng[end])

    # refresh!(state)
    return state
end

function jitter!(indices, minindex, maxindex)
    for i in eachindex(indices)
        @inbounds μ = indices[i]
        idx = Float32(rand(truncated(Normal(μ, σ),minindex,maxindex)))
        @inbounds indices[i] = idx
    end
    return indices
end
