function result = lbp(varargin)  % (image,radius,neighbors,mapping,mode)

% Check number of input arguments.% %% �������ĸ���nargin��ʹ�����1С��5��������ڴ����䣬�ͱ���
error(nargchk(1,5,nargin));
image=varargin{1};% % %% �ѵ�һ��������ֵ��image
d_image=double(image);% % % ��ͼ���uint8ת��double���ͣ��Ա��Ժ����
 
% % % ֻ�и����������ͼ��һ��������ʱ��ʹ��Ĭ�ϵ����á�
% % % sp���������ĵ������Ľ��ڵ����λ��
% % % neighbors������ڸ���
% % % mapping�����ӳ��
% % % mode����ֱ��ͼ�����ͣ�'h' or 'hist'��ֱ��ͼ��nh�ǹ�һ����ֱ��ͼ
if nargin==1
spoints=[-1 -1; -1 0; -1 1; 0 -1; -0 1; 1 -1; 1 0; 1 1]; 
neighbors=8;
mapping=0;
mode='h';
end
 
% % % �����������������ҵڶ���������������ڰ뾶���ĳ���Ϊ1ʱ
% % % ֻ�����˽��ڵİ뾶��û�������ڵĸ���������
if (nargin == 2) && (length(varargin{2}) == 1)
error('Input arguments');
end
% % % ��������������ϵĲ��������ҵڶ���������������ڰ뾶���ĳ���Ϊ1
% % % �뾶��Ϊ�ڶ�������
% % % ���ڸ�����Ϊ����������
if (nargin > 2) && (length(varargin{2}) == 1)
radius=varargin{2};
neighbors=varargin{3};
 
spoints=zeros(neighbors,2);
 
% % % ��360�Ⱦ��ȷֳ�neighbors�֣��Լ�����ڵ������ĵ��������
a = 2*pi/neighbors;
 
% % % �������꣬ÿһά����y,�ڶ�ά����x
% % % spoints�ĵ�i�д����i������
for i = 1:neighbors
spoints(i,1) = -radius*sin((i-1)*a);
spoints(i,2) = radius*cos((i-1)*a);
end
% % % ��������������ڵ���4�����ĸ�������ֵ��ӳ��mapping��������ӳ�䡣
if(nargin >= 4)
     mapping=varargin{4};
     if(isstruct(mapping) && mapping.samples ~= neighbors)
        error('Incompatible mapping');
     end
else 
     mapping=0;
end
% % % ���������ȷ��ֱ��ͼ������
if(nargin >= 5)
     mode=varargin{5};
else
    mode='h';
   end
end
% % % ���������������1�����ҵڶ��������ĳ��ȴ���1����ڶ��������������ڵ������ĵ�����λ��
if (nargin > 1) && (length(varargin{2}) > 1)
spoints=varargin{2};
neighbors=size(spoints,1);
% % % ������е�����������������ֵ��ӳ��mapping
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
 
% ͼ��Ĵ�С����һά��y���ڶ�ά��x
[ysize xsize] = size(image);
 
% % % ȷ��block�����Ϻ�����������
miny=min(spoints(:,1));
maxy=max(spoints(:,1));
minx=min(spoints(:,2));
maxx=max(spoints(:,2));
 
% Block size, each LBP code is computed within a block of size
% bsizey*bsizex 
% % % block�Ĵ�С
bsizey=ceil(max(maxy,0))-floor(min(miny,0))+1;
bsizex=ceil(max(maxx,0))-floor(min(minx,0))+1;
 
% Coordinates of origin (0,0) in the block
% % % ��block�����ĵ������
origy=1-floor(min(miny,0));
origx=1-floor(min(minx,0));
 
% Minimum allowed size for the input image depends
% on the radius of the used LBP operator.
% % % ���block��img�Ĵ�С
if(xsize < bsizex || ysize < bsizey)
    error('Too small input image. Should be at least (2*radius+1) x (2*radius+1)');
end
 
% Calculate dx and dy;
dx = xsize - bsizex;
dy = ysize - bsizey;
 
% Fill the center pixel matrix C.
% % % ���п�����Ϊģ�����ĵ�����ؼ���
C = image(origy:origy+dy,origx:origx+dx);
d_C = double(C);
 
bins = 2^neighbors;
 
% Initialize the result matrix with zeros.
result=zeros(dy+1,dx+1);
% % % ��ʼ���������

% % % ����ÿһ��neighbor����ʹҪ�Ƚϵĵ������ĵ���룬Ȼ������D = N >= C�Ƚ����ǵĴ�С��
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
% % % ���½������
v = 2^(i-1);
result = result + v*D;
end
 
%Apply mapping if it is defined
% % % ���mapping�Ѿ����ڣ���ô�������mapping.
if isstruct(mapping)
    bins = mapping.num;
    for i = 1:size(result,1)
        for j = 1:size(result,2)
        result(i,j) = mapping.table(result(i,j)+1);
        end
    end
end
% % % ���Ҫ�����б�ָ����ֱ��ͼ�����ԣ�����ֱ��ͼ
if (strcmp(mode,'h') || strcmp(mode,'hist') || strcmp(mode,'nh'))
    result=hist(result(:),0:(bins-1));
    if (strcmp(mode,'nh'))
        result=result/sum(result);
    end
else
    if ((bins-1)<=intmax('uint8'))% ���û��ָ��ֱ��ͼ�����ԣ�������ֵ����
        result=uint8(result);
    elseif ((bins-1)<=intmax('uint16'))
        result=uint16(result);
    else
        result=uint32(result);
    end
end
end
