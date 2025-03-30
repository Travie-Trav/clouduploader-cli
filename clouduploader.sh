#!/bin/bash

file_path="$1"
s3_bucket="$2"

file_name=$(basename "$file_path")
echo "File name: $file_name"

# Confirm number of arguments is correct
if [ $# -ne 2 ]; then
    echo "Please provide two parameters: the file path and the S3 bucket's destination path."
    exit 1
fi

# Check if file exists
file_confirmation() {
    if [ -f "$file_path" ]; then
        echo "$file_name exists."
    else
        echo "Error: $file_name does not exist."
        exit 1
    fi
}

file_confirmation

confirm_s3_configuration() {
    echo "Checking S3 configuration..."
    if aws s3 ls "$s3_bucket" &> /dev/null; then
        echo "S3 configured. $s3_bucket available."
    else
        echo "Error: S3 configuration unavailable."
        exit 1
    fi
}

confirm_s3_configuration

# Perform upload
upload_file() {
    local src_file="$1"
    local s3_destination="$2"

    echo "Uploading $src_file to bucket $s3_destination..."

    if pv "$src_file" | aws s3 cp - "s3://$s3_destination/$file_name"; then
        echo "File upload successful."
    else
       echo "Error: File failed to upload to $s3_destination."
       exit 1
    fi
            
}

upload_file $file_path $s3_bucket
