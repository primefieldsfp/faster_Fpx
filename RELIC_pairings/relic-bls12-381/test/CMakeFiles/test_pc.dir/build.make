# CMAKE generated file: DO NOT EDIT!
# Generated by "Unix Makefiles" Generator, CMake Version 3.19

# Delete rule output on recipe failure.
.DELETE_ON_ERROR:


#=============================================================================
# Special targets provided by cmake.

# Disable implicit rules so canonical targets will work.
.SUFFIXES:


# Disable VCS-based implicit rules.
% : %,v


# Disable VCS-based implicit rules.
% : RCS/%


# Disable VCS-based implicit rules.
% : RCS/%,v


# Disable VCS-based implicit rules.
% : SCCS/s.%


# Disable VCS-based implicit rules.
% : s.%


.SUFFIXES: .hpux_make_needs_suffix_list


# Command-line flag to silence nested $(MAKE).
$(VERBOSE)MAKESILENT = -s

#Suppress display of executed commands.
$(VERBOSE).SILENT:

# A target that is always out of date.
cmake_force:

.PHONY : cmake_force

#=============================================================================
# Set environment variables for the build.

# The shell in which to execute make rules.
SHELL = /bin/sh

# The CMake executable.
CMAKE_COMMAND = /usr/local/bin/cmake

# The command to remove a file.
RM = /usr/local/bin/cmake -E rm -f

# Escaping for special characters.
EQUALS = =

# The top-level source directory on which CMake was run.
CMAKE_SOURCE_DIR = /home/plonga/Documents/pairings/relic

# The top-level build directory on which CMake was run.
CMAKE_BINARY_DIR = /home/plonga/Documents/pairings/relic

# Include any dependencies generated for this target.
include test/CMakeFiles/test_pc.dir/depend.make

# Include the progress variables for this target.
include test/CMakeFiles/test_pc.dir/progress.make

# Include the compile flags for this target's objects.
include test/CMakeFiles/test_pc.dir/flags.make

test/CMakeFiles/test_pc.dir/test_pc.c.o: test/CMakeFiles/test_pc.dir/flags.make
test/CMakeFiles/test_pc.dir/test_pc.c.o: test/test_pc.c
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green --progress-dir=/home/plonga/Documents/pairings/relic/CMakeFiles --progress-num=$(CMAKE_PROGRESS_1) "Building C object test/CMakeFiles/test_pc.dir/test_pc.c.o"
	cd /home/plonga/Documents/pairings/relic/test && /usr/bin/cc $(C_DEFINES) $(C_INCLUDES) $(C_FLAGS) -o CMakeFiles/test_pc.dir/test_pc.c.o -c /home/plonga/Documents/pairings/relic/test/test_pc.c

test/CMakeFiles/test_pc.dir/test_pc.c.i: cmake_force
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Preprocessing C source to CMakeFiles/test_pc.dir/test_pc.c.i"
	cd /home/plonga/Documents/pairings/relic/test && /usr/bin/cc $(C_DEFINES) $(C_INCLUDES) $(C_FLAGS) -E /home/plonga/Documents/pairings/relic/test/test_pc.c > CMakeFiles/test_pc.dir/test_pc.c.i

test/CMakeFiles/test_pc.dir/test_pc.c.s: cmake_force
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Compiling C source to assembly CMakeFiles/test_pc.dir/test_pc.c.s"
	cd /home/plonga/Documents/pairings/relic/test && /usr/bin/cc $(C_DEFINES) $(C_INCLUDES) $(C_FLAGS) -S /home/plonga/Documents/pairings/relic/test/test_pc.c -o CMakeFiles/test_pc.dir/test_pc.c.s

# Object files for target test_pc
test_pc_OBJECTS = \
"CMakeFiles/test_pc.dir/test_pc.c.o"

# External object files for target test_pc
test_pc_EXTERNAL_OBJECTS =

bin/test_pc: test/CMakeFiles/test_pc.dir/test_pc.c.o
bin/test_pc: test/CMakeFiles/test_pc.dir/build.make
bin/test_pc: lib/librelic_s.a
bin/test_pc: /usr/lib/x86_64-linux-gnu/libgmp.a
bin/test_pc: test/CMakeFiles/test_pc.dir/link.txt
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green --bold --progress-dir=/home/plonga/Documents/pairings/relic/CMakeFiles --progress-num=$(CMAKE_PROGRESS_2) "Linking C executable ../bin/test_pc"
	cd /home/plonga/Documents/pairings/relic/test && $(CMAKE_COMMAND) -E cmake_link_script CMakeFiles/test_pc.dir/link.txt --verbose=$(VERBOSE)

# Rule to build all files generated by this target.
test/CMakeFiles/test_pc.dir/build: bin/test_pc

.PHONY : test/CMakeFiles/test_pc.dir/build

test/CMakeFiles/test_pc.dir/clean:
	cd /home/plonga/Documents/pairings/relic/test && $(CMAKE_COMMAND) -P CMakeFiles/test_pc.dir/cmake_clean.cmake
.PHONY : test/CMakeFiles/test_pc.dir/clean

test/CMakeFiles/test_pc.dir/depend:
	cd /home/plonga/Documents/pairings/relic && $(CMAKE_COMMAND) -E cmake_depends "Unix Makefiles" /home/plonga/Documents/pairings/relic /home/plonga/Documents/pairings/relic/test /home/plonga/Documents/pairings/relic /home/plonga/Documents/pairings/relic/test /home/plonga/Documents/pairings/relic/test/CMakeFiles/test_pc.dir/DependInfo.cmake --color=$(COLOR)
.PHONY : test/CMakeFiles/test_pc.dir/depend
