# Set MATLAB on your PATH, or override with `make MATLAB=/path/to/matlab`
MATLAB ?= /home/anwar/MATLAB/R2026a/bin/matlab
SCRIPT=reference_model.m

.PHONY: all run clean

all: run

run:
	$(MATLAB) -batch "run('$(SCRIPT)')"

clean:
	rm -f docs/waveforms/frequency_response.png
