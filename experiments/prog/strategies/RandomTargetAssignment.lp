% assigned(R,S) :- shelf(S,_), robot(R), S==R.
{assigned(R,S)} :- robot(R),shelf(S,_). 
:- robot(R), not assigned(R,_).
:- shelf(S,_), not assigned(_,S).
:- robot(R), shelf(S1,_), shelf(S2,_), assigned(R,S1), assigned(R,S2), S1!=S2.
