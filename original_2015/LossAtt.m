function Losses = LossAtt(PriceAtt, Portfolio)

K = Portfolio.K;
rf = Portfolio.rf;
vol = Portfolio.vol;
T = Portfolio.T;
LGD = Portfolio.LGD';

DefaultAtt = bsxfun(@ge, K, PriceAtt);
d2 = bsxfun(@rdivide,...
                bsxfun(@plus, ...
                        log(bsxfun(@rdivide, PriceAtt, K)), ...
                        (rf - 0.5 * vol.^2) .*T),...
                (vol .* sqrt(T)));
        
DigitalPut = bsxfun(@times, exp(-rf.*T), normcdf(-d2));
Losses = bsxfun(@max, DefaultAtt, DigitalPut) * LGD;

end