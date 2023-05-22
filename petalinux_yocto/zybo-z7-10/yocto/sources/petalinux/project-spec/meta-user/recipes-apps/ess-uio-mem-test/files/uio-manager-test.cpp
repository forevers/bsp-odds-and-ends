/*
    description:
        Constructs uio memory maps to to overlay reserved memory spaces.

    build:
        petalinux-build -c ess-uio-mem-test
        results at
            build/tmp/work/cortexa9t2hf-neon-xilinx-linux-gnueabi/ess-uio-mem-test/1.0-r0/image/usr/bin/ess-uio-mem-test
        copy to target
            scp build/tmp/work/cortexa9t2hf-neon-xilinx-linux-gnueabi/ess-uio-mem-test/1.0-r0/image/usr/bin/ess-uio-mem-test root@<ip>:/dev/shm

    test sequence:
    - run test app
        $ ./ess-uio-mem-test
    - key in the 'i' character to generate interrupts
    - key in the 'q' to quit
 */
#include "uio-manager.h"

#include <condition_variable>
#include <cassert>
#include <cstdint>
#include <errno.h>
#include <fcntl.h>
#include <iomanip>
#include <iostream>
#include <mutex>
#include <signal.h>
#include <stdio.h>
#include <string.h>
#include <sys/timeb.h>
#include <termios.h>
#include <thread>
#include <unistd.h>
#include <utility>

using namespace std;


void usage()
{
    cout<<endl<<"*********************************************************************"<<endl;
    cout<<endl;
    cout<<" this application tests uio interrupt generation, handling and memory access"<<endl;
    cout<<endl;
    cout<<"  `i` - generate interrupt" << endl;
    cout<<"  `h` - print this menu" << endl;
    cout<<"  `q` - quit application" << endl;
    cout<<endl;
    cout<<"*********************************************************************"<<endl;
}

int main (int argc, char *argv[])
{
    usage();

    shared_ptr<UioManager> uio_manager = make_shared<UioManager>("uio6", "uio-reserved-regs");
    if (EXIT_SUCCESS != uio_manager->init()) {
        return EXIT_FAILURE;
    }

    // disable buffering
    struct termios t;
    tcgetattr(STDIN_FILENO, &t);
    t.c_lflag &= ~ICANON;
    t.c_lflag &= ~ECHO;
    tcsetattr(STDIN_FILENO, TCSANOW, &t);

    int ch;
    while ('q' != (ch = getchar())) {

        switch (ch) {

            case 'h': {
                usage();
                break;
            }

            case 'i': {
                // uio_manager->generateInterrupt();
                static long val = 0;
                val++;
                // fill uio memory from devmem
                // read memory from uio uio_manager
                break;
            }
        }
    }

    // enable buffering
    tcgetattr(STDIN_FILENO, &t);
    t.c_lflag |= ICANON;
    t.c_lflag |= ECHO;
    tcsetattr(STDIN_FILENO, TCSANOW, &t);

    return EXIT_SUCCESS;
}
