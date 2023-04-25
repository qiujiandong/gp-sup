function [pAlpha] = train(x)

kxx = gaussAutoCorrelation(x);
kxxHat = fft2(kxx);
prob = zeros(32, 32);
fSigma = 32/2.5*0.125;
fMult = -0.5/(fSigma * fSigma);
for i = 1:32
    for j = 1:32
        if(i > 17)
            deltaY = 33 - i;
        else
            deltaY = i - 1;
        end
        if(j > 17)
            deltaX = 33 - j;
        else
            deltaX = j - 1;
        end
        prob(i, j) = exp(fMult * (deltaX * deltaX + deltaY * deltaY));
    end
end
probHat = fft2(prob);
lambda = 0.001;
pAlpha = probHat ./ (kxxHat + lambda);

end