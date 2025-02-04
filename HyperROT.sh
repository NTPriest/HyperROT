#!/bin/bash
#Author:NTPriest 
Red='\033[0;31m'
Orange='\033[38;5;214m'
NC='\033[0m' #No color

# Load alphabet from file or user input
while true; do
    read -p "Enter custom alphabet (or leave empty to load from file): " custom_alphabet

    # If user already provide custom alpha.
    if [ -n "$custom_alphabet" ]; then
        break
    fi

    # If not, look for file
    if [ -f "alphabet.txt" ]; then
        custom_alphabet=$(<alphabet.txt)
        break
    else
        echo -e "${Red}alphabet.txt not found! Please provide a custom alphabet.${NC}"
    fi
done


# checking, if alphabet is special (lack of duplicates)
if [[ ! "$custom_alphabet" =~ ^([a-zA-Z])*$ ]]; then
    echo -e "${Red}Invalid characters in alphabet! Only letters allowed.${NC}"
    exit 1
fi
# Alphabet seed for ROT operation
# You can use your own seed as you want.
alphabet=($(echo "$custom_alphabet" | grep -o .))

rot_n_simple() {
    local text="$1"
    local shift="$2"
    local result=""

    for ((i = 0; i < ${#text}; i++)); do
        char="${text:$i:1}"

        # checking if letter exist in alphabet
        for index in "${!alphabet[@]}"; do
            if [[ "${alphabet[$index]}" == "$char" ]]; then
                if [[ "$mode" == "encrypt" ]]; then
                    new_index=$(( (index + shift) % 26 ))  # Right shift 
                else
                    new_index=$(( (index - shift + 26) % 26 )) # Left shift
                fi
                result+="${alphabet[$new_index]}"
                continue 2  # exit from internal `for`
            fi
        done
        
        # if letter in alphabet, we adding him 
        result+="$char"
    done

    echo "$result"
}
# Menu
echo -e "${Orange}--- 1.Encrypt ---${NC}"
echo -e "${Orange}--- 2.Decrypt ---${NC}"
read -p "Choose option from menu: " OPTION

case $OPTION in
    1) mode="encrypt" ;;
    2) mode="decrypt" ;;
    *) echo -e "${Red}Invalid option!${NC}" && exit 1 ;;
esac

# use example 
read -p "Enter text: " input_text
while  true ; do
    read -p "Enter ROT shift (1-25): " shift
    if [[ "$shift" =~ ^[1-9]$|^[1][0-9]$|^2[0-5]$ ]]; then
        break
    else
        echo -e "${Red}Invalid shift! Please enter a number between 1 and 25.${NC}"
    fi
done
# Conversion to small letter
input_text=$(echo "$input_text" | tr '[:upper:]' '[:lower:]')

# enrcypting/decrypting ROT-N
encoded_text=$(rot_n_simple "$input_text" "$shift" "$mode")
echo -e "ROT-$shift Result: \e[38;5;208m$encoded_text\e[0m"
