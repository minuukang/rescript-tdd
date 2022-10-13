type calc = Plus(int, int) | Minus(int, int) | Multiple(int, int) | Divide(int, int)
let calc = target => {
  switch target {
  | Plus(a, b) => a + b
  | Minus(a, b) => a - b
  | Multiple(a, b) => a * b
  | Divide(a, b) => a / b
  }
}
