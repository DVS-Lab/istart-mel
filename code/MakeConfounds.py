
# coding: utf-8

# E.G. use
# python3 MakeConfounds.py --fmriprepDir="/ZPOOL/data/projects/istart-mel/updated_rsa/derivatives/fmriprep"

# TO DO:
# 1. write to subject folders, create if it doesn't exist
# 2. simplify input argument to project name. all paths should be standardized within a project folder
# 3. check for existence of output before overwiting older output. helps with version control on datalad.
# 4. give option to overwrite existing output


import numpy as np
import pandas as pd
import argparse
import os
import re

parser = argparse.ArgumentParser(description='Give me a path to your fmriprep output')
group = parser.add_mutually_exclusive_group(required=True)

group.add_argument('--fmriprepDir',default=None, type=str,help="This is the full path to your fmriprep dir")
args = parser.parse_args()

fmriprep_path = args.fmriprepDir

print("finding confound files located in %s"%(fmriprep_path))
#make list of confound tsvs
cons=[]
for root, dirs, files in os.walk(fmriprep_path):
    for f in files:
        if f.endswith('-confounds_timeseries.tsv'):
            cons.append(os.path.join(root, f))


for f in cons:
    sub=re.search('/func/(.*)_task', f).group(1)
    run=re.search('_run-(.*)_desc', f).group(1)
    task=re.search('_task-(.*)_run',f).group(1)
    derivitive_path=re.search('(.*)fmriprep/sub',f).group(1)


    outfile="%s_task-%s_run-%s_desc-fslConfounds.tsv"%(sub,task,run)


    #read in the confounds, aroma mixing, and aroma confound indexes
    con_regs=pd.read_csv(f,sep='\t')

    other=['csf','white_matter']
    cosine = [col for col in con_regs if col.startswith('cosine')]
    NSS = [col for col in con_regs if col.startswith('non_steady_state')]
    #motion_out=[col for col in con_regs if col.startswith('motion_outlier')]
    aroma_motion=[col for col in con_regs if col.startswith('aroma')]

    filter_col=np.concatenate([cosine,NSS,aroma_motion,other])#here we combine all NSS AROMA motion & the rest

    #This Dataframe will be the full filter matrix
    df_all=con_regs[filter_col]
    outdir=derivitive_path+"fsl/confounds/%s/" %(sub)

    if not os.path.exists(outdir):
    	os.makedirs(outdir)
    output=outdir+outfile
    print(sub,run,task)

    df_all.to_csv(output,index=False,sep='\t',header=False)