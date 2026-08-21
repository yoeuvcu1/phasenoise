% Mevcut bir iteration sweep'ine yeni degerler ekler.
%
% Akis:
%   1. BASE_RESULTS_SUBFOLDER icindeki eski sonuclar okunur.
%   2. IMPORT_RESULTS_SUBFOLDERS icindeki tamamlanmis kosular ice aktarilir.
%   3. NEW_ITERATION_VALUES icinde hala eksik kalan degerler calistirilir.
%   4. Eski klasorler degistirilmeden yeni bir *_iterations_merged klasoru yazilir.

%% ---------------- MERGE SETTINGS ----------------
BASE_RESULTS_SUBFOLDER = "20260821_122201830_iterations";

% run_iterations ile ayri calistirilmis ek sonuc klasorleri. Bu klasorlerin
% summary.mat dosyasi olusmus, yani kosu tamamlanmis olmalidir.
IMPORT_RESULTS_SUBFOLDERS = {"20260821_145005070_iterations"};

% Ice aktarilan klasorlerde bulunmayan degerler burada verilirse yalnizca bu
% eksik degerler calistirilir. Ornek: [250, 500, 2500]
NEW_ITERATION_VALUES = [];

SHOW_FIGURES = true;

%% ---------------- EXTEND AND MERGE ----------------
project_dir = fileparts(mfilename("fullpath"));
addpath(project_dir);

merged_results_subfolder = extend_iteration_results_main( ...
    BASE_RESULTS_SUBFOLDER, IMPORT_RESULTS_SUBFOLDERS, ...
    NEW_ITERATION_VALUES, SHOW_FIGURES, project_dir);

fprintf("\nHazir. Birlesik sonuclar: %s\n", ...
    fullfile(project_dir, "results", merged_results_subfolder));
