/**
 *  Standalone Build Options:
 *      Host gcc build command line:
 *          g++ -g -O0 -std=c++20 main.cpp -o ess-canonical-app
 *      SDK based build command line:
 *          $CXX $CXXFLAGS -v ess-canonical-app main.cpp
 *      BSP based standalone build command line:
 *          bitbake ess-canonical-app
 *
 *  Side-load:
 *      scp <base path>/tmp/work/cortexa72-poky-linux/ess-canonical-app/1.00-r0/image/usr/bin/ess-canonical-app root@<ip>:/usr/bin
 */

/*
Using this library may require additional compiler/linker options.
GNU implementation prior to 9.1 requires linking with -lstdc++fs and
LLVM implementation prior to LLVM 9.0 requires linking with -lc++fs.
*/

#include <cstdlib>
#include <iostream>
#include <filesystem>
#include <stdlib.h>

#include "header.h"
#include "header-1-00.h"

using namespace std;
namespace fs = std::filesystem;

int main(int argc, char* argv[])
{
    cout<<"Name: "<<argv[0]<<endl;
    cout<<g_header_string<<endl;
    cout<<g_header_1_00_string<<endl;

    /* test distro config */
    const fs::path dep_1_file_path { "/usr/bin/ess-canonical-feature-default" };
    fs::directory_entry dep_1_file_dir_entry { dep_1_file_path };
    if (dep_1_file_dir_entry.exists()) {
        system(dep_1_file_path.string().c_str());
    }

    const fs::path dep_2_file_path { "/usr/bin/ess-canonical-feature-optional" };
    fs::directory_entry dep_2_file_dir_entry { dep_2_file_path };
    if (dep_2_file_dir_entry.exists()) {
        system(dep_2_file_path.string().c_str());
    }

    return EXIT_SUCCESS;
}