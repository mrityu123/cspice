LEX        = flex
YACC       = bison
LEX_FLAG   = -Pparse
YACC_FLAG  = -d -p parse

CXX        = g++
CFLAGS     = -O3 -Iinclude

OBJDIR     = obj
BINDIR     = bin

CSRCS      = $(wildcard src/*.cpp)
CHDRS      = $(wildcard include/*.h)

COBJS      = $(OBJDIR)/main.o \
             $(OBJDIR)/simulator.o \
             $(OBJDIR)/circuit.o \
             $(OBJDIR)/utils.o \
             $(OBJDIR)/parseLEX.o \
             $(OBJDIR)/parseYY.o

all: $(BINDIR)/cspice

# Ensure directories exist
$(OBJDIR):
    mkdir -p $(OBJDIR)

$(BINDIR):
    mkdir -p $(BINDIR)

src/parseLEX.cpp: src/parser.l src/parseYY.hpp
    @echo "> lexing: $<"
    @$(LEX) $(LEX_FLAG) -o$@ $<

src/parseYY.cpp src/parseYY.hpp: src/parser.y
    @echo "> yaccing: $<"
    @$(YACC) $(YACC_FLAG) -o parseYY.cpp $<
    @mv parseYY.cpp src/parseYY.cpp
    @mv parseYY.hpp src/parseYY.hpp
    @ln -sf src/parseYY.hpp include/parseYY.hpp

# Final link step depends on bin directory
$(BINDIR)/cspice: $(COBJS) | $(BINDIR)
    $(CXX) $(CFLAGS) -o $@ $(COBJS)

# Object file rules depend on obj directory
$(OBJDIR)/%.o: src/%.cpp | $(OBJDIR)
    $(CXX) $(CFLAGS) -c -o $@ $<

$(OBJDIR)/%.o: src/%.c | $(OBJDIR)
    $(CXX) $(CFLAGS) -c -o $@ $<

$(COBJS): $(CHDRS)

clean:
    -rm -f $(OBJDIR)/* $(BINDIR)/* src/parseYY.cpp src/parseYY.hpp src/parseLEX.cpp
