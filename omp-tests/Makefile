CC = icx
BUILD = build
REPORTS = reports
SRC_FOLDER = src
CFLAGS = -fopenmp -vec -qopt-report=max -g -O2 -xHost
SRC_CODE = hello.c
NAME = $(basename $(SRC_CODE))

$(shell mkdir -p $(BUILD) $(REPORTS))

all: test

test:
	$(CC) $(CFLAGS) $(SRC_FOLDER)/$(SRC_CODE) \
	-o $(BUILD)/$(NAME) \
	-qopt-report-file=$(REPORTS)/$(NAME).optrpt

clean:
	rm -rf $(BUILD) $(REPORTS)
