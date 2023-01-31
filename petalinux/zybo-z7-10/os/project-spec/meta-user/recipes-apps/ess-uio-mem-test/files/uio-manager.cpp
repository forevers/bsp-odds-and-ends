#include "uio-manager.h"

#include <cassert>
#include <chrono>
#include <cstring>
#include <fcntl.h>
#include <iomanip>
#include <iostream>
#include <poll.h>
#include <sys/mman.h>
#include <sys/stat.h>
#include <unistd.h>
#include <utility>

using namespace std;


UioManager::UioManager(string uio_number, string uio_name) :
    uio_name_(uio_name),
    uio_number_(uio_number),
    num_bytes_(0),
    initialized_(false),
    running_(false)
{
}


UioManager::~UioManager()
{
    running_ = false;
    if (uioIrq_thread_.joinable()) uioIrq_thread_.join();

    munmap(ptr_, num_bytes_);
    close(fd_);
}


int UioManager::init()
{
    /* find uio device and extract parameters */

    string uio_dir = "cat "+uio_sysfs_path_+"/"+uio_number_+"/name";
    FILE *proc = popen(uio_dir.c_str(), "r");
    if (!proc) {
        cerr<<"error: process open failed"<<endl;
        return EXIT_FAILURE;
    }
    char name[17];
    if (fscanf(proc, "%16s", name) == 1) {
        if (0 == strncmp(name, uio_name_.c_str(), 16)) {
            printf ("name: %s\n", name);
        } else {
            cout<<"uio_pipeline not found"<<endl;
        }
    } else {
        cout<<"uio_pipeline not found"<<endl;
    }
    pclose (proc);

    uio_dir = "cat "+uio_sysfs_path_+"/"+uio_number_+"/maps/map0/addr";
    proc = popen(uio_dir.c_str(), "r");
    if (!proc) {
        cerr<<"error: process open failed."<<endl;
        return EXIT_FAILURE;
    }
    if (fscanf(proc, "0x%x", &base_addr_) == 1) {
        printf ("addr: 0x%x\n", base_addr_);
    } else {
        cout<<"addr not found"<<endl;
    }
    pclose (proc);

    uio_dir = "cat "+uio_sysfs_path_+"/"+uio_number_+"/maps/map0/size";
    proc = popen(uio_dir.c_str(), "r");
    if (!proc) {
        cerr<<"error: process open failed."<<endl;
        return EXIT_FAILURE;
    }
    if (fscanf(proc, "0x%x", &num_bytes_) == 1) {
        printf ("size: 0x%x\n", num_bytes_);
    } else {
        num_bytes_ = 0;
        cout<<"size not found"<<endl;
        pclose(proc);
        return EXIT_FAILURE;
    }
    pclose (proc);

    /* open uio device */
    uio_dir = "/dev/"+uio_number_;
    cout<<"open "+uio_dir<<endl;
    fd_ = open(uio_dir.c_str(), O_RDWR|O_SYNC);
    if (fd_ < 1) {
        cerr<<"error: couldn't open "+uio_dir+" device file"+strerror(errno)<<endl;
        return EXIT_FAILURE;
    }

    /* offset must be a multiple of the page size as returned by sysconf(_SC_PAGE_SIZE). */
    long page_size = sysconf(_SC_PAGE_SIZE);
    num_bytes_ = num_bytes_ - (num_bytes_ % page_size);
    cout << "uio page size : " << page_size << ", allocated bytes : " << std::hex << num_bytes_ << endl;
    ptr_ = (uint8_t *)mmap(NULL, num_bytes_, PROT_READ|PROT_WRITE, MAP_SHARED, fd_, 0);

    if (ptr_ == MAP_FAILED) {
        perror("Couldn't mmap ptr_");
        close(fd_);
        return EXIT_FAILURE;
    }

    initialized_ = true;
    uioIrq_thread_ = thread(&UioManager::handlerIrq, this);

    return EXIT_SUCCESS;
}


void UioManager::stop()
{
    running_ = false;
}


void UioManager::handlerIrq()
{
    char buf[4];
    int bytes;
    /* uio driver interrupt enable command */
    char startval[] = {0,0,0,1};
    pollfd read_fd_poll[1];

    running_ = true;

    cout<<"Waiting for interrupts"<<endl;

    do {

        /* enable interrupt */
        if (4 != (bytes = pwrite(fd_, &startval, 4, 0))) {
            cerr<<"error: problem enabling the interrupt: "<<strerror(errno)<<endl;
            exit(EXIT_FAILURE);
        }

        /* poll detects interrupt occurance */
        read_fd_poll[0].fd = fd_;
        read_fd_poll[0].events = POLLIN;

        int timeout_ms = 1000;
        int retval;

        /* poll to detect interupt(s) */
        if (1 <= (retval = poll(read_fd_poll, 1, timeout_ms))) {

            // addDelay(nsec_delay);

            bytes = pread(fd_, buf, 4, 0);

            if (bytes != 4) {
                perror("uioctl");
                cerr<<"error: problem reading the interrupt count"<<endl;
                exit(EXIT_FAILURE);
            }

        } else if (0 != retval)  {
            cerr<<"error: poll() failure : "<<strerror(errno)<<endl;
        }

    } while (running_);

    close(fd_);

    cout<<"handler_irq() exit"<<endl;
}


void UioManager::testInterruptTransfer(void)
{
    // increment fill value
    // fill buffer with fill value
    // sw interrupt generation
}
