**BUSCO - Benchmarking sets of Universal Single-Copy Orthologs.**

> The new BUSCO datasets, **odb10**, will be available very soon. Stay tuned !

To install, ``sudo python setup.py install`` or ``python setup.py install --user``

To get help, ``python scripts/run_BUSCO.py -h`` and ``python scripts/generate_plot.py -h``

Do not forget to create a ``config.ini`` file in the ``config/`` subfolder. You can set the ``BUSCO_CONFIG_FILE`` 
environment variable to define a custom path (including the filename) to the ``config.ini`` file, 
useful for switching between configurations or in a multi-users environment.

See also the user guide: BUSCO_v3_userguide.pdf

You can download BUSCO datasets on http://busco.ezlab.org

You can find scripts to produce a phylogeny and a Dockerfile that contains BUSCO on https://gitlab.com/ezlab/busco_usecases/tree/master/phylogenomics

**How to cite BUSCO**

*BUSCO applications from quality assessments to gene prediction and phylogenomics.*
Robert M. Waterhouse, Mathieu Seppey, Felipe A. Simão, Mose Manni, Panagiotis Ioannidis, Guennadi Klioutchnikov, Evgenia V. Kriventseva, and Evgeny M. Zdobnov
*Molecular Biology & Evolution*, Volume 35, Issue 3, 1 March 2018, Pages 543–548 (published online Dec 6, 2017) 
doi: 10.1093/molbev/msx319 

*BUSCO: assessing genome assembly and annotation completeness with single-copy orthologs.*
Felipe A. Simão, Robert M. Waterhouse, Panagiotis Ioannidis, Evgenia V. Kriventseva, and Evgeny M. Zdobnov
*Bioinformatics*, Volume 31, Issue 19, 1 October 2015, Pages 3210–3212 (published online June 9, 2015) 
doi: 10.1093/bioinformatics/btv351

*Using BUSCO to assess insect genomic resources.*
Robert M. Waterhouse, Mathieu Seppey, Felipe A. Simão, and Evgeny M. Zdobnov
*Methods in Molecular Biology*, Insect Genomics, Humana Press, New York, NY 2019, Pages 59-74 (published online November 10, 2018) 
doi: 10.1007/978-1-4939-8775-7_6

Copyright (c) 2016-2019, Evgeny Zdobnov (ez@ezlab.org)
Licensed under the MIT license. See LICENSE.md file.
