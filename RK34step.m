function [unew, err] = RK34step(f, uold, told, h)

Y1 = f(told, uold);
Y2 = f(told + h/2, uold + h*Y1/2);
Y3 = f(told + h/2, uold + h*Y2/2);
Z3 = f(told + h, uold - h*Y1 + 2*h*Y2);
Y4 = f(told + h, uold + h*Y3);

unew = uold + h/6*(Y1 + 2*Y2 + 2*Y3 + Y4);
err = uold + h/6*(Y1 + 4*Y2 + Z3);
end