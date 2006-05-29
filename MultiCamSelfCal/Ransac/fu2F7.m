function Fs = fu2F7(u)

Z = lin_fm(u);

NullSp   = null(Z);
if size(NullSp,2) > 2 
   Fs = [];
   return; %degenerated sample
end

F1    = reshape(NullSp(:,1),3,3);
F2    = reshape(NullSp(:,2),3,3);
p = fslcm(F1,F2);
aroots = rroots(p);

%xr = o_fslcm(F1,F2)

%aroots == xr

for i = 1:length(aroots)
   l  = aroots(i);
   Ft    = F1 * l + F2 * (1-l);
%   Ft = Ft /norm(Ft,2);
   Fs(:,:,i) = Ft;
end



