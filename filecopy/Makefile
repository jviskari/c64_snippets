CC := cc65
CL := cl65
CL_FLAGS := -t c64 --static-locals
CFLAGS := -t c64 --add-source -O --static-locals

BIN := bin
SRC := src
EXECUTABLE := filecopy.prg

.PHONY: default all clean

OBJECTS=$(SRC)/main.s 

$(BIN)/$(EXECUTABLE): $(OBJECTS)
	$(CL) $(CL_FLAGS) -o $(BIN)/$(EXECUTABLE) $(OBJECTS)

.c.s:
	$(CC) $(CFLAGS) $< -o $@


clean:
	rm -f $(SRC)/*.s
	rm -f $(SRC)/*.o
	rm -f $(BIN)/$(EXECUTABLE)