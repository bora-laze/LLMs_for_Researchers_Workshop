# Sleep and GPA pilot analysis
#
# This script loads the pilot sleep dataset, checks that the expected inputs are
# present, investigates missingness, runs the planned regression models, and
# saves labeled figures for the workshop demo.

required_columns <- c(
  "student_id",
  "year_of_study",
  "sleep_hours",
  "caffeine_mg_daily",
  "stress_score",
  "gpa"
)

numeric_columns <- c(
  "year_of_study",
  "sleep_hours",
  "caffeine_mg_daily",
  "stress_score",
  "gpa"
)

get_script_dir <- function() {
  file_arg <- "--file="
  file_path <- sub(
    file_arg,
    "",
    commandArgs(trailingOnly = FALSE)[startsWith(commandArgs(trailingOnly = FALSE), file_arg)][1]
  )

  if (!is.na(file_path)) {
    return(dirname(normalizePath(file_path, mustWork = FALSE)))
  }

  source_files <- vapply(
    sys.frames(),
    function(frame) {
      if (!is.null(frame$ofile)) {
        return(frame$ofile)
      }
      NA_character_
    },
    character(1)
  )
  source_files <- source_files[!is.na(source_files)]

  if (length(source_files) > 0) {
    return(dirname(normalizePath(source_files[length(source_files)], mustWork = FALSE)))
  }

  getwd()
}

find_data_path <- function(script_dir) {
  env_path <- Sys.getenv("PILOT_SLEEP_CSV", unset = NA_character_)
  candidates <- c(
    env_path,
    file.path(script_dir, "pilot_sleep.csv"),
    file.path(script_dir, "data", "pilot_sleep.csv"),
    file.path(dirname(script_dir), "demo_2", "pilot_sleep.csv"),
    file.path(getwd(), "pilot_sleep.csv")
  )
  candidates <- unique(candidates[!is.na(candidates) & nzchar(candidates)])
  matches <- candidates[file.exists(candidates)]

  if (length(matches) == 0) {
    stop(
      paste(
        "Could not find pilot_sleep.csv. Checked:",
        paste(candidates, collapse = "; "),
        "Set PILOT_SLEEP_CSV to the full CSV path if the file lives elsewhere."
      ),
      call. = FALSE
    )
  }

  matches[1]
}

validate_input <- function(data, required_columns, numeric_columns) {
  missing_columns <- setdiff(required_columns, names(data))

  if (length(missing_columns) > 0) {
    stop(
      paste("The dataset is missing required columns:", paste(missing_columns, collapse = ", ")),
      call. = FALSE
    )
  }

  non_numeric_columns <- numeric_columns[!vapply(data[numeric_columns], is.numeric, logical(1))]

  if (length(non_numeric_columns) > 0) {
    stop(
      paste("These columns should be numeric:", paste(non_numeric_columns, collapse = ", ")),
      call. = FALSE
    )
  }

  invisible(TRUE)
}

save_histogram <- function(values, file_path, title, x_label) {
  png(file_path, width = 900, height = 650)
  hist(
    values,
    breaks = 20,
    main = title,
    xlab = x_label,
    col = "gray80",
    border = "white"
  )
  dev.off()
}

save_scatter_plot <- function(data, model, file_path) {
  png(file_path, width = 900, height = 650)
  plot(
    data$sleep_hours,
    data$gpa,
    xlab = "Sleep duration (hours per night)",
    ylab = "GPA",
    main = "Relationship Between Sleep Duration and GPA",
    pch = 19,
    col = rgb(0, 0, 0, 0.45)
  )
  abline(model, col = "red", lwd = 2)
  mtext("Line shows the unadjusted linear regression fit.", side = 3, line = 0.3, cex = 0.85)
  dev.off()
}

save_diagnostic_plots <- function(model, file_path) {
  png(file_path, width = 1000, height = 800)
  par(mfrow = c(2, 2))
  plot(model)
  par(mfrow = c(1, 1))
  dev.off()
}

script_dir <- get_script_dir()
data_path <- find_data_path(script_dir)
figure_dir <- file.path(script_dir, "figures")

if (!dir.exists(figure_dir)) {
  dir.create(figure_dir, recursive = TRUE)
}

sleep_data <- read.csv(data_path, stringsAsFactors = FALSE)
validate_input(sleep_data, required_columns, numeric_columns)

cat("Loaded", nrow(sleep_data), "rows from", data_path, "\n\n")
cat("Preview:\n")
print(head(sleep_data))
cat("\nSummary:\n")
print(summary(sleep_data[required_columns]))
cat("\nStructure:\n")
str(sleep_data[required_columns])

missing_summary <- data.frame(
  variable = required_columns,
  missing_count = colSums(is.na(sleep_data[required_columns])),
  missing_percent = round(colMeans(is.na(sleep_data[required_columns])) * 100, 1),
  row.names = NULL
)

cat("\nMissing values by required column:\n")
print(missing_summary)

model_columns <- c("sleep_hours", "gpa", "stress_score", "year_of_study", "caffeine_mg_daily")
model_data <- sleep_data[complete.cases(sleep_data[model_columns]), model_columns]

rows_excluded <- nrow(sleep_data) - nrow(model_data)
cat("\nRows excluded from regression models because of missing model variables:", rows_excluded, "\n")
cat("Rows available for regression models:", nrow(model_data), "\n\n")

if (nrow(model_data) == 0) {
  stop("No complete rows are available for the planned regression models.", call. = FALSE)
}

save_histogram(
  model_data$sleep_hours,
  file.path(figure_dir, "sleep_hours_distribution.png"),
  "Distribution of Sleep Duration",
  "Sleep duration (hours per night)"
)

save_histogram(
  model_data$gpa,
  file.path(figure_dir, "gpa_distribution.png"),
  "Distribution of GPA",
  "GPA"
)

sleep_model <- lm(gpa ~ sleep_hours, data = model_data)
adjusted_model <- lm(gpa ~ sleep_hours + stress_score + year_of_study, data = model_data)
full_model <- lm(gpa ~ sleep_hours + stress_score + year_of_study + caffeine_mg_daily, data = model_data)

save_scatter_plot(model_data, sleep_model, file.path(figure_dir, "sleep_gpa_scatter.png"))
save_diagnostic_plots(adjusted_model, file.path(figure_dir, "adjusted_model_diagnostics.png"))

cat("Unadjusted model: GPA predicted by sleep duration\n")
print(summary(sleep_model))

cat("\nAdjusted model: GPA predicted by sleep duration, stress, and year of study\n")
print(summary(adjusted_model))

cat("\nFull model: adjusted model plus daily caffeine intake\n")
print(summary(full_model))

correlation_matrix <- cor(model_data[model_columns], use = "pairwise.complete.obs")
cat("\nCorrelation matrix for model variables:\n")
print(round(correlation_matrix, 3))

cat("\nAdjusted model R-squared:", round(summary(adjusted_model)$r.squared, 3), "\n")
cat("Figures saved in:", figure_dir, "\n")
