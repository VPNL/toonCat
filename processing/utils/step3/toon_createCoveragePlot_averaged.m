% function figHandle = toon_createCoveragePlot_averaged(RFcov, fits, name,hemi, fieldRange, norm, n)
% 
%     % plotting subroutine for rmPlotCoverage. Broken off by ras 10/2009.
%     % And edited for scripting by JG 05/2016
%     % edited for FWHM and center by JKY 09/2023
%     % All you have to do is feed it a 128x128 coverage
% 
% 
%     % % % Load dummy filler data for kids study:
%     % fileDir = '/sni-storage/kalanit/biac2/kgs/projects/Longitudinal/FMRI/Retinotopy/results/pRF_figures/Coverage/plottingVariables';
%     % load(fullfile(fileDir,'dummyVariables.mat'));
%     vfc.cmap = 'jet';
%     vfc.fieldRange = fieldRange;
%     data.X = repmat(linspace(-fieldRange, fieldRange, 128), 128, 1);
%     data.Y = repmat(linspace(-fieldRange, fieldRange, 128), 128, 1)';
%     figHandle = gcf;
% 
%     % normalize the color plots to 1
%     if norm == 1
%         rfMax = max(RFcov(:));
%     else
%         rfMax = 1;
%     end
% 
%     img = RFcov ./ rfMax;
% 
%     mask = makecircle(length(img));
%     img = img .* mask;
%     imagesc(data.X(1, :), data.Y(:, 1), img);
%     set(gca, 'YDir', 'normal');
%     grid on
% 
%     colormap(vfc.cmap);
%     colorbar;
% 
%     % start plotting
%     hold on;
% 
%     % add polar grid on top
%     % p.ringTicks = (1:3) / 3 * vfc.fieldRange;
%     p.ringTicks = [0 5 10 20];
%     p.color = [0.6, 0.6, 0.6];
%     polarPlot([], p);
% 
% 
%     % Existing polar plot code
%     polarPlot([], p);
% 
%     % Find all polar axes in the current figure (assuming there's just one set of polar axes)
%     polarAxes = findall(gcf, 'Type', 'polaraxes');
% 
%     % Check if any polar axes were found and then remove the tick labels
% 
%         set(polarAxes, 'ThetaTickLabel', []); % Removes the radial (angle) tick labels
%         set(polarAxes, 'RTickLabel', []);     % Removes the radial distance tick labels
% 
% 
%     % Increase the fontsize of tick numbers
%     %set(findall(gcf, 'Type', 'text'), 'FontSize', 16); % Adjust the FontSize value as needed
% 
%     % scale z-axis
%     caxis([0,1]);
% 
%     axis image;
%     xlim([-vfc.fieldRange, vfc.fieldRange])
%     ylim([-vfc.fieldRange, vfc.fieldRange])
% 
% 
%     % Fit a circular 2D gaussian to the data and calculate the fwhm
%     [~, center_x, center_y, ~, fwhm] = toon_fitCircularGauss(img,hemi, fieldRange);
% 
%     % Scale the center coordinates and FWHM to fit within the field range
%     scaled_center_x = ((center_x - 1) / (128 - 1)) * (vfc.fieldRange - (-vfc.fieldRange)) + (-vfc.fieldRange);
%     scaled_center_y = ((center_y - 1) / (128 - 1)) * (vfc.fieldRange - (-vfc.fieldRange)) + (-vfc.fieldRange);
%     scaled_center = [scaled_center_x, scaled_center_y];
%     scaled_fwhm = fwhm * (vfc.fieldRange - (-vfc.fieldRange)) / 128;
% 
%     % Get CoM from dataframe
%     CoM_x = nanmean(fits.CoM_x);
%     CoM_y = nanmean(fits.CoM_y);
% 
%     % Plot the FWHM as dotted circle
%     theta = linspace(0, 2 * pi, 100);
%     xCircle = scaled_center_x + scaled_fwhm/2 * cos(theta);
%     yCircle = scaled_center_y + scaled_fwhm/2 * sin(theta);
%     plot(xCircle, yCircle, 'k--', 'LineWidth', 3);
% 
%     % Plot the center as a white asterisk
%     xline(0, 'Color', 'w', 'LineWidth', 6); % Draw line for Y axis.
%     yline(0, 'Color', 'w', 'LineWidth', 6); % Draw line for X axis.
% 
%     plot(CoM_x, CoM_y, 'w*', 'MarkerSize', 40, 'LineWidth',3);
%     % plot(center_x, center_y, 'w*', 'MarkerSize', 40, 'LineWidth',2);
% 
%     % Plot center coordinates (scaled)
%     text(scaled_center_x, scaled_center_y + scaled_fwhm/5, sprintf('(%0.1f, %0.1f)',scaled_center_x, scaled_center_y),...
%         'Color', 'k', 'VerticalAlignment','bottom', 'HorizontalAlignment','center', 'FontSize', 35);
%     % text(center_x, center_y + 1, sprintf('(%0.1f, %0.1f)', center_x, center_y),...
%     %     'Color', 'k', 'VerticalAlignment','bottom', 'HorizontalAlignment','center', 'FontSize', 35);
% 
%     %title([name, sprintf('\n'), 'N = ', n], 'FontSize', 18, 'Interpreter', 'none');
%     % Set the title without N = 
%     %title(name, 'FontSize', 18, 'Interpreter', 'none')
% 
%     % Add the N = text in the lower left corner of the plot
%     %text(-vfc.fieldRange, -vfc.fieldRange, ['N = ', num2str(n)], 'Color', 'white', 'FontSize', 40, 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'left');
% 
% 
% 
%     return;
% end

function figHandle = toon_createCoveragePlot_averaged(RFcov, fits, name, hemi, fieldRange, norm, n)
    % Plotting subroutine for rmPlotCoverage. 
    % Edited for FWHM and center by JKY 09/2023
    % All you have to do is feed it a 128x128 coverage map
    
    % Set up the visual field coordinates
    vfc.cmap = 'jet';
    vfc.fieldRange = fieldRange;
    data.X = repmat(linspace(-fieldRange, fieldRange, 128), 128, 1);
    data.Y = repmat(linspace(-fieldRange, fieldRange, 128), 128, 1)';
    figHandle = gcf;

    % Normalize the color plots if needed
    if norm == 1
        rfMax = max(RFcov(:));
    else
        rfMax = 1;
    end

    img = RFcov ./ rfMax;

    % Apply a circular mask to the image
    mask = makecircle(length(img));
    img = img .* mask;

    % Plot the coverage map
    imagesc(data.X(1, :), data.Y(:, 1), img);
    set(gca, 'YDir', 'normal');
    grid on

    colormap(vfc.cmap);
    colorbar;

    hold on;

    % Add polar grid on top with visual degrees labels
    p.ringTicks = [0 5 10 20];
    p.color = [0.6, 0.6, 0.6];
    polarPlot([], p);

    % Remove the tick labels from the polar plot axes
    polarAxes = findall(gcf, 'Type', 'polaraxes');
    if ~isempty(polarAxes)
        set(polarAxes, 'ThetaTickLabel', []); % Removes angle tick labels
        set(polarAxes, 'RTickLabel', []);     % Removes radial distance tick labels
    end

    % Scale the z-axis
    caxis([0,1]);

    axis image;
    xlim([-vfc.fieldRange, vfc.fieldRange]);
    ylim([-vfc.fieldRange, vfc.fieldRange]);

    % Fit a circular 2D Gaussian to the data and calculate the FWHM
    [~, center_x, center_y, ~, fwhm] = toon_fitCircularGauss(img, hemi, fieldRange);

    % Scale the center coordinates and FWHM to fit within the visual field range
    scaled_center_x = ((center_x - 1) / (128 - 1)) * (vfc.fieldRange - (-vfc.fieldRange)) + (-vfc.fieldRange);
    scaled_center_y = ((center_y - 1) / (128 - 1)) * (vfc.fieldRange - (-vfc.fieldRange)) + (-vfc.fieldRange);
    scaled_fwhm = fwhm * (vfc.fieldRange - (-vfc.fieldRange)) / 128;

    % Get center of mass from fits (these should be in visual degrees)
    CoM_x = nanmean(fits.CoM_x);
    CoM_y = nanmean(fits.CoM_y);

    % Plot the FWHM as a dotted circle
    theta = linspace(0, 2 * pi, 100);
    xCircle = scaled_center_x + scaled_fwhm/2 * cos(theta);
    yCircle = scaled_center_y + scaled_fwhm/2 * sin(theta);
    plot(xCircle, yCircle, 'k--', 'LineWidth', 3);

    % Plot the center as a white asterisk
    plot(CoM_x, CoM_y, 'w*', 'MarkerSize', 40, 'LineWidth', 3);

    % Plot the center coordinates (scaled) as text in visual degrees
    text(scaled_center_x, scaled_center_y + scaled_fwhm/5, sprintf('(%0.1f, %0.1f)', CoM_x, CoM_y),...
        'Color', 'k', 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'center', 'FontSize', 35);

    % Draw lines for the X and Y axes in white
    xline(0, 'Color', 'w', 'LineWidth', 6); % Y axis
    yline(0, 'Color', 'w', 'LineWidth', 6); % X axis

    return;
end
