open! Jest

JestJs.mock("../src/ReactHook.bs.js")

@module("../src/ReactHook.bs.js")
external mockUseFetchPokemon: Mock.t<string => ReactHook.fetchType, string, ReactHook.fetchType> =
  "useFetchPokemon"

describe("test ReactComponent module", () => {
  open! Expect
  open! TestingLibrary.JestExpect

  beforeEach(() => {
    mockUseFetchPokemon->Mock.mockReturnValue(
      Success({
        name: "pikachu",
      }),
    )
  })

  afterEach(() => {
    mockUseFetchPokemon->Mock.mockClear
  })

  testPromise("test search pokemon", async () => {
    ReactTestingLibrary.render(<ReactComponent />)->ignore
    let event = EventTestingLibrary.setup()
    let input =
      DomTestingLibrary.screen->DomTestingLibrary.ByPlaceholderText.get("Enter pokemon name")
    await (event->EventTestingLibrary.type_(input, "pikachu"))
    await (
      event->EventTestingLibrary.click(
        DomTestingLibrary.screen->DomTestingLibrary.ByDisplayValue.get("Search"),
      )
    )

    await TestingLibrary.waitFor(
      async () => {
        DomTestingLibrary.screen->DomTestingLibrary.ByRole.find("search")->ignore
      },
    )

    expect(
      await (
        DomTestingLibrary.screen->DomTestingLibrary.ByRole.findWithOption(
          "heading",
          {
            level: 1,
          },
        )
      ),
    )->toHaveTextContent("pikachu")
  })
})
