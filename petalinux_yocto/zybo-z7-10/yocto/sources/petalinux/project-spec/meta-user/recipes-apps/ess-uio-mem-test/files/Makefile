APP = ess-uio-mem-test

APP_OBJS = uio-manager-test.o uio-manager.o

all: $(APP)

CFLAGS += -pthread
LDFLAGS += -pthread

$(APP): $(APP_OBJS)
	$(CXX) $(LDFLAGS) -o $@ $(APP_OBJS) $(LDLIBS)

clean:
	-rm -f $(APP) *.elf *.gdb *.o
