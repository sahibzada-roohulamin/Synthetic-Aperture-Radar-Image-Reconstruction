function compressed = rangeCompression(tx, rx)

matchedFilter = conj(fliplr(tx));

compressed = conv(rx, matchedFilter, 'same');

end