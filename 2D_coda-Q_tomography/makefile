# ######################################################################################################
#
#  Makefile to compile the Q_n_Eta_tomography Routines
#
# #######################################################################################################

SRC_TOMO_DIR = ./Q_n_Eta_tomography/src
SRC_PSF_DIR = ./PSF/src

BIN_TOMO_DIR = ./Q_n_Eta_tomography/bin
BIN_PSF_DIR = ./PSF/bin

FC      = gfortran

all:
	${FC} ${SRC_TOMO_DIR}/back_proj_tomo.f90 -o ${BIN_TOMO_DIR}/back_proj_tomo
	${FC} ${SRC_PSF_DIR}/back_proj_calc_psf.f90 -o ${BIN_PSF_DIR}/back_proj_calc_psf
	${FC} ${SRC_PSF_DIR}/forward_calc_psf.f90 -o ${BIN_PSF_DIR}/forward_calc_psf
	${FC} ${SRC_PSF_DIR}/check_make_psf.f90 -o ${BIN_PSF_DIR}/check_make_psf

clean:
	rm -f  ${BIN_TOMO_DIR}/back_proj_tomo ${BIN_PSF_DIR}/back_proj_calc_psf ${BIN_PSF_DIR}/forward_calc_psf ${BIN_PSF_DIR}/check_make_psf

