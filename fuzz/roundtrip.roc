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

## TESTING.md 4 (L1 target of roc-base58), R-PK3: decode(encode(b)) == Ok(b),
## so each leading zero byte is kept. B58-Q1, TW24 proposal: b has at most
## 749 bytes, so encode(b) has at most 1024 bytes (the decode limit).
test : Input -> Fuzz.Outcome
test = |input| {
	bytes = List.repeat(0, input.zeros.to_u64()).concat(input.rest).take_first(749)
	if Base58.decode(Base58.encode(bytes)) == Ok(bytes) Fuzz.keep else crash "round trip failed"
}

target = Fuzz.target_with({
	name: "roundtrip",
	generator: Input.generator_for(Default),
	test,
	show: |input| Str.inspect(input),
})
