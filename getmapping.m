function mapping = getmapping(samples,mappingtype)

table = 0:2^samples-1;
newMax = 0; %number of patterns in the resulting LBP code
index = 0;
 
if strcmp(mappingtype,'u2')  %Uniform 2
    newMax = samples*(samples-1) + 3; 
for i = 0:2^samples-1
% % % j��iѭ�����ƵĽ��
%j = bitset(bitshift(i,1,'uint8'),1,bitget(i,samples)); %rotate left
i_bin = dec2bin(i,samples);
j_bin = circshift(i_bin',-1)'; 
numt = sum(i_bin~=j_bin);

num=uint8(0);
for index=0:1:255
    %��Ϊ��Ӧ�Ķ�������
    temp1=uint8(zeros(1,8));
    index1=1;
    temp2=index;
    while temp2
          temp1(1,index1)=mod(temp2,2);
          temp2=floor(temp2/2);
          index1=index1+1;
    end
end

% % % ��������Ĵ���
numt=0;
for index1=1:1:7
        if temp1(1,index1)~=temp1(1,index1+1) 
            numt=numt+1;
        end
end
    if temp1(1,1)~=temp1(1,8)
        numt=numt+1;
    end
    if numt <= 2 % % % ����������������2����ô�½�һ�����index;����������һ��
        table(1,index+1) = index;
        if (index<59)
            num=num+1
        end
    else
        table(1,index+1) =59;
    end
end
end

temp=1;
for index=1:1:256
    if(table(1,index)~=59)
      if(temp==num+1)
       temp=temp+1;       
      end
       table(2,index)=temp;
      temp=temp+1;
    else table(2,index)=num+1;
    end
end

if strcmp(mappingtype,'ri') %Rotation invariant
    tmpMap = zeros(2^samples,1) - 1;
for i = 0:2^samples-1
    rm = i;
%r = i;

r_bin = dec2bin(i,samples);

% % % ��������rotate����С��һ��
for j = 1:samples-1
%r = bitset(bitshift(r,1,'uint8'),1,bitget(r,samples)); %rotate

r_bin = dec2bin(i,samples);

if r < rm
    rm = r;
end
end
% % % ͬ��
if tmpMap(rm+1) < 0
    tmpMap(rm+1) = newMax;
    newMax = newMax + 1;
end
table(i+1) = tmpMap(rm+1);
end
end
 
if strcmp(mappingtype,'riu2') %Uniform & Rotation invariant
    newMax = samples + 2;
for i = 0:2^samples - 1
%j = bitset(bitshift(i,1,'uint8'),1,bitget(i,samples)); 
%rotate left
%numt = sum(bitget(bitxor(i,j),1:samples));

   i_bin =  dec2bin(i,samples);
   j_bin = circshift(i_bin',-1)';
   numt = sum(i_bin~=j_bin);

if numt <= 2
    table(i+1) = sum(bitget(i,1:samples));
else
    table(i+1) = samples+1;
end
end
end
 
mapping.table=table;
mapping.samples=samples;
mapping.num=newMax;

