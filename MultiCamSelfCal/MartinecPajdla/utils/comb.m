%returns combination number n over k
function r = comb(n,k)

r=1;
for i=1:k
  r=r*(n-i+1)/i;
end

