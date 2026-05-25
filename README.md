# LLMs_for_Researchers_Workshop
Resources from 2026 Claude & Codex Workshop

Files used to carry out demonstrations 1-3 are made available here within the "Demos" folder for you to test out on your own devices. These demonstrations have been made to illustrate how you might use different tools to help you with different parts of your research workflow. To successfully carry out these demonstrations, download the files in the "demo_1" and "demo_2" folder so that Claude can work locally for the first two demonstrations. For Codex in the third demonstration, simply direct Codex to this respository, specifically the "demo_3" folder.

Links to the additional resources to deepen your understanding and optimize your own workflows are also available here in the "Additional_Resources" file.

The demonstrations are built on the following scenario:

Imagine you are a researcher who is interested in studying the relationship between sleep and GPA in undergraduate students and eventually writing a paper and presenting your research at conferences. Before you collect any data, you need to review the existing literature to get a good sense of what you might expect to find as well as good approaches to data collection methods that suit your research. Once that is done, you go out and collect data from 200 undergraduate students. Then, you want to statistically analyse this data as well as find any issues with it that might affect the results and their interpretation.

## Demonstration 1: A Messy Literature Review
In the "demo_1" folder, you will find 15 papers related to studies on sleep and GPA. You will also find a document with unorganized notes related to the paper as well as a structural outline for literature review section of your paper. The problems you want to try and address with Claude Cowork are as follows:
- One of the papers (Paper 9) is outside the scope of your research as it looked at clinical cases of sleep apnea.
- Another paper (paper 12) is actually the same paper as Paper 1, just with a different bibliographic entry.
- You want to identify the main themes amongst your papers and organize a one-page summary of this research according to these themes. 

You can either come up with your own prompt or try the following prompt: "I have a folder for a literature review on sleep duration and academic performance in university students. Read everything, identify the main themes, flag anything off-topic or duplicated, and produce a structured one-page summary organized by theme. Save it as literature_summary.docx."

## Demonstration 2: A Pilot Study Dataset
In the "demo_2" folder, you will find a spreadsheet containing 200 undergraduate student entries with rows for their unique identifiers (student_id), their year of study in university (year_of_study), the number of hours slept (sleep_hours), their daily caffeine intake in milligrams (caffeine_mg_daily), their stress scores on a scale of 1-10 (stress_score), their grade point average on a 4-point scale (gpa). The problems you want to try and address with Claude Code are as follows:
- There are missing values in both the sleep_hours and caffeine_mg_daily columns.
- Student S011 is an outlier with only 2 hours of sleep.
- There is a mild heteroscedasticity violation, which could influence the interpretability of the results.

You can either come up with your own prompt or try the following prompt: "I have pilot_sleep.csv — 200 students, with sleep hours, GPA, stress, caffeine, and year of study. Load it, describe the data, flag missing values or outliers, run a regression of GPA on sleep hours controlling for stress and caffeine, plot the residuals, and give me a plain-language summary."

## Demonstration 3: A Messy R Script
In the "demo_3" folder, you will find an R script in progress with a to-do list of things that should be done to tidy the script up and produce the desired figures. The problems you want to try and address with Codex are:
- The file path is hardcoded, meaning this script will fail if run on any other machine.
- Missing values are handled lazily, indiscriminate use of complete.cases(), where all rows with any NA are dropped with no pattern investigation.
- No input validation, means it assumed the file exists and columns are correct; this script will fail cryptically if that's not the case.
- The figures are unlabeled: no axis labels, placeholder titles, no captions.

You can either come up with your own prompt or try the following prompt: "Review and clean up analysis.R — fix any code quality issues you find".
