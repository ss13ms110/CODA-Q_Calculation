# ######################################################################################################
#
#  Makefile to compile the Coda_Q_SS Single_Trace_Measurement_Routines
#
# #######################################################################################################

SRC_DIR	= ./src
BIN_DIR = ./bin

FC      = gfortran

all:
	${FC} ${SRC_DIR}/Q_f_calc.f90 -o ${BIN_DIR}/Q_f_calc
	${FC} ${SRC_DIR}/Q0_eta_calc.f90 -o ${BIN_DIR}/Q0_eta_calc

clean:
	rm -f  ${BIN_DIR}/Q_f_calc ${BIN_DIR}/Q0_eta_calc

