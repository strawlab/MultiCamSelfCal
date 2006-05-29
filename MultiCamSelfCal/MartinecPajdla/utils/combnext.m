%combnext Returns the next combination in order of shifting the least left
%number to the right.
%
%  function next=combnext(n, k, com)
%
%n and k has the meaning of combination number.
function next=combnext(n, k, com)

   next=com;
   move=k; moved=0;
   while ~moved
     if next(move) < n-k+move
       next(move)=next(move)+1;
       for i=move+1:k
	 next(i)=next(move)+i-move;
       end
       moved=1;
     else 
       if move>1
	 move=move-1;
       else
	 disp('Error: this code should have never be called');
       end
     end
   end

return

