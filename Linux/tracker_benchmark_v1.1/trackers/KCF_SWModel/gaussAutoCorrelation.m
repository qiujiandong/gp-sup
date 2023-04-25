function [kxx] = gaussAutoCorrelation(x)
rszpX = reshape(x', 32, 32, 31);
pSum_ref = zeros([32 32]);
for i = 1:31
    pSum_ref = pSum_ref + fft2(rszpX(:, :, i)') .* conj(fft2(rszpX(:, :, i)'));
end
pIfft_ref = ifft2(pSum_ref);
qsum_ref = sum(sum(x .* x));
kxx = exp((pIfft_ref - qsum_ref)*2/32/32/31/0.6/0.6);
end