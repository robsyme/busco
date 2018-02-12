**BUSCO - Benchmarking sets of Universal Single-Copy Orthologs.**

To install, ``sudo python setup.py install`` or ``python setup.py install --user``

To get help, ``python scripts/run_BUSCO.py -h`` and ``python scripts/generate_plot.py -h``

Do not forget to create a ``config.ini`` file in the ``config/`` subfolder. You can set the ``BUSCO_CONFIG_FILE`` 
environment variable to define a custom path (including the filename) to the ``config.ini`` file, 
useful for switching between configurations or in a multi-users environment.

See also the user guide: BUSCO_v3_userguide.pdf

You can download BUSCO datasets on http://busco.ezlab.org

Copyright (c) 2016-2018, Evgeny Zdobnov (ez@ezlab.org)
Licensed under the MIT license. See LICENSE.md file.
