// cfile.c

#include <stdio.h>
// #include <sys/types.h>
// #include <sys/socket.h>
// #include <netdb.h>

// int getaddrinfo(
//     const char *node,    // e.g. "www.example.com" or IP
//     const char *service, // e.g. "http" or port number
//     const struct addrinfo *hints,
//     struct addrinfo **res);

void printb(long long n)
{
  long long s, c;

  for (c = 63; c >= 0; c--)
  {
    s = n >> c;

    if ((c + 1) % 8 == 0)
    {
      printf(" ");
    }

    if (s & 1)
    {
      printf("1");
    }
    else
    {
      printf("0");
    }
  }

  printf("\n");
}