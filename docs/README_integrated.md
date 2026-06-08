# Integrated Dual-Database Pipeline

This folder contains the new integrated pipeline. It does not replace the original scripts in the parent directory.

## What It Runs

- Denoising methods: DADA2 and UNOISE3.
- Taxonomy branches for each denoising result:
  - SILVA + naive Bayes classifier: `*_silva.*`
  - Greengenes2: `*_gg2.*`
- UPARSE is not called.

## Main Entry

Run from the project root:

```bash
bash integrate_pipline/run_integrated_dualdb.batch
```

Or from this folder:

```bash
bash run_integrated_dualdb.batch
```

The runner calls the local upstream scripts in this folder:

- `integrated_q2a_usearchMergePairs.batch`
- `integrated_q2b_dada2.batch`
- `integrated_q2b_unoise3.batch`

After denoising, it switches to the integrated scripts in this folder.

PICRUSt2 functional prediction runs after taxonomy-based mitochondria/chloroplast
filtering and before feature filtering/tree building. It uses SILVA-filtered
non-rarefied inputs only: `*_tab_silva_pk.qza` feature tables and
`*_rep_silva_pk.qza` representative sequences for DADA2 and UNOISE3.

## Configuration

All scripts in this folder read:

```text
integrate_pipline/configuration_integrated.txt
```

Input files should be placed in this folder using the same names expected by the original pipeline, for example `${prefix}_seq`, `${prefix}_manifest.tsv`, and the metadata file configured by `metadata_file`.

## Output Naming

For each denoising method, the integrated branch writes separate database-specific files:

- DADA2 + SILVA: `test_da2_*_silva.*`
- DADA2 + Greengenes2: `test_da2_*_gg2.*`
- UNOISE3 + SILVA: `test_un3_*_silva.*`
- UNOISE3 + Greengenes2: `test_un3_*_gg2.*`

Downstream filtered, tree, rarefied, diversity, and ANCOM outputs keep the same `silva` or `gg2` suffix.
