
%% 3.1.2

%training data
n = 100;
mA = [ 1.8, 0.8]; sigmaA = 0.5;
mB = [-1.8, -0.8]; sigmaB = 0.5;
classA(1,:) = randn(1,n) .* sigmaA + mA(1);
classA(2,:) = randn(1,n) .* sigmaA + mA(2);
classA(3,:)=ones(1,n);
classB(1,:) = randn(1,n) .* sigmaB + mB(1);
classB(2,:) = randn(1,n) .* sigmaB + mB(2);
classB(3,:)=-ones(1,n);

tmp = [classA,classB];
patterns=tmp(:,randperm(2*n));
w=randn(1,3);
targets=(patterns(3,:));
patterns=[patterns(1:2,:);ones(1,2*n)];

%test data
tclassA(1,:) = randn(1,n) .* sigmaA + mA(1);
tclassA(2,:) = randn(1,n) .* sigmaA + mA(2);
tclassA(3,:)=ones(1,n);
tclassB(1,:) = randn(1,n) .* sigmaB + mB(1);
tclassB(2,:) = randn(1,n) .* sigmaB + mB(2);
tclassB(3,:)=-ones(1,n);

tmp = [tclassA,tclassB];
tpatterns=tmp(:,randperm(2*n));
ttargets=(tpatterns(3,:));
tpatterns=[tpatterns(1:2,:);ones(1,2*n)];


%% perceptron (3.1.2.1)

eta=0.003;
epoch=100;

e1=[];

for j=1:epoch
    for i=1:n*2

        y=sign(w*patterns(:,i));
        e=targets(i)-y;
    
        deltaw=eta*e*patterns(:,i)';
        w=w+deltaw;

    end
    
    y=sign(w*patterns);
    e=targets-y;
    e1=[e1,sum(e.^2)];
    
end


%test
typerc=sign(w*tpatterns);
correctperc = sum(typerc==ttargets);

figure(1)
plot(classA(1,:),classA(2,:),'r.')
hold on

plot(classB(1,:),classB(2,:),'b.')

w1= ([w(1),w(2)]./norm(w))*(-w(3))/norm(w);
w2=[w1(2),-w1(1)]+w1;


xlim([-3 3])
ylim([-3 3])

m = (w2(2)-w2(1))/(w1(2)-w1(1));
n1 = w2(2)*m - w1(2);
y1 = m*-3 + n1;
y2 = m*3 + n1;
line([-3,3],[y1 y2])
title('Boundary for perceptron')
hold off



%% delta bacth mode (3.1.2.1)

epochs = 100;
eta=0.001;
w=randn(1,3);

e2=[];

for i=0:epochs

    e=w*patterns-targets;
    
    deltaw=eta*e*patterns';
    w=w-deltaw;
    
    
    e2=[e2,sum(e.^2)/200];
    
end


%test
tydelta=sign(w*tpatterns);
correctdelta = sum(tydelta==ttargets);

figure(2)
plot(classA(1,:),classA(2,:),'r.')
hold on

plot(classB(1,:),classB(2,:),'b.')
w1= ([w(1),w(2)]./norm(w))*(-w(3))/norm(w);
w2=[w1(2),-w1(1)]+w1;

xlim([-3 3])
ylim([-3 3])

m = (w2(2)-w2(1))/(w1(2)-w1(1));
n1 = w2(2)*m - w1(2);
y1 = m*-3 + n1;
y2 = m*3 + n1;
title('Boundary for delta batch mode')
line([-3,3],[y1 y2])
hold off


%% delta sequential (3.1.2.2)

w=randn(1,3);

e3=[];

for i=0:epochs

    for j=1:n*2
        e=w*patterns(:,j)-targets(:,j);

        deltaw=eta*e*patterns(:,j)';
        w=w-deltaw;
    end
    
    e=w*patterns-targets;
    e3=[e3,sum(e.^2)/200];
    
end

%test
tydelta=sign(w*tpatterns);
correctdelta = sum(tydelta==ttargets);

figure(3)
plot(classA(1,:),classA(2,:),'r.')
hold on

plot(classB(1,:),classB(2,:),'b.')
w1= ([w(1),w(2)]./norm(w))*(-w(3))/norm(w);
w2=[w1(2),-w1(1)]+w1;

xlim([-3 3])
ylim([-3 3])

m = (w2(2)-w2(1))/(w1(2)-w1(1));
n1 = w2(2)*m - w1(2);
y1 = m*-3 + n1;
y2 = m*3 + n1;
title('Boundary for delta sequential mode')
line([-3,3],[y1 y2])
hold off

%% Ploting mean square error (3.1.2.1 & 3.1.2.2)


figure(4)
plot(e1)
hold on
plot(e2)

%comment e3 for 3.1.2.1
plot(e3)
legend('Perceptron','Delta batch','Delta sequential')
title('Mean square error at each batch')



%% 3.1.2.3


%training data
n = 100;
mA = [ 1.8, -0.8]; sigmaA = 0.5;
mB = [-1, 0.5]; sigmaB = 0.5;
classA(1,:) = randn(1,n) .* sigmaA + mA(1);
classA(2,:) = randn(1,n) .* sigmaA + mA(2);
classA(3,:)=ones(1,n);
classB(1,:) = randn(1,n) .* sigmaB + mB(1);
classB(2,:) = randn(1,n) .* sigmaB + mB(2);
classB(3,:)=-ones(1,n);

tmp = [classA,classB];
patterns=tmp(:,randperm(2*n));
targets=(patterns(2,:));
patterns=[patterns(1:2,:)];

epochs = 100;
eta=0.001;
w=randn(1,2);

e2=[];

for i=0:epochs

    e=w*patterns-targets;
    
    deltaw=eta*e*patterns';
    w=w-deltaw;
    
    
    e2=[e2,sum(e.^2)/200];
    
end

%test
tydelta=sign(w*tpatterns(1:2,:));
correctdelta = sum(tydelta==ttargets);

close all
figure(5)
plot(classA(1,:),classA(2,:),'r.')
hold on

plot(classB(1,:),classB(2,:),'b.')
w1=[-w(2), w(1)];
w2=-w1;

xlim([-3 3])
ylim([-3 3])

title('Boundary for delta batch mode without bias')
plot([0,w(1)],[0,w(2)])
plot([w1(1),w2(1)],[w1(2),w2(2)])

hold off

