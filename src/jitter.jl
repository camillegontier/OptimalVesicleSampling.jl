function jitter!(state::GridModel, width)

    jitter!(state.A1ind, state.A1rng[1], state.A1rng[end], width[1])
    jitter!(state.τ1ind, state.τ1rng[1], state.τ1rng[end], width[2])
    jitter!(state.τ2ind, state.τ2rng[1], state.τ2rng[end], width[3])

    # refresh!(state)
    return state
end

function jitter!(indices, minindex, maxindex, width)
    for i in eachindex(indices)
        @inbounds μ = indices[i]
        idx = Float32(rand(truncated(Normal(μ, width),minindex,maxindex)))
        @inbounds indices[i] = idx
    end
    return indices
end
