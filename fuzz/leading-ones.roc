app [target] {
	fuzz: platform "https://github.com/lukewilliamboswell/roc-fuzz/releases/download/0.4.3/41NK5FShyGC9Z8HNpUdUeXMWwLmLNfFxsfmLvdPL4Fxb.tar.zst",
	pkg: "../package/main.roc",
}

import fuzz.Fuzz
import pkg.Base58

# The input: 0 to 8 zero bytes, then random bytes (which can start with more zeros).
Input := { zeros : U8, rest : List(U8) }.{
	generator_for : Fuzz.FuzzEncoding -> Fuzz.Generator(Input)
	generator_for = |_| { zeros: Fuzz.u8_in(0, 8), rest: Fuzz.bytes }.Fuzz
}

# The count of the leading items that are equal to `x`.
count_leading : List(U8), U8 -> U64
count_leading = |items, x| items.fold_until(0, |n, item| if item == x Continue(n + 1) else Break(n))

## BTC (the Bitcoin base58 rules), R-PK3: each leading zero byte is one leading `1`,
## so the count of leading `1` in encode(b) is the count of leading zero bytes of b
test : Input -> Fuzz.Outcome
test = |input| {
	bytes = List.repeat(0, input.zeros.to_u64()).concat(input.rest)
	ones = count_leading(Base58.encode(bytes).to_utf8(), '1')
	if ones == count_leading(bytes, 0) Fuzz.keep else crash "the count of leading 1 is not the count of leading zero bytes"
}

target = Fuzz.target_with({
	name: "leading-ones",
	generator: Input.generator_for(Default),
	test,
	show: |input| Str.inspect(input),
})
