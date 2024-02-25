#!/bin/lksh
# ez működik

#  h_frac=(' ' '▏' '▎' '▍' '▌' '▋' '▊' '▉' '█')
#   h_frac=(' ' '▏' '▎' '▍' '▌' '▋' '▊' '▉')
   h_frac=(' ' '▏' '▎' '▍' '▋' '▊' )
#csikvege=(" " "▏" "▎" "▌" "▊")

csikot8()
{
    local percent=$1
    local percentmax=$2
    local hossz=$3
    local linechar=${4:-█}
    local linetop=${5:-}
    local lineback=${6:- }
    local units=${#h_frac[@]}
    local csikunits=$((hossz * units ))
    local fillsize=$(( (percent * csikunits / percentmax) * hossz / csikunits ))
    [[ $fillsize -gt $hossz ]] && fillsize=$hossz
    local fillnsize=$((hossz - fillsize - 1))
    [[ $1 -lt $percentmax ]] && linetop=${h_frac[$(( (csikunits * percent / percentmax) % units ))]}
#    ((fillsize--))
    local fill filln
    [[ $fillsize -gt 0 ]] && while ((fillsize--));do fill+="$linechar";done
    [[ $fillnsize -gt 0 ]] && while ((fillnsize--));do filln+="$lineback";done
    echo -n "[${fill}${linetop}${filln}]"
}

