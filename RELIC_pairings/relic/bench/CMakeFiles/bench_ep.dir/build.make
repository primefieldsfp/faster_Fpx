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
include bench/CMakeFiles/bench_ep.dir/depend.make

# Include the progress variables for this target.
include bench/CMakeFiles/bench_ep.dir/progress.make

# Include the compile flags for this target's objects.
include bench/CMakeFiles/bench_ep.dir/flags.make

bench/CMakeFiles/bench_ep.dir/bench_ep.c.o: bench/CMakeFiles/bench_ep.dir/flags.make
bench/CMakeFiles/bench_ep.dir/bench_ep.c.o: bench/bench_ep.c
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green --progress-dir=/home/plonga/Documents/pairings/relic/CMakeFiles --progress-num=$(CMAKE_PROGRESS_1) "Building C object bench/CMakeFiles/bench_ep.dir/bench_ep.c.o"
	cd /home/plonga/Documents/pairings/relic/bench && /usr/bin/cc $(C_DEFINES) $(C_INCLUDES) $(C_FLAGS) -o CMakeFiles/bench_ep.dir/bench_ep.c.o -c /home/plonga/Documents/pairings/relic/bench/bench_ep.c

bench/CMakeFiles/bench_ep.dir/bench_ep.c.i: cmake_force
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Preprocessing C source to CMakeFiles/bench_ep.dir/bench_ep.c.i"
	cd /home/plonga/Documents/pairings/relic/bench && /usr/bin/cc $(C_DEFINES) $(C_INCLUDES) $(C_FLAGS) -E /home/plonga/Documents/pairings/relic/bench/bench_ep.c > CMakeFiles/bench_ep.dir/bench_ep.c.i

bench/CMakeFiles/bench_ep.dir/bench_ep.c.s: cmake_force
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Compiling C source to assembly CMakeFiles/bench_ep.dir/bench_ep.c.s"
	cd /home/plonga/Documents/pairings/relic/bench && /usr/bin/cc $(C_DEFINES) $(C_INCLUDES) $(C_FLAGS) -S /home/plonga/Documents/pairings/relic/bench/bench_ep.c -o CMakeFiles/bench_ep.dir/bench_ep.c.s

# Object files for target bench_ep
bench_ep_OBJECTS = \
"CMakeFiles/bench_ep.dir/bench_ep.c.o"

# External object files for target bench_ep
bench_ep_EXTERNAL_OBJECTS =

bin/bench_ep: bench/CMakeFiles/bench_ep.dir/bench_ep.c.o
bin/bench_ep: bench/CMakeFiles/bench_ep.dir/build.make
bin/bench_ep: lib/librelic_s.a
bin/bench_ep: /usr/lib/x86_64-linux-gnu/libgmp.a
bin/bench_ep: bench/CMakeFiles/bench_ep.dir/link.txt
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green --bold --progress-dir=/home/plonga/Documents/pairings/relic/CMakeFiles --progress-num=$(CMAKE_PROGRESS_2) "Linking C executable ../bin/bench_ep"
	cd /home/plonga/Documents/pairings/relic/bench && $(CMAKE_COMMAND) -E cmake_link_script CMakeFiles/bench_ep.dir/link.txt --verbose=$(VERBOSE)

# Rule to build all files generated by this target.
bench/CMakeFiles/bench_ep.dir/build: bin/bench_ep

.PHONY : bench/CMakeFiles/bench_ep.dir/build

bench/CMakeFiles/bench_ep.dir/clean:
	cd /home/plonga/Documents/pairings/relic/bench && $(CMAKE_COMMAND) -P CMakeFiles/bench_ep.dir/cmake_clean.cmake
.PHONY : bench/CMakeFiles/bench_ep.dir/clean

bench/CMakeFiles/bench_ep.dir/depend:
	cd /home/plonga/Documents/pairings/relic && $(CMAKE_COMMAND) -E cmake_depends "Unix Makefiles" /home/plonga/Documents/pairings/relic /home/plonga/Documents/pairings/relic/bench /home/plonga/Documents/pairings/relic /home/plonga/Documents/pairings/relic/bench /home/plonga/Documents/pairings/relic/bench/CMakeFiles/bench_ep.dir/DependInfo.cmake --color=$(COLOR)
.PHONY : bench/CMakeFiles/bench_ep.dir/depend

