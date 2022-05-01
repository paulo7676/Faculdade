defmodule Carpeado.Consumer do
  #consumidor de eventos do discord
  #iex -S mix
  #mix run --no halt

  use Nostrum.Consumer
  alias Nostrum.Api

  def start_link do
    Consumer.start_link(__MODULE__)
  end

  def handle_event({:MESSAGE_CREATE, msg, _ws_state}) do
    cond do
      String.starts_with?(msg.content, "!coffee") -> coffee(msg)
      String.starts_with?(msg.content, "!wiki") -> wiki(msg)
      String.starts_with?(msg.content, "!dollar") -> dollar(msg)
      String.starts_with?(msg.content, "!DDD") -> ddd(msg)
      String.starts_with?(msg.content, "!CEP") -> cep(msg)
      String.starts_with?(msg.content, "!Musica") -> musica(msg)
      String.starts_with?(msg.content, "!Url") -> url(msg)
      String.starts_with?(msg.content, "!QR_code") -> qr_code(msg)
      String.starts_with?(msg.content, "!Populacao") -> populacao(msg)
      String.starts_with?(msg.content, "!Mapa") -> mapa(msg)
      true -> :ignore
    end
  end

  def coffee(msg) do
    resp = HTTPoison.get!("https://coffee.alexflipnote.dev/random.json")
    {:ok, map} = Poison.decode(resp.body)
    Api.create_message(msg.channel_id, map["file"])
  end

  def wiki(msg) do
    aux = String.split(msg.content, " ",parts: 2)

    wikis = Enum.fetch!(aux,1)
    wiki_s = String.replace(wikis," ","_")
    resp = HTTPoison.get!("https://pt.wikipedia.org/api/rest_v1/page/summary/#{wiki_s}?redirect=true")

    case resp.status_code do
      200 ->
        {:ok, map} = Poison.decode(resp.body)
        informacao = map["extract"]
        imagem = map["thumbnail"]["source"]
        Api.create_message(msg.channel_id, imagem)
        Api.create_message(msg.channel_id, informacao)
      404 ->
        Api.create_message(msg.channel_id, "Nao Conseguimos encontrar informações sobre #{wikis} tente novamente")
    end
  end

  def dollar(msg) do
    resp = HTTPoison.get!("https://cdn.jsdelivr.net/gh/fawazahmed0/currency-api@1/latest/currencies/brl.json")
    {:ok, map} = Poison.decode(resp.body)
    dollar = map["brl"]["usd"]
    Api.create_message(msg.channel_id,"O valor do dollar hoje é #{1/dollar}")
  end

  def ddd(msg) do

    aux = String.split(msg.content, " ",parts: 2)
    conteudo = Enum.fetch!(aux,1)
    conteudo_ = String.replace(conteudo," ","_")

    resp = HTTPoison.get!("https://brasilapi.com.br/api/ddd/v1/#{conteudo_}")

    case resp.status_code do
      200 ->
        {:ok, map} = Poison.decode(resp.body)
        retorno = map["state"]
        Api.create_message(msg.channel_id,"O DDD #{conteudo_} pertence ao estado #{retorno}")
      404 -> 
        Api.create_message(msg.channel_id,"O DDD #{conteudo_} nao existe")
      500 -> 
        Api.create_message(msg.channel_id,"Todos os servicos de DDD retornaram erro")
      end
  end

  def cep(msg) do

    aux = String.split(msg.content, " ",parts: 2)
    conteudo = Enum.fetch!(aux,1)
    conteudo_ = String.replace(conteudo," ","_")

    resp = HTTPoison.get!("https://brasilapi.com.br/api/cep/v1/#{conteudo_}")
    case resp.status_code do
      200 ->
        {:ok, map} = Poison.decode(resp.body)
        cidade = map["city"]
        bairro = map["neighborhood"]
        rua = map["street"]
        Api.create_message(msg.channel_id,"O CEP: #{conteudo_} pertence a: \nCidade: #{cidade}\nBairro: #{bairro}\nRua: #{rua}\n") 
      400 -> 
        Api.create_message(msg.channel_id,"O CEP #{conteudo_} nao existe")
      end
  end

  def musica(msg) do

    aux = String.split(msg.content, " ",parts: 2)
    artista = Enum.fetch!(aux,1)
    artista_ = String.replace(artista," ","-")
    resp = HTTPoison.get!("https://www.vagalume.com.br/#{artista_}/index.js")
    
    case resp.status_code do
      200 ->
        {:ok, map} = Poison.decode(resp.body)
        musica = :rand.uniform(length(map["artist"]["lyrics"]["item"]))
        elemento = Enum.fetch(map["artist"]["lyrics"]["item"],musica)
        elemnto_url = elem(elemento,1)["url"]
        url = "https://www.vagalume.com.br#{elemnto_url}"
        Api.create_message(msg.channel_id,url)
      404 -> 
        Api.create_message(msg.channel_id,"Nao encontramos esse artista")
      end
  end

  def url(msg) do
    aux = String.split(msg.content, " ",parts: 2)
    url = Enum.fetch!(aux,1)
    resp = HTTPoison.get!("https://ulvis.net/API/write/get?url=#{url}")
    {:ok, map} = Poison.decode(resp.body)
    url_shortened = map["data"]["url"]
    Api.create_message(msg.channel_id, url_shortened)
  end

  def qr_code(msg) do
    aux = String.split(msg.content, " ",parts: 2)
    imagem = Enum.fetch!(aux,1)
    resp = HTTPoison.get!("https://www.qrtag.net/api/qr_4.png?url=#{imagem}")
    case resp.status_code do
      200 ->
        Api.create_message(msg.channel_id, resp.request_url)
      301 ->
      Api.create_message(msg.channel_id, "Nao conseguimos criar o qr code")
      end
  end

  def populacao(msg) do
    aux = String.split(msg.content, " ",parts: 2)
    nome = Enum.fetch!(aux,1)
    nome_ = String.replace(nome," ","%20")
    resp = HTTPoison.get!("https://restcountries.com/v3.1/name/#{nome_}")
    case resp.status_code do
      200 ->
        {:ok, map} = Poison.decode(resp.body)
        aux = Enum.fetch(map,0)
        elementos = elem(aux,1)
        Api.create_message(msg.channel_id, "O Pais #{elementos["name"]["common"]} tem uma população de #{elementos["population"]}")
      404 ->
      Api.create_message(msg.channel_id, "Nao conseguimos encontrar esse País")
      end
  end

  def mapa(msg) do
    aux = String.split(msg.content, " ",parts: 2)
    nome = Enum.fetch!(aux,1)
    nome_ = String.replace(nome," ","%20")
    resp = HTTPoison.get!("https://restcountries.com/v3.1/name/#{nome_}")
    case resp.status_code do
      200 ->
        {:ok, map} = Poison.decode(resp.body)
        aux = Enum.fetch(map,0)
        elementos = elem(aux,1)
        Api.create_message(msg.channel_id, elementos["maps"]["googleMaps"])
      404 ->
      Api.create_message(msg.channel_id, "Nao conseguimos encontrar esse País")
      end
  end

  def handle_event(_event) do
    :noop
  end
end
