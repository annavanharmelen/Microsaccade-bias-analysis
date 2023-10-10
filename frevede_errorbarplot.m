function [m_plot] = frevede_errorbarplot(xax, values, rgb, shading) 

    % Input arguments 
    % xax: time axis, 
    % values: 2D data (subjects x time), 
    % rgb: color as RGB values
    % shading: for only se 'se', for only ci 'ci', for se & ci 'both'

    % get mean and SE
    m = squeeze(nanmean(values)); % MEAN
    se = squeeze(nanstd(values)) ./ sqrt(size(values,1)); % SE = std / sqrt(n)
    
    % also get 95% CI
    [~,~,ci,~] = ttest(values);
    
    % flip vectors if columns instead of rows
    if size(xax,1) > size(xax,2) 
        xax = xax'; 
    end
    
    if size(m,1) > size(m,2) 
        m = m'; 
    end
    
    if size(se,1) > size(se,2) 
        se = se'; 
    end
    
    % plot mean 
    m_plot = plot(xax, m, 'color', rgb); hold on
    
    % plot SE using 'patch'
    if ismember(shading, 'se') | ismember(shading, 'both') % If you want only se's or both
        patch([xax, fliplr(xax)],[m-se, fliplr(m+se)], rgb, 'edgecolor', 'none', 'FaceAlpha', .3);   % +/- 1 SEM
    end    
    
    if ismember(shading, 'ci') | ismember(shading, 'both') % If you want only CI's or both
        patch([xax, fliplr(xax)],[ci(1,:), fliplr(ci(2,:))], rgb, 'edgecolor', 'none', 'FaceAlpha', .1); % +/- 95% CI
    end
    
end

% figure;
% [m_plot1] = frevede_errorbarplot(load1v2v4_all.time, load1v2v4_all.load2_load1_beta_C3, [0, 1, 1], 'both');
% [m_plot2] = frevede_errorbarplot(load1v2v4_all.time, load1v2v4_all.load4_load2_beta_C3, [0.5, 0.5, 0.5], 'both');
% [m_plot3] = frevede_errorbarplot(load1v2v4_all.time, load1v2v4_all.load4_load1_beta_C3, [1, 0, 1], 'both');
% 
% legend([m_plot1, m_plot2, m_plot3] , titles_loadcomp, 'AutoUpdate', 'off') % Auto-update off so it does not add anything else