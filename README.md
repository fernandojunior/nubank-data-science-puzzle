# Nubank Data Science Puzzle

A solution for the NuBank Puzzle.

Basic algorithm to get it:

1. Load the training and testing data sets
2. For each data set, convert categorical features to numeric, then standardize
all features.
3. Using training set, find the best (highest Adjusted R-squared) linear model
by eliminating lower significant coefficients
4. Predict the testing data set using the model
5. Un-standardize and save predictions

According to the results, the found model is significant with p-value
 < 2.2e-16, has adjusted R-squared = 0.2593609, and uses only 70 features.
The average of execution time is about 80 seconds on my machine.

>
The Nubank Puzzle is a short modeling assignment that is typical of some of the work done at Nubank.
>
The ZIP archive contains 3 CSV files: train.csv, test.csv, and sample_submission.csv. train.csv contains a column called id which uniquely identifies each row, several columns identified by hexadecimal strings, and a column target which we would like for you to predict. Columns that contain SHA-256 hashes for their values represent categorical variables, while the rest of the variables are numeric. test.csv has the same column names and data types as train.csv, but it is missing the target column. There are no missing values or data corruption problems in either of these files. Do not worry about the meanings of the variables or the metadata -- this is an artificial dataset.
>
Any programming language and modeling approach can be choice. You will be evaluated primarily on the R2 of your predictions against the true values in the test set, but the accuracy of your estimate of your R2 will also be considered.
>
Please submit your predictions as a CSV file. You should include a header with columns as below and put the id and your predicted target for each corresponding row from the test.csv file. sample_submission.csv gives an example of what your submission file should look like.
>
id,prediction
>
Please submit your prediction CSV file and source code we can use to reproduce your submission in a ZIP file. Please put your prediction CSV file in the root of the archive. The only file in the archive with a .csv file extension should be your predictions.
>
To submit your solution, please email ----- ---- at ----------@------.---.-- with a short explanation of what you did and what you expect the R2 to be for your predictions, and attach the ZIP file with your predictions and source code. If you have any feedback or questions, feel free to email ----- as well.

## License

[![CC0](https://i.creativecommons.org/l/by-nc-sa/4.0/88x31.png)](https://creativecommons.org/licenses/by-nc-sa/4.0/)

The source code `source.R` is released under The MIT License.

-

Copyright (c) 2014-2016 [Fernando Felix do Nascimento Junior](https://github.com/fernandojunior/).
