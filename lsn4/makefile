VERILATOR = verilator
CXX       = g++
CXXFLAGS  = -I/usr/share/verilator/include -Iobj_dir -Wall

TARGET    = ledreq_sim
SRC       = ledreq.cpp
VERILOG   = ledreq.v

all: $(TARGET)

$(TARGET): $(SRC) $(VERILOG)
	$(VERILATOR) --cc $(VERILOG) --exe $(SRC) --trace
	make -C obj_dir -f Vledreq.mk
	$(CXX) $(CXXFLAGS) \
		/usr/share/verilator/include/verilated.cpp \
		/usr/share/verilator/include/verilated_vcd_c.cpp \
		/usr/share/verilator/include/verilated_threads.cpp \
		$(SRC) obj_dir/Vledreq__ALL.a \
		-o $(TARGET)

clean:
	rm -rf obj_dir/ $(TARGET)
