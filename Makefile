BUILD    := build
VINC     := $(shell verilator --getenv VERILATOR_ROOT)/include
CXXFLAGS := -O2 -std=c++17 \
            -I$(VINC) \
            -Isim \
            -I$(BUILD)/obj_mont_reduce

.PHONY: all constants lint prove clean

# run everything in order
all: constants lint prove

# step 1: check all constants before anything compiles
constants:
	@echo "== constants =="
	@python3 scripts/verify_constants.py

# step 2: lint the RTL
lint:
	@echo "== lint =="
	@verilator --lint-only -Wall -Wno-UNUSED --top-module mont_reduce rtl/mont_reduce.sv

# step 3: verilate -- generate C++ model from RTL
$(BUILD)/obj_mont_reduce/Vmont_reduce__ALL.a: rtl/mont_reduce.sv
	@mkdir -p $(BUILD)
	verilator --cc -Wall -Wno-UNUSED \
	  --top-module mont_reduce \
	  --Mdir $(BUILD)/obj_mont_reduce \
	  --build \
	  rtl/mont_reduce.sv

# step 4: compile testbench and link against generated model
$(BUILD)/sim: sim/main.cpp sim/ref_model.hpp \
              $(BUILD)/obj_mont_reduce/Vmont_reduce__ALL.a
	$(CXX) $(CXXFLAGS) -o $@ \
	  sim/main.cpp \
	  $(VINC)/verilated.cpp \
	  $(BUILD)/obj_mont_reduce/Vmont_reduce__ALL.a

# step 5: run it
prove: constants lint $(BUILD)/sim
	@echo "== exhaustive 2^24 reducer =="
	@$(BUILD)/sim

clean:
	rm -rf $(BUILD)