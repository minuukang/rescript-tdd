open Jest

describe("Utils function", () => {
  open Expect

  describe("Utils.calc", () => {
    describe(
      "Test calc plus",
      () => {
        test(
          "Should sum two values",
          () => {
            expect(Utils.calc(Plus(1, 2)))->toEqual(3)
          },
        )
      },
    )

    describe(
      "Test calc minus",
      () => {
        test(
          "Should minus two values",
          () => {
            expect(Utils.calc(Minus(1, 2)))->toEqual(-1)
          },
        )
      },
    )

    Test.todo("Should multiple two values")
    Test.todo("Should divide two values")
  })
})
