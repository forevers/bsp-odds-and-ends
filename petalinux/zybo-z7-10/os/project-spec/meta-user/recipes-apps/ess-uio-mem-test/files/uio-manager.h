#pragma once

#include <atomic>
#include <functional>
#include <list>
#include <mutex>
#include <thread>

class UioManager final
{
public:

    // UioManager(std::string uio_sysfs_path, std::string uio_number, std::string uio_name, int64_t num_delays);

    /*
        Constructor of a UioManager Constructor
        uio_number - number of the uio device
        uio_name - expected name of the uio device.
    */
    UioManager(std::string uio_number, std::string uio_name);
    ~UioManager();

    int init();
    void stop();

    /*
        process uio interrupt
        read buffer
        increment buffer fill value
        write buffer with fill value
    */
    void testInterruptTransfer();

    uint32_t const getNumBytes() {
        return num_bytes_;
    }

private:

    std::string uio_sysfs_path_ {"/sys/class/uio"};

    std::string uio_name_;
    std::string uio_number_;

    std::thread uioIrq_thread_;
    void handlerIrq();

    uint32_t base_addr_;
    uint32_t num_bytes_;

    int fd_;
    uint8_t *ptr_;

    bool initialized_;
    std::atomic_bool running_;
};
