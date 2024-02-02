function [nzero] = MontaFunc(n,delta,dist)
C = 1.2 * rand(39,1);
D = 40 * rand(39,1);

fun = @(n) funcao(n,delta,dist);

vetor_n = -3:0.01:3;

nzero = fzero(fun,-5)


plot(vetor_n, fun(vetor_n),'r'), grid on

    return
end
