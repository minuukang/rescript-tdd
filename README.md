# Rescript Jest Mocking

사이드 이펙트가 없는 모듈을 테스트하는것이 가장 이상적이고 행복한 테스트지만, 현실은 녹록치 않습니다. 특히나 컴포넌트나 외부 모듈이 함께 들어있는 경우 사이드 이펙트가 배로 늘어나게 되고, 내가 의도치 않은 테스트 결과가 언제든지 나올 수 있습니다. 이러한 **외부 모듈은 각각의 유닛 테스트로 결과를 보장한다고 가정하고**, 내가 테스트하고자 하는 모듈만을 순수하게 테스트하기 위해서 모킹을 잘하는 것이 중요합니다.

# 모킹 함수에 대하여

테스트하고자 하는 모듈에 의존적으로 넘기는 함수나 해당 모듈에서 사이드 이펙트로 다루고 있는 함수를 감시(spy)하는 역할입니다. 해당 함수가 정상적으로 호출되었는지 / 원하는 인자로 호출되었는지를 테스트할 수 있습니다.

## 모킹 함수 생성

```reason
open Jest

let mockFn = Mock.empty() // 인자가 없는 함수
let mockFn1 = Mock.make(_ => ()) // 인자가 있는 함수

<WantTestComponent onHandler={mockFn->Mock.fn} />
```

해당 래퍼 함수의 결과물은 `Mock.t` 타입으로, 아래의 호출 검증에서 사용하는 `toBeCalled`, `toBeCalledWith` 등에 사용할 수 있습니다. 호출하는 함수 형태로 되돌리기 위해서는 `MockJs.fn` 함수를 사용합니다.

```reason
open Jest

@val external window: 'a = "window"

let mockAlertFn = JestJs.spyOn(window, "alert")
```

특정 객체 내부에 있는 함수의 검사해주기 위해서 위와 같이 spyOn을 사용해서 검사할 수 있습니다. (매우 다이나믹한 기능이기 때문에 패키지에서는 제한적인 타이핑을 지원합니다. 권장 x)

## 모킹 함수 호출 검증

```reason
open Jest
open Expect

describe("Test my module", () => {
  let myMockFunction = JestJs.make2((msg, msg2) => msg ++ msg2)
  let setup = () => {
    (myMockFunction->Mock.fn)("Hello ", "world!")
  }
  describe("When call setup", () => {
    beforeEach(() => {
      setup()
    })

    afterEach(() => {
      myMockFunction->Mock.mockClear
    })

    test("myFunction is should called", () => {
      expect(myMockFunction)->toBeCalled()
      expect(myMockFunction)->toBeCalledTimes(1)
    })

    test("myFunction is should called with 'Hello ', 'world!'", () => {
      expect(myMockFunction)->toBeCalledWith(("Hello ", "world!"))
    })

    test("myFunction return is 'Hello world!'", () => {
      expect(myMockFunction)->toReturnedWith("Hello world!")
    })
  })
  
})
```

# 특정 패키지의 함수 모킹하기

`UniquelID` 라는 모듈에서는 `make` 함수를 통해서 uniqid라는 패키지를 바인딩하고 있습니다. 

```reason
// UniquelID.res
@module("uniqid") external make: (~prefix: string, unit) => string = "default"
```

다음과 같이 테스트 파일에서 동일하게 가져와줍니다. 먼저 패키지를 `JestJs.mock` 을 통해 모킹해줍니다. 이렇게 되면 해당 패키지의 결과물들은 모두 모킹된 함수로 가져오게 됩니다.

그리고 uniqid.default 의 내용을 모킹 함수 형태로 선언합니다.

```reason
open Jest
open Expect

JestJs.mock("uniqid")

@module("uniqid") external mockMakeId: Mock.t<unit => string, unit, string> = "default"
```

`Mock.t` 의 타입인자는 순서대로 “함수 본체”, “인자(argument)”, “결과” 타입입니다.

```reason
open Jest
open Expect

beforeEach(() => {
  mockMakeId->Mock.mockReturnValue("mock id")
})

afterEach(() => {
  mockMakeId->Mock.mockClear
})

test("Mocking이 잘됐나요?", () => {
  expect(UniqueID.make(~prefix="blabla", ()))->toBe("mock id")
})
```

> afterEach에서 mockClear를 사용하는 이유는 다음 테스트에서 부작용이 발생하는 것을 방지하기 위해 해당 모킹 함수의 감시 인스턴스를 초기화해줍니다. 항상 초기화하는 습관을 가져야합니다!
> 

# 로컬 모듈의 함수 모킹하기

패키지 모킹과 과정은 비슷하지만, 결과물로 출력된 `.bs.js` 의 export를 파악하고 모킹해야합니다 (리스크립트 모듈의 경험을 그대로 사용할 수 없어서 아쉬움)

예를 들어, `BrowserStorage` 모듈의 `WhetherVisitMypage.get` 을 모킹하고 싶다면 다음과 같이 이루어집니다. (위치는 "src/util/BrowserStorage.bs.js")

```reason
open Jest
open Expect

JestJs.mock("src/util/BrowserStorage.bs.js")

@module("src/util/BrowserStorage.bs.js") @scope("WhetherVisitMypage")
external mockWhetherVisitMypageGet: Mock.t<unit, bool> = "get"

beforeEach(() => {
  mockWhetherVisitMypageGet->Mock.mockReturnValue(true)
})

afterEach(() => {
  mockWhetherVisitMypageGet->Mock.mockClear
})

test("Mocking이 잘됐나요?", () => {
  expect(BrowserStorage.WhetherVisitMypage.get())->toBe(true)
})
```

모킹 모듈을 bs.js로 선언한거 외에는 위와 똑같이 사용합니다.

# 타이머 모킹하기

[https://jestjs.io/docs/timer-mocks](https://jestjs.io/docs/timer-mocks)

jest에서는 자체적으로 timer를 모킹할 수 있도록 제공하고 있습니다.

```reason
open Jest
open Expect

beforeEach(() => {
  JestJs.useFakeTimers()
})

afterEach(() => {
  JestJs.useRealTimers()
})

test("타이머 모킹하기", () => {
  let mockFn = Mock.empty()
  Js.Global.setTimeout(() => (mockFn->Mock.fn)()->ignore, 1000)->ignore
  Js.Global.setTimeout(() => (mockFn->Mock.fn)()->ignore, 2000)->ignore
  Js.Global.setTimeout(() => (mockFn->Mock.fn)()->ignore, 3000)->ignore
  JestJs.advanceTimersByTime(2500) // 2500ms 지나가게끔 만들기
  // Jest.runAllTimers() 이거 쓰면 전부 실행
  expect(mockFn)->toBeCalledTimes(2) // 2.5초 동안 2번만 실행했으니
})
```

# 네트워크 모킹 (TBD)

[https://www.npmjs.com/package/nock](https://www.npmjs.com/package/nock) 패키지 사용하기

# 현재 시간 모킹 (TBD)

[https://www.npmjs.com/package/mockdate](https://www.npmjs.com/package/mockdate) 패키지 사용하기

# 브라우저 API 모킹

브라우저 API들은 대부분 jsdom에서 readonly로 설정되어 있습니다.

```reason
open Jest
open Expect
open Webapi

let mockAssignFn: Mock.t<unit, unit> = Mock.spyOn(Dom.location->Obj.magic, "assign")

beforeEach(() => {
  Dom.location->Dom.Location.assign("/foo/bar")
})

// ❌ TypeError: Cannot assign to read only property 'assign' of object '[object Location]’
test("location.assign is called", () => {
  expect(mockAssignFn)->toBeCalled
})
```

> TypeError: Cannot assign to read only property 'assign' of object '[object Location]’
> 

그래서 spyOn으로 특정 메서드를 감시하고자해도 막히는 경우가 많습니다.

이 경우에는 `Object.defineProperty` 를 이용해서 window객체를 직접 수정해서 location 객체를 새로 대체해야합니다.

```reason
@val external window: 'a = "window"
type defineProperty = {value: {.}}
@scope("Object") @val
external defineProperty: ('a, string, defineProperty) => unit = "defineProperty"

let mockLocation = (mockLocation: {..}) => {
  let beforeLocation = ref(None)

  Jest.beforeEach(() => {
    beforeLocation.contents = Some(Webapi.Dom.location)
    defineProperty(
      window,
      "location",
      {
        value: Js.Obj.empty()
        ->Js.Obj.assign(beforeLocation.contents->Obj.magic)
        ->Js.Obj.assign(mockLocation),
      },
    )
  })

  Jest.afterEach(() => {
    beforeLocation.contents = Some(Webapi.Dom.location)
    defineProperty(
      window,
      "location",
      {
        value: beforeLocation.contents->Obj.magic,
      },
    )
  })
}
```

기존 location 객체를 ref로 따로 저장해두었다가 defineProperty로 window객체의 location을 새로 대체하는 식으로 수정합니다. afterEach에서는 원래대로 되돌려 놓습니다.

```reason
open Jest
open Expect
open Webapi

let mockAssignFn: Mock.t<unit, unit> = Mock.empty()
MockBrowser.mockLocation({
  "href": "/",
  "assign": mockAssignFn,
})

beforeEach(() => {
  Dom.location->Dom.Location.assign("/foo/bar")
})

// ✅
test("location.assign is called", () => {
  expect(mockAssignFn)->toBeCalled
})
```

정상적으로 모킹되었습니다!
