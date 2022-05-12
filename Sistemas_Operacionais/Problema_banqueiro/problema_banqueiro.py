#valores:
Recursos_Existentes = [6,3,4,2,2] #vetor de recursos existentes

Recursos_Compartilhados = [[1,0,1,1,1],[0,1,0,0,0],[1,1,1,0,0],[1,0,0,1,0],[0,1,0,0,0]] #matriz de alocação de recursos

Recursos_pedidos = [[2,0,0,0,0],[1,0,1,0,1],[1,0,1,0,2],[3,0,1,1,1],[0,1,0,0,0]] #matriz de requisição de alocação

Recursos_apos_alocacao = list.copy(Recursos_Existentes)

#alocacao dos recursos
for i in Recursos_Compartilhados:
    for j in range(len(Recursos_Compartilhados)):
        Recursos_apos_alocacao[j] = Recursos_apos_alocacao[j] - i[j]
        
print(Recursos_apos_alocacao)


while(len(Recursos_pedidos)!= 0):
    
    #leitura dos array
    for i in Recursos_pedidos:
        possivel_liberacao = False
        for j in range(len(i)):
            
            #ver se temos recursos sufientes para a situação
            if Recursos_apos_alocacao[j] - i[j] >=0:
                possivel_liberacao = True
            else:
                possivel_liberacao = False
                break
        
        #devolve os recursos
        if possivel_liberacao == True:
            Recursos_pedidos.index(i)
            for k in range(len(i)):
                Recursos_apos_alocacao[k] = Recursos_apos_alocacao[k] + Recursos_Compartilhados[Recursos_pedidos.index(i)][k]
            Recursos_Compartilhados.pop(Recursos_pedidos.index(i))
            Recursos_pedidos.pop(Recursos_pedidos.index(i))

print(Recursos_apos_alocacao)
        