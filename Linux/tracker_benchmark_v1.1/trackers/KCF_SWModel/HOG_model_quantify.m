function [hog_feature_float] = HOG_model_quantify(image_gray, Qn)
% 注意输入的qn需要为浮点数，输出结果为single类型，大小为（32，32，31）
% clear all;
% clear;
% clc;

image_size = 136;
image_gray = int32(image_gray);

%读取原始图像
% initial_image = imread('D:\code\Matlab_prj\220727_HOG_model\0.bmp');

%先生成一个136*136灰度矩阵,每像素8bit
%image_gray = randi([0,255],image_size,'uint8');

% image_gray = imresize(initial_image,[image_size image_size],'bilinear');%将图像双线性插值成我们所需的136x136大小
% image_gray = single(image_gray);

% 18个bin的单位向量,保留到小数点后4位
bin_vec = zeros(5,2,'int64');%只保留象限1的5个bin的单位向量
for i = 1:5
    bin_vec(i,1) = int64(floor(cos(pi*(i-1)/9) * 2^Qn));
    bin_vec(i,2) = int64(floor(sin(pi*(i-1)/9) * 2^Qn));
end
%初始化34x34x18的cell矩阵
hist_cell = zeros(image_size/4,image_size/4,18+9,'int64');
%初始像素梯度
pixel_grad = zeros(1,2,'int64');

% vec_mod = 0;
vec_mod_array = zeros(image_size,'int64');
bin_num_array = zeros(image_size,'int64');
%直方图统计
for i = 1:image_size
    for j = 1:image_size
        %得到方向梯度模长
        if(j == 1 || j == image_size)
            pixel_grad(1,1) = 0;%左右边界x方向梯度
        else
            pixel_grad(1,1) = int64(image_gray(i,j+1) * 2^Qn) - int64(image_gray(i,j-1) * 2^Qn);%x方向梯度
        end
        if(i == 1 || i == image_size)%上下边界y方向梯度
            pixel_grad(1,2) = 0;
        else
            pixel_grad(1,2) = int64(image_gray(i+1,j) * 2^Qn) - int64(image_gray(i-1,j) * 2^Qn);%y方向梯度
        end
        
        % vec_mod = sqrt(sum(pixel_grad.*pixel_grad));%像素方向梯度模长
        c = int64(0);
        if(abs(pixel_grad(1,1)) > abs(pixel_grad(1,2)))
            c = bitshift(int64(floor(0.875 * 2^Qn)) * abs(pixel_grad(1,1)),-Qn) + bitshift(abs(pixel_grad(1,2)),-1);
            if(c > abs(pixel_grad(1,1)))
                vec_mod = c;
            else
                vec_mod = abs(pixel_grad(1,1));
            end
        else
            c = bitshift(int64(floor(0.875 * 2^Qn)) * abs(pixel_grad(1,2)),-Qn) + bitshift(abs(pixel_grad(1,1)),-1);
            if(c > abs(pixel_grad(1,2)))
                vec_mod = c;
            else
                vec_mod = abs(pixel_grad(1,2));
            end
        end
        
        vec_mod_array(i,j) = vec_mod;
        %得到方向梯度直方图统计bin值
        
        dot_product = int64(0);
        bin_num = 1;
        if(pixel_grad(1,1)>=0 && pixel_grad(1,2)>=0)%方向梯度在第一象限，包括x、y轴和原点
            for k = 1:5
                dot_product_temp = bitshift(abs(pixel_grad(1,1))*bin_vec(k,1),-Qn)+bitshift(abs(pixel_grad(1,2))*bin_vec(k,2),-Qn);
                if(dot_product_temp > dot_product)
                    dot_product = dot_product_temp;
                    bin_num = k;
                end
            end%得到在第1象限的bin分布
        elseif (pixel_grad(1,1)<0 && pixel_grad(1,2)>=0)%方向梯度在第二象限，包括x轴
            for k = 1:5
                dot_product_temp = bitshift(abs(pixel_grad(1,1))*bin_vec(6-k,1),-Qn)+bitshift(abs(pixel_grad(1,2))*bin_vec(6-k,2),-Qn);
                if(dot_product_temp > dot_product)
                    dot_product = dot_product_temp;
                    bin_num = k+5;
                end
            end%得到在第2象限的bin分布
        elseif (pixel_grad(1,1)<=0 && pixel_grad(1,2)<0)%方向梯度在第三象限，包括y轴
            for k = 1:5
                dot_product_temp = bitshift(abs(pixel_grad(1,1))*bin_vec(k,1),-Qn)+bitshift(abs(pixel_grad(1,2))*bin_vec(k,2),-Qn);
                if(dot_product_temp > dot_product)
                    dot_product = dot_product_temp;
                    bin_num = k+9;
                end
            end%得到在第3象限的bin分布
        elseif (pixel_grad(1,1)>0 && pixel_grad(1,2)<0)%方向梯度在第4象限
            for k = 1:5
                dot_product_temp = bitshift(abs(pixel_grad(1,1))*bin_vec(6-k,1),-Qn)+bitshift(abs(pixel_grad(1,2))*bin_vec(6-k,2),-Qn);
                if(dot_product_temp > dot_product)
                    dot_product = dot_product_temp;
                    bin_num = k+14;
                    if(bin_num == 19)    %防止出现bin19
                        bin_num = 1;
                    end
                end
            end%得到在第4象限的bin分布
        end
        bin_num_array(i,j) = bin_num-1;
        %对每个像素点的梯度进行直方图统计
        cell_row = fix((i-1)/4)+1;%像素所在cell的row坐标
        cell_col = fix((j-1)/4)+1;%像素所在cell的col坐标
        pixel_row = rem(i-1,4)+1;%像素所在cell的内部row坐标
        pixel_col = rem(j-1,4)+1;%像素所在cell的内部col坐标
        if(pixel_row<3 && pixel_col<3)%像素在cell中左上块
            hist_cell(cell_row,cell_col,bin_num) = hist_cell(cell_row,cell_col,bin_num) + bitshift(int64(floor((5/8+2/8*(pixel_row-1))*(5/8+2/8*(pixel_col-1))*2^Qn))*vec_mod,-Qn);%本身cell
            if(cell_row>1)
                hist_cell(cell_row-1,cell_col,bin_num) = hist_cell(cell_row-1,cell_col,bin_num) + bitshift(int64(floor((3/8-2/8*(pixel_row-1))*(5/8+2/8*(pixel_col-1))*2^Qn))*vec_mod,-Qn);%上cell
            end
            if(cell_row>1 && cell_col>1)
                hist_cell(cell_row-1,cell_col-1,bin_num) = hist_cell(cell_row-1,cell_col-1,bin_num) + bitshift(int64(floor((3/8-2/8*(pixel_row-1))*(3/8-2/8*(pixel_col-1))*2^Qn))*vec_mod,-Qn);%左上cell
            end
            if(cell_col>1)
                hist_cell(cell_row,cell_col-1,bin_num) = hist_cell(cell_row,cell_col-1,bin_num) + bitshift(int64(floor((5/8+2/8*(pixel_row-1))*(3/8-2/8*(pixel_col-1))*2^Qn))*vec_mod,-Qn);%左cell
            end
        elseif(pixel_row<3 && pixel_col>2)%像素在cell中右上块
            hist_cell(cell_row,cell_col,bin_num) = hist_cell(cell_row,cell_col,bin_num) + bitshift(int64(floor((5/8+2/8*(pixel_row-1))*(7/8-2/8*(pixel_col-3))*2^Qn))*vec_mod,-Qn);%本身cell
            if(cell_row>1)
                hist_cell(cell_row-1,cell_col,bin_num) = hist_cell(cell_row-1,cell_col,bin_num) + bitshift(int64(floor((3/8-2/8*(pixel_row-1))*(7/8-2/8*(pixel_col-3))*2^Qn))*vec_mod,-Qn);%上cell
            end
            if(cell_row>1 && cell_col<image_size/4)
                hist_cell(cell_row-1,cell_col+1,bin_num) = hist_cell(cell_row-1,cell_col+1,bin_num) + bitshift(int64(floor((3/8-2/8*(pixel_row-1))*(1/8+2/8*(pixel_col-3))*2^Qn))*vec_mod,-Qn);%右上cell
            end
            if(cell_col<image_size/4)
                hist_cell(cell_row,cell_col+1,bin_num) = hist_cell(cell_row,cell_col+1,bin_num) + bitshift(int64(floor((5/8+2/8*(pixel_row-1))*(1/8+2/8*(pixel_col-3))*2^Qn))*vec_mod,-Qn);%右cell
            end
        elseif(pixel_row>2 && pixel_col<3)%像素在cell中左下块
            hist_cell(cell_row,cell_col,bin_num) = hist_cell(cell_row,cell_col,bin_num) + bitshift(int64(floor((7/8-2/8*(pixel_row-3))*(5/8+2/8*(pixel_col-1))*2^Qn))*vec_mod,-Qn);%本身cell
            if(cell_row<image_size/4)   
                hist_cell(cell_row+1,cell_col,bin_num) = hist_cell(cell_row+1,cell_col,bin_num) + bitshift(int64(floor((1/8+2/8*(pixel_row-3))*(5/8+2/8*(pixel_col-1))*2^Qn))*vec_mod,-Qn);%下cell
            end
            if(cell_row<image_size/4 && cell_col>1)
                hist_cell(cell_row+1,cell_col-1,bin_num) = hist_cell(cell_row+1,cell_col-1,bin_num) + bitshift(int64(floor((1/8+2/8*(pixel_row-3))*(3/8-2/8*(pixel_col-1))*2^Qn))*vec_mod,-Qn);%左下cell
            end
            if(cell_col>1)
                hist_cell(cell_row,cell_col-1,bin_num) = hist_cell(cell_row,cell_col-1,bin_num) + bitshift(int64(floor((7/8-2/8*(pixel_row-3))*(3/8-2/8*(pixel_col-1))*2^Qn))*vec_mod,-Qn);%左cell
            end
        elseif(pixel_row>2 && pixel_col>2)%像素在cell中右下块
            hist_cell(cell_row,cell_col,bin_num) = hist_cell(cell_row,cell_col,bin_num) + bitshift(int64(floor((7/8-2/8*(pixel_row-3))*(7/8-2/8*(pixel_col-3))*2^Qn))*vec_mod,-Qn);%本身cell
            if(cell_row<image_size/4)
                hist_cell(cell_row+1,cell_col,bin_num) = hist_cell(cell_row+1,cell_col,bin_num) + bitshift(int64(floor((1/8+2/8*(pixel_row-3))*(7/8-2/8*(pixel_col-3))*2^Qn))*vec_mod,-Qn);%下cell
            end
            if(cell_row<image_size/4 && cell_col<image_size/4)
                hist_cell(cell_row+1,cell_col+1,bin_num) = hist_cell(cell_row+1,cell_col+1,bin_num) + bitshift(int64(floor((1/8+2/8*(pixel_row-3))*(1/8+2/8*(pixel_col-3))*2^Qn))*vec_mod,-Qn);%右下cell
            end
            if(cell_col<image_size/4)
                hist_cell(cell_row,cell_col+1,bin_num) = hist_cell(cell_row,cell_col+1,bin_num) + bitshift(int64(floor((7/8-2/8*(pixel_row-3))*(1/8+2/8*(pixel_col-3))*2^Qn))*vec_mod,-Qn);%右cell
            end
        end
    end
end
% %读取vs中的int_histcell,进行对比
% C = load('C:\Users\LinMian\Desktop\HOG_20220902\vs_output_data\data2_int_histcell.txt');
% D = load('C:\Users\LinMian\Desktop\HOG_20220902\vs_output_data\data2_int_vec_mod_array.txt');
% E = load('C:\Users\LinMian\Desktop\HOG_20220902\vs_output_data\data2_int_bin_num_array.txt');
% int_histcell = zeros(34,34,27);
% int_vec_mod_array = zeros(136,136);
% int_bin_num_array = zeros(136,136);
% for i = 1:34
%    for j = 1:34
%       for k = 1:27
%          int_histcell(i,j,k) = C((i-1)*34*27+(j-1)*27+k); 
%       end
%    end
% end
% error2 = 0;
% max_0 = 0;
% max_1 = 0;
% max_2 = 0;
% max_3 = 0;
% a = 0;
% b = 0;
% max_2_coordinate = zeros(1,3);
% for i = 1:34
%     for j = 1:34
%         for k = 1:27
%             if(abs(hist_cell(i,j,k) - int_histcell(i,j,k)) > 1E-4)
%                 error2 = error2 + 1;
%                 if(abs(hist_cell(i,j,k) - int_histcell(i,j,k))>max_0)
%                    
%                    max_3 = max_2;
%                    max_2 = max_1;
%                    max_1 = max_0;
%                    max_0 = abs(hist_cell(i,j,k) - int_histcell(i,j,k));
%                    a = hist_cell(i,j,k);
%                    b = int_histcell(i,j,k);
%                    max_2_coordinate = [i,j,k];
%                    
%                 end
%                 
%             end
%         end
%     end
% end
% error_mod = 0;
% error_max_mod = 0;
% error_max_mod_cordinate = zeros(1,2);
% error_bin_num = 0;
% 
% for i = 1:136
%    for j = 1:136
%        int_vec_mod_array(i,j) = D((i-1)*136+j);
%        int_bin_num_array(i,j) = E((i-1)*136+j);
%    end
% end
% 
% for i = 1:136
%    for j = 1:136
%        if(abs(vec_mod_array(i,j) - int_vec_mod_array(i,j)) > 1E-4)
%            error_mod = error_mod +1;
%            if(abs(vec_mod_array(i,j) - int_vec_mod_array(i,j)) > error_max_mod)
%                 error_max_mod = abs(vec_mod_array(i,j) - int_vec_mod_array(i,j));
%                 error_max_mod_cordinate = [i,j];
%            end
%        end
%        if(bin_num_array(i,j) ~= int_bin_num_array(i,j))
%            error_bin_num = error_bin_num +1;
%            fprintf('bin_num_array[%d][%d] = %d    ',i,j,bin_num_array(i,j)); 
%            fprintf('int_bin_num_array[%d][%d] = %d\n',i,j,int_bin_num_array(i,j)); 
%        end
%    end
% end


%归一化
param1 = 1/2;%18bin和9bin的主成分分析系数
param2 = 1/sqrt(18);%18bin求和主成分分析系数

block_mod_square = zeros(34,'int64');%暂存每个cell的模平方
hog_feature = zeros(32,32,31,'int64');%归一化和主成分分析后特征图，9+18+4
for i = 1:image_size/4
    for j = 1:image_size/4
        for k = 1:9
            hist_cell(i,j,k+18) = hist_cell(i,j,k) + hist_cell(i,j,k+9);%统计本cell的9个bin的值
        end
        for l = 1:9
            block_mod_square(i,j) = block_mod_square(i,j) + bitshift(hist_cell(i,j,l+18) * hist_cell(i,j,l+18),-Qn);
        end
        %block_mod_square(i,j) = sum(hist_cell(i,j,19:27).*hist_cell(i,j,19:27));%得到本cell的9bin的模平方
        if(i>2 && j>2)%缓存3x3的模
           r = zeros(1,4,'int64');
           r(1,1) = Q_rsqrt_quantify(block_mod_square(i-2,j-2) + block_mod_square(i-2,j-1) + block_mod_square(i-1,j-2) + block_mod_square(i-1,j-1)+ int64(1), Qn);%左上block
           r(1,2) = Q_rsqrt_quantify(block_mod_square(i-2,j-1) + block_mod_square(i-2,j) + block_mod_square(i-1,j-1) + block_mod_square(i-1,j) + int64(1), Qn);%右上block
           r(1,3) = Q_rsqrt_quantify(block_mod_square(i-1,j-2) + block_mod_square(i-1,j-1) + block_mod_square(i,j-2) + block_mod_square(i,j-1) + int64(1), Qn);%左下block
           r(1,4) = Q_rsqrt_quantify(block_mod_square(i-1,j-1) + block_mod_square(i-1,j) + block_mod_square(i,j-1) + block_mod_square(i,j) + int64(1), Qn);%右下block
           %主成分分析
           vec_28 = int64(0);%第28维求和特征
           vec_29 = int64(0);%第28维求和特征
           vec_30 = int64(0);%第28维求和特征
           vec_31 = int64(0);%第28维求和特征
           for h = 1:9
               cut_norm = zeros(1,12, 'int64');%如果特征值归一化后大于0.2，则设置为0.2
               for k = 1:4
                   
                   temp1 = int64(bitshift(hist_cell(i-1,j-1,h) * r(1,k), -Qn));
                   temp2 = int64(bitshift(hist_cell(i-1,j-1,h+9) * r(1,k), -Qn));
                   temp3 = int64(bitshift(hist_cell(i-1,j-1,h+18) * r(1,k), -Qn));
                   if(temp1 > int64(floor(0.2 * 2^Qn)))
                       cut_norm(1,k) = int64(floor(0.2 * 2^Qn));
                   else
                       cut_norm(1,k) = temp1;
                   end
                   if(temp2 > int64(floor(0.2 * 2^Qn)))
                       cut_norm(1,k+4) = int64(floor(0.2 * 2^Qn));
                   else
                       cut_norm(1,k+4) = temp2;
                   end
                   if(temp3 > int64(floor(0.2 * 2^Qn)))
                       cut_norm(1,k+8) = int64(floor(0.2 * 2^Qn));
                   else
                       cut_norm(1,k+8) = temp3;
                   end
                   hog_feature(i-2,j-2,h) = hog_feature(i-2,j-2,h) + cut_norm(1,k);%18bin中角度相反的两个bin归一化和主成分分析,1-9
                   hog_feature(i-2,j-2,h+9) = hog_feature(i-2,j-2,h+9) + cut_norm(1,k+4);%18bin中角度相反的两个bin归一化和主成分分析，10-18
                   hog_feature(i-2,j-2,h+18) = hog_feature(i-2,j-2,h+18) + cut_norm(1,k+8);%8bin归一化和主成分分析
               end
               hog_feature(i-2,j-2,h) = bitshift(int64(floor(param1 * 2^Qn)) * hog_feature(i-2,j-2,h), -Qn);
               hog_feature(i-2,j-2,h+9) = bitshift(int64(floor(param1 * 2^Qn)) * hog_feature(i-2,j-2,h+9), -Qn);
               hog_feature(i-2,j-2,h+18) = bitshift(int64(floor(param1 * 2^Qn)) * hog_feature(i-2,j-2,h+18), -Qn);
%                hog_feature(i-2,j-2,h+18) = hog_feature(i-2,j-2,h) + hog_feature(i-2,j-2,h+9);%8bin归一化和主成分分析
               vec_28 = vec_28 + (cut_norm(1,1) + cut_norm(1,1+4));%18bin内部求和特征
               vec_29 = vec_29 + (cut_norm(1,2) + cut_norm(1,2+4));
               vec_30 = vec_30 + (cut_norm(1,3) + cut_norm(1,3+4));
               vec_31 = vec_31 + (cut_norm(1,4) + cut_norm(1,4+4));
%                hog_feature(i-2,j-2,h) = param1*(1/r1+1/r2+1/r3+1/r4)*hist_cell(i-1,j-1,h);
%                hog_feature(i-2,j-2,h+9) = param1*(1/r1+1/r2+1/r3+1/r4)*hist_cell(i-1,j-1,h+9);%18bin中角度相反的两个bin归一化和主成分分析
%                hog_feature(i-2,j-2,h+18) = hog_feature(i-2,j-2,h) + hog_feature(i-2,j-2,h+9);%8bin归一化和主成分分析
%                vec_28 = vec_28 + param2*(1/r1)*(hist_cell(i-1,j-1,h) + hist_cell(i-1,j-1,h+9));%18bin内部求和特征
%                vec_29 = vec_29 + param2*(1/r2)*(hist_cell(i-1,j-1,h) + hist_cell(i-1,j-1,h+9));
%                vec_30 = vec_30 + param2*(1/r3)*(hist_cell(i-1,j-1,h) + hist_cell(i-1,j-1,h+9));
%                vec_31 = vec_31 + param2*(1/r4)*(hist_cell(i-1,j-1,h) + hist_cell(i-1,j-1,h+9));
           end
           hog_feature(i-2,j-2,28) = bitshift(int64(floor(param2 * 2^Qn)) * vec_31, -Qn);%28-31维求和特征
           hog_feature(i-2,j-2,29) = bitshift(int64(floor(param2 * 2^Qn)) * vec_29, -Qn);
           hog_feature(i-2,j-2,30) = bitshift(int64(floor(param2 * 2^Qn)) * vec_30, -Qn);
           hog_feature(i-2,j-2,31) = bitshift(int64(floor(param2 * 2^Qn)) * vec_28, -Qn);
        end
    end
end

%生成hann窗
hann1t = zeros(1,32);
hann2d = zeros(32,32,'int64');

for i = 1:32
   hann1t(i) = 0.5 * (1 - cos(2 * pi * (i - 1)/31));
end
for i = 1:32
   for j = 1:32
       hann2d(i,j) = int64(floor((hann1t(i) * hann1t(j) * 2^Qn)));
   end
end

% 生成特征图经过滑窗
for i = 1:32
   for j = 1:32
       for k = 1:31
           hog_feature(i,j,k) = bitshift(hog_feature(i,j,k) * hann2d(i,j),-Qn);
       end
   end
end

%输出single结果
hog_feature_float = zeros(32,32,31,'single');
for i = 1:32
   for j = 1:32
       for k = 1:31
           hog_feature_float(i,j,k) = single(hog_feature(i,j,k))/single(2^Qn);
       end
   end
end

%寻找特征图中有无出现运算出错的地方
% nan_A = isnan(hog_feature);
% position_nan_A = find(nan_A == 1);
% inf_A = isinf(hog_feature);
% position_inf_A = find(inf_A == 1);

% B = hist_cell(11,13,1:18)
% target_image_gray = image_gray(11*4-5:11*4+2,13*4-5:13*4+2)
