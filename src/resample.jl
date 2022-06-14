function resample!(state, u)
    usum, idx = indices!(u)
    resample_indices!(state, idx)
    return state
end

function indices!(v::AbstractArray{T}) where T
    # initializations:

    # indices
    idx = Array{Int}(undef, size(v)...)

    # outer likelihoods
    # Initialize to -1 in order to track which elements have been written to.
    # Since likelihoods are nonnegative, negative elements have never been visited.
    u = zeros(T, size(v)[1:end-1]...)

    # random numbers
    r = Array{T}(undef, size(v)...)

    Rout  = CartesianIndices(u) # indices for first n-1 dimensions
    M_out = length(u)
    M_in  = last(size(v))

    for id in 1:M_out
        # sample descending sequence of sorted random numbers
        # r[i,M_in] >= ... >= r[i,2] >= r[i,1]
        # Algorithm by:
        # Bentley & Saxe, ACM Transactions on Mathematical Software, Vol 6, No 3
        # September 1980, Pages 359--364
        vsum = zero(T)
        CurMax = one(T)
        @inbounds i = Rout[id]
        for j in 1:M_in
            mirrorj = M_in - j + 1 # mirrored index j
            CurMax *= exp(log(rand(T)) / mirrorj)
            @inbounds v[i, j] += vsum
            @inbounds vsum = v[i, j]
            @inbounds r[i, mirrorj] = CurMax
        end
        # compute average likelihood across inner particles
        # (with normalization constant that was omitted from v for speed)
        @inbounds u[i] = vsum

        # O(n) binning algorithm for sorted samples
        bindex = 1 # bin index
        for j in 1:M_in
            # scale random numbers (this is equivalent to normalizing v)
            @inbounds rsample = r[i, j] * vsum
            # checking bindex <= M_in - 1 not necessary since
            # v[i, M_in] = vsum
            @inbounds while rsample > v[i, bindex]
                bindex += 1
            end
            @inbounds idx[i, j] = bindex
        end
    end
    return u, idx
end

function resample_indices!(in, out, idx)
    idx_dim = ndims(idx)
    R1 = CartesianIndices(size(in)[1:idx_dim-1]) # indices before resampling dimension
    R2 = CartesianIndices((size(in, idx_dim),)) # indices for resampling dimension
    R3 = CartesianIndices(size(in)[idx_dim+1:end]) # indices after resampling dimension

    Ra = CartesianIndices((length(R1), length(R2), length(R3))) # high-level indices

    @inbounds for i in 1:length(in)
        I = Ra[i]     # choose high-level index
        I1 = R1[I[1]] # choose index before resampling dimension
        I2 = R2[I[2]] # choose index for resampling
        I3 = R3[I[3]] # choose index after resampling dimension
        out[I1, I2, I3] = in[I1, idx[I1, I2], I3]
    end
    return out
end

function resample_indices!(in, idx)
    size(in)[1:ndims(idx)] == size(idx) || throw(DimensionMismatch("input and index array must have matching size"))
    out = similar(in)
    resample_indices!(in, out, idx)
    in .= out
    return in
end

function resample_indices!(state::GridModel, idx)
    resample_indices!(state.A1ind, idx)
    resample_indices!(state.τ1ind, idx)
    resample_indices!(state.A2ind, idx)
    resample_indices!(state.τ2ind, idx)
    return state
end
