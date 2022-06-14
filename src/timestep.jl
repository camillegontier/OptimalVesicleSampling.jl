abstract type Timestep end

function (ts::Timestep)() end

struct RandomTimestep{T} <: Timestep
    distribution::T
end

(timestep::RandomTimestep)() = rand(timestep.distribution)
