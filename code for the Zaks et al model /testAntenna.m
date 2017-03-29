function testAntenna
q = 0:0.1:1 ;  %probability of quenching by qE site
r = 0:0.1:1 ;  %probability of quenching by RC

[q r]=quantum_yield(q,r);

plot3(q,r,f);

end

% function describing the quantum yield of quenching
function [q_yield r_yield]=quantum_yield(qvec,rvec)
end
