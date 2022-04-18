#include <stdio.h>
#include <stdlib.h>
#include <pthread.h>
#include <semaphore.h>
#include <windows.h>

sem_t b;
sem_t l,l2;
sem_t m;

//Jantas dos filosos -> mesa redonda com mesmo numero de filósofos e hashis (ou o filosofo come ou filosofa),
//cada qual na sua vez

//criacao das treads
pthread_t F0;
pthread_t F1;
pthread_t F2;
pthread_t F3;
pthread_t F4;

//semaforo mutex (binario)
pthread_mutex_t Hashi[5];

void* filosofo(void* V){

    int* p = (int*)V;
    int n = *p;

    while (1)
    {
    printf("Filosofo %d está pensando\n", n);
    pthread_mutex_lock(&Hashi[n]); //pegamos um hashi
    pthread_mutex_lock(&Hashi[(n+1)%5]); //pegamos o proximo hashi


    printf("Filosofo %d está comendo\n", n);
    pthread_mutex_unlock(&Hashi[n]); //pegamos um hashi
    pthread_mutex_unlock(&Hashi[(n+1)%5]); //pegamos o proximo hashi
    }


    return NULL;
}

int main()
{
    int n0 = 0;
    int n1 = 1;
    int n2 = 2;
    int n3 = 3;
    int n4 = 4;

    pthread_create(&F0,NULL,&filosofo,&n0);
    pthread_create(&F1,NULL,&filosofo,&n1);
    pthread_create(&F2,NULL,&filosofo,&n2);
    pthread_create(&F3,NULL,&filosofo,&n3);
    pthread_create(&F4,NULL,&filosofo,&n4);


    pthread_join(F0,NULL);
    pthread_join(F1,NULL);
    pthread_join(F2,NULL);
    pthread_join(F3,NULL);
    pthread_join(F4,NULL);

    return 0;
}
