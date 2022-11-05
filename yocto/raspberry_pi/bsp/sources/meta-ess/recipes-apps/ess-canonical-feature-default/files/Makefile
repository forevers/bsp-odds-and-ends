APP = ess-canonical-feature-default

APP_OBJS = main.o

CXXFLAGS += -std=c++20

all: $(APP)

$(APP): $(APP_OBJS)
	$(CXX) $(CXXFLAGS) $(LDFLAGS) -o $@ $(APP_OBJS) $(LDLIBS)

clean:
	-rm -f $(APP) *.elf *.gdb *.o
