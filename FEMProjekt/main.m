%Set init params
b = 187.5e-3;
d = 12.5e-3;
l1 = 31.25e-3;
l2 = 50e-3;
l3 = 62.5e-3;
l4 = 75e-3;
T_water = 74;
T_air = 20;
nelm = size(t,2);
ndof = size(p,2);
E = 72e9;
v = 0.3;
alpha_c = 500;
alpha_water = 5000;
alpha = 23e-6;

%Get nodal points on boundaries
%bc1 = e(1,1:5)';
%bc2 = e(1,6:15)';
%bc3 = e(1,16:23)';
%bc3 = [bc3; e(2,23)];
bc1 = [];

%Create K-matrix
f = zeros(ndof, 1);
K = zeros(ndof);
D = alpha_c*[1 0; 0 1];

%Create Edof matrix
Edof = zeros(nelm, 4);
Edof(:,1) = 1:nelm;
Edof(:,2:4) = t(1:3,:)';

for i = 1:nelm
    ex = p(1, t(1:3,i));
    ey = p(2, t(1:3,i));
    [Ke, fe] = flw2te(ex(1,:), ey(1,:), 1, D, 0);
    K = assem(Edof, K, Ke);
    f(Edof(i, 2:4)) = f(Edof(i, 2:4)) + fe;
    %f = insert(Edof, f, fe);
    %f = insert(Edof, f, fe);
end

%Get triangles for boundary
for i = 1:size(e,2) %edge
    for j = 1:nelm %triangle
        a = (find(t(1:3,j) == e(1,i)));
        b = (find(t(1:3,j) == e(2,i)));
        if (a+b) ~= b
            bc1 = [bc1; j e(1,i) e(2,i)];
        end
    end
end

bc = [bc1(1:4,:); bc1(16:23,:)];
%f = zeros(nelm, 1);
K1 = K;
for i = 1:size(bc,1)
    n1 = p(:,bc(i,2));
    n2 = p(:,bc(i,3));
    L = ((n1(1)-n2(1))^2+(n1(2)-n2(2)^2))^(1/2);
    Ke_b = alpha_water*L/6*[2 1; 1 2];
    %fe_b=-alpha_water*T_air*L*[1/2; 1/2];
    K = assem(bc(i,:), K, Ke_b);
    %f = insert(bc(i,:), f, fe_b); 
    f(bc(i,2)) = f(bc(i,2)) - alpha_water*T_air*L*1/2;
    f(bc(i,3)) = f(bc(i,3)) - alpha_water*T_air*L*1/2;
end

%Get nodal points on boundaries
bc2 = e(1,1:5)';
bc3 = e(1,6:15)';
bc4 = e(1,16:23)';
bc4 = [bc4; e(2,23)];

%Set boundary conditions
bc2(:,2) = T_water;
bc3(:,2) = T_air;
bc4(:,2) = T_water;
boundary = [bc2; bc3; bc4];

a = solveq(K, f, boundary);

for i = 1:nelm
    ex(i,:) = p(1, Edof(i, 2:4));
    ey(i,:) = p(2, Edof(i, 2:4));
end
%[ex, ey] = coordxtr(Edof, p, dof, 3);
ed = extract(Edof, a);
fill(ex', ey', ed')

%% Stress equations

%Calculate element temperature
for i = 1:ndof
    dT(i) = sum(a(t(1:3,i)))/3 - T_air;
end

%Create Edof matrix
Edof = zeros(nelm, 7);
Edof(:,1) = 1:nelm;
Edof(:,2) = t(1,:)';
Edof(:,3) = Edof(:,2);
Edof(:,4) = t(2,:)';
Edof(:,5) = Edof(:,4);
Edof(:,6) = t(3,:)';
Edof(:,7) = Edof(:,6);

%Get K 
K = zeros(ndof);
D = hooke(1, E, v);
f0 = zeros(ndof, 1);

for i = 1:ndof
    ex = p(1, t(1:3,i));
    ey = p(2, t(1:3,i));
    C = [ones(3,1) ex' ey'];
    [Ke, fe] = plante(ex, ey, [1 1], D, [0; 0]);
    K = assem(Edof, K, Ke);
    
    f0_e = [0 1 0 0 0 1]'*1/2*det(C)*alpha*dT(i)/(1-v)*1;
    f0_e
    f0(Edof(i,2:end), 1) = f0(Edof(i,2:end), 1) + f0_e;
end

a = solveq(K, f0);

[Ex, Ey] = coordxtr(Edof, p, 
%% Heat equations

%Create Edof matrix
Edof = zeros(nelm, 4);
Edof(:,1) = 1:nelm;
Edof(:,2:4) = t(1:3,:)';

%Initialize D-matrix, K-matrix, ex, ey, f
ndof = size(p,2);
D = alpha_c*[1 0; 0 1];
K = zeros(ndof);
f = zeros(ndof,1);

%Create K-matrix
for i = 1:nelm
    ex = p(1, t(1:3,i));
    ey = p(2, t(1:3,i));
    [Ke, fe] = flw2te(ex(1,:), ey(1,:), 1, D, 0);
    K = assem(Edof, K, Ke);
    %f = insert(Edof, f, fe);
end

%Create fb
C = [ones(3,1) 

%Solve equation, plot graph

a = solveq(K, f, bc);
%dof = 1:nelm';
%dof = reshape(dof, [3, nelm])';
for i = 1:nelm
    ex(i,:) = p(1, Edof(i, 2:4));
    ey(i,:) = p(2, Edof(i, 2:4));
end
%[ex, ey] = coordxtr(Edof, p, dof, 3);
ed = extract(Edof, a);
fill(ex, ey, ed)

%% Stress equations

%Create Edof matrix
Edof = zeros(nelm, 7);
Edof(:,1) = 1:nelm;
Edof(:,2) = t(1,:)';
Edof(:,3) = Edof(:,2);
Edof(:,4) = t(2,:)';
Edof(:,5) = Edof(:,4);
Edof(:,6) = t(3,:)';
Edof(:,7) = Edof(:,6);

%Get K 
ndof = 2*size(p,2);
K = zeros(ndof);
D = hooke(1, E, v);

for i = 1:nelm
    Ke = plante(p(1, t(1:3,i)), p(2, t(1:3,i)), [1 1], D)
    
    K = assem(Edof, K, Ke);
end
