#!/bin/bash
BASE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source $BASE_DIR/common.sh


VERSION=${1:-}

version_input_check $VERSION
create_folders
information "Building Recomended packages"

libs=( unzip )
for lib in "${libs[@]}"
    do
        information "Installing required libs $lib"
        sudo yum install -y $lib || (error "Unable to install $lib" && exit)
    done

 

R_COMPILED_ZIP=$R_OUTPUT_FOLDER/R-compiled-$VERSION.zip

if [ ! -f "$R_COMPILED_ZIP" ]; then
	$BASE_DIR/build_r.sh $VERSION 
fi


if [ -d "$R_OUTPUT_FOLDER/$VERSION/recomended" ]; then
  	sudo rm -rf $R_OUTPUT_FOLDER/$VERSION/recomended
fi

mkdir -p $R_OUTPUT_FOLDER/$VERSION/recomended || error "Unable to create folder $R_OUTPUT_FOLDER/$VERSION/recomended"

cd $R_OUTPUT_FOLDER/$VERSION/recomended

mkdir -p R.orig/

unzip -q $R_COMPILED_ZIP -d R.orig/
mkdir -p R/library


recommended=(boot class cluster codetools foreign KernSmooth lattice MASS Matrix mgcv nlme nnet rpart spatial survival AnomalyDetection)
for package in "${recommended[@]}"
do
   mv R.orig/library/$package/ R/library/$package/
done
chmod -R 755 R/

zip -r -q $R_OUTPUT_FOLDER/recommended-$VERSION.zip R/

success "Recommended package zip located at $R_OUTPUT_FOLDER/recommended-$VERSION.zip"