## Base58 text for bytes, with the Bitcoin alphabet:
## `123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz`.
##
## The text is the bytes as one big-endian number in base 58, with the most
## significant digit first. Each leading zero byte is one leading `1`.
Base58 :: [].{

	## The base58 text of the bytes. Each leading zero byte gives one leading `1`.
	## An empty list gives the empty text.
	encode : List(U8) -> Str
	encode = |bytes| {
		zeros = count_leading(bytes, 0)
		digits = bytes.drop_first(zeros).fold([], |acc, b| mul_add(acc, 256, 58, b.to_u32()))
		chars = digits.rev().map(|d| alphabet.get(d.to_u64()) ?? '1')
		# Each byte is an ASCII character of the alphabet, so the UTF-8 is valid.
		Str.from_utf8_lossy(List.repeat('1', zeros).concat(chars))
	}

	## The bytes of base58 text. Each leading `1` gives one leading zero byte.
	## The empty text gives the empty list.
	##
	## A text longer than 1024 UTF-8 bytes gives `Err(TooLong(length))`, where
	## `length` is the count of UTF-8 bytes of the text. The cost of decode grows
	## with the square of the length, so the limit protects a caller that
	## decodes text from other people. Each list of at most 749 bytes encodes
	## to at most 1024 bytes. This check is first.
	##
	## A byte of the text that is not in the alphabet gives
	## `Err(InvalidChar(index))`, where `index` is the position of the first
	## such byte in the UTF-8 bytes of the text. Whitespace is not in the
	## alphabet.
	decode : Str -> Try(List(U8), [InvalidChar(U64), TooLong(U64)])
	decode = |text| {
		length = text.count_utf8_bytes()
		if length > max_text_len {
			return Err(TooLong(length))
		}
		chars = text.to_utf8()
		match chars.find_first_index(|c| digit_value(c).is_err()) {
			Ok(index) => Err(InvalidChar(index))
			Err(NotFound) => Ok(digits_to_bytes(chars.map(|c| digit_value(c) ?? 0)))
		}
	}
}

# The digit characters, in order of digit value (0 to 57).
alphabet : List(U8)
alphabet = "123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz".to_utf8()

# The longest text, in UTF-8 bytes, that decode accepts.
max_text_len : U64
max_text_len = 1024

# The digit value of one character of the alphabet.
digit_value : U8 -> Try(U8, [NotFound])
digit_value = |c| alphabet.find_first_index(|a| a == c).map_ok(|i| i.to_u8_wrap())

# The count of the leading items that are equal to `x`.
count_leading : List(U8), U8 -> U64
count_leading = |items, x| items.fold_until(0, |n, item| if item == x Continue(n + 1) else Break(n))

# The bytes of base58 digit values. Each leading digit 0 gives one zero byte.
digits_to_bytes : List(U8) -> List(U8)
digits_to_bytes = |values| {
	zeros = count_leading(values, 0)
	bytes = values.drop_first(zeros).fold([], |acc, v| mul_add(acc, 58, 256, v.to_u32()))
	List.repeat(0, zeros).concat(bytes.rev())
}

# The number `digits * factor + add`, as digits in base `radix`, least
# significant first. Each digit of the input is below `radix`.
mul_add : List(U8), U32, U32, U32 -> List(U8)
mul_add = |digits, factor, radix, add| {
	var $carry = add
	var $out = List.with_capacity(digits.len() + 2)
	for d in digits {
		v = d.to_u32() * factor + $carry
		$out = $out.append((v % radix).to_u8_wrap())
		$carry = v // radix
	}
	while $carry > 0 {
		$out = $out.append(($carry % radix).to_u8_wrap())
		$carry = $carry // radix
	}
	$out
}
