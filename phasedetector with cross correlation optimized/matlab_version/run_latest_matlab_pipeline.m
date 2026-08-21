function run_latest_matlab_pipeline()
% Güncel repo profilini MATLAB R2025b altında sırasıyla çalıştırır.
% 1) run_comparisons
% 2) N=1.000.000 kullanan run_iterations

project_dir = fileparts(mfilename("fullpath"));
addpath(project_dir);

log_path = fullfile(project_dir, "run_latest_pipeline.log");
if exist(log_path, "file")
    delete(log_path);
end
diary(log_path);
cleanup_diary = onCleanup(@() diary("off"));

fprintf("LATEST_PIPELINE_START: %s\n", char(datetime("now")));
fprintf("SOURCE_COMMIT: 0799f9f\n");
fprintf("MATLAB_VERSION: %s\n", version);

fprintf("\n=== RUN_COMPARISONS START ===\n");
run(fullfile(project_dir, "run_comparisons.m"));
fprintf("=== RUN_COMPARISONS COMPLETE ===\n");

fprintf("\n=== RUN_ITERATIONS START | N=1000000 ===\n");
run(fullfile(project_dir, "run_iterations.m"));
fprintf("=== RUN_ITERATIONS COMPLETE ===\n");

marker_path = fullfile(project_dir, "LATEST_PIPELINE_COMPLETE.txt");
marker_id = fopen(marker_path, "w");
if marker_id < 0
    error("Tamamlanma işaretçisi yazılamadı: %s", marker_path);
end
fprintf(marker_id, "Güncel MATLAB R2025b pipeline tamamlandı.\n");
fprintf(marker_id, "Kaynak commit: 0799f9f\n");
fprintf(marker_id, "N: 1000000\n");
fprintf(marker_id, "Tamamlanma: %s\n", char(datetime("now")));
fclose(marker_id);

fprintf("LATEST_PIPELINE_COMPLETE: %s\n", char(datetime("now")));

end
