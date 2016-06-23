j = true;
time = 0;
PossibleActions = [-1 0 1];
alpha = 0.001;
gamma = 0.95;
sigma = 0.12;
T = 3;
hidden = 4;
features = 3;
input = features;
[Theta_old, Theta_new] = init_theta(sigma, input, hidden);
firstAction = true;
Theta_grad = zeros(size(Theta_old));
grad = 0;

% subplot(2,1,2);
x = [-pi:0.01:pi];
a = 1 + cos(x - pi);
plot(x, a);
hold on;

for abba = 1:10000
    j = true;
    Position = 0.3*(rand()-0.5);
    Velocity = 0.0;
    height = 1 - cos(Position);
    kval = 0;
    while j == true
        sequence = [Velocity Position];
        z = [];
        z(1,:) = phi_func(sequence,features-1);
        for t = 1:T
            time = time + 1;
            epsilon = rand();
            if (epsilon <= 1-0.9*sigmoid(abba*0.1 - 2)) || (firstAction == true)
                Action = randi([-1 1]);
            else
                [Action,~] = Action_forwardprop(Theta_new, z(t,:), input, hidden);
%                 disp([Theta_old Theta_new Action*ones(size(Theta_old))]);
%                 disp(Action);
            end
            
            [Velocity, Position, height, reward, j] = emulate_action(Velocity, Action, Position);
            
            sequence = [sequence Action Velocity Position];
%             disp(sequence);
%             pause();
            z(t+1,:) = phi_func(sequence,features-1);
            D = store_to_D(z(t,:), Action, reward, z(t+1,:));
            X = fetch(D);
%             disp(z);
%             pause();
%             format long;
%             disp(X(:,2));
%             pause(1);
            if size(X) > 0;
                for update = 1:10
                    Theta_grad = zeros(size(Theta_old));
                    z_t_ = X(:,1:2);
                    a_t = X(:,3);
                    rew = X(:,4);
                    z_t1_ = X(:,5:6);
                    
                    for iteration = 1:10
                        z_t = X(iteration,1:2);
                        this_action = X(iteration,3);
                        reward = X(iteration,4);
                        z_t1 = X(iteration,5:6);

                        if iteration < 10
                            [~,Qmax] = Action_forwardprop(Theta_old, z_t1, input, hidden);
                        else
                            Qmax = 0;
                        end
                        y = reward + Qmax;
                        Qval = forwardprop(Theta_new, z_t, this_action, input, hidden);
                        grad = backprop(Theta_new, y, z_t, this_action, input, hidden);
                        Theta_grad = Theta_grad + (reward + gamma*Qmax - Qval)*grad;
                    end
                    Theta_old = Theta_new;
                    Theta_new = Theta_new - alpha/10*Theta_grad;
                end
            end
                
%             if t <= T
%                 [~,Qmax] = Action_forwardprop(Theta_old, z(t+1,:), input, hidden);
%             else
%                 Qmax = 0;
%             end
%             y = reward + Qmax;
%             Qval = forwardprop(Theta_new, z(t,:), Action, input, hidden);
%             grad = backprop(Theta_new, y, z(t,:), Action, input, hidden);
%             
%             Theta_grad = Theta_grad + (reward + gamma*Qmax - Qval)*grad;
%             disp([Theta_grad t*ones(size(Theta_grad))]);
%             if mod(t,10) == 0
%                 Theta_old = Theta_new;
%                 Theta_new = Theta_new - alpha/10*Theta_grad;
%                 Theta_grad = zeros(size(Theta_old));
%                 Cost = (reward + gamma*Qmax - Qval)^2;
%                 
%                 %                     subplot(2,1,1)
%                 %                     g(time) = plot(time, Cost,'+');
%                 %                     hold on;
%                 %                     drawnow;
%             end
            
            %             if (t == T) && (kval > 0)
            %                 Theta_old = Theta_new;
            %                 Theta_new = Theta_new - alpha/(T-kval+1)*Theta_grad;
            %                 Theta_grad = zeros(size(Theta_old));
            %                 Cost = (reward + gamma*Qmax - Qval)^2;
            %             end
            
            
            %Draw next state
            %             subplot(2,1,2)
            %             disp(z);
             draw_world(Position, height, time);
            
            firstAction = false;
        end
%         if mod(t,10) ~= 0
%             disp(mod(t,10));
%             Theta_old = Theta_new;
%             Theta_new = Theta_new - alpha/mod(t,10)*Theta_grad;
%             Theta_grad = zeros(size(Theta_old));
%             Cost = (reward + gamma*Qmax - Qval)^2;
%         end
        
    end
    
end
