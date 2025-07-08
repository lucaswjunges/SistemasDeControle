function dxdt = sistema_nao_linear_q5(t, x, u_signal, t_sim, CAF, k1, k2, k3)
    u_current = interp1(t_sim, u_signal, t);
    dxdt = [-k1*x(1) - k3*x(1)^2 + (CAF - x(1))*u_current;
            k1*x(1) - k2*x(2) - x(2)*u_current];
end