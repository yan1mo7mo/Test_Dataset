function [s_ESN]=op_BuildSingleReservoir(s_ESN)
rand( 'seed', 42 );
s_ESN.Win = s_ESN.IS*(-1 + 2*rand(s_ESN.resSize,1+s_ESN.inSize));
s_ESN.sparsity = s_ESN.degree/s_ESN.resSize;
W= sprand(s_ESN.resSize,s_ESN.resSize,s_ESN.sparsity);
e = max(abs(eigs(W)));
s_ESN.Wres = (W./e).*s_ESN.radius;
end