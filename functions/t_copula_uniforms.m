function Uniforms = t_copula_uniforms(Correlation, DegreesOfFreedom, NumSamples, Stream)
% Samples from a bivariate t-copula, drawn from a given random stream
% (copularnd draws from the global stream, so the construction is written
% out here to make each sample path's random numbers reproducible)
% Input(s):
% -- Correlation: 2 x 2 correlation matrix
% -- DegreesOfFreedom: nu
% -- NumSamples: number of samples
% -- Stream: RandStream
% Output(s):
% -- Uniforms: NumSamples x 2, each row a t-copula sample in (0,1)^2
% formula: U = T_nu(Z / sqrt(W / nu)), Z ~ N(0, Correlation), W ~ chi2(nu)

if DegreesOfFreedom ~= round(DegreesOfFreedom)
    error('t_copula_uniforms: integer degrees of freedom required.');
end
Cholesky = chol(Correlation);                              % upper triangular
Normals = randn(Stream, NumSamples, 2) * Cholesky;         % rows ~ N(0, Correlation)
% chi2(nu) as a sum of nu squared standard normals (randg cannot draw from
% a given stream)
ChiSquares = sum(randn(Stream, NumSamples, DegreesOfFreedom).^2, 2);
StudentT = Normals ./ sqrt(ChiSquares / DegreesOfFreedom); % multivariate t
Uniforms = tcdf(StudentT, DegreesOfFreedom);
end
