# Functional Rust

* Intro
* Rvalue Referenzen, Konstruktoren und Immutability
* Traits und Trait bounds (wie C++ Concepts)
* Race Conditions != Data Races
* Anonyme Funktionen und pythonige Iteratoren

# Intro - Variablendeklaration

```c++
typ variablenname = initialer_wert;
```

```rust
let variablenname: typ = initialer_wert;
let s: String = String::new();
```

# Intro - Variablendeklarationen

`typ` kann (meist) auch weggelassen werden:

```c++
auto variablenname = initialer_wert;
```

```rust
let x = String::new();
```

# Intro - Funktionen

```rust
fn funktionsname(arg0: Typ0, arg1: Typ1) -> ReturnTyp {
    // Körper
}
```

# Inference

Spätere Funktionsaufrufe schränken Typen ein

```rust
fn foo(y: u8) { /* `y` verwenden */ }
let x = 42; // x hat typ `u8`
foo(x);
let y = 42; // y hat typ `i32` (fallback)
```

# Expressions

Funktionen können oft ohne `return` oder Variablen geschrieben werden

```rust
// gibt x² zurück
fn square(x: u64) -> u64 { x * x }
fn fibonacci(i: u64) -> u64 {
    // if Bedingung ohne Klammern
    if i <= 1 {
        1
    } else {
        fibonacci(i - 1) + fibonacci(i - 2)
    }
}
```

# Expressions

Jede Expression kann überall verwendet werden wo Expressions erwartet werden

```c++
// Spezialsyntax in C++
auto x = (y < z) ? a : b;
```

```rust
// Wiederverwendung von `if` Bedingungen in Rust
let x = if y < z {
    a
} else {
    b
};
```

# Functional Rust

* Intro
* **Rvalue Referenzen**, Konstruktoren und Immutability
* Traits und Trait bounds (wie C++ Concepts)
* Race Conditions != Data Races
* Anonyme Funktionen und pythonige Iteratoren

# Rvalue Referenzen

Gibt's nicht in Rust

`std::move` ist direkt in der Zuweisung eingebaut

# Rvalue Referenzen

```c++
auto s = std::string("foo");
auto s2 = std::move(s); // `s` ist jetzt ""
```

```rust
let s = String::from("foo");
let s2 = s; // `s` ist jetzt "weg"
```

# Rvalue Referenzen

```c++
auto s = std::string();
auto s2 = std::move(s);
auto s3 = std::move(s); // ok
```

```rust
let s = String::new();
let s2 = s;
let s3 = s; // Fehler
```

# Ownership

* typestate (Yemini et al (1986)) für alle Variablen
    * uninitialisiert oder nicht mehr initialisiert
    * initialisiert
    * borrowed

```rust
let s = String::new();
let slice = &s; // Zeiger auf `s`
let s2 = s; // Fehler
let slice2 = slice;
```

# Borrowing

* Zeiger in Rust heißen "Referenzen"
* Einhalten der Zeigergültigkeitsregeln durch statische Analysen
* Funktionsschnittstellen als Grenze
* Dokumentieren von Zeigerannahmen in Funktionsschnittstelle

# Borrowing

```rust
fn foo() -> &i32 {
    let x = 42;
    return &x; // Fehler, dangling pointer
}
```

# Borrowing

```rust
struct Foo {
    x: i32,
}
fn foo(bar: &Foo) -> &i32 {
    let y = 42;
    return &y; // Fehler, dangling pointer
    return &bar.x;
}
```

# Borrowing

```rust
struct Foo {
    x: i32,
}
fn foo(bar: &Foo, asdf: &Foo) -> &i32 { // Fehler
    // beliebiger Körper
}
```

# Borrowing

```rust
struct Foo {
    x: i32,
}
fn foo<'a, 'b>(bar: &'a Foo, asdf: &'b Foo) -> &'a i32 {
    return &bar.x; // ok
    return &asdf.x; // Fehler
}
```

# Borrowing

```rust
struct Foo {
    x: i32,
}
fn foo<'a>(bar: &'a Foo, asdf: &'a Foo) -> &'a i32 {
    return &bar.x; // ok
    return &asdf.x; // ok
}
```

# Borrowing

```rust
struct Foo {
    x: i32,
}
fn foo<'a, 'b>(bar: &'a Foo, asdf: &'b Foo) -> &'a i32 {
    // körper für Aufrufer irrelevant
}
let mut z = Foo { x: 42 };
let mut y = Foo { x: 99 };
let tmp = foo(&z, &y); // 'a lifetime bindet `z` an `tmp`
z.x = 0; // fehler: aliasing Regeln misachtet
y.x = 0; // ok
```

# Functional Rust

* Intro
* Rvalue Referenzen, **Konstruktoren** und Immutability
* Traits und Trait bounds (wie C++ Concepts)
* Race Conditions != Data Races
* Anonyme Funktionen und pythonige Iteratoren

# Konstruktoren

Gibt's nicht in Rust

Stattdessen: "Named constructor idiom"

# Konstruktoren

```c++
class Rechteck {
    int32_t breite;
    int32_t hoehe;
public:
    static Rechteck quadrat(int32_t seitenlaenge) {
        return Rechteck { seitenlaenge, seitenlaenge };
    }
};
```

```rust
struct Rechteck {
    breite: i32,
    hoehe: i32,
}
impl Rechteck {
    pub fn quadrat(seitenlaenge: i32) -> Rechteck {
        Rechteck {
            hoehe, seitenlaenge,
            breite: seitenlaenge,
        }
    }
}
```

# Functional Rust

* Intro
* Rvalue Referenzen, Konstruktoren und **Immutability**
* Traits und Trait bounds (wie C++ Concepts)
* Race Conditions != Data Races
* Anonyme Funktionen und pythonige Iteratoren

# Immutability

```c++
const int i = 42;
int j = 55;
```

```rust
let i = 42;
let mut j = 55;
```

# Immutable References

```rust
let mut i = 42;
let ptr = &i;
i = 5; // Fehler
let j = *ptr;
```

# Functional Rust

* Intro
* Rvalue Referenzen, Konstruktoren und Immutability
* **Traits und Trait bounds (wie C++ Concepts)**
* Race Conditions != Data Races
* Anonyme Funktionen und pythonige Iteratoren

# Traits und Trait bounds

* wie C++ Concepts
* wie Haskell Typeclasses
* wie Java Interfaces

# Traits: Copy "Konstruktor"

```rust
struct Foo {
    i: i32,
}
impl Copy for Foo {}
struct Bar {
    s: String,
}
impl Copy for Bar {} // Fehler
```

# Traits: Copy

```rust
struct Foo {
    i: i32,
}
impl Copy for Foo {}

let x = Foo { i: 99 };
let y = x;
let z = x; // OK
```

# Traits & Methoden

```rust
struct Foo {
    i: i32,
}
impl Add for Foo {
    fn add(self, other: Foo) -> Foo {
        Foo {
            i: self.i + other.i,
        }
    }
}
```

# Traits bounds

```c++
template<typename T> auto foo(T t) {
    T u = t;
    T v = t;
}
```

```rust
fn foo<T: Copy>(t: T) {
    let u = t;
    let v = t;
}
```

# Functional Rust

* Intro
* Rvalue Referenzen, Konstruktoren und Immutability
* Traits und Trait bounds (wie C++ Concepts)
* **Race Conditions != Data Races**
* Anonyme Funktionen und pythonige Iteratoren

# Race Conditions != Data Races

Zur Errinnerung:

* Data Race: Undefined Behavior durch gleichzeitigen Zugriff auf Speicher
* Race Condition: kein deterministisches Verhalten aber Speichersicher

Rust
* verhindert Data Races
* Race Conditions, Deadlocks, Livelocks, ... weiterhin möglich

# Data Race Verhinderung

* `Sync` Trait
    * Objekte von `Sync` Typen dürfen gleichzeitig von mehreren Threads verwendet werden
    * z.B. `AtomicU32` oder `Mutex<T>`
* `Send` Trait
    * Besitz von Objekten von `Send` Typen darf über Threadgrenzen weitergegeben werden
    * z.B. `String` oder `File`

# Sync

```c++
static Mutex FOO;
static int32_t FOO_VALUE = 42;

// thread 1
auto guard = std::scoped_lock(FOO);
FOO_VALUE += 3;

// thread 2
auto guard = std::scoped_lock(FOO);
FOO_VALUE -= 3;
```

Am Ende ist `FOO_VALUE` garantiert `42`.

`FOO` Zugriff kann vergessen werden

# Sync

```rust
static FOO: Mutex<i32> = Mutex::new(42);

// thread 1
let guard = FOO.lock().unwrap();
*guard += 3;

// thread 2
let guard = FOO.lock().unwrap();
*guard -= 3;
```

Am Ende ist `FOO` garantiert `42`.

Kein Zugriff auf Daten ohne `lock` möglich.

# Send

```rust
let s = String::new();
// Anonyme funktion als argument zur `spawn` Funktion
std::thread::spawn(|| {
    // besitz an anderen thread weitergegeben
    let t = s;
});
let u = s; // Fehler
```

# Functional Rust

* Intro
* Rvalue Referenzen, Konstruktoren und Immutability
* Traits und Trait bounds (wie C++ Concepts)
* Race Conditions != Data Races
* **Anonyme Funktionen** und pythonige Iteratoren

# Anonyme Funktionen

```c++
auto square = [](auto x) { return x * x; };
```

```rust
let square = |x| x * x;
```

# Closure/Capture

Anonyme Funktionen haben Zugriff auf ihre Umgebung:

```c++
std::vector<int32_t> ints;
auto foo = [&](auto x) { ints.push_back(x); };
foo(5);
foo(42);
```

```rust
let mut ints = Vec::new();
let mut foo = |x| ints.push(x);
foo(5);
foo(42);
```

# Closure/Capture by ownership

Anonyme Funktionen haben Zugriff auf ihre Umgebung:

```c++
std::vector<int32_t> ints;
auto foo = [ints = move(ints)] (auto x) mutable {
    // element hinten anhängen
    ints.push_back(x);
    // ausgabe der Vektorlänge
    cout << ints.size() << endl;
};
foo(5); // `5` wird nicht an `ints` angehängt, sondern es wird aus `ints` gemoved
foo(42);
```

```rust
let ints = Vec::new();
// nach initialisierung von `foo` ist `ints` nicht mehr verfügbar
let mut foo = move |x| {
    // element hinten anhängen
    ints.push(x);
    // ausgabe der Vektorlänge
    dbg!(ints.len());
};
foo(5);
foo(42);
```

# Closure/Capture Regeln

* C++: explizit
    * direkte Auflistung oder "catch all" mit `=` bzw `&`
* Rust: implizit
    * durch Ownership ist späteres Nutzen von capture-Variablen nicht möglich

# Functional Rust

* Intro
* Rvalue Referenzen, Konstruktoren und Immutability
* Traits und Trait bounds (wie C++ Concepts)
* Race Conditions != Data Races
* Anonyme Funktionen und **pythonige Iteratoren**

# pythonige Iteratoren

```rust
let vec = /* create Vec */;
// does not actually iterate
let odd_numbers = vec.iter().filter(|x| x % 2 == 0);
// does not actually iterate
let odd_not_10s = odd_numbers.filter(|x| x % 10 != 0);
// iterates and sums up
let summe = odd_not_10s.sum();
```

# Projections

```rust
struct Officer {
    id: i32,
    name: String,
}
let vec = /* create Vec */;
let ids_of_spocks: Vec<i32> = vec
    // does not actually iterate
    .filter(|officer| officer.name == "Spock")
    // does not actually iterate
    .map(|officer| officer.id)
    // iterates and creates a *new* vector
    .collect();
```

# Funktionale Iteratoren

```rust
let a = [1, 2, 3];

let sum = a.iter()
    // start wert + fold-closure
    .fold(0, |acc, x| acc + x);

assert_eq!(sum, 6);
```

# Ausblick

* `async`/`await`
* generatoren & `yield`
* value generics

# Zusammenfassung

* Rust enthält kaum innovative Features
    * Umgesetzte Features sind jedoch first-class Konstrukte
    * Zentrales Feature: Ownership
* Funktionale Aspekte sind nicht per Definition "pure"
    * purity ist jedoch in der API erzwingbar
* Escape-Hatch: `unsafe`
    * Nutzer können eigene Abstraktionen bauen

# Doktorand ab sofort gesucht

<table>
<tr><td colspan=2>Thema: 3D-Partikeltracking in Flammen mit Highspeed-Lichtfeldkamera</td></tr>
<tr><td><img src="image001.png" width=300/></td><td><img src="image002.png" width=700/></td></tr>
</table>
