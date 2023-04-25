function [m_roi, fPeak] = update(src, m_roi, m_pTmpl, m_pAlpha)

[z, m_fScaleW, m_fScaleH] = getFeatures(src, 1.0, m_roi); 
[ansX, ansY, fPeak] = detect(z, m_pTmpl, m_pAlpha);

m_roi.x = m_roi.x + ansX * 4 * m_fScaleW;
m_roi.y = m_roi.y + ansY * 4 * m_fScaleH;

end