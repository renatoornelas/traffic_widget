Batman.Filters.shortenedData = (num) ->
    return num if isNaN(num)
    if num >= 1000000000000
        (num / 1000000000000).toFixed(2) + 'T'
    else if num >= 1000000000
        (num / 1000000000).toFixed(2) + 'G'
    else if num >= 1000000
        (num / 1000000).toFixed(2) + 'M'
    else if num >= 1000
        (num / 1000).toFixed(2) + 'K'
    else
        num