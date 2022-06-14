"""
    OEDPolicy <: Timestep
An abstract type for choosing time steps based on optimizing a given cost function.
This is provided in order to do active inference.
"""
abstract type OEDPolicy <: Timestep end

"""
    policy(sim)
Return the instance of OEDPolicy used in simulation `sim`.
"""
policy(sim::Simulation) = sim.tsteps
