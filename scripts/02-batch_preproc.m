%% 单个被试预处理（Realign → Slice Timing → Segment → Normalise → Smooth）
clear; clc;
root = 'C:\Users\Akira\Documents\MATLAB\spm\Visual_Object\ds000105_R2.0.2_raw\ds000105_R2.0.2';
subj = 'sub-4';   % 修改为你要处理的被试
func_dir = fullfile(root, subj, 'func');
anat_dir = fullfile(root, subj, 'anat');
TR = 2.5;
nslices = 64;
nRuns = 12;

% 1. Realign
runs_scans = cell(nRuns,1);
for r = 1:nRuns
    fname = fullfile(func_dir, sprintf('%s_task-objectviewing_run-%02d_bold.nii', subj, r));
    runs_scans{r} = {fname};
end
matlabbatch{1}.spm.spatial.realign.estwrite.data = runs_scans;
matlabbatch{1}.spm.spatial.realign.estwrite.roptions.prefix = 'r';
spm_jobman('run', matlabbatch); clear matlabbatch

% 2. Slice Timing
r_files = cell(nRuns,1);
for r = 1:nRuns
    fname = fullfile(func_dir, sprintf('r%s_task-objectviewing_run-%02d_bold.nii', subj, r));
    r_files{r} = {fname};
end
matlabbatch{1}.spm.temporal.st.scans = r_files;
matlabbatch{1}.spm.temporal.st.nslices = nslices;
matlabbatch{1}.spm.temporal.st.tr = TR;
matlabbatch{1}.spm.temporal.st.ta = TR - TR/nslices;
matlabbatch{1}.spm.temporal.st.so = 1:nslices;
matlabbatch{1}.spm.temporal.st.refslice = floor(nslices/2);
matlabbatch{1}.spm.temporal.st.prefix = 'a';
spm_jobman('run', matlabbatch); clear matlabbatch

% 3. Segment (使用 SPM 模板)
if ~exist(fullfile(anat_dir, 'avg152T1.nii'), 'file')
    spm_dir = fileparts(which('spm'));
    copyfile(fullfile(spm_dir, 'canonical', 'avg152T1.nii'), fullfile(anat_dir, 'avg152T1.nii'));
end
t1_file = fullfile(anat_dir, 'avg152T1.nii');
matlabbatch{1}.spm.spatial.preproc.channel.vols = {t1_file};
matlabbatch{1}.spm.spatial.preproc.channel.biasreg = 0.0001;
matlabbatch{1}.spm.spatial.preproc.channel.biasfwhm = 60;
matlabbatch{1}.spm.spatial.preproc.channel.write = [0 1];
spm_dir = fileparts(which('spm'));
tpm = fullfile(spm_dir, 'tpm', 'TPM.nii');
ngaus = [1,1,2,3,4,2];
for tis = 1:6
    matlabbatch{1}.spm.spatial.preproc.tissue(tis).tpm = {[tpm ',' num2str(tis)]};
    matlabbatch{1}.spm.spatial.preproc.tissue(tis).ngaus = ngaus(tis);
    matlabbatch{1}.spm.spatial.preproc.tissue(tis).native = [1 0];
    matlabbatch{1}.spm.spatial.preproc.tissue(tis).warped = [0 1];
end
matlabbatch{1}.spm.spatial.preproc.warp.mrf = 1;
matlabbatch{1}.spm.spatial.preproc.warp.cleanup = 1;
matlabbatch{1}.spm.spatial.preproc.warp.reg = [0 0 0.1 0.01 0.04];
matlabbatch{1}.spm.spatial.preproc.warp.affreg = 'mni';
matlabbatch{1}.spm.spatial.preproc.warp.fwhm = 0;
matlabbatch{1}.spm.spatial.preproc.warp.samp = 3;
matlabbatch{1}.spm.spatial.preproc.warp.write = [0 1];
matlabbatch{1}.spm.spatial.preproc.warp.vox = NaN;
matlabbatch{1}.spm.spatial.preproc.warp.bb = [NaN NaN NaN; NaN NaN NaN];
spm_jobman('run', matlabbatch); clear matlabbatch

% 4. Normalise
def_file = fullfile(anat_dir, 'y_avg152T1.nii');
a_files = cell(nRuns,1);
for r = 1:nRuns
    fname = fullfile(func_dir, sprintf('ar%s_task-objectviewing_run-%02d_bold.nii', subj, r));
    a_files{r} = fname;
end
matlabbatch{1}.spm.spatial.normalise.write.subj.def = {def_file};
matlabbatch{1}.spm.spatial.normalise.write.subj.resample = a_files;
matlabbatch{1}.spm.spatial.normalise.write.woptions.vox = [2 2 2];
matlabbatch{1}.spm.spatial.normalise.write.woptions.prefix = 'w';
spm_jobman('run', matlabbatch); clear matlabbatch

% 5. Smooth
w_files = cell(nRuns,1);
for r = 1:nRuns
    fname = fullfile(func_dir, sprintf('war%s_task-objectviewing_run-%02d_bold.nii', subj, r));
    w_files{r} = fname;
end
matlabbatch{1}.spm.spatial.smooth.data = w_files;
matlabbatch{1}.spm.spatial.smooth.fwhm = [8 8 8];
matlabbatch{1}.spm.spatial.smooth.prefix = 's';
spm_jobman('run', matlabbatch);
fprintf('预处理完成\n');