clear;
close all;
clc;

pkg load signal;
script_path = mfilename('fullpath');
project_folder = fileparts(script_path);

% Altındaki functions klasörünü Octave yoluna ekle
functions_folder = fullfile(project_folder, 'functions');
addpath(functions_folder);

% Fonksiyon listesini yenile
rehash;

N = 100000;
fs = 1e6;

t = (0:N-1)' / fs;

A = 1;
f0 = 10e3;

%% Phase-noise RMS değerleri

phase_rms_dut  = 0.05;
phase_rms_ref1 = 0.02;
phase_rms_ref2 = 0.02;



%% Birbirinden bağımsız faz gürültüleri
phase_noise_dut = generate_phase_noise(N, phase_rms_dut);

phase_noise_ref1 = generate_phase_noise(N, phase_rms_ref1);
phase_noise_ref2 = generate_phase_noise(N, phase_rms_ref2);



%% Sinyaller

x_clean = A*cos(2*pi*f0*t);
x_dut = A*cos(2*pi*f0*t + phase_noise_dut);

% Referanslar nominal olarak DUT'a göre 90 derece kayık
x_ref1 = A*cos(2*pi*f0*t + pi/2 + phase_noise_ref1);
x_ref2 = A*cos(2*pi*f0*t + pi/2 + phase_noise_ref2);


%% RMS kontrolü

fprintf('DUT phase RMS  = %.5f rad\n', std(phase_noise_dut));

fprintf('Ref-1 phase RMS = %.5f rad\n', std(phase_noise_ref1));

fprintf('Ref-2 phase RMS = %.5f rad\n', std(phase_noise_ref2));

%% Kaynakları görüntüle

number_of_cycles = 5;
number_of_samples = round(number_of_cycles * fs/f0);

index = 1:number_of_samples;

figure;

subplot(2,1,1);
plot(t(index)*1e3, x_clean(index), 'k--', 'LineWidth', 1.5);
hold on;

plot(t(index)*1e3, x_dut(index), 'b', 'LineWidth', 1);
grid on;

xlabel('Zaman [ms]');
ylabel('Genlik');
title('Temiz sinyal ve DUT');
legend('Temiz sinyal', 'DUT');

%%%

subplot(2,1,2);
plot(t(index)*1e3, x_dut(index), 'b', 'LineWidth', 1);
hold on;

plot(t(index)*1e3, x_ref1(index), 'r', 'LineWidth', 1);
grid on;

xlabel('Zaman [ms]');
ylabel('Genlik');
title('DUT ve 90° kaydırılmış Ref-1');
legend('DUT', 'Ref-1');
