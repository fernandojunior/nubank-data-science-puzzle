# Released under The MIT License
# Copyright (c) 2016 Fernando Felix do Nascimento Junior

categorical_to_numeric = function (x) {
    # Convert a categorical vector x to a numeric one
    return(as.numeric(factor(x, labels=(1:length(levels(factor(x)))))))
}


find_model = function (x, target, predictors, base=NULL) {
    # Find the best multiple linear regression model using backwards
    # elimination. Features with highest p-value (low signficante) are
    # eliminated until find the model with the highest Adjusted R-squared
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


lm_formula = function (target, predictors) {
    # Create a linear regression formula dynamically
    return(as.formula(sprintf('%s ~%s', target, paste(predictors, collapse='+'))))
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
    return(mean(x) + (y * sd(x)))
}


main = function () {
    # Load and standardize training data set
    training = read.csv('train.csv')
    training.target = training$target  # labels backup
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

    # Full linear model, all 106 training features are considered
    # Adjusted R-squared: 0.2586891
    # p-value: < 2.2e-16
    # summary(lm(formula=lm_formula('target', training_features), training))

    # Find the best linear model, i.e. with the highest Adjusted R-squared
    # Only 70 training features are considered in the model
    # Adjusted R-squared: 0.2593609
    # p-value: < 2.2e-16
    model = find_model(training, 'target', training_features)
    print(model$summary)

    # Predict and un-standardize targets of testing data
    prediction = unstandardize(predict(model, testing), training.target)

    # Save CSV file
    output = cbind(id=training$id, prediction=prediction)
    write.csv(output, 'output.csv', row.names=FALSE)
}

system.time(main())
