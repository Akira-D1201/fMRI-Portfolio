%% 二阶组分析（单样本 t 检验）
clear; clc;
root = 'C:\Users\Akira\Documents\MATLAB\spm\Visual_Object\ds000105_R2.0.2_raw\ds000105_R2.0.2';
subjects = {'sub-1','sub-2','sub-3','sub-4','sub-6'};
nSub = length(subjects);

con_images = cell(nSub,1);
for i = 1:nSub
    con_images{i} = fullfile(root, subjects{i}, '1stLevel', 'con_0001.nii');
end

group_dir = fullfile(root, 'GroupAnalysis');
if ~exist(group_dir, 'dir'); mkdir(group_dir); end

spm('defaults','FMRI');
spm_jobman('initcfg');
clear matlabbatch

matlabbatch{1}.spm.stats.factorial_design.dir = {group_dir};
matlabbatch{1}.spm.stats.factorial_design.des.t1.scans = con_images;
matlabbatch{1}.spm.stats.factorial_design.masking.tm.tm_none = 1;
matlabbatch{1}.spm.stats.factorial_design.masking.im = 1;
matlabbatch{1}.spm.stats.factorial_design.masking.em = {''};
matlabbatch{1}.spm.stats.factorial_design.globalc.g_omit = 1;
matlabbatch{1}.spm.stats.factorial_design.globalm.gmsca.gmsca_no = 1;
matlabbatch{1}.spm.stats.factorial_design.globalm.glonorm = 1;
spm_jobman('run', matlabbatch);

clear matlabbatch
matlabbatch{1}.spm.stats.fmri_est.spmmat = {fullfile(group_dir, 'SPM.mat')};
matlabbatch{1}.spm.stats.fmri_est.write_residuals = 0;
matlabbatch{1}.spm.stats.fmri_est.method.Classical = 1;
spm_jobman('run', matlabbatch);

clear matlabbatch
matlabbatch{1}.spm.stats.con.spmmat = {fullfile(group_dir, 'SPM.mat')};
matlabbatch{1}.spm.stats.con.consess{1}.tcon.name = 'Group mean > 0';
matlabbatch{1}.spm.stats.con.consess{1}.tcon.weights = 1;
matlabbatch{1}.spm.stats.con.consess{1}.tcon.sessrep = 'none';
matlabbatch{1}.spm.stats.con.delete = 0;
spm_jobman('run', matlabbatch);
fprintf('二阶分析完成\n');