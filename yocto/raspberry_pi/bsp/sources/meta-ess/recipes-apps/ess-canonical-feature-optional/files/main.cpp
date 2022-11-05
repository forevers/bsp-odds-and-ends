/**
 *  Standalone Build Options:
 *      Host gcc build command line:
 *          g++ -g -O0 -std=c++20 main.cpp -o ess-canonical-feature-optional
 *      SDK based build command line:
 *          $CXX $CXXFLAGS -v ess-canonical-feature-optional main.cpp
 *      BSP based standalone build command line:
 *          bitbake ess-canonical-feature-optional
 *
 *  Side-load:
 *      scp <base path>/tmp/work/cortexa72-poky-linux/ess-canonical-feature-optional/1.00-r0/image/usr/bin/ess-canonical-feature-optional root@<ip>:/usr/bin
 */

#include <cstdlib>
#include <iostream>

using namespace std;

int main(int argc, char* argv[])
{
    cout<<"ess-canonical-feature-optional"<<endl;

    return EXIT_SUCCESS;
}