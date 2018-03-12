**BUSCO - Benchmarking sets of Universal Single-Copy Orthologs.**

To install, ``sudo python setup.py install`` or ``python setup.py install --user``

To get help, ``python scripts/run_BUSCO.py -h`` and ``python scripts/generate_plot.py -h``

Do not forget to create a ``config.ini`` file in the ``config/`` subfolder. You can set the ``BUSCO_CONFIG_FILE`` 
environment variable to define a custom path (including the filename) to the ``config.ini`` file, 
useful for switching between configurations or in a multi-users environment.

See also the user guide: BUSCO_v3_userguide.pdf

You can download BUSCO datasets on http://busco.ezlab.org

You can find scripts to produce a phylogeny and a Dockerfile that contains BUSCO on https://gitlab.com/ezlab/busco_usecases

**How to cite BUSCO**

*BUSCO applications from quality assessments to gene prediction and phylogenomics.*
Robert M. Waterhouse, Mathieu Seppey, Felipe A. Simão, Mose Manni, Panagiotis Ioannidis, Guennadi Klioutchnikov, Evgenia V. Kriventseva, and Evgeny M. Zdobnov
*Mol Biol Evol*, published online Dec 6, 2017 
doi: 10.1093/molbev/msx319 

*BUSCO: assessing genome assembly and annotation completeness with single-copy orthologs.*
Felipe A. Simão, Robert M. Waterhouse, Panagiotis Ioannidis, Evgenia V. Kriventseva, and Evgeny M. Zdobnov
*Bioinformatics*, published online June 9, 2015 
doi: 10.1093/bioinformatics/btv351

Copyright (c) 2016-2018, Evgeny Zdobnov (ez@ezlab.org)
Licensed under the MIT license. See LICENSE.md file.
