open Jest

describe("ReactHook module test", () => {
  open! Expect
  open! ReactHook

  describe("Test ReactHook.useFetchPokemon", () => {
    describe(
      "When fetch success",
      () => {
        testPromise(
          "Should return Success variant with data",
          async () => {
            let response = {name: "pikachu"}
            let scope =
              Nock.make("https://pokeapi.co")
              ->Nock.get(`/api/v2/pokemon/pikachu`)
              ->Nock.replyAny(200, response)
            let hook = ReactTestingLibrary.renderHook(() => useFetchPokemon(~name="pikachu"))
            expect(hook.result.current)->toEqual(Loading)
            await TestingLibrary.waitFor(
              () => {
                expect(scope->Nock.isDone)->toBe(true)->Promise.resolve
              },
            )
            expect(hook.result.current)->toEqual(Success({name: "pikachu"}))
            scope->Nock.done
          },
        )
      },
    )

    describe(
      "When fetch failure",
      () => {
        testPromise(
          "Should return Error variant with error status",
          async () => {
            let scope =
              Nock.make("https://pokeapi.co")
              ->Nock.get(`/api/v2/pokemon/pikachu2222`)
              ->Nock.reply(404)
            let hook = ReactTestingLibrary.renderHook(() => useFetchPokemon(~name="pikachu2222"))
            expect(hook.result.current)->toEqual(Loading)
            await TestingLibrary.waitFor(
              () => {
                expect(scope->Nock.isDone)->toBe(true)->Promise.resolve
              },
            )
            expect(hook.result.current)->toEqual(Error(404))
            scope->Nock.done
          },
        )
      },
    )
  })
})
