%SampleCnt calculates number of samples needed to be done

function SampleCnt = nsamples(ni, ptNum, pf, conf)
q  = prod ([(ni-pf+1) : ni] ./ [(ptNum-pf+1) : ptNum]);

if (1 -q) < eps
   SampleCnt = 1;
else  
   SampleCnt  = log(1 - conf) / log(1 - q);
end

if SampleCnt < 1
   SampleCnt = 1;
end
