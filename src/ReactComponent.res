module Result = {
  @react.component
  let make = (~name) => {
    let status = ReactHook.useFetchPokemon(~name)
    <div role="search">
      {switch status {
      | Loading => <p> {React.string(`Loading...`)} </p>
      | Error(_) => <p> {React.string(`Error!!`)} </p>
      | Success(data) => <h1> {data.name->React.string} </h1>
      }}
    </div>
  }
}

@react.component
let make = () => {
  let inputRef = React.useRef(Js.Nullable.null)
  let (searchName, setSearchName) = React.useState(() => None)

  let handleSubmit = e => {
    e->ReactEvent.Form.preventDefault
    setSearchName(_ =>
      inputRef.current
      ->Js.Nullable.toOption
      ->Option.flatMap(element => {
        element
        ->Webapi.Dom.HtmlInputElement.ofElement
        ->Option.map(input => input->Webapi.Dom.HtmlInputElement.value)
      })
    )
  }
  <div>
    <form onSubmit={handleSubmit}>
      <input type_="text" placeholder="Enter pokemon name" ref={inputRef->ReactDOM.Ref.domRef} />
      <input type_="submit" value="Search" />
    </form>
    {switch searchName {
    | Some(name) => <Result name />
    | None => React.null
    }}
  </div>
}
