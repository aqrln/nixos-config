#[inline(never)]
fn inspect(owned: String, slice: &str, expected: bool) {
    std::hint::black_box((&owned, slice, expected));
}

#[inline(never)]
fn conditional(value: String) {
    std::hint::black_box(value);
}

fn main() {
    for (left, right, expected) in [
        ("hello", "hello", true),
        ("hello", "world", false),
        ("hello", "hell", false),
        ("", "", true),
        ("", "hello", false),
        ("café 🦀", "café 🦀", true),
        ("a\0b", "a\0b", true),
        ("a\0b", "a\0c", false),
        ("a\0b", "a", false),
    ] {
        inspect(left.into(), right, expected);
    }
    conditional("skip".into());
    conditional("match".into());
    conditional("skip again".into());
}
