function [amplitude, center_x, center_y, std, fwhm, fwhm_upper, fwhm_lower, fwhm_central5, fwhm_central10, fwhm_contra, fwhm_ipsi, fwhm_upperContra, fwhm_lowerContra, fwhm_upperIpsi, fwhm_lowerIpsi] = toon_fitCircularGauss(data, hemi, fieldRange)
    % Define circular Gaussian function with parameters [amplitude, center_x, center_y, std]
    circular_gaussian = @(params, coordinates) params(1) * exp(-((coordinates(:,:,1)-params(2)).^2 + (coordinates(:,:,2)-params(3)).^2) / (2*params(4)^2));

    % Initial guesses for the parameters [amplitude, center_x, center_y, std]
    initial_amplitude_guess = 0.5;  
    initial_center_x_guess = size(data, 2) / 2;  
    initial_center_y_guess = size(data, 1) / 2;  
    initial_std_guess = size(data, 1) / 4;   

    initial_guess = [initial_amplitude_guess, initial_center_x_guess, initial_center_y_guess, initial_std_guess];

    % Create a grid of x and y coordinates
    [X, Y] = meshgrid(1:size(data, 2), 1:size(data, 1));

    % Fit the circular Gaussian by optimizing parameters
    fit_params = lsqcurvefit(circular_gaussian, initial_guess, cat(3, X, Y), data);

    % Extract fitted parameters
    amplitude = fit_params(1);
    center_x = fit_params(2);
    center_y = fit_params(3);
    std = fit_params(4);

    % Calculate the FWHM for the circular Gaussian
    fwhm = 2 * sqrt(2 * log(2)) * std;

    % --------------------------
    % Apply scaling to the centers and FWHM to reflect visual field coordinates
    scaled_center_x = ((center_x - 1) / (128 - 1)) * (fieldRange - (-fieldRange)) + (-fieldRange);
    scaled_center_y = ((center_y - 1) / (128 - 1)) * (fieldRange - (-fieldRange)) + (-fieldRange);
    scaled_fwhm = fwhm * (fieldRange / 128);

    % Scale the X and Y grids from pixel space to visual field space
    scaled_X = ((X - 1) / (128 - 1)) * (fieldRange - (-fieldRange)) + (-fieldRange);
    scaled_Y = ((Y - 1) / (128 - 1)) * (fieldRange - (-fieldRange)) + (-fieldRange);

    % 1. Eccentricity: Distance from the center of the visual field (0, 0)
    eccentricity = sqrt(scaled_X.^2 + scaled_Y.^2);

    % 2. Distance from the center of the FWHM (scaled_center_x, scaled_center_y)
    distance_from_fwhm_center = sqrt((scaled_X - scaled_center_x).^2 + (scaled_Y - scaled_center_y).^2);

    % --------------------------
    % Calculate metrics based on the voxels within the FWHM
    fwhm_radius = scaled_fwhm / 2;  % FWHM is the full width, use half for the radius

    % Find voxels within the FWHM radius (based on distance from FWHM center)
    within_fwhm_mask = distance_from_fwhm_center <= fwhm_radius;

    % Find valid (non-NaN) voxels in data that are also within the FWHM
    valid_voxels_fwhm = data > 0 & within_fwhm_mask;

    % Total number of valid voxels within FWHM
    total_fwhm_voxels = sum(valid_voxels_fwhm(:));

    % --------------------------
    % Calculate the metrics based on valid voxels

    if total_fwhm_voxels > 0
        % 1. Calculate % of valid voxels in the central 5 degrees (eccentricity <= 5)
        central_mask5 = eccentricity <= 5;
        fwhm_central5 = sum(valid_voxels_fwhm(central_mask5)) / total_fwhm_voxels * 100;

        % 2. Calculate % of valid voxels in the central 10 degrees (eccentricity <= 10)
        central10_mask = eccentricity <= 10;
        fwhm_central10 = sum(valid_voxels_fwhm(central10_mask)) / total_fwhm_voxels * 100;

        % 3. Calculate % of valid voxels in the upper visual field
        upper_mask = scaled_Y > 0;
        fwhm_upper = sum(valid_voxels_fwhm(upper_mask)) / total_fwhm_voxels * 100;

        % 4. Calculate % of valid voxels in the lower visual field
        lower_mask = scaled_Y < 0;
        fwhm_lower = sum(valid_voxels_fwhm(lower_mask)) / total_fwhm_voxels * 100;

        % 5. Calculate % of valid voxels in the contralateral visual field
        if strcmp(hemi, 'lh')
            contralateral_mask = scaled_X > 0;  % Right visual field for LH
        else
            contralateral_mask = scaled_X < 0;  % Left visual field for RH
        end
        fwhm_contra = sum(valid_voxels_fwhm(contralateral_mask)) / total_fwhm_voxels * 100;

        % 6. Calculate % of valid voxels in the ipsilateral visual field
        if strcmp(hemi, 'lh')
            ipsilateral_mask = scaled_X < 0;  % Left visual field for LH
        else
            ipsilateral_mask = scaled_X > 0;  % Right visual field for RH
        end
        fwhm_ipsi = sum(valid_voxels_fwhm(ipsilateral_mask & contralateral_mask)) / total_fwhm_voxels * 100;
        
        % 7. Calculate % of valid voxels in the upper contralateral
        % quadrant
        fwhm_upperContra = sum(valid_voxels_fwhm(upper_mask & contralateral_mask)) / total_fwhm_voxels * 100;

        % 8. Calculate the % of valid voxels in the lower contralateral
        % quadrant
        fwhm_lowerContra = sum(valid_voxels_fwhm(lower_mask & contralateral_mask)) / total_fwhm_voxels * 100;

        % 9. Calculate the % of valid voxels in the upper ipsilateral
        % quadrant
        fwhm_upperIpsi = sum(valid_voxels_fwhm(upper_mask & ipsilateral_mask)) / total_fwhm_voxels * 100;

        % 10. Calculate the % of valid voxels in the lower ipsilateral
        % quadrant
        fwhm_lowerIpsi = sum(valid_voxels_fwhm(lower_mask & ipsilateral_mask)) / total_fwhm_voxels * 100;

    else
        % If no valid voxels within FWHM, return NaN for the FWHM-based metrics
        fwhm_upper = NaN;
        fwhm_lower = NaN;
        fwhm_contra = NaN;
        fwhm_ipsi = NaN;
        fwhm_central5 = NaN;
        fwhm_central10 = NaN;
        fwhm_upperContra = NaN;
        fwhm_lowerContra = NaN;
        fwhm_upperIpsi = NaN;
        fwhm_lowerIpsi = NaN;

    end
end