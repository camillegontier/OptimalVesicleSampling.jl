abstract type AbstractModel end

struct GroundTruthModel{T1} <: AbstractModel
    A1::T1
    τ1::T1
    τ2::T1
    σ::T1
end

struct GridModel{T1} <: AbstractModel
    A1ind::T1
    τ1ind::T1
    τ2ind::T1
    A1rng::T1
    τ1rng::T1
    τ2rng::T1
end

struct Observation{T1, T2}
    EPSP::T1
    dt::T2
end

function ScalarGroundTruthModel(A1, τ1, τ2, σ; device::Symbol = :cpu)
    if device == :cpu
        A1 = A1 .* ones(1)
        τ1 = τ1 .* ones(1)
        τ2 = τ2 .* ones(1)
        σ = σ .* ones(1)
    elseif device === :gpu
        A1 = Float32(A1) .* CUDA.ones(1)
        τ1 = Float32(τ1) .* CUDA.ones(1)
        τ2 = Float32(τ2) .* CUDA.ones(1)
        σ = Float32(σ) .* CUDA.ones(1)
    end
    return GroundTruthModel(A1, τ1, τ2, σ)
end

function ScalarGroundTruthModel(σ; device::Symbol = :cpu)
    if device == :cpu
        A1 = zeros(1)
        τ1 = zeros(1)
        τ2 = zeros(1)
        σ = σ .* ones(1)
    elseif device === :gpu
        A1 = CUDA.zeros(1)
        τ1 = CUDA.zeros(1)
        τ2 = CUDA.zeros(1)
        σ = Float32(σ) .* CUDA.ones(1)
    end
    return GroundTruthModel(A1, τ1, τ2, σ)
end

function GridModel(
    m_out::Integer, A1rng, τ1rng, τ2rng;
    device::Symbol = :gpu
)

    A1ind = (A1rng[end]-A1rng[1])*rand(m_out).+A1rng[1]
    τ1ind = (τ1rng[end]-τ1rng[1])*rand(m_out).+τ1rng[1]
    τ2ind = (τ2rng[end]-τ2rng[1])*rand(m_out).+τ2rng[1]

    if device === :cpu
        return GridModel(
            A1ind, τ1ind, τ2ind,
            A1rng, τ1rng, τ2rng
        )
    elseif device === :gpu
        A1rng = CuArray(Float32.(A1rng))
        τ1rng = CuArray(Float32.(τ1rng))
        τ2rng = CuArray(Float32.(τ2rng))

        A1ind = CuArray(Float32.(A1ind))
        τ1ind = CuArray(Float32.(τ1ind))
        τ2ind = CuArray(Float32.(τ2ind))

        return GridModel(
        A1ind, τ1ind, τ2ind,
        A1rng, τ1rng, τ2rng
        )
    end
    throw(ArgumentError("Device must be either :cpu or :gpu."))
end
