type pokemon = {name: string}

type fetchType = Loading | Error(int) | Success(pokemon)
let useFetchPokemon = (~name) => {
  let (data, setData) = React.useState(() => Loading)
  React.useEffect1(() => {
    let call = async () => {
      setData(_ => Loading)
      let response = await Webapi.Fetch.fetch(`https://pokeapi.co/api/v2/pokemon/${name}`)
      switch response->Webapi.Fetch.Response.ok {
      | true => {
          let result = await (response->Webapi.Fetch.Response.json)
          setData(_ => Success(result->Obj.magic))
        }

      | false => setData(_ => Error(response->Webapi.Fetch.Response.status))
      }
    }
    call()->ignore
    None
  }, [name])
  data
}
