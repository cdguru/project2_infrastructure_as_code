#!/usr/bin/env bash

##
# Purpose: Deploy lambda zipped code
#
# Parameters:
# $1: Lambda Name
##

function change_latest() {
    
    NUEVA_VERSION=$(aws lambda publish-version --function-name $1 --query 'Version' --output text)

    CHANGE_VERSION_ACTION=$(aws lambda update-alias --function-name $1 --name $1 --function-version $NUEVA_VERSION --output text)

    CURRENT_LAMBDA_VERSION=$(aws lambda get-alias --function-name $1 --name $1 --query 'FunctionVersion' --output text)

    if [[ $CURRENT_LAMBDA_VERSION == '$LATEST' ]];
    then
        echo "### Oops, i could not changed the lambda version, i cannot continue =(, bye."
        exit 1
    else
        echo "### Done!, the new version of lambda $1 is: $CURRENT_LAMBDA_VERSION"
    fi    
}

if [ -f appspec.yaml ]; 
then

    aws lambda update-function-code --function-name $1 --zip-file fileb://lambda.zip --no-publish

    CURRENT_LAMBDA_VERSION=$(aws lambda get-alias --function-name $1 --name $1 --query 'FunctionVersion' --output text)

    if [[ $CURRENT_LAMBDA_VERSION == '$LATEST' ]];
    then
        echo '### WARNING: Version of lambda is $LATEST this will break AWS CodeDeploy, i will try to fix it.'
        change_latest $1
    fi

    TARGET_LAMBDA_VERSION=$(aws lambda publish-version --function-name $1 --query 'Version' --output text)

    if [[ $CURRENT_LAMBDA_VERSION == $TARGET_LAMBDA_VERSION ]];
    then
        echo "### Hmm: Current version and Target version are the same, are you sure there was any changes in the code??."
    else
        echo "### Current Version is: $CURRENT_LAMBDA_VERSION, Target Version is: $TARGET_LAMBDA_VERSION"
    fi

    echo "### Preparing appspec.yaml for AWS CodeDeploy"
    sed -i "s/CHANGE_NAME/$LAMBDA_FUNCTION_NAME/g" appspec.yaml
    sed -i "s/CHANGE_CURRENT_VERSION/$CURRENT_LAMBDA_VERSION/g" appspec.yaml
    sed -i "s/CHANGE_TARGET_VERSION/$TARGET_LAMBDA_VERSION/g" appspec.yaml
    echo "### appspec.yaml Done"

else
    echo "### Oh no!, appspec.yaml not found, we cannot continue."
    exit 1
fi