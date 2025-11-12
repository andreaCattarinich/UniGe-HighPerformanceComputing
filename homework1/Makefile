CC = icc
CFLAGS = -O2 -qopenmp -qopt-report=5 -qopt-report-phase=vec 

SRC_FOLDER = src
SRC_CODE = omp_homework.c

BUILD = build
REPORTS = reports

NAME = $(basename $(SRC_CODE))
TARGET = $(BUILD)/$(NAME)

all:
	mkdir -p $(BUILD) $(REPORTS)
	$(CC) $(CFLAGS) $(SRC_FOLDER)/$(SRC_CODE) -o $(TARGET)
	mv $(BUILD)/$(NAME).optrpt $(REPORTS)/ 2>/dev/null || true
	@echo "Compiled in $(TARGET)"
	@echo "Report in $(REPORTS)"

clean:
	rm -rf $(BUILD) $(REPORTS)
	@echo "Cleaned"