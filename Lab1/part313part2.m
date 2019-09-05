%training data

ndata = 100;
mA = [ 1.0, 0.3]; sigmaA = 0.2;
mB = [ 0.0, -0.1]; sigmaB = 0.3;
classA(1,:) = [ randn(1,round(0.5*ndata)) .* sigmaA - mA(1), ...
randn(1,round(0.5*ndata)) .* sigmaA + mA(1)];
classA(2,:) = randn(1,ndata) .* sigmaA + mA(2);
classA(3,:)=ones(1,ndata);
classB(1,:) = randn(1,ndata) .* sigmaB + mB(1);
classB(2,:) = randn(1,ndata) .* sigmaB + mB(2);
classB(3,:)=-ones(1,ndata);

tmp = [classA,classB];
patterns=tmp(:,randperm(2*ndata));
w=randn(1,3);
targets=(patterns(3,:));
patterns=[patterns(1:2,:);ones(1,2*ndata)];


%test data
ndata = 100;
mA = [ 1.0, 0.3]; sigmaA = 0.2;
mB = [ 0.0, -0.1]; sigmaB = 0.3;
tclassA(1,:) = [ randn(1,round(0.5*ndata)) .* sigmaA - mA(1), ...
randn(1,round(0.5*ndata)) .* sigmaA + mA(1)];
tclassA(2,:) = randn(1,ndata) .* sigmaA + mA(2);
tclassA(3,:)=ones(1,ndata);
tclassB(1,:) = randn(1,ndata) .* sigmaB + mB(1);
tclassB(2,:) = randn(1,ndata) .* sigmaB + mB(2);
tclassB(3,:)=-ones(1,ndata);

tmp = [tclassA,tclassB];
tpatterns=tmp(:,randperm(2*ndata));
ttargets=(tpatterns(3,:));
tpatterns=[tpatterns(1:2,:);ones(1,2*ndata)];



%% delta bacth mode

epochs = 100;
eta=0.001;
w=randn(1,3);

e2=[];

for i=0:epochs

    e=w*patterns-targets;
    
    deltaw=eta*e*patterns';
    w=w-deltaw;
    
end

%test
tydelta=sign(w*tpatterns);
correctdelta1 = sum(tydelta==ttargets);

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


%% remove 25% from each class

removedA=randperm(100);
removedA=removedA(26:end);

removedB=randperm(100);
removedB=removedB(26:end);

tmp = [classA(:,removedB),classB(:,removedB)];
patterns=tmp(:,randperm(length(tmp)));
w=randn(1,3);
targets=(patterns(3,:));
patterns=[patterns(1:2,:);ones(1,length(tmp))];

epochs = 100;
eta=0.001;
w=randn(1,3);

e2=[];

for i=0:epochs

    e=w*patterns-targets;
    
    deltaw=eta*e*patterns';
    w=w-deltaw;
    
end

%test
tydelta=sign(w*tpatterns);
correctdelta25 = sum(tydelta==ttargets);

figure(3)
plot(classA(1,removedA),classA(2,removedA),'r.')
hold on

plot(classB(1,removedB),classB(2,removedB),'b.')
w1= ([w(1),w(2)]./norm(w))*(-w(3))/norm(w);
w2=[w1(2),-w1(1)]+w1;

xlim([-3 3])
ylim([-3 3])

m = (w2(2)-w2(1))/(w1(2)-w1(1));
n1 = w2(2)*m - w1(2);
y1 = m*-3 + n1;
y2 = m*3 + n1;
title('Boundary for 25% removed of both')
line([-3,3],[y1 y2])
hold off



%% remove 50% of class A

removedA=randperm(100);
removedA=removedA(51:end);

tmp = [classA(:,removedA),classB];
patterns=tmp(:,randperm(length(tmp)));
w=randn(1,3);
targets=(patterns(3,:));
patterns=[patterns(1:2,:);ones(1,length(tmp))];

epochs = 100;
eta=0.001;
w=randn(1,3);

e2=[];

for i=0:epochs

    e=w*patterns-targets;
    
    deltaw=eta*e*patterns';
    w=w-deltaw;
    
end

%test
tydelta=sign(w*tpatterns);
correctdelta50A = sum(tydelta==ttargets);

figure(4)
plot(classA(1,removedA),classA(2,removedA),'r.')
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
title('Boundary for 50% removed of A')
line([-3,3],[y1 y2])
hold off



%% remove 50% of class B


removedB=randperm(100);
removedB=removedB(51:end);

tmp = [classA,classB(:,removedB)];
patterns=tmp(:,randperm(length(tmp)));
w=randn(1,3);
targets=(patterns(3,:));
patterns=[patterns(1:2,:);ones(1,length(tmp))];

epochs = 100;
eta=0.001;
w=randn(1,3);

e2=[];

for i=0:epochs

    e=w*patterns-targets;
    
    deltaw=eta*e*patterns';
    w=w-deltaw;
    
end

%test
tydelta=sign(w*tpatterns);
correctdelta50B = sum(tydelta==ttargets);

figure(5)
plot(classA(1,:),classA(2,:),'r.')
hold on

plot(classB(1,removedB),classB(2,removedB),'b.')
w1= ([w(1),w(2)]./norm(w))*(-w(3))/norm(w);
w2=[w1(2),-w1(1)]+w1;

xlim([-3 3])
ylim([-3 3])

m = (w2(2)-w2(1))/(w1(2)-w1(1));
n1 = w2(2)*m - w1(2);
y1 = m*-3 + n1;
y2 = m*3 + n1;
title('Boundary for 50% removed of B')
line([-3,3],[y1 y2])
hold off



%% 20% from a subset of classA for which classA(1,:)<0 and 80% from a 
%subset of classA for which classA(1,:)>0

len = length(classA(:,classA(1,:)<0));
removedA1=randperm(len);
removedA1=removedA1(len-0.8*len+1:end);


len = length(classA(:,classA(1,:)>0));
removedA2=randperm(len);
removedA2=removedA2(len-0.2*len+1:end);

tmpA1 = classA(:,classA(1,:)<0);
tmpA2 = classA(:,classA(1,:)>0);
tmp = [tmpA1(:,removedA1),tmpA2(:,removedA2),classB];
patterns=tmp(:,randperm(length(tmp)));
w=randn(1,3);
targets=(patterns(3,:));
patterns=[patterns(1:2,:);ones(1,length(tmp))];

epochs = 100;
eta=0.001;
w=randn(1,3);

e2=[];

for i=0:epochs

    e=w*patterns-targets;
    
    deltaw=eta*e*patterns';
    w=w-deltaw;
    
end

%test
tydelta=sign(w*tpatterns);
correctdeltamixedA = sum(tydelta==ttargets);

figure(6)
plot([tmpA1(1,removedA1),tmpA2(1,removedA2)],[tmpA1(2,removedA1),tmpA2(2,removedA2)],'r.')


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
title('Boundary for 20% removed where classA_x<1 and 80% removed where classA_x>1')
line([-3,3],[y1 y2])
hold off




