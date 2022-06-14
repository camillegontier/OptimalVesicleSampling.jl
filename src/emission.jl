function emit(sim::Simulation, dt)
    return emit(sim.gtmodel, dt)
end

function emit(
    gtmodel::AbstractModel,
    δ::Number
)
    A1 = gtmodel.A1[1]
    τ1 = gtmodel.τ1[1]
    A2 = gtmodel.A2[1]
    τ2 = gtmodel.τ2[1]
    σ = gtmodel.σ[1]

    μ = A1*(1-exp(-δ/τ1)) + A2*(1-exp(-δ/τ2))

    EPSP = Float32(rand(Normal(μ, σ)))
    return Observation(EPSP, δ)
end
