app [target] {
	fuzz: platform "https://github.com/lukewilliamboswell/roc-fuzz/releases/download/0.4.3/41NK5FShyGC9Z8HNpUdUeXMWwLmLNfFxsfmLvdPL4Fxb.tar.zst",
	pkg: "../package/main.roc",
}

import fuzz.Fuzz
import pkg.Base58

alphabet : List(U8)
alphabet = "123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz".to_utf8()

## BTC (the Bitcoin base58 rules), R-PK3: each text of alphabet characters is the
## one encode result of its bytes, so encode(decode(t)) == t.
## The generator maps each random byte b to the alphabet character at b % 58.
## B58-Q1, TW24 proposal: the text has at most 1024 bytes (the decode limit).
test : List(U8) -> Fuzz.Outcome
test = |raw| {
	text = Str.from_utf8(raw.take_first(1024).map(|b| alphabet.get((b % 58).to_u64()) ?? '1')) ?? ""
	match Base58.decode(text) {
		Ok(bytes) if Base58.encode(bytes) == text => Fuzz.keep
		_ => crash "encode(decode(t)) is not t"
	}
}

target = Fuzz.target_with({
	name: "canonical",
	generator: Fuzz.bytes,
	test,
	show: |raw| Str.inspect(raw),
})
