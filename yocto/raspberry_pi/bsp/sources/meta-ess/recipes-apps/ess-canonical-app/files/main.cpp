#include <cstdlib>
#include <iostream>

#include "header.h"
#include "header-1-00.h"

using namespace std;

int main(int argc, char* argv[])
{
    cout<<"Name: "<<argv[0]<<endl;
    cout<<g_header_string<<endl;
    cout<<g_header_1_00_string<<endl;

    return EXIT_SUCCESS;
}