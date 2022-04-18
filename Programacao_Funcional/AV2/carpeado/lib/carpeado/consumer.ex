defmodule Carpeado.Consumer do
  #consumidor de eventos do discord

  use Nostrum.Consumer
  alias Nostrum.Api

  def start_link do
    Consumer.start_link(__MODULE__)
  end



  def handle_event({:MESSAGE_CREATE, msg, _ws_state}) do
    cond do
      String.starts_with?(msg.content, "a") -> teste(msg)
      String.starts_with?(msg.content, "!dog_facts") -> dog_Facts(msg)
      String.starts_with?(msg.content, "!dog_pics") -> dog_pics(msg)
      String.starts_with?(msg.content, "!wiki ") -> wiki(msg)
      true -> :ignore
    end
  end

  def wiki(msg) do
    aux = String.split(msg.content, " ",parts: 2)

    wikis = Enum.fetch!(aux,1)
    wiki_s = String.replace(wikis," ","_")
    resp = HTTPoison.get!("https://pt.wikipedia.org/api/rest_v1/page/summary/#{wiki_s}?redirect=true")


    case resp.status_code do
      200 ->
        {:ok, map} = Poison.decode(resp.body, keys: :atoms)
        informacao = map["extract"]
        imagem = map["thumbnail"]["source"]
        Api.create_message(msg.channel_id, imagem)
        Api.create_message(msg.channel_id, informacao)
      404 ->
        Api.create_message(msg.channel_id, "Nao Conseguimos encontrar informações sobre #{wikis} tente novamente")
    end
  end

  def dog_Facts(msg) do
    resp = HTTPoison.get!("https://dog-facts-api.herokuapp.com/api/v1/resources/dogs/all")
    {:ok, map} = Poison.decode(resp.body, keys: :atoms)
    length_list = length(map)

    Api.create_message(msg.channel_id, Enum.at(map,
    :rand.uniform(length_list))["fact"])
  end

  def dog_pics(msg) do
    resp = HTTPoison.get!("https://random.dog/woof.json")
    {:ok, map} = Poison.decode(resp.body, keys: :atoms)
    imagem = map["url"]
    Api.create_message(msg.channel_id, imagem)
  end

  def teste(msg) do
    resp = HTTPoison.get!("https://nekos.best/api/v2/kiss")
    {:ok, map} = Poison.decode(resp.body)
    a = map["results"]
    Api.create_message(msg.channel_id, Enum.at(map["results"],0)["url"])
  end


  def handle_event(_event) do
    :noop
  end
end
