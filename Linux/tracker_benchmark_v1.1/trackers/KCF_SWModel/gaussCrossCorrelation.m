function [kzx] = gaussCrossCorrelation(z, x)
rszpZ = reshape(z', 32, 32, 31);
rszpX = reshape(x', 32, 32, 31);
pSum_ref = zeros([32 32]);
for i = 1:31
    pSum_ref = pSum_ref + fft2(rszpZ(:, :, i)') .* conj(fft2(rszpX(:, :, i)'));
end
pIfft_ref = ifft2(pSum_ref);
qsum_ref = sum(sum(x .* x)) + sum(sum(z .* z));
kzx = exp((pIfft_ref * 2 - qsum_ref)/32/32/31/0.6/0.6);
end