app [target] {
	fuzz: platform "https://github.com/lukewilliamboswell/roc-fuzz/releases/download/0.4.3/41NK5FShyGC9Z8HNpUdUeXMWwLmLNfFxsfmLvdPL4Fxb.tar.zst",
	pkg: "../package/main.roc",
}

import fuzz.Fuzz
import pkg.Base58

alphabet : List(U8)
alphabet = "123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz".to_utf8()

# The input: a prefix of `len` alphabet characters (0 to 2100), then random text.
# The prefix repeats the digits (each random byte b gives the character at
# b % 58), or the alphabet when there are no digits. So some inputs are valid,
# some are not, and about half are longer than the limit of 1024 bytes.
Input := { len : U64, digits : List(U8), rest : Str }.{
	generator_for : Fuzz.FuzzEncoding -> Fuzz.Generator(Input)
	generator_for = |_| { len: Fuzz.u64_in(0, 2100), digits: Fuzz.bytes, rest: Fuzz.str }.Fuzz
}

# `len` alphabet characters that repeat the characters of the digits.
prefix_of : Input -> Str
prefix_of = |input| {
	base = if input.digits.is_empty() alphabet else input.digits.map(|b| alphabet.get((b % 58).to_u64()) ?? '1')
	chars = U64.until(0, input.len).fold([], |acc, i| acc.append(base.get(i % base.len()) ?? '1'))
	Str.from_utf8(chars) ?? ""
}

## TESTING.md 4 ("never crashes"), R-PK3, BTC, TW24: decode never crashes on
## any text. B58-Q1 (proposal): a text of n > 1024 bytes gives Err(TooLong(n)).
## Else it gives Err(InvalidChar(i)) when byte i is the first byte that is not
## in the alphabet (accepted), and Ok when there is no such byte.
test : Input -> Fuzz.Outcome
test = |input| {
	text = prefix_of(input).concat(input.rest)
	n = text.count_utf8_bytes()
	first_bad = text.to_utf8().find_first_index(|c| !alphabet.contains(c))
	match (Base58.decode(text), first_bad) {
		(Err(TooLong(m)), _) if n > 1024 and m == n => Fuzz.keep
		(Ok(_), Err(NotFound)) if n <= 1024 => Fuzz.keep
		(Err(InvalidChar(i)), Ok(j)) if n <= 1024 and i == j => Fuzz.keep
		_ => crash "decode result does not agree with the length and the first byte outside the alphabet"
	}
}

target = Fuzz.target_with({
	name: "decode-total",
	generator: Input.generator_for(Default),
	test,
	show: |input| Str.inspect(input),
})
