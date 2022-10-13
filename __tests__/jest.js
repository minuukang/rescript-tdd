
describe("테스트 선언", () => {
  beforeEach(() => {
    console.log("beforeEach")
  })

  beforeAll(() => {
    console.log("beforeAll")
  })

  afterEach(() => {
    console.log("afterEach")
  })

  afterAll(() => {
    console.log("afterAll")
  })

  describe("테스트1", () => {
    test("무엇을 할 것 인가 1", () => {
      console.log("test 1")
      expect(1).toBe(1)
    })

    test("무엇을 할 것 인가 2", () => {
      console.log("test 2")
      expect(2).toEqual(2)
    })
  })
})