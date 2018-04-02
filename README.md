# GCxGC-NMF-Classification
An R code for classifying GCxGC data using a NMF algorithm

This R source code is developed for classifying GCxGC data based on a NMF algorithm. When univariate GCxGC data, such as GCxGC-FID or TIC of GCxGC-MS, are provided as the input data, these data are automatically classified according to the similarity of their 2D chromatogram patterns. See "<a href="">User’s Guide</a>" for details.

A user is requested to locate 2 categorized data in the input folder: 1. GCxGC data (.csv) to make NMF classes, 2. GCxGC data (.csv) of unknown samples to be classified into the prepared NMF class.
These GCxGC data should be taken by the same conditions on GC run and detector.


Open "Just_Run_Me.r" file. 
Modify "Folder_location", so that it is adjusted for your PC environment.
Then, just run the code in R.


Test data set is involved in this version, therefore, the user can quickly experience how it works.


Ref: <a href="https://pubs.acs.org/doi/10.1021/acs.analchem.7b04313">Zushi Y. and Hashimoto S., Direct classification of GC × GC-analyzed complex mixtures using non-negative matrix factorization based feature extraction, Anal. Chem., 2018, 90 (6), pp 3819–3825.</a>

<br><br> Author contacts:
<br>Yasuyuki Zushi, yasuyuki.zushi@gmail.com
