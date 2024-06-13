function frevede_allbyall_correlations_new(datamat, varlabels)

% to test
% varlabels = {'var1','var2','var3','var4','var5'};
% % datamat = rand(25, 5); 
% datamat(:,1) = linspace(0,1,25)' + rand(25, 1);
% datamat(:,2) = linspace(0,1,25)' + rand(25, 1);
% datamat(:,3) = linspace(0,1,25)' + rand(25, 1);
% datamat(:,4) = linspace(0,1,25)' + rand(25, 1);
% datamat(:,5) = linspace(0,1,25)' + rand(25, 1);
% load C:\Users\fee250\surfdrive\VU_ANALYSIS\general_functions\data+labels.mat
% varlabels = labels;

% do once for real values (pearson), and once for rank-ordered values (i.e. spearman)
for rankinstead = 0:1;

% if rank-correlation instead
if rankinstead
    [~,X]       = sort(datamat);
    [~,datamat] = sort(X);
end

% set sizes
npp = size(datamat,1);
nvar = size(datamat,2);
rmatrix = zeros(nvar);

% draw fig
figure;
count = 0;
for yvar = 1:nvar-1 
for xvar = 2:nvar
count = count+1;
if xvar > yvar % only plot off diagonal
    subplot(nvar-1, nvar-1, count); hold on; axis square;
    scatter(datamat(:,xvar), datamat(:,yvar), 'k'); lsline; 
    xlabel(varlabels{xvar}); ylabel(varlabels{yvar}); 
    [r,p] = corr(datamat(:,xvar), datamat(:,yvar)); title(['r = ' num2str(round(r*100)/100), ', p = ', num2str(round(p*100)/100)]);
    rmatrix(xvar,yvar) = r; % also save r values for below summary plot.
    if p < 0.1 scatter(datamat(:,xvar), datamat(:,yvar), 'c'); end % highlight in cyan if one-sided significant (uncorrected)
    if p < 0.05 scatter(datamat(:,xvar), datamat(:,yvar), 'm'); end  % highlight in magenta if two-sided significant (uncorrected)    
    plot(xlim, [0,0], ':k');  plot([0,0], ylim, ':k'); 
    if rankinstead
        sgtitle('Spearman');
    else
        sgtitle('Pearson');
    end
end
end
end

% also draw summary plot with just r values.
figure; imagesc(rmatrix', [-.5 .5]); xticks(1:nvar); yticks(1:nvar); xticklabels(varlabels);  yticklabels(varlabels); colormap('jet');

end