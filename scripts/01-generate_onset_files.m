%% 从 _events.tsv 生成每个 run 每个条件的 onset 文件
clear; clc;
root = 'C:\Users\Akira\Documents\MATLAB\spm\Visual_Object\ds000105_R2.0.2_raw\ds000105_R2.0.2';
subjects = {'sub-1','sub-2','sub-3','sub-4','sub-6'};
cond_names = {'face','house'};
nRuns = 12;

for s = 1:length(subjects)
    subj = subjects{s};
    func_dir = fullfile(root, subj, 'func');
    for run = 1:nRuns
        tsv_file = fullfile(func_dir, sprintf('%s_task-objectviewing_run-%02d_events.tsv', subj, run));
        if ~exist(tsv_file, 'file')
            warning('文件不存在：%s', tsv_file);
            continue;
        end
        data = readtable(tsv_file, 'FileType', 'text', 'Delimiter', '\t');
        for c = 1:length(cond_names)
            cond = cond_names{c};
            idx = strcmp(data.trial_type, cond);
            onsets = data.onset(idx);
            outfile = fullfile(func_dir, sprintf('%s_run%02d.txt', cond, run));
            dlmwrite(outfile, onsets, 'delimiter', '\n', 'precision', '%.3f');
        end
    end
    fprintf('完成 %s\n', subj);
end