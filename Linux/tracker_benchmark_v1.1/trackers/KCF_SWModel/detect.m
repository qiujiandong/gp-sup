function [ansX, ansY, fPeak] = detect(z, m_pTmpl, m_pAlpha)

kzx = gaussCrossCorrelation(z, m_pTmpl);

kzxHat = fft2(kzx);
fzHat = kzxHat .* m_pAlpha;
fz = ifft2(fzHat);
fPeak = max(max(fz));
[nY, nX] = find(fz == fPeak, 1);

% global a;
% subplot(3,3,a);
% a = mod(a, 9) + 1;
% surf(fftshift(fz));
% set(gca,'YDir','reverse');

deltaX = subPixelPeak(fz(nY, mod(nX - 1 + 32 - 1, 32) + 1), fz(nY, nX), fz(nY, mod(nX - 1 + 32 + 1, 32) + 1));
deltaY = subPixelPeak(fz(mod(nY - 1 + 32 - 1, 32) + 1, nX), fz(nY, nX), fz(mod(nY - 1 + 32 + 1, 32) + 1, nX));
ansX = (mod(nX - 1 + 16, 32) - 16 + deltaX);
ansY = (mod(nY - 1 + 16, 32) - 16 + deltaY);
end