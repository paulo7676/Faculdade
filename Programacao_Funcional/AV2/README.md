# Carpeado

## **Desenvolvido por Paulo Henrique Ribeiro Costa**

Chatbot para o discord utilizando a linguagem Elixir desenvolvido na disciplina de Programação Funcional. Ele possui 10 comandos distintos que utilizam diferentes Rest APIs, tratando as possiveis entradas de dados, realizando as funcionalidades esperadas quando a entrada é correta e, retornando mensagens de erro quando contrario.

Temos os seguintes comandos:

1. !coffee -> Retorna uma imagem aleatória de um café
2. !wiki *nome* -> Realiza uma busca de um item na wikipedia retonando seu resumo e foto
3. !dollar -> Retorna a cotação do Dollar em real
4. !DDD *numero* -> Retorna o estado desse DDD
5. !CEP *numero* -> Retorna a cidade, bairro e rua de um CEP
6. !Musica *artista* -> Retorna uma musica aleatória de um artista
7. !Url *Url* -> Retona a Url Encurtada
8. !QR_code *imagem* -> Recebe o link de uma imagem e retorna um Código QR que, quando escaneado leva até a imagem
9. !Populacao *pais* -> Retorna a população de um país.
10. !Mapa *país* ->  Retorna um link para o google maps do país inserido

---

| Comando | Api Utilizada |
| ----------- | ----------- |
| !coffee | https://coffee.alexflipnote.dev/ |
| !wiki | https://pt.wikipedia.org/api/rest_v1/page/summary/{item}?redirect=true |
| !dollar | https://cdn.jsdelivr.net/gh/fawazahmed0/currency-api@1/latest/currencies/brl.json |
| !DDD | https://brasilapi.com.br/api/ddd/v1/{ddd} |
| !CEP | https://brasilapi.com.br/api/cep/v1/{cep} |
| !Musica | https://www.vagalume.com.br/{artista}/index.js |
| !Url | https://ulvis.net/API/write/get?url={url} |
| !QR_code | https://www.qrtag.net/api/qr_4.png?url=#{imagem} |
| !Populacao | https://restcountries.com/v3.1/name/#{pais} |
| !Mapa | https://restcountries.com/v3.1/name/#{pais} |
