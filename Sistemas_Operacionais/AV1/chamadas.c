#include <stdio.h>
#include <stdlib.h>
#include <pthread.h>
#include <semaphore.h>

sem_t b;
sem_t l,l2;
sem_t m;

void* bart(void* v)
{
    for(int i=0;i<100;i++)
    {
        sem_wait(&b);
        printf("Bart  ");
        sem_post(&l);
    }
}

void* lisa(void* v)
{
    for(int i=0;i<100;i++)
    {
        sem_wait(&l);
        printf("Lisa  ");
        sem_post(&m);
        sem_wait(&l2);
        printf("Lisa  ");
        sem_post(&b);

    }
}

void* maggie(void* v)
{
    for(int i=0;i<100;i++)
    {
        sem_wait(&m);
        printf("Maggie  ");
        sem_post(&l2);
    }
}

int main()
{
    int tid1 = 1;
    int tid2 = 2;
    int tid3 = 3;

    sem_init(&b,0,1);
    sem_init(&l,0,0);
    sem_init(&l2,0,0);
    sem_init(&m,0,0);

    pthread_t thread_bart;
    pthread_t thread_lisa;
    pthread_t thread_maggie;

    pthread_create(&thread_bart,NULL,&bart,&tid1);
    pthread_create(&thread_lisa,NULL,&lisa,&tid2);
    pthread_create(&thread_maggie,NULL,&maggie,&tid3);

    pthread_join(thread_bart,NULL);
    pthread_join(thread_lisa,NULL);
    pthread_join(thread_maggie,NULL);

    return 0;
}