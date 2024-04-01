#!/bin/bash

# Check for correct usage
if [ $# -ne 1 ]; then
    echo "Usage: $(basename "$0") <filename>"
    exit 1
fi

# Configuration variables
original_file="$1"
destination_dir="/opt/php_extension_copier"
script_name="$(basename "$0")"

# Ensure script is in the correct directory and PATH is set
moveAndSetPath() {
    mkdir -p "$destination_dir"
    mv "$0" "$destination_dir/$script_name"
    chmod +x "$destination_dir/$script_name"
    if ! grep -q "$destination_dir" ~/.bashrc; then
        echo "export PATH=\$PATH:$destination_dir" >> ~/.bashrc
    fi
}

# Main operation function
copyFiles() {
    for ext in php php3 php4 php5 php7 phps phtml phar; do
        cp "$original_file" "${destination_dir}/${original_file}.$ext"
    done
    echo "Copies of $original_file with PHP extensions created in $destination_dir."
}

# Script starts here
if [[ "$(realpath "$0")" != "$destination_dir/$script_name" ]]; then
    if [ "$(id -u)" -ne 0 ]; then
        echo "Script not in $destination_dir. Please run as root to move it."
        exit 1
    fi
    moveAndSetPath
    echo "Script moved to $destination_dir. Run it again from the new location."
else
    copyFiles
fi


#One liner
#mkdir -p php_copies && for ext in php php3 php4 php5 php7 phps phtml phar; do cp your_file_here php_copies/your_file_here.$ext; done
