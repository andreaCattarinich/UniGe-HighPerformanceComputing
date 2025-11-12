CC = icx
CFLAGS = -O2 -fopenmp -qopt-report=max -vec 

SRC_FOLDER = src
SRC_CODE = omp_homework_vectorization_report_v1.c

BUILD = build
REPORTS = reports

NAME = $(basename $(SRC_CODE))
TARGET = $(BUILD)/$(NAME)

all:
	mkdir -p $(BUILD) $(REPORTS)
	$(CC) $(CFLAGS) $(SRC_FOLDER)/$(SRC_CODE) -o $(TARGET)
	mv $(BUILD)/$(NAME).optrpt $(REPORTS)/ 2>/dev/null || true
	mv $(NAME).opt.yaml $(REPORTS)/ 2>/dev/null || true
	@echo "-- Compiled in $(TARGET)/"
	@echo "-- Report in $(REPORTS)/"

clean:
	rm -rf $(BUILD) $(REPORTS)
	@echo "Cleaned"