open Jest

describe("ReactHook module test", () => {
  open! Expect
  open! ReactHook

  describe("Test ReactHook.useFetchPokemon", () => {
    describe(
      "When fetch success",
      () => {
        Test.todo("Should return Success variant with data")
      },
    )

    describe(
      "When fetch failure",
      () => {
        Test.todo("Should return Error variant with error status")
      },
    )
  })
})
