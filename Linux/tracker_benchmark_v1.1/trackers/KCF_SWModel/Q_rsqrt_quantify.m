function [result] = Q_rsqrt_quantify(mod, Qn)

number = single(mod);

% x2 = number * single(0.5);
y = number;
i = typecast(y, 'int32');
magic_num = int32(1597463007);% 0x5f3759df
i = magic_num - bitshift(i, -1);
y = typecast(i, 'single');
z = int64(floor(y * single(2^(Qn + Qn/2)) + 0.5));
result = bitshift(z * (int64(floor(3 * (2^Qn))) - bitshift(mod * bitshift(z * z, -Qn), -Qn)), -(Qn + 1));
