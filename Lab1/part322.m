
%X
patterns=[1,-1,-1,-1,-1,-1,-1,-1;...
    -1,1,-1,-1,-1,-1,-1,-1;...
    -1,-1,1,-1,-1,-1,-1,-1;...
    -1,-1,-1,1,-1,-1,-1,-1;...
    -1,-1,-1,-1,1,-1,-1,-1;...
    -1,-1,-1,-1,-1,1,-1,-1;...
    -1,-1,-1,-1,-1,-1,1,-1;...
    -1,-1,-1,-1,-1,-1,-1,1];
%T
targets=patterns;

w=randn(3,9);
v=randn(8,4);
dw=0;
dv=0;

ndata=8;
epochs = 100;
eta=0.001;
Nhidden=3;
alpha = 0.9;

%training, works well
for i=1:epochs
    %forward pass
    hin = w * [patterns ; ones(1,ndata)];
    hout = [2 ./ (1+exp(-hin)) - 1 ; ones(1,ndata)];
    oin = v * hout;
    out = 2 ./ (1+exp(-oin)) - 1;

    %backward pass
    delta_o = (out - targets) .* ((1 + out) .* (1 - out)) * 0.5;
    delta_h = (v'* delta_o) .* ((1 + hout) .* (1 - hout)) * 0.5;
    delta_h = delta_h(1:Nhidden, :);

    %backpropagation
    dw = (dw .* alpha) - (delta_h * [patterns ; ones(1,ndata)]') .* (1-alpha);
    dv = (dv .* alpha) - (delta_o * hout') .* (1-alpha);
    w = w + dw .* eta;
    v = v + dv .* eta;
end


%testing or whatever
hin = w * [patterns ; ones(1,ndata)];
hout = [2 ./ (1+exp(-hin)) - 1 ; ones(1,ndata)];
oin = v * hout;
out = 2 ./ (1+exp(-oin)) - 1;
%should use acivator or something??


