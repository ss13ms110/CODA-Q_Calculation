!program to do forward calculation for PSF written on 26/02/2017

program	ForwardPsf
implicit none

	integer :: i, j, k, Nd, xlen, ylen, Ng
	real :: grdsz, longA, longB, latA, latB, dummy, dum1, dum2, sm, tmp
	real, dimension(:), allocatable :: long, lat, Q0, sn, Qin, snn
	real, dimension(:,:), allocatable :: Gmat
	character (len=50) :: Ndd

	call getarg(1,Ndd) !no. of traces
	read( Ndd, '(I3)') Nd
	!give value to variables
	longA = 82.0
	longB = 100.0
	latA = 19.0
	latB = 35.0
	grdsz = 0.2
	ylen = (latB - latA)/grdsz - 1
	xlen = (longB - longA)/grdsz - 1
	Ng = (xlen)*(ylen)
	!allocation 
	allocate(lat(Ng))
	allocate(long(Ng))
	allocate(Q0(Nd))
	allocate(Gmat(Ng+1,Nd))
	allocate(sn(Nd))
	allocate(Qin(Ng))
	allocate(snn(Nd))

	
	!running loop and setting Qm2 values
	open(10,file="inp.txt",status='old')
	do j = 1, Ng
		read(10,*) dum1, dum2, Qin(j)
	end do
	close(10)

	open(20,file="01_weightage.txt",status='old')
	read(20,*) dummy
	read(20,*) long
	read(20,*) lat
	close(20)
	
	!opening and reading Gmatrix file
	open(30,file="Gmatrix.txt",status='old')
	read(30,*) Gmat
	close(30)
	
	!getting the sum(sn) of overlapping area and the sum(snn) of squares of weightage
	do j = 1, Nd
		tmp = 0.0
		do k = 1, Ng
			tmp = tmp + Gmat(k,j)*Gmat(k,j)
		end do
		snn(j) = tmp
		sn(j) = Gmat(Ng+1,j)
	end do

	open(30,file="Q_inp.txt",status='replace')	
	!getting initial residual error
	do j = 1, Nd
		sm = 0.0
		do k = 1, Ng
			sm = sm + Gmat(k,j)*Qin(k)
		end do
		 Q0(j) = sm/sn(j)
		 write(30,*), Q0(j), sm
	end do

end program ForwardPsf
