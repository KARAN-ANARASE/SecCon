#!/bin/bash
black='\e[38;5;016m'
bluebg='\e[48;5;038m'${black}
red='\e[31m'
lightred='\e[91m'
blink='\e[5m'
lightblue='\e[38;5;109m'
green='\e[32m'
greenbg='\e[48;5;038m'${black}
yellow='\e[33m'
logo='\033[0;36m'
upper="${lightblue}╔$(printf '%.0s═' $(seq "80"))╗${end}"
lower="${lightblue}╚$(printf '%.0s═' $(seq "80"))╝${end}"
right=$(printf '\u2714')
cross=$(printf '\u2718')
end='\e[0m'
process_file() {
    local file="$1"


    # Get unique IPs
    zcat "$file" 2>/dev/null | jq -r 'select(.ip_str != null) | .ip_str' | sort -u | while read -r IP; do
        [ -z "$IP" ] && continue

        # Extract data **per IP**
        OS=$(zcat "$file" | jq -r --arg ip "$IP" 'select(.ip_str == $ip and .os != null) | .os' | sort -u | tr '\n' ',' | sed 's/,$//')
        ORG=$(zcat "$file" | jq -r --arg ip "$IP" 'select(.ip_str == $ip and .org != null) | .org' | sort -u | tr '\n' ',' | sed 's/,$//')
        PORT=$(zcat "$file" | jq -r --arg ip "$IP" 'select(.ip_str == $ip and .port != null) | .port' | sort -u | tr '\n' ',' | sed 's/,$//')
        SERVER=$(zcat "$file" | jq -r --arg ip "$IP" 'select(.ip_str == $ip) | .http.server // empty' | sort -u | tr '\n' ',' | sed 's/,$//')
        PRODUCT=$(zcat "$file" | jq -r --arg ip "$IP" 'select(.ip_str == $ip and .product != null) | .product' | sort -u | tr '\n' ',' | sed 's/,$//')
        HOSTNAME=$(zcat "$file" | jq -r --arg ip "$IP" 'select(.ip_str == $ip and .hostnames != null) | .hostnames[]' | sort -u | tr '\n' ',' | sed 's/,$//')
        CVE=$(zcat "$file" | jq -r --arg ip "$IP" '
            select(.ip_str == $ip and .vulns != null) |
            .vulns | to_entries[]?.key // empty
        ' 2>/dev/null | sort -u | tr '\n' ',' | sed 's/,$//')

        printf "[${right}] ${red}%s${end}\n" "$IP"
        printf "\t┌${bluebg}OS${end}\t\t────>\t %s\n" "${OS:-${yellow}No results found${end}}"
        printf "\t├${bluebg}HOST${end}\t\t────>\t %s\n" "${HOSTNAME:-${yellow}No results found${end}}"
        printf "\t├${bluebg}ORGS${end}\t\t────>\t %s\n" "${ORG:-${yellow}No results found${end}}"
        printf "\t├${bluebg}PORTS${end}\t\t────>\t %s\n" "${PORT:-${yellow}No results found${end}}"
        printf "\t├${bluebg}SERVERS${end}\t────>\t %s\n" "${SERVER:-${yellow}No results found${end}}"
        printf "\t├${bluebg}PRODUCTS${end}\t────>\t %s\n" "${PRODUCT:-${yellow}No results found${end}}"
        printf "\t└${bluebg}CVE VULNs${end}\t────>\t %s\n\n" "${CVE:-${yellow}No results found${end}}"
    done
}

for x in *.json.gz; do
    process_file "$x"
done
