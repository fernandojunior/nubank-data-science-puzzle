categorical_to_numeric = function (x) {
    # Convert a categorical vector x to a numeric one
    return(as.numeric(factor(x, labels=(1:length(levels(factor(x)))))))
}


find_model = function (x, target, predictors, base=NULL) {
    # Find the best multivariate linear model using backwards elimination.
    # Features with highest p-value (low signficante) are eliminated until find
    # the model with the highest adj.r.squared.
    model = lm(formula=lm_formula(target, predictors), data=x)
    model$summary = summary(model)

    if (is.null(base))
        base = model

    if (model$summary$adj.r.squared >= base$summary$adj.r.squared) {
        p.values = model$summary$coefficients[predictors, 'Pr(>|t|)']
        worst_predictor = names(sort(p.values, decreasing=TRUE)[1])
        find_model(x, target, setdiff(predictors, worst_predictor), model)
    } else {
        return(base)
    }
}


find_model.alt = function (x, target, predictors) {
    # Bad alternative to find the best multivariate linear model using brute
    # force backwards elimination. The features are eliminated at a time until
    # find the best model with the highest adj.r.squared.
    model = lm(formula=lm_formula(target, predictors), data=x)
    model$summary = summary(model)
    best = NULL
    print(predictors)

    if (length(predictors > 1)) {
        for (predictor in predictors) {
            print(paste('eliminating', predictor))
            tmp_model = lm(
                formula=lm_formula(target, setdiff(predictors, predictor)),
                data=x
            )
            tmp_model$summary = summary(tmp_model)
            if (tmp_model$summary$adj.r.squared > model$summary$adj.r.squared)
                best = tmp_model
        }
    }

    if (!is.null(best))
        find_model.alt(x, target, intersect(names(best$coefficients), features))
    else
        return(model)
}


lm_formula = function (target, predictors) {
    # Create a linear model formula dynamically
    return(as.formula(sprintf('%s ~%s', target, paste(predictors, collapse="+"))))
}


standardize = function (x) {
    # Normalize a numeric vector x using its z-score = (x-mean(x))/sd(x)
    # If x is categorical, it will be converted into a numeric one
    if (is.numeric(x))
        return(scale(x))
    else
        return(standardize(categorical_to_numeric(x)))
}


unstandardize = function (y, x) {
    # Un-standardize a vector y using a vector x as reference
    # !z-score = mean(x) + (y * sd(x))

    return(mean(x) + (y * sd(x)))
}

main = function () {

    # Load and standardize training data set
    training = read.csv('train.csv')
    training.target = training$target # backuping labels
    training_features = setdiff(colnames(training), union('id', 'target'))
    training = data.frame(cbind(
        apply(training[, union(training_features, 'target')], 2, standardize),
        id=training$id
    ))

    # Load and standardize testing data set
    testing = read.csv('test.csv')
    testing_features = setdiff(colnames(testing), c('id'))
    testing = data.frame(cbind(
        apply(testing[, testing_features], 2, standardize),
        id=testing$id
    ))

    # Find the linear model with the best adj. R squared
    model1 = find_model(training, 'target', training_features)

    model1$summary$adj.r.squared
    # [1] 0.2593609

    # Predict and un-standardize targets of testing data
    prediction = unstandardize(predict(model1, testing), training.target)

    # Save CSV file
    output = cbind(id=training$id, prediction=prediction)
    write.csv(output, 'output.csv', row.names=FALSE)

    # (Bad) alternative finding
    # model2 = find_model.alt(training, 'target', features)
    # > model1$summary$adj.r.squared == model2$summary$adj.r.squared
    # [1] TRUE
    # > all(model1$coefficients %in% model2$coefficients)
    # [1] TRUE

    # > rownames(model1$summary$coefficients)
    #  [1] "(Intercept)" "X016399044a" "X023c68873b" "X0342faceb5" "X04e7268385"
    #  [6] "X06888ceac9" "X087235d61e" "X12eda2d982" "X136c1727c3" "X174825d438"
    # [11] "X1f222e3669" "X1f3058af83" "X253eb5ef11" "X25bbf0e7e7" "X2719b72c0d"
    # [16] "X298ed82b22" "X29bbd86997" "X2d7fe4693a" "X2e874bc151" "X361f93f4d1"
    # [21] "X384bec5dd1" "X3df2300fa2" "X3e200bf766" "X435dec85e2" "X4468394575"
    # [26] "X49756d8e0f" "X4fc17427c8" "X55cf3f7627" "X56371466d7" "X5b862c0a8f"
    # [31] "X5f360995ef" "X60ec1426ce" "X6db53d265a" "X7743f273c2" "X779d13189e"
    # [36] "X7841b6a5b1" "X789b5244a9" "X8311343404" "X87b982928b" "X8a21502326"
    # [41] "X8c2e088a3d" "X8de0382f02" "X8f5f7c556a" "X91145d159d" "X96c30c7eef"
    # [46] "X96e6f0be58" "X9a575e82a4" "a24802caa5"  "aa69c802b6"  "abca7a848f"
    # [51] "aee1e4fc85"  "b4112a94a6"  "b709f75447"  "b835dfe10f"  "bdf934caa7"
    # [56] "beb6e17af1"  "c0c3df65b1"  "d2c775fa99"  "dcfcbc2ea1"  "e0a0772df0"
    # [61] "e5efa4d39a"  "e86a2190c1"  "ea0f4a32e3"  "ed7e658a27"  "ee2ac696ff"
    # [66] "f013b60e50"  "f0a0febd35"  "fdf8628ca7"  "fe0318e273"  "fe8cdd80ba"
    # [71] "ffd1cdcfc1"

}

system.time(main())

