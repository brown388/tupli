function x = roundn(x, n)
error(nargchk(2, 2, nargin, 'struct'))
validateattributes(x, {'single', 'double'}, {}, 'ROUNDN', 'X')
validateattributes(n, ...
{'numeric'}, {'scalar', 'real', 'integer'}, 'ROUNDN', 'N')
if n < 0
    p = 10 ^ -n;
    x = round(p * x) / p;
elseif n > 0
    p = 10 ^ n;
    x = p * round(x / p);
else
    x = round(x);
end
end