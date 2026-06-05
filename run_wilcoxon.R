args <- commandArgs(trailingOnly = TRUE)
if (length(args) < 5) {
  stop("Usage: Rscript run_wilcoxon.R alpha-diversity.tsv metadata.tsv metric paired output_prefix [group_column]")
}

alpha_file <- args[[1]]
metadata_file <- args[[2]]
metric <- args[[3]]
paired <- tolower(args[[4]]) == "true"
output_prefix <- args[[5]]
group_column <- if (length(args) >= 6) args[[6]] else "group"

alpha <- read.delim(alpha_file, check.names = FALSE, comment.char = "")
metadata <- read.delim(metadata_file, check.names = FALSE, comment.char = "")

sample_candidates <- c("sample-id", "SampleID", "#SampleID", "id")
alpha_sample_col <- intersect(sample_candidates, names(alpha))[1]
metadata_sample_col <- intersect(sample_candidates, names(metadata))[1]

if (is.na(alpha_sample_col)) {
  alpha_sample_col <- names(alpha)[1]
}
if (is.na(metadata_sample_col)) {
  metadata_sample_col <- names(metadata)[1]
}
if (!group_column %in% names(metadata)) {
  stop(sprintf("Group column '%s' was not found in %s", group_column, metadata_file))
}

value_col <- metric
if (!value_col %in% names(alpha)) {
  numeric_cols <- names(alpha)[vapply(alpha, is.numeric, logical(1))]
  numeric_cols <- setdiff(numeric_cols, alpha_sample_col)
  if (length(numeric_cols) == 0) {
    stop(sprintf("No numeric alpha diversity column found in %s", alpha_file))
  }
  value_col <- numeric_cols[1]
}

names(alpha)[names(alpha) == alpha_sample_col] <- "sample_id"
names(metadata)[names(metadata) == metadata_sample_col] <- "sample_id"
dat <- merge(alpha[, c("sample_id", value_col)], metadata[, c("sample_id", group_column)], by = "sample_id")
names(dat) <- c("sample_id", "value", "group")
dat <- dat[complete.cases(dat), ]
dat$group <- as.factor(dat$group)

if (nrow(dat) == 0 || length(levels(dat$group)) < 2) {
  stop("Wilcoxon test needs at least two groups with non-missing alpha diversity values.")
}

dir.create(dirname(output_prefix), recursive = TRUE, showWarnings = FALSE)
summary_file <- paste0(output_prefix, ".summary.tsv")
result_file <- paste0(output_prefix, ".pairwise.tsv")

summary_out <- do.call(rbind, lapply(split(dat$value, dat$group), function(x) {
  data.frame(
    n = length(x),
    mean = mean(x),
    median = median(x),
    sd = stats::sd(x),
    check.names = FALSE
  )
}))
summary_out <- data.frame(group = rownames(summary_out), summary_out, check.names = FALSE)
rownames(summary_out) <- NULL
write.table(summary_out, summary_file, sep = "\t", quote = FALSE, row.names = FALSE)

pairwise <- pairwise.wilcox.test(dat$value, dat$group, p.adjust.method = "BH", paired = paired)
p_matrix <- pairwise$p.value
rows <- data.frame()
if (!is.null(p_matrix)) {
  for (i in seq_len(nrow(p_matrix))) {
    for (j in seq_len(ncol(p_matrix))) {
      p <- p_matrix[i, j]
      if (!is.na(p)) {
        rows <- rbind(rows, data.frame(group1 = rownames(p_matrix)[i], group2 = colnames(p_matrix)[j], p_adjusted = p))
      }
    }
  }
}
write.table(rows, result_file, sep = "\t", quote = FALSE, row.names = FALSE)
