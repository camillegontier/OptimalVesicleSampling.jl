# OptimalVesicleSampling.jl

## Simulations

To run a simulation with fixed ground-truth parameters and where sampling times are drawn from an exponential distribution, use:

```julia
A1 = 0.2
τ1 = 0.026
A2 = 0.8
τ2 = 2
σ = 0.01

sim = Simulation(
        A1, τ1, A2, τ2, σ,
        [0.0,1.0],
        [0.0,τ1*3],
        [0.0,1.0],
        [0.0,τ2*3],
        10000, 0.1,
        timestep = RandomTimestep(Exponential(0.8)),
        device=:cpu
        )
        
run_simulation!(sim, T=20, plot_each_timestep = true)
```

To run a stimulation where sampling times are optimized, use:
```julia
A1 = 0.2
τ1 = 0.026
A2 = 0.8
τ2 = 2
σ = 0.01

dts = LinRange(0,4,200)
sim = Simulation(
        A1, τ1, A2, τ2, σ,
        [0.0,1.0],
        [0.0,τ1*3],
        [0.0,1.0],
        [0.0,τ2*3],
        5000, 0.1,
        timestep = Myopic(dts),
        device=:cpu
        )
        
run_simulation!(sim, T=20, plot_each_timestep = true)
```

## Experiments

During an experiment, to find the optimal next sampling time given the previous sampling times and recordings (which are given as vectors `times` and `epsps`), use:

```julia
expe = Experiment(σ,
[0.0,1.0],
[0.0,τ1*3],
[0.0,1.0],
[0.0,τ2*3],
5000, 0.1,
timestep = Myopic(dts),
device = :cpu
)

run_experiment!(
    expe,
    times,epsps,
    plot_each_timestep = false
)
```
