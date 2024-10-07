# Makefile for compiling crc32

CXX = gcc

CXXFLAGS = -O3

BINDIR = ../bin
OBJDIR = ../obj

TARGET = $(BINDIR)/crc32

SRCS = crc32.c sim.c

OBJS = $(patsubst %.c, $(OBJDIR)/%.o, $(SRCS))

all: $(TARGET)

$(TARGET): $(OBJS)
	@mkdir -p $(BINDIR)
	$(CXX) $(CXXFLAGS) -o $(TARGET) $(OBJS)

$(OBJDIR)/%.o: %.c
	@mkdir -p $(OBJDIR)
	$(CXX) $(CXXFLAGS) -c $< -o $@

clean:
	rm -f $(OBJS) $(TARGET)

.PHONY: all clean
