%% 单个被试一阶模型
clear; clc;
root = 'C:\Users\Akira\Documents\MATLAB\spm\Visual_Object\ds000105_R2.0.2_raw\ds000105_R2.0.2';
subj = 'sub-4';   % 修改被试
func_dir = fullfile(root, subj, 'func');
output_dir = fullfile(root, subj, '1stLevel');
if ~exist(output_dir, 'dir'); mkdir(output_dir); end

TR = 2.5;
nRuns = 12;
cond_names = {'face','house'};
prefix = 'swar';

runs_scans = cell(nRuns,1);
for r = 1:nRuns
    fname = fullfile(func_dir, sprintf('%s%s_task-objectviewing_run-%02d_bold.nii', prefix, subj, r));
    runs_scans{r} = {fname};
end

onsets_all = cell(nRuns,2);
for r = 1:nRuns
    onsets_all{r,1} = load(fullfile(func_dir, sprintf('face_run%02d.txt', r)));
    onsets_all{r,2} = load(fullfile(func_dir, sprintf('house_run%02d.txt', r)));
end

spm('defaults','FMRI');
spm_jobman('initcfg');
clear matlabbatch

matlabbatch{1}.spm.stats.fmri_spec.dir = {output_dir};
matlabbatch{1}.spm.stats.fmri_spec.timing.units = 'secs';
matlabbatch{1}.spm.stats.fmri_spec.timing.RT = TR;
matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t = 16;
matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t0 = 1;
for r = 1:nRuns
    matlabbatch{1}.spm.stats.fmri_spec.sess(r).scans = runs_scans{r};
    matlabbatch{1}.spm.stats.fmri_spec.sess(r).cond(1).name = 'face';
    matlabbatch{1}.spm.stats.fmri_spec.sess(r).cond(1).onset = onsets_all{r,1};
    matlabbatch{1}.spm.stats.fmri_spec.sess(r).cond(1).duration = 0;
    matlabbatch{1}.spm.stats.fmri_spec.sess(r).cond(2).name = 'house';
    matlabbatch{1}.spm.stats.fmri_spec.sess(r).cond(2).onset = onsets_all{r,2};
    matlabbatch{1}.spm.stats.fmri_spec.sess(r).cond(2).duration = 0;
    matlabbatch{1}.spm.stats.fmri_spec.sess(r).hpf = 128;
end
matlabbatch{1}.spm.stats.fmri_spec.global = 'None';
matlabbatch{1}.spm.stats.fmri_spec.cvi = 'AR(1)';
spm_jobman('run', matlabbatch);

clear matlabbatch
matlabbatch{1}.spm.stats.fmri_est.spmmat = {fullfile(output_dir, 'SPM.mat')};
matlabbatch{1}.spm.stats.fmri_est.write_residuals = 0;
matlabbatch{1}.spm.stats.fmri_est.method.Classical = 1;
spm_jobman('run', matlabbatch);

load(fullfile(output_dir, 'SPM.mat'));
nCol = size(SPM.xX.X,2);
c = zeros(1,nCol);
for r = 1:nRuns
    c((r-1)*2+1) = 1;
    c((r-1)*2+2) = -1;
end
clear matlabbatch
matlabbatch{1}.spm.stats.con.spmmat = {fullfile(output_dir, 'SPM.mat')};
matlabbatch{1}.spm.stats.con.consess{1}.tcon.name = 'Face > House';
matlabbatch{1}.spm.stats.con.consess{1}.tcon.weights = c;
matlabbatch{1}.spm.stats.con.delete = 0;
spm_jobman('run', matlabbatch);
fprintf('一阶模型完成\n');