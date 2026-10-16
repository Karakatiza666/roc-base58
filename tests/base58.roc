app [main!] { pkg: "../package/main.roc" }

import pkg.Base58

main! = |_args| Ok({})

# Sources of the rules in this file:
# - R-PK3 (Talon DESIGN.md 6.1): encode and decode, the Bitcoin alphabet.
# - BTC: the Bitcoin base58 rules. The alphabet is the 58 characters below,
#   in this order (digit value 0 to 57). The text is the bytes as one
#   big-endian number in base 58, most significant digit first. Each leading
#   zero byte is one leading `1`. Decode rejects a character outside the
#   alphabet.
# - TW24 (Talon TESTING.md 7.3): the errors of decode. The design does not
#   name them. Accepted at the review (2026-10-16): `InvalidChar(index)`, the
#   index of the first bad byte. Answer to B58-Q1 (decode needs a length
#   limit), with the proposed limit and tag: a text of more than 1024 UTF-8
#   bytes gives `TooLong(length)`, and this check is first.
alphabet : Str
alphabet = "123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz"

# The byte values 0 to 57, in order.
digit_values : List(U8)
digit_values = U8.until(0, 58).fold([], |acc, i| acc.append(i))

# R-PK3, BTC: the byte value i (below 58) encodes to the digit at index i of the alphabet
expect digit_values.map(|i| Base58.encode([i])) == alphabet.to_utf8().map(|c| Str.from_utf8([c]) ?? "?")

# R-PK3, BTC: the digit at index i of the alphabet decodes to the byte value i
expect alphabet.to_utf8().map(|c| Base58.decode(Str.from_utf8([c]) ?? "?")) == digit_values.map(|i| Ok([i]))

# R-PK3, BTC: the first and the last digit
expect Base58.encode([0]) == "1"
expect Base58.encode([57]) == "z"

# R-PK3, BTC: 58 is two digits, most significant first: 1 * 58 + 0
expect Base58.encode([58]) == "21"
expect Base58.decode("21") == Ok([58])

# R-PK3, BTC: a `1` that is not leading is the digit 0: "z1" is 57 * 58 = 3306 = 0x0CEA
expect Base58.encode([12, 234]) == "z1"
expect Base58.decode("z1") == Ok([12, 234])

# R-PK3, BTC: the empty list and the empty text
expect Base58.encode([]) == ""
expect Base58.decode("") == Ok([])

# R-PK3, BTC: each leading zero byte is one leading `1`
expect Base58.encode([0, 0, 0]) == "111"
expect Base58.encode([0, 0, 1]) == "112"
expect Base58.encode([0, 58]) == "121"

# R-PK3, BTC: each leading `1` is one leading zero byte, so decode keeps them
expect Base58.decode("1") == Ok([0])
expect Base58.decode("111") == Ok([0, 0, 0])
expect Base58.decode("112") == Ok([0, 0, 1])
expect Base58.decode("121") == Ok([0, 58])

# R-PK3, BTC: the 4 letters and digits that are not in the alphabet: 0, O, I, l
expect Base58.decode("0") == Err(InvalidChar(0))
expect Base58.decode("O") == Err(InvalidChar(0))
expect Base58.decode("I") == Err(InvalidChar(0))
expect Base58.decode("l") == Err(InvalidChar(0))

# R-PK3, BTC: characters of other encodings (base64, a sign) are not in the alphabet
expect Base58.decode("ab+c") == Err(InvalidChar(2))
expect Base58.decode("ab/c") == Err(InvalidChar(2))
expect Base58.decode("abc=") == Err(InvalidChar(3))
expect Base58.decode("-2g") == Err(InvalidChar(0))

# R-PK3, BTC: whitespace is not in the alphabet, also at the start or the end
expect Base58.decode(" 2g") == Err(InvalidChar(0))
expect Base58.decode("2g ") == Err(InvalidChar(2))
expect Base58.decode("2g\n") == Err(InvalidChar(2))
expect Base58.decode("2 g") == Err(InvalidChar(1))

# TW24 (accepted): the error names the first bad byte when there are more
expect Base58.decode("2l0") == Err(InvalidChar(1))
expect Base58.decode("a3gV0O") == Err(InvalidChar(4))

# TW24 (accepted): the index counts UTF-8 bytes, not characters ("é" is 2 bytes)
expect Base58.decode("2é") == Err(InvalidChar(1))
expect Base58.decode("éé2") == Err(InvalidChar(0))
expect Base58.decode("22€") == Err(InvalidChar(2))

# B58-Q1, TW24 proposal: the limit. 1024 bytes is the longest text that decode accepts
expect Base58.decode("1".repeat(1024)) == Ok(List.repeat(0, 1024))
expect Base58.decode("1".repeat(1023).concat("2")) == Ok(List.repeat(0, 1023).append(1))

# B58-Q1, TW24 proposal: one byte past the limit gives TooLong with the length of the text
expect Base58.decode("1".repeat(1025)) == Err(TooLong(1025))

# B58-Q1, TW24 proposal: the length check is first, before the alphabet check
expect Base58.decode("0".concat("1".repeat(1024))) == Err(TooLong(1025))

# B58-Q1, TW24 proposal: a bad byte at the last index inside the limit
expect Base58.decode("1".repeat(1023).concat("0")) == Err(InvalidChar(1023))

# B58-Q1, TW24 proposal: the limit counts UTF-8 bytes ("é" is 2 bytes)
expect Base58.decode("é".repeat(512)) == Err(InvalidChar(0))
expect Base58.decode("é".repeat(512).concat("1")) == Err(TooLong(1025))

# B58-Q1, TW24 proposal, R-PK3: 749 bytes of 0xFF (the largest number of 749
# bytes) encode to 1023 bytes, inside the limit, so they decode back
expect {
	bytes = List.repeat(255, 749)
	text = Base58.encode(bytes)
	text.count_utf8_bytes() <= 1024 and Base58.decode(text) == Ok(bytes)
}
