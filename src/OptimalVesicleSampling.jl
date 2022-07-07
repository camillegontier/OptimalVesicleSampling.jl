module OptimalVesicleSampling

using Distributions: Exponential, Normal, truncated
using LaTeXStrings
using Plots
using LinearAlgebra: det
using CovarianceEstimation
using ProgressMeter
using StatsBase

include("models.jl")
export GroundTruthModel, GridModel, Observation, ScalarGroundTruthModel

include("timestep.jl")
export Timestep, RandomTimestep

include("record.jl")
export Recording

include("simulate.jl")
export Simulation, run_simulation!

include("experiment.jl")
export Experiment, run_experiment!

include("emission.jl")
export emit

include("likelihood.jl")
export likelihood

include("jitter.jl")
export jitter!

include("resample.jl")
export resample!

include("filter.jl")
export ParticleState, update!

include("visualize.jl")
export plot_results

include("OED.jl")
export OEDPolicy, policy

include("myopic.jl")
export MyopicPolicy, Myopic

end#module
