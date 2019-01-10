#!/usr/bin/env python
# coding: utf-8

"""
.. module:: BuscoPlacer
   :synopsis: BuscoPlacer implements methods required for automatically selecting the appropriate dataset
   to be used during BUSCO analysis
.. versionadded:: 3.1.0
.. versionchanged:: 3.1.0

Copyright (c) 2016-2019, Evgeny Zdobnov (ez@ezlab.org)
Licensed under the MIT license. See LICENSE.md file.

"""

from Bio import Phylo
import glob
import os


class BuscoPlacer():

    def __init__(self):
        pass

    @staticmethod
    def extract_single_copy_sequences(folder, sequences):
        """
        This function extracts all single copy BUSCO genes from a protein run folder
        :param folder: a BUSCO protein run folder
        :type str
        :param sequences: protein fasta used as input for the BUSCO run corresponding to the folder
        :type str
        """

        os.mkdir('%s/single_copy_busco_sequences/' % folder)

        mapping_header_busco = {}

        for full_table in glob.glob('%s/full_table_*.tsv' % folder):

            for line in open(full_table):
                try:
                    if line.split('\t')[1] == 'Complete':
                        busco_name = line.split('\t')[0]
                        fasta_header = line.split('\t')[2]
                        mapping_header_busco.update({fasta_header:busco_name})
                except IndexError:
                    pass

        write = False
        fasta_outp = None

        for line in open(sequences):
            if line.startswith('>'):
                if line.strip()[1:].split(' ')[0] in mapping_header_busco:
                    write = True
                    try:
                        fasta_outp.close()
                    except AttributeError:
                        pass
                    busco_name = mapping_header_busco[line.strip()[1:].split(' ')[0]]
                    fasta_outp = open('%s/single_copy_busco_sequences/%s.faa' % (folder, busco_name), 'w')
                else:
                    write = False
            if write:
                fasta_outp.write(line)
        fasta_outp.close()

    @staticmethod
    def define_dataset(tree_file, mapping_file, threshold):
        """
        This function processes a pplacer output to define which dataset should be used
        :param tree_file: a tree in phyloXML format
        :type file
        :param mapping_file: mapping between taxid found in the tree and datasets
        :type file
        :param threshold: different in width required for a dataset to be considered when compared with another.
        :type float
        :return: the dataset to be used
        :rtype: str
        """

        # load the tree
        tree = Phylo.read(tree_file, 'phyloxml')

        # load the mapping: key are taxid, values are busco datasets
        taxid_mapping = {}
        # and keep track of the hierarchy of the datasets
        child_parent_mapping = {}

        for line in open(mapping_file):
            line = line.strip()
            taxid_mapping.update({line.split('\t')[0]: line.split('\t')[1].split(',')})
            try:
                if line.split('\t')[1].split(',')[-1] in child_parent_mapping:
                    child_parent_mapping[line.split('\t')[1].split(',')[-1]].update(
                        line.split('\t')[1].split(',')[0:-1])
                else:
                    child_parent_mapping.update(
                        {line.split('\t')[1].split(',')[-1]:set(line.split('\t')[1].split(',')[0:-1])})
            except IndexError:
                pass

        # transform:  key are busco datsets, values are taxid
        datasets_mapping = {}
        for taxid in taxid_mapping:
            for dataset in taxid_mapping[taxid]:
                if dataset in datasets_mapping:
                    datasets_mapping[dataset].append(taxid)
                else:
                    datasets_mapping.update({dataset: [taxid]})

        # identify the node in the tree that is this common ancestor (i.e. busco_dataset)
        # and compute the total witdh (=weight) of the clade

        weigth = {}

        for dataset in datasets_mapping:

            clades = [clade[0] if clade else None
                      for clade in [list(tree.find_clades({"name": taxid}))
                      for taxid in datasets_mapping[dataset]]]

            ancestor_node = tree.common_ancestor([clade for clade in clades if clade is not None])

            weigths = [0]

            for clade in ancestor_node.get_terminals() + ancestor_node.get_nonterminals():
                if clade.width:
                    weigths.append(clade.width)

            weigth.update({dataset: sum(weigths)})

        # Define the dataset that should be used. As follows:
        # Do a pairwise comparision of the weight of each datasets
        # If a clade is the parent of the other one, substract the weight of the children clade from the parent.
        # Define a score for the comparision, depending on the threshold.
        # Keep the dataset that has the best score overall

        best_clade = None
        best_score = 0

        for candidate_clade in datasets_mapping:

            for other_clade in datasets_mapping:

                if candidate_clade != other_clade:

                    candidate_weight = weigth[candidate_clade]

                    other_weight = weigth[other_clade]

                    if candidate_clade in child_parent_mapping[other_clade]:
                        candidate_weight -= other_weight

                    if other_clade in child_parent_mapping[candidate_clade]:
                        other_weight -= candidate_weight

                    candidate_score = candidate_weight - threshold*other_weight

                    if candidate_score > best_score:
                        best_clade = candidate_clade
                        best_score = candidate_score

        return best_clade
