function result = lbp(varargin)  % (image,radius,neighbors,mapping,mode)

% Check number of input arguments.% %% 检查参数的个数nargin，使其大于1小于5。如果不在此区间，就报错
error(nargchk(1,5,nargin));
image=varargin{1};% % %% 把第一个参数赋值给image
d_image=double(image);% % % 把图像从uint8转成double类型，以便以后计算
 
% % % 只有给出待处理的图像（一个参数）时，使用默认的设置。
% % % sp定义了中心点与它的近邻的相对位置
% % % neighbors定义近邻个数
% % % mapping定义的映射
% % % mode区别直方图的类型，'h' or 'hist'是直方图，nh是规一化的直方图
if nargin==1
spoints=[-1 -1; -1 0; -1 1; 0 -1; -0 1; 1 -1; 1 0; 1 1]; 
neighbors=8;
mapping=0;
mode='h';
end
 
% % % 给出两个参数，并且第二个参数（代表近邻半径）的长度为1时
% % % 只给出了近邻的半径，没给出近邻的个数，报错
if (nargin == 2) && (length(varargin{2}) == 1)
error('Input arguments');
end
% % % 如果给出两个以上的参数，并且第二个参数（代表近邻半径）的长度为1
% % % 半径设为第二个参数
% % % 近邻个数设为第三个参数
if (nargin > 2) && (length(varargin{2}) == 1)
radius=varargin{2};
neighbors=varargin{3};
 
spoints=zeros(neighbors,2);
 
% % % 把360度均匀分成neighbors分，以计算近邻点与中心的相对坐标
a = 2*pi/neighbors;
 
% % % 计算坐标，每一维代表y,第二维代表x
% % % spoints的第i行代表第i个近邻
for i = 1:neighbors
spoints(i,1) = -radius*sin((i-1)*a);
spoints(i,2) = radius*cos((i-1)*a);
end
% % % 如果参数个数大于等于4，第四个参数赋值给映射mapping；否则，无映射。
if(nargin >= 4)
     mapping=varargin{4};
     if(isstruct(mapping) && mapping.samples ~= neighbors)
        error('Incompatible mapping');
     end
else 
     mapping=0;
end
% % % 第五个参数确定直方图的属性
if(nargin >= 5)
     mode=varargin{5};
else
    mode='h';
   end
end
% % % 如果参数个数大于1，并且第二个参数的长度大于1。则第二个参数给出近邻点与中心点的相对位置
if (nargin > 1) && (length(varargin{2}) > 1)
spoints=varargin{2};
neighbors=size(spoints,1);
% % % 如果还有第三个参数，把它赋值给映射mapping
if(nargin >= 3)
mapping=varargin{3};
if(isstruct(mapping) && mapping.samples ~= neighbors)
    error('Incompatible mapping');
end
else
    mapping=0;
end
 
if(nargin >= 4)
    mode=varargin{4};
else
    mode='h';
end 
end
 
% 图像的大小，第一维是y，第二维是x
[ysize xsize] = size(image);
 
% % % 确定block的左上和右下两个点
miny=min(spoints(:,1));
maxy=max(spoints(:,1));
minx=min(spoints(:,2));
maxx=max(spoints(:,2));
 
% Block size, each LBP code is computed within a block of size
% bsizey*bsizex 
% % % block的大小
bsizey=ceil(max(maxy,0))-floor(min(miny,0))+1;
bsizex=ceil(max(maxx,0))-floor(min(minx,0))+1;
 
% Coordinates of origin (0,0) in the block
% % % 在block里中心点的坐标
origy=1-floor(min(miny,0));
origx=1-floor(min(minx,0));
 
% Minimum allowed size for the input image depends
% on the radius of the used LBP operator.
% % % 检查block和img的大小
if(xsize < bsizex || ysize < bsizey)
    error('Too small input image. Should be at least (2*radius+1) x (2*radius+1)');
end
 
% Calculate dx and dy;
dx = xsize - bsizex;
dy = ysize - bsizey;
 
% Fill the center pixel matrix C.
% % % 所有可以作为模板中心点的像素集合
C = image(origy:origy+dy,origx:origx+dx);
d_C = double(C);
 
bins = 2^neighbors;
 
% Initialize the result matrix with zeros.
result=zeros(dy+1,dx+1);
% % % 初始化结果矩阵

% % % 对于每一个neighbor，先使要比较的点与中心点对齐，然后利用D = N >= C比较它们的大小。
for i = 1:neighbors
y = spoints(i,1)+origy;
x = spoints(i,2)+origx;
% Calculate floors, ceils and rounds for the x and y.
fy = floor(y); cy = ceil(y); ry = round(y);
fx = floor(x); cx = ceil(x); rx = round(x);
% Check if interpolation is needed.
if (abs(x - rx) < 1e-6) && (abs(y - ry) < 1e-6)
% Interpolation is not needed, use original datatypes
N = image(ry:ry+dy,rx:rx+dx);
D = N >= C; 
else
% Interpolation needed, use double type images 
ty = y - fy;
tx = x - fx;
 
% Calculate the interpolation weights.
w1 = roundn((1 - tx) * (1 - ty),-6);
w2 = roundn(tx * (1 - ty),-6);
w3 = roundn((1 - tx) * ty,-6) ;
w4 = roundn(1-w1-w2-w3,-6) ;
% Compute interpolated pixel values
N = w1*d_image(fy:fy+dy,fx:fx+dx) + w2*d_image(fy:fy+dy,cx:cx+dx) + ...
w3*d_image(cy:cy+dy,fx:fx+dx) + w4*d_image(cy:cy+dy,cx:cx+dx);
N=roundn(N,-4);
D = N >= d_C; 
end 
% Update the result matrix.
% % % 更新结果矩阵
v = 2^(i-1);
result = result + v*D;
end
 
%Apply mapping if it is defined
% % % 如果mapping已经存在，那么利用这个mapping.
if isstruct(mapping)
    bins = mapping.num;
    for i = 1:size(result,1)
        for j = 1:size(result,2)
        result(i,j) = mapping.table(result(i,j)+1);
        end
    end
end
% % % 如果要参数列表指定了直方图的属性，计算直方图
if (strcmp(mode,'h') || strcmp(mode,'hist') || strcmp(mode,'nh'))
    result=hist(result(:),0:(bins-1));
    if (strcmp(mode,'nh'))
        result=result/sum(result);
    end
else
    if ((bins-1)<=intmax('uint8'))% 如果没有指定直方图的属性，返回数值方阵
        result=uint8(result);
    elseif ((bins-1)<=intmax('uint16'))
        result=uint16(result);
    else
        result=uint32(result);
    end
end
end
