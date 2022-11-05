/**
 *  Standalone Build Options:
 *      Host gcc build command line:
 *          g++ -g -O0 -std=c++20 main.cpp -o ess-canonical-feature-default
 *      SDK based build command line:
 *          $CXX $CXXFLAGS -v ess-canonical-feature-default main.cpp
 *      BSP based standalone build command line:
 *          bitbake ess-canonical-feature-default
 *
 *  Side-load:
 *      scp <base path>/tmp/work/cortexa72-poky-linux/ess-canonical-feature-default/1.00-r0/image/usr/bin/ess-canonical-feature-default root@<ip>:/usr/bin
 */

#include <cstdlib>
#include <iostream>

using namespace std;

int main(int argc, char* argv[])
{
    cout<<"ess-canonical-feature-default"<<endl;

    return EXIT_SUCCESS;
}