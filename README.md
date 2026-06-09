# Integrated Dual-Database Pipeline

This repository contains the integrated 16S pipeline. The runnable batch files are
kept under `scripts/`, the main configuration is kept under `config/`, and this
README is kept under `docs/`.

## What It Runs

- Denoising methods: DADA2 and UNOISE3.
- Taxonomy branches for each denoising result:
  - SILVA + naive Bayes classifier: `*_silva.*`
  - Greengenes2: `*_gg2.*`
- UPARSE is not called.

## Main Entry

Run from the project root:

```bash
bash scripts/run_integrated_dualdb.batch
```

Or from the `scripts/` folder:

```bash
cd scripts
bash run_integrated_dualdb.batch
```

The runner calls these scripts in order:

- `integrated_q2a_usearchMergePairs.batch`
- `integrated_q2b_dada2.batch`
- `integrated_q2b_unoise3.batch`
- `integrated_q2d_taxaClassify.batch`
- `integrated_q2e_taxaFilterMitoChlo.batch`
- `integrated_q2x_picrust2.batch`
- `integrated_q2x_featuresFilter.batch`
- `integrated_q2f_treeBuildFilter.batch`
- `integrated_q2x_rarefy.batch`
- `integrated_q2x_alphaDiversity.batch`
- `integrated_q2x_betaDiversity.batch`
- `integrated_q2x_ancom.batch`

The downstream scripts source `scripts/integrated_common.sh`. This file is not a
manual entry point; it provides shared helpers such as `get_config`, `WORK_DIR`,
and the resolved configuration path.

PICRUSt2 functional prediction runs after taxonomy-based mitochondria/chloroplast
filtering and before feature filtering/tree building. It uses SILVA-filtered
non-rarefied inputs only: `*_tab_silva_pk.qza` feature tables and
`*_rep_silva_pk.qza` representative sequences for DADA2 and UNOISE3.

## Configuration

The tracked configuration file is:

```text
config/configuration_integrated.txt
```

The current runner exports `CONFIG_FILE` as `scripts/configuration_integrated.txt`.
The later scripts can fall back to `config/configuration_integrated.txt` through
`scripts/integrated_common.sh`, but the first denoising scripts use the
runner-provided path directly. For a full run with the runner as currently
written, either keep a copy of the configuration at
`scripts/configuration_integrated.txt` or update the runner to point at
`config/configuration_integrated.txt`.

The current runner sets `WORK_DIR` to the `scripts/` directory. Therefore, with
the scripts as currently written, input files should be available under
`scripts/` using the names expected by the original pipeline, for example
`${prefix}_seq`, `${prefix}_manifest.tsv`, and the metadata file configured by
`metadata_file`.

The first denoising scripts define their own `get_config` function. The later
integrated scripts load `scripts/integrated_common.sh`.

## Output Naming

For each denoising method, the integrated branch writes separate database-specific files:

- DADA2 + SILVA: `test_da2_*_silva.*`
- DADA2 + Greengenes2: `test_da2_*_gg2.*`
- UNOISE3 + SILVA: `test_un3_*_silva.*`
- UNOISE3 + Greengenes2: `test_un3_*_gg2.*`

Downstream filtered, tree, rarefied, diversity, and ANCOM outputs keep the same `silva` or `gg2` suffix.

Because the current runner works inside `scripts/`, most generated QIIME2
artifacts and result folders are written under `scripts/` unless `WORK_DIR` is
changed in the runner.
