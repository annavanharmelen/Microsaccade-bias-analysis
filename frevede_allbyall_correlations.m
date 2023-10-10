function frevede_allbyall_correlations(datamat, varlabels, split_colours)

% to test
% datamat = rand(25, 5); varlabels = {'var1','var2','var3','var4','var5'};

% set sizes
npp = size(datamat,1);
nvar = size(datamat,2);
rmatrix = zeros(nvar);

% set colourlist
if split_colours
    sc = zeros(length(datamat),3);
    sc(1:16,1) = 1;
    sc(17:41,3) = 1;
else
    sc = 'k';
end

% draw fig
figure;
count = 0;
for yvar = 1:nvar-1 
for xvar = 2:nvar
count = count+1;
if xvar > yvar % only plot off diagonal
    subplot(nvar-1, nvar-1, count); hold on; axis square;
    scatter(datamat(:,xvar), datamat(:,yvar), [], sc); lsline; 
    xlabel(varlabels{xvar}, 'Interpreter', 'none'); ylabel(varlabels{yvar}, 'Interpreter', 'none'); 
    [r,p] = corr(datamat(:,xvar), datamat(:,yvar));
    t = title(['r = ' num2str(round(r*100)/100), ', p = ', num2str(round(p*100)/100)]);
    rmatrix(xvar,yvar) = r; % also save r values for below summary plot.
    if split_colours
        if p < 0.1 t.Color = 'c'; end % highlight in cyan if one-sided significant (uncorrected)
        if p < 0.05 t.Color = 'm'; end % highlight in magenta if two-sided significant (uncorrected)    
    else
        if p < 0.1 scatter(datamat(:,xvar), datamat(:,yvar), 'c'); end % highlight in cyan if one-sided significant (uncorrected)
        if p < 0.05 scatter(datamat(:,xvar), datamat(:,yvar), 'm'); end  % highlight in magenta if two-sided significant (uncorrected)    
    end
    plot(xlim, [0,0], ':k');  plot([0,0], ylim, ':k'); 
end
end
end

% also draw summary plot with just r values.
figure; imagesc(rmatrix', [-.5 .5]); xticks(1:nvar); yticks(1:nvar); xticklabels(varlabels);  yticklabels(varlabels); colormap('jet');
